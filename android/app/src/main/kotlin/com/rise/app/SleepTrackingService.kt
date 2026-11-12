package com.rise.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import kotlin.math.sqrt

/**
 * Foreground service that samples the accelerometer through the night and
 * re-triggers the alarm early when the sleeper is in light sleep inside the
 * smart wake-up window.
 *
 * This is the piece that makes `smartAlarmEnabled` real. It has to be a
 * foreground service: a background isolate cannot be relied on to keep
 * sampling, and a missed sample silently corrupts the phase detector.
 *
 * On firing it cancels the pending AlarmManager alarm so the nominal time does
 * not ring a second time, then starts the normal alarm path.
 */
class SleepTrackingService : Service(), SensorEventListener {

    companion object {
        private const val TAG = "SleepTracking"
        private const val CHANNEL_ID = "sleep_tracking_channel"
        private const val NOTIFICATION_ID = 2002

        const val EXTRA_ALARM_ID = "alarm_id"
        const val EXTRA_TRIGGER_TIME = "trigger_time"
        const val EXTRA_EARLIEST_FIRE_TIME = "earliest_fire_time"
        const val EXTRA_MISSION_TYPE = "mission_type"
        const val EXTRA_DIFFICULTY = "difficulty"

        /** Set when the service fired the alarm early. */
        const val ACTION_SMART_ALARM_FIRED = "com.rise.app.SMART_ALARM_FIRED"

        @Volatile
        var isRunning = false
            private set

        @JvmStatic
        fun start(
            context: Context,
            alarmId: Int,
            triggerTime: Long,
            earliestFireTime: Long,
            missionType: String,
            difficulty: Int,
        ) {
            val intent = Intent(context, SleepTrackingService::class.java).apply {
                putExtra(EXTRA_ALARM_ID, alarmId)
                putExtra(EXTRA_TRIGGER_TIME, triggerTime)
                putExtra(EXTRA_EARLIEST_FIRE_TIME, earliestFireTime)
                putExtra(EXTRA_MISSION_TYPE, missionType)
                putExtra(EXTRA_DIFFICULTY, difficulty)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        @JvmStatic
        fun stop(context: Context) {
            context.stopService(Intent(context, SleepTrackingService::class.java))
        }
    }

    private var sensorManager: SensorManager? = null
    private var detector: SleepPhaseDetector? = null

    private var alarmId = -1
    private var triggerTime = 0L
    private var earliestFireTime = 0L
    private var missionType = "math"
    private var difficulty = 3

    private var fired = false
    private var lastSampleAt = 0L

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            stopSelf()
            return START_NOT_STICKY
        }

        alarmId = intent.getIntExtra(EXTRA_ALARM_ID, -1)
        triggerTime = intent.getLongExtra(EXTRA_TRIGGER_TIME, 0L)
        earliestFireTime = intent.getLongExtra(EXTRA_EARLIEST_FIRE_TIME, 0L)
        missionType = intent.getStringExtra(EXTRA_MISSION_TYPE) ?: "math"
        difficulty = intent.getIntExtra(EXTRA_DIFFICULTY, 3)

        if (alarmId == -1 || earliestFireTime <= 0L) {
            Log.e(TAG, "Invalid arguments; stopping")
            stopSelf()
            return START_NOT_STICKY
        }

        startForeground(NOTIFICATION_ID, createNotification())
        isRunning = true
        fired = false
        detector = SleepPhaseDetector()

        val accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        if (accelerometer == null) {
            Log.e(TAG, "No accelerometer; stopping")
            stopSelf()
            return START_NOT_STICKY
        }

        sensorManager?.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL)
        Log.i(
            TAG,
            "Tracking #$alarmId, earliest fire ${earliestFireTime}, " +
                "trigger ${triggerTime}",
        )
        return START_STICKY
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (fired || event.sensor.type != Sensor.TYPE_ACCELEROMETER) return

        val x = event.values[0]
        val y = event.values[1]
        val z = event.values[2]
        val magnitude = sqrt((x * x + y * y + z * z).toDouble())
        lastSampleAt = System.currentTimeMillis()

        val phase = detector?.addSample(magnitude) ?: return
        if (phase != SleepPhaseDetector.Phase.LIGHT_SLEEP) return

        val now = System.currentTimeMillis()
        if (now < earliestFireTime) return
        // Require a moment of sustained light sleep before committing.
        if (now - lastSampleAt > SleepPhaseDetector.POINT_INTERVAL_MS * 2) return

        fireEarly()
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun fireEarly() {
        if (fired) return
        fired = true
        Log.i(TAG, "Light sleep inside window; firing #$alarmId early")

        // Do not let the nominal time ring a second time.
        AlarmScheduler.cancelAlarm(applicationContext, alarmId)

        val serviceIntent = Intent(this, AlarmService::class.java).apply {
            putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmReceiver.EXTRA_ALARM_TIME, triggerTime)
            putExtra(AlarmReceiver.EXTRA_MISSION_TYPE, missionType)
            putExtra(AlarmReceiver.EXTRA_DIFFICULTY, difficulty)
            // Already in the smart window, so no further ramp delay.
            putExtra(AlarmReceiver.EXTRA_GENTLE_ENABLED, false)
            putExtra(AlarmReceiver.EXTRA_GENTLE_DURATION_MS, 0)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }

        val activityIntent = Intent(this, AlarmRingActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_NO_HISTORY
            putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmReceiver.EXTRA_MISSION_TYPE, missionType)
            putExtra(AlarmReceiver.EXTRA_DIFFICULTY, difficulty)
        }
        startActivity(activityIntent)

        applicationContext.sendBroadcast(Intent(ACTION_SMART_ALARM_FIRED).apply {
            putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
        })

        teardown()
        stopSelf()
    }

    private fun teardown() {
        sensorManager?.unregisterListener(this)
        detector?.reset()
        detector = null
        isRunning = false
    }

    override fun onDestroy() {
        teardown()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Sleep tracking",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Samples movement to time the smart alarm"
            setSound(null, null)
            enableVibration(false)
            setShowBadge(false)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun createNotification(): Notification {
        val contentIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("Rise is tracking your sleep")
            .setContentText("Timing the smart alarm")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(pendingIntent)
            .build()
    }
}