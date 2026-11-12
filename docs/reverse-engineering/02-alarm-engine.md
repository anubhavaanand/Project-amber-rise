# Alarm Scheduling, Ringing & Volume Engine (Sleep as Android 20261016)

Target: `/tmp/opencode/sleep-analysis/Sleep-prod.apk` (`com.urbandroid.sleep`, sha256 `e1dc93bfe9541a64f24230637a1dfb0ed2fb72675ae0c15c867f1c9208fd86cf`).
Decompiler: JADX headless 0.7.1 via the REA MCP server; smali cross-checked with `apktool d` output.

All constants below are literal values read from the dex. Claims that are not directly proven are marked
**INFERRED**; things that could not be determined are marked **UNKNOWN**.

---

## Alarm data model (full field table)

### 1.1 Storage

Alarms live in a SQLite table `alarms` owned by `com.urbandroid.sleep.alarmclock.AlarmProvider`
(`AlarmProvider$DatabaseHelper`). The exact DDL from the dex:

```sql
-- AlarmProvider$DatabaseHelper.onCreate (smali)
"CREATE TABLE alarms (_id INTEGER PRIMARY KEY,hour INTEGER, minutes INTEGER, daysofweek INTEGER, alarmtime INTEGER, enabled INTEGER, vibrate INTEGER, message TEXT, alert TEXT, suspendtime INTEGER, ndswakeupwindow INTEGER, captcha INTEGER, generic_extension BLOB);"
-- migration: "ALTER TABLE alarms ADD COLUMN ndswakeupwindow INTEGER"
-- migration: "ALTER TABLE alarms ADD COLUMN generic_extension BLOB"
```

Content URI: `content://com.urbandroid.sleep.alarmclock/alarm` (`Alarm.Columns.CONTENT_URI`),
row URI `content://com.urbandroid.sleep.alarmclock/alarm/#` (`AlarmProvider.sURLMatcher` codes 1 and 2).

Default rows inserted on DB create (two alarms, 08:30 daily and 09:00 on bitmask 96):

```sql
"INSERT INTO alarms (hour, minutes, daysofweek, alarmtime, enabled, vibrate, message, alert, suspendtime, ndswakeupwindow, captcha) VALUES (8, 30, 31, 0, 0, 1, '', 'android.resource://com.urbandroid.sleep/raw/default', 0, 30, 0);"
"INSERT INTO alarms (hour, minutes, daysofweek, alarmtime, enabled, vibrate, message, alert, suspendtime, ndswakeupwindow, captcha) VALUES (9, 00, 96, 0, 0, 1, '', 'android.resource://com.urbandroid.sleep/raw/default', 0, 30, 0);"
```

### 1.2 `com.urbandroid.sleep.alarmclock.AlarmColumns`

Only one member. `ALARM_QUERY_COLUMNS` (static, built in `<clinit>`), in **query order** — this order is
what `Alarm(Cursor)` indexes by:

```java
// AlarmColumns.<clinit> (smali -> array)
{"_id", "hour", "minutes", "daysofweek", "alarmtime", "enabled", "vibrate",
 "message", "alert", "suspendtime", "ndswakeupwindow", "captcha", "generic_extension"}
```

### 1.3 `com.urbandroid.sleep.alarmclock.Alarm` — persisted columns

| Column | Java field | Type | Default (new `Alarm()`) | Notes |
|---|---|---|---|---|
| `_id` | `id` | `int` | `-1` | primary key |
| `hour` | `hour` | `int` | current hour (`Calendar.HOUR_OF_DAY`) | local wall-clock hour |
| `minutes` | `minutes` | `int` | current minute | |
| `daysofweek` | `daysOfWeek.days` | `int` bitmask | `0` (no repeat) | bit i = Mon..Sun (see §3.1) |
| `alarmtime` | `time` | `long` | `0` | absolute next fire time (ms epoch). Clamped to year ≤ 2050 when read |
| `enabled` | `enabled` | `boolean` | `false` | stored as 0/1 |
| `vibrate` | `legacyVibrate` | `boolean` | `true` | legacy "vibrate" flag |
| `message` | `label` | `String` | `null` | alarm label |
| `alert` | `alert` | `Uri` | `null` | sound URI; literal string `"silent"` means silent alarm |
| `suspendtime` | `suspendTime` | `long` | `-1` | "skip next occurrence" deadline; `-1` = not skipped |
| `ndswakeupwindow` | `nonDeepsleepWakeupWindow` | `int` | `-1` | per-alarm smart wake-up window override in **minutes**; `-1` = use global setting |
| `captcha` | `captcha` | `int` | `-1` | captcha id / mode; `-1` = none |
| `generic_extension` | `extendedConfig` | `AlarmExtendedConfig` (Java-serialised → BLOB) | `new AlarmExtendedConfig()` | see §1.4 |

Non-persisted (in-memory only) fields of `Alarm`: `silent` (boolean, alarm is muted), `extendedConfig`
serialised for `Parcel`/`Intent` passing.

`Alarm(Cursor)` reads by index (column order above):

```java
public Alarm(Cursor cursor) {
    this.extendedConfig = new AlarmExtendedConfig();
    this.id = cursor.getInt(0);
    this.enabled = cursor.getInt(5) == 1;
    this.hour = cursor.getInt(1);
    this.minutes = cursor.getInt(2);
    long j = cursor.getLong(4);
    this.time = j;
    if (j != 0) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(new Date(this.time));
        if (calendar.get(1) > 2050) {                       // year > 2050
            Logger.logSevere("Weird alarm time.. " + calendar + " Resetting down to 2050.");
            calendar.set(1, 2050);
            this.time = calendar.getTimeInMillis();
        }
    }
    this.legacyVibrate = cursor.getInt(6) == 1;
    this.label = cursor.getString(7);
    this.suspendTime = cursor.isNull(9) ? -1L : cursor.getLong(9);
    this.nonDeepsleepWakeupWindow = cursor.isNull(10) ? -1 : cursor.getInt(10);
    this.captcha = cursor.isNull(11) ? -1 : cursor.getInt(11);
    parseAlertFromString(cursor.getString(8));
    this.extendedConfig = (AlarmExtendedConfig) DbEncodingUtils.decodeSerializableIntoByteArray(cursor.getBlob(12));
    this.daysOfWeek = new DaysOfWeek(cursor.getInt(3), getWeekRepeat());
    ...
}
```

Write path (`Alarms.createContentValues(Context, Alarm, long, boolean)`):

```java
private static ContentValues createContentValues(Context context, Alarm alarm, long j, boolean z) {
    ContentValues contentValues = new ContentValues(8);
    long jCalculateAlarm = calculateAlarm(context, alarm, j);
    if (z) { contentValues.put("_id", Integer.valueOf(alarm.id)); }
    contentValues.put("enabled", Integer.valueOf(alarm.enabled ? 1 : 0));
    contentValues.put("hour", Integer.valueOf(alarm.hour));
    contentValues.put("minutes", Integer.valueOf(alarm.minutes));
    contentValues.put("alarmtime", Long.valueOf(jCalculateAlarm));
    contentValues.put("daysofweek", Integer.valueOf(alarm.getDaysOfWeek().getCoded()));
    contentValues.put("vibrate", Boolean.valueOf(alarm.legacyVibrate));
    contentValues.put("message", alarm.label);
    contentValues.put("suspendtime", Long.valueOf(alarm.suspendTime));
    contentValues.put("ndswakeupwindow", Integer.valueOf(alarm.nonDeepsleepWakeupWindow));
    contentValues.put("captcha", Integer.valueOf(alarm.captcha));
    alarm.extendedConfig.setWeekRepeat(Integer.valueOf(alarm.getDaysOfWeek().getWeekRepeat()));
    if (alarm.getDaysOfWeek().isNonWeekly()) {
        alarm.extendedConfig.setNonWeeklyFrom(Long.valueOf(alarm.getDaysOfWeek().getNonWeeklyFrom()));
        alarm.extendedConfig.setNonWeeklyRepeat(Integer.valueOf(alarm.getDaysOfWeek().getNonWeeklyRepeat()));
    }
    alarm.resetoffsetIfExpired(j);
    contentValues.put("generic_extension", DbEncodingUtils.encodeSerializableIntoByteArray(alarm.extendedConfig));
    Uri uri = alarm.alert;
    contentValues.put("alert", uri == null ? "silent" : uri.toString());
    return contentValues;
}
```

### 1.4 `com.urbandroid.sleep.alarmclock.AlarmExtendedConfig`

Java-`Serializable`, stored in the `generic_extension` BLOB. 23 fields:

| Field | Type | Meaning | Sentinel |
|---|---|---|---|
| `gradualVolumeIncrease` | `Integer` | gentle volume-ramp duration in **ms** | `null` or `-2` ⇒ use global `alarm_increasing_volume_duration` |
| `idealSleepMinutes` | `Integer` | per-alarm target sleep length (minutes) | `null` |
| `isSelfDisposable` | `Boolean` | alarm deletes itself after firing/wake-up check | `null` |
| `lastEnableTimestamp` | `Long` | ms epoch of last enable | `null` |
| `nonWeeklyFrom` | `Long` | start date for "repeat every N days" / day-of-month | `-2` = `NON_WEEKLY_START_OF_MONTH` |
| `nonWeeklyRepeat` | `Integer` | repeat every N days | `-1` |
| `offsetInMinutes` | `Integer` | alarm time offset (minutes) | `0`/absent ⇒ no offset |
| `offsetValidTill` | `Long` | offset validity deadline (ms epoch) | `null` ⇒ permanent |
| `realNextTime` | `Long` | cached real next time | – |
| `ringtoneName` | `String` | resolved ringtone display name | `null` |
| `selectedPlaylists` | `Set<String>` | selected lullaby playlists | `null` |
| `snoozeAfterAlarm` | `int` | snooze-until-alarm flag (1/0) | `0` |
| `snoozeDuration` | `Integer` | snooze length (minutes) | `null` |
| `snoozeLimit` | `Integer` | max number of snoozes | `0` = unlimited |
| `snoozeTotalTimeLimit` | `Integer` | total snooze time budget | `null` |
| `soundDelay` | `Integer` | delay before the sound starts (ms) | `-2` ⇒ use global `alarm_sound_delay` |
| `terminatesTracking` | `Boolean` | alarm ends the sleep record | `null` |
| `timeToBed` | `int` | per-alarm time-to-bed (minutes before alarm) | `0` |
| `vibrationStart` | `Integer` | vibration start delay (ms) | `-2` ⇒ global `gradual_vibration_new`; `-1` ⇒ no vibration |
| `vibrationStartSmartWatch` | `Integer` | smartwatch vibration delay (ms) | `-2` ⇒ global `gradual_vibration_smartwatch_new` |
| `wakeUpCheck` | `Integer` | wake-up check mode/id | `null` |
| `weekRepeat` | `Integer` | odd/even week repeat flag | `0` |
| `serialVersionUID` | `long` | – | – |

### 1.5 `com.urbandroid.sleep.alarmclock.Alarm$DaysOfWeek`

Fields: `days:int` (bitmask), `weekRepeat:int`, `nonWeeklyFrom:long`, `nonWeeklyRepeat:int`,
`stashDays:int`, `defaultStashDays:int`.

```java
// Alarm$DaysOfWeek.<clinit>
DAY_MAP = {2, 3, 4, 5, 6, 7, 1};          // Calendar.MONDAY..SUNDAY
NON_WEEKLY_START_OF_MONTH = -2L;
```

`isSet(int dayIndex)` is `days & (1 << dayIndex) != 0`, index 0 = Monday … 6 = Sunday.
`defaultStashDays = 31` (Mon–Fri). The `BITMASK_*` fields (MONDAY=1, TUESDAY=2, WEDNESDAY=4,
THURSDAY=8, FRIDAY=0x16, SATURDAY=0x32, SUNDAY=0x64) are **write-only dead constants** — `isSet` uses
`1 << i`, so the authoritative encoding is the plain bitmask. (`0x16/0x32/0x64` are almost certainly an
upstream typo, but they are not used anywhere.)

---

## Scheduling: AlarmManager usage, intents, extras, next-time computation

### 2.1 Which AlarmManager API is used

Three wrappers in `com.urbandroid.sleep.alarmclock.Alarms`:

```java
public static void setAlarmClockCompat(AlarmManager alarmManager, Context context, int i, int i2, long j, PendingIntent pendingIntent) {
    if (!Environment.isLollipopOrGreater() || !SharedApplicationContext.getSettings().isStatusBarIcon()) {
        setAlarmCompat(alarmManager, i2, j, pendingIntent);
        return;
    }
    if (Build.VERSION.SDK_INT >= 31 && !alarmManager.canScheduleExactAlarms()) {
        Logger.logSevere("Cannot set EXACT alarms");
        alarmManager.setAndAllowWhileIdle(0, j, pendingIntent);   // request code 0
        return;
    }
    Intent intent = new Intent(context, (Class<?>) SetAlarm.class);
    intent.putExtra("alarm_id", i);
    intent.putExtra("set_time_extra", true);
    intent.addFlags(ClientDefaults.MAX_MSG_SIZE);                // 0x40000000
    Logger.logInfo("Alarms: setAlarmClock " + new Date(j));
    alarmManager.setAlarmClock(
        new AlarmManager.AlarmClockInfo(j, PendingIntentBuilder.get(context, i, intent, 134217728).getActivity()),
        pendingIntent);
}

public static void setAlarmCompat(AlarmManager alarmManager, int i, long j, PendingIntent pendingIntent) {
    Logger.logInfo("Alarms: setAlarmCompat " + new Date(j));
    if (Environment.isMOrGreater()) {
        AlarmManagerCompat.setExactAndAllowWhileIdle(alarmManager, i, j, pendingIntent);
    } else if (Environment.isKitKatOrGreater()) {
        alarmManager.setExact(i, j, pendingIntent);
    } else {
        alarmManager.set(i, j, pendingIntent);
    }
}
```

`com.urbandroid.util.AlarmManagerCompat` is the app's own back-compat shim:

```java
// util/AlarmManagerCompat (smali)
canScheduleExactAlarms()  ->  p0.canScheduleExactAlarms()
setAndAllowWhileIdle(I,J,Landroid/app/PendingIntent;)V
setExactAndAllowWhileIdle(I,J,Landroid/app/PendingIntent;)V
```

**Summary**

| Situation | API |
|---|---|
| API ≥ 21 **and** "status bar icon" setting enabled **and** (API < 31 or exact alarms permitted) | `AlarmManager.setAlarmClock(AlarmClockInfo, PendingIntent)` |
| API ≥ 21, status-bar-icon disabled, or API ≥ 31 without `SCHEDULE_EXACT_ALARM` | `AlarmManager.setExactAndAllowWhileIdle` (via app shim), or `setAndAllowWhileIdle(0, …)` if exact is not permitted |
| API 19–20 | `AlarmManager.setExact` |
| API < 19 | `AlarmManager.set` |
| Bedtime / auto-start / wake-up-check (non-alarm-clock) | `setAlarmCompat` (request code 0) |

### 2.2 PendingIntent request codes, flags, actions, extras

PendingIntent flags:

```java
// Alarms.getPendingIntentFlags()
return 0x0C000000;      // FLAG_UPDATE_CURRENT (0x08000000) | FLAG_IMMUTABLE (0x04000000)
// Alarms.getPendingIntentFlagsLegacy()
return 0x08000000;      // FLAG_UPDATE_CURRENT only
```

`PendingIntentBuilder` (com.urbandroid.sleep) adds `FLAG_IMMUTABLE` automatically on API ≥ 31 when
neither `FLAG_IMMUTABLE` nor `FLAG_MUTABLE` is already set:

```java
// PendingIntentBuilder.<init>
int p1 = Build.VERSION.SDK_INT;
int p2 = 0x1F;                       // 31
if (p1 >= p2) {
    int p3 = flags & 0x04000000;     // FLAG_IMMUTABLE
    if (p3 != 0x04000000) {
        int p4 = flags & 0x02000000; // FLAG_MUTABLE
        if (p4 != 0x02000000) { flags |= 0x04000000; }
    }
}
```

Request codes observed:

| Request code | Intent action | Target | Extras | API used |
|---|---|---|---|---|
| **72849** | `com.urbandroid.sleep.alarmclock.ALARM_ALERT` | broadcast to `AlarmReceiver` **and** foreground service to `AlarmKlaxon` | `intent.extra.alarm_raw` = `byte[]` (`alarm.serializeToArray()`), optional `intent.extra.alarm` (Parcelable), `intent.extra.alarm_restarted` (bool), `use_headsup_extra` (bool) | `setAlarmClockCompat` |
| **2** | `com.urbandroid.sleep.alarmclock.AUTO_START_SLEEP_TRACK` | broadcast (`AutoStartTrackReceiver`) | `SCHEDULED_AUTO_START`=true, `alarm_id`=int | `setAlarmCompat` (request code 0) |
| **2** | `com.urbandroid.sleep.alarmclock.AUTO_START_SLEEP_TRACK_BEDTIME` | broadcast | `SCHEDULED_AUTO_START`=true | `setAlarmCompat` |
| **0** | `com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALARM_ALERT` | broadcast (`BedtimeReceiver`) | `alarm_id`=int, `time_to_bed_message`=String, `time_to_bed_content_info`=String | `setAlarmCompat` |
| **3** | `com.urbandroid.sleep.alarmclock.ALARM_WAKE_UP_CHECK` | broadcast (`AlarmReceiver`) | `intent.extra.alarm_raw` | `setAlarmClockCompat` |
| **666** (0x29a) | *(none — explicit)* `com.urbandroid.sleep.alarmclock.lockedboot.BackupAlarmService` | foreground service | `next_alarm`=long | `setAlarmClock` (direct-boot) |
| **alarm.id** | *(none — explicit)* `com.urbandroid.sleep.alarmclock.SetAlarm` | activity (the `AlarmClockInfo.showIntent`) | `alarm_id`=int, `set_time_extra`=true | `setAlarmClock` |
| 472937 | `com.urbandroid.sleep.alarmclock.AlarmClock` | activity | `notification_tapped`=true | notification |
| 878202189 | `com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALERT_SNOOZE_ACTION` | broadcast | `time_to_bed_message`, `time_to_bed_content_info` | notification action |
| 3284879 | `com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALERT_DISMISS_ACTION` | broadcast | – | notification delete |
| 9277632 | `com.urbandroid.sleep.alarmclock.START_SLEEP_WIDGET_TRACK` | activity | `extra_broadcast_action` | notification action |
| 0 | `com.urbandroid.sleep.alarmclock.DELAYED_BOOT_COMPLETED` | broadcast | – | `AlarmManager.set` (plain, +180 s after boot) |

### 2.3 The scheduling entry point

`Alarms.enableAlert(Context, Alarm, long)` is the single place where the main alarm is registered
(decompiled Java, abridged):

```java
private static void enableAlert(final Context context, final Alarm alarm, long j) {
    final AlarmManager alarmManager2 = (AlarmManager) context.getSystemService("alarm");
    long jFixDayLiteSavingRemove = fixDayLiteSavingRemove(j);
    Logger.logInfo("Alarms:** setAlert id " + alarm.id + " atTime " + new Date(jFixDayLiteSavingRemove));
    Intent intent = new Intent("com.urbandroid.sleep.alarmclock.ALARM_ALERT");
    intent.putExtra("intent.extra.alarm_raw", alarm.serializeToArray());
    if (Environment.isKitKatOrGreater()) { intent.addFlags(ClientDefaults.MAX_MSG_SIZE); }
    ... // bedtime / auto-start scheduling (see §6)
    Settings settings = new Settings(context);
    if (Experiments.getInstance().isReliableAlarmExperiment()) {
        intent.setPackage(context.getPackageName());
        Intent intent3 = new Intent("com.urbandroid.sleep.alarmclock.ALARM_ALERT");
        intent3.putExtra("intent.extra.alarm_raw", alarm2.serializeToArray());
        intent3.setPackage(context.getPackageName());
        PendingIntentBuilder pendingIntentBuilder3 = PendingIntentBuilder.get(context, 72849, intent3, getPendingIntentFlags());
        pendingIntentBuilder3.cancelAlarmService();
        PendingIntentBuilder.get(context, 72849, intent3, getPendingIntentFlagsLegacy()).cancelAlarmService();
        setAlarmClockCompat(alarmManager2, context, alarm2.id, 0, jFixDayLiteSavingRemove, pendingIntentBuilder3.getForegroundService());
        settings.setReliableAlarmScheduled(true);
    } else {
        settings.setReliableAlarmScheduled(false);
    }
    PendingIntentBuilder pendingIntentBuilder4 = PendingIntentBuilder.get(context, 72849, intent, getPendingIntentFlags());
    pendingIntentBuilder4.cancelAlarmBroadcast();
    PendingIntentBuilder.get(context, 72849, intent, getPendingIntentFlagsLegacy()).cancelAlarmBroadcast();
    setAlarmClockCompat(alarmManager2, context, alarm2.id, 0, jFixDayLiteSavingRemove, pendingIntentBuilder4.getExplicitBroadcast());
    ...
}
```

So **the main alarm is registered twice** with the *same* trigger time and the *same* request code 72849:
once as a **foreground service** (`AlarmKlaxon`) and once as an **explicit broadcast** (`AlarmReceiver`).
Which one wins is decided by the `isReliableAlarmExperiment()` A/B flag; the receiver and the service
both check `settings.isReliableAlarmScheduled()` before acting, so only one actually starts the alarm.

Call chain:

```
Alarms.enableAlarm(ctx, id, enabled)
  -> Alarms.enableAlarmInternal(ctx, alarm, enabled)   // writes the DB row
  -> Alarms.setNextAlert(ctx)
       -> Alarms.enableSnoozeAlert(ctx, now)             // pending snooze wins
       -> Alarms.calculateNextAlert(ctx, now)            // pick earliest enabled alarm
       -> Alarms.enableAlert(ctx, nextAlarm, nextAlarm.time)
       -> Alarms.scheduleTimeToBedBedtime(...) / scheduleTimeToBedAutoStart(...)
```

`Alarms.setAlarm(Context, Alarm, long)` (used by the editor) writes the row and re-arms:

```java
public static long setAlarm(Context context, Alarm alarm, long j) {
    if (alarm.enabled) { alarm.extendedConfig.setLastEnableTimestamp(Long.valueOf(j)); }
    ContentValues cv = createContentValues(context, alarm, j);
    context.getContentResolver().update(ContentUris.withAppendedId(Alarm.Columns.CONTENT_URI, alarm.id), cv, null, null);
    getAlarm(context.getContentResolver(), alarm.id);
    long jCalculateAlarm = calculateAlarm(context, alarm, j);
    if (alarm.enabled) { clearSnoozeIfNeeded(context, jCalculateAlarm); }
    setNextAlert(context);
    return jCalculateAlarm;
}
```

### 2.4 "Next alarm time" computation

```java
// Alarms.calculateAlarm(Context, Alarm, long)  -> uses suspendTime as an upper bound
public static long calculateAlarm(Context context, Alarm alarm, long j) {
    Calendar calendar = Calendar.getInstance();
    calendar.setTimeInMillis(j);
    long jCalculateAlarm = calculateAlarm(context, alarm, calendar);
    long j2 = alarm.suspendTime;
    if (j2 <= jCalculateAlarm) { return jCalculateAlarm; }
    calendar.setTimeInMillis(j2);
    return calculateAlarm(context, alarm, calendar);
}

// Alarms.calculateAlarm(Context, Alarm, Calendar)  -> applies the time offset
public static long calculateAlarm(Context context, Alarm alarm, Calendar calendar) {
    return calculateAlarm(context,
                          alarm.getOffsetHour(context, calendar.getTimeInMillis()),
                          alarm.getOffsetMinutes(context, calendar.getTimeInMillis()),
                          alarm.getDaysOfWeek(),
                          calendar).getTimeInMillis();
}

// Alarms.calculateAlarm(Context, int hour, int minute, DaysOfWeek, Calendar)
private static Calendar calculateAlarm(Context context, int i, int i2, Alarm.DaysOfWeek daysOfWeek, Calendar calendar) {
    TimeZone.getDefault();
    int i3 = calendar.get(11);            // HOUR_OF_DAY
    int i4 = calendar.get(12);            // MINUTE
    if (i < i3 || (i == i3 && i2 <= i4)) { calendar.add(6, 1); }   // roll to tomorrow if not in the future
    calendar.set(11, i);
    calendar.set(12, i2);
    calendar.set(13, 0);                 // SECOND
    calendar.set(14, 0);                 // MILLISECOND
    int nextAlarm = daysOfWeek.getNextAlarm(context, calendar);
    if (nextAlarm > 0) { calendar.add(7, nextAlarm); }   // +1 week * days
    calendar.set(11, i);
    return calendar;
}
```

Offset helper (the "offset" feature shifts the wall-clock hour/minute of the alarm):

```java
// Alarm.getOffsetCalendar(Context, long)
private Calendar getOffsetCalendar(Context context, long j) {
    int nextAlarm;
    Calendar calendar = Calendar.getInstance();
    calendar.setTimeInMillis(j);
    if (getDaysOfWeek() != null && (nextAlarm = getDaysOfWeek().getNextAlarm(context, calendar)) > 0) {
        calendar.add(5, nextAlarm);       // +1 day * days
    }
    calendar.set(11, this.hour);
    calendar.set(12, this.minutes);
    if (calendar.getTime().before(new Date(j))) { calendar.add(5, 1); }
    calendar.set(11, this.hour);
    calendar.add(12, getOffset(j));       // offset in minutes
    return calendar;
}

// Alarm.getOffset(long)
public int getOffset(long j) {
    if (extendedConfig == null || extendedConfig.getOffsetInMinutes() == null
        || extendedConfig.getOffsetInMinutes().intValue() == 0
        || extendedConfig.getOffsetValidTill() == null
        || extendedConfig.getOffsetValidTill().longValue() <= j) { return 0; }
    return extendedConfig.getOffsetInMinutes().intValue();
}
```

`Alarms.calculateNextAlert(Context, long)` picks the alarm with the smallest `time`, honouring
`suspendTime` (skip-next) and disabling one-shot alarms whose time is in the past:

```java
long j2 = Long.MAX_VALUE; Alarm best = null;
for each enabled alarm:
    if (alarm.getDaysOfWeek().isRepeatSet()) {
        alarm.time = calculateAlarm(context, alarm);          // recompute, persist if changed
    } else if (alarm.time < now) {
        enableAlarmInternal(context, alarm, false);            // one-shot in the past -> disable
    }
    if (alarm.suspendTime == -1 || alarm.suspendTime < alarm.time) {
        if (alarm.time < bestTime) { bestTime = alarm.time; best = alarm; }
    } else if (alarm.getDaysOfWeek().isRepeatSet()) {
        // suspended but repeating: recompute from suspendTime+1
        Calendar c = Calendar.getInstance();
        c.setTimeInMillis(Math.max(now, alarm.suspendTime + 1));
        alarm.time = calculateAlarm(context, alarm, c);
        if (alarm.time < bestTime) { bestTime = alarm.time; best = alarm; }
    }
```

---

## Repeat / skip / offset logic

### 3.1 Repeat (weekly / non-weekly)

`Alarm$DaysOfWeek.getNextAlarm(Context, Calendar)` returns the number of days to add:

```java
public int getNextAlarm(Context context, Calendar calendar) {
    int i = 0;
    if (!isNonWeekly()) {
        if (this.days == 0) { return -1; }                 // no repeat -> -1 (fire once)
        Calendar calendar2 = Calendar.getInstance();
        calendar2.setTime(calendar.getTime());
        while (i < 14) {                                   // search at most 2 weeks
            int i2 = (calendar2.get(7) + 5) % 7;           // Calendar.DAY_OF_WEEK -> Mon..Sun index
            if (isThisWeek(context, calendar2) && isSet(i2)) { break; }
            calendar2.add(6, 1);                           // +1 day
            i++;
        }
        return i;
    }
    // --- non-weekly: "every N days" or "day of month" ---
    Calendar calendar3 = ...; calendar3.set(11,0); set(12,0); set(13,0); set(14,0);
    if (this.nonWeeklyFrom == NON_WEEKLY_START_OF_MONTH) {          // -2
        while (calendar3.get(5) != this.nonWeeklyRepeat) {          // DAY_OF_MONTH
            calendar3.add(5, 1); i++;
            if (i > 31) { Logger.logSevere("Repeat: failed to find day of month ..."); break; }
        }
        return i;
    }
    Calendar calendar4 = ...; calendar4.setTimeInMillis(this.nonWeeklyFrom); zero time-of-day;
    if (this.nonWeeklyRepeat < 1) { Logger.logSevere("Repeat: this should never happen nonweeklyrepeat is < 1 "); return -1; }
    if (calendar3.before(calendar4)) {
        return (int) Math.round((calendar4.getTimeInMillis() - calendar3.getTimeInMillis()) / 8.64E7d);
    }
    long jRound = Math.round((calendar3.getTimeInMillis() - calendar4.getTimeInMillis()) / 8.64E7d);
    int i3 = this.nonWeeklyRepeat;
    long j = jRound % i3;
    if (j == 0) { Logger.logInfo("Repeat: every " + i3 + " days. Fires today!"); return 0; }
    int i5 = (int) (i3 - j);
    Logger.logInfo("Repeat: every " + i3 + " days. Next fire in " + i5 + " days.");
    return i5;
}
```

`isThisWeek(context, calendar)` additionally honours `weekRepeat` (odd/even week) via
`DaysOfWeek.isWeekOdd(context, calendar)`.

### 3.2 Skip next

```java
// Alarms.isSkipped(Alarm)
public static boolean isSkipped(Alarm alarm) { return alarm.suspendTime > System.currentTimeMillis(); }

// Alarms.setSkipNext(Context, Alarm, boolean)
public static void setSkipNext(Context context, Alarm alarm, boolean z) {
    if (z) { skipAlarmOrShowCaptcha(context, alarm); }
    else { setSuspendTime(alarm, -1L); setAlarm(context, alarm); }
}

// Alarms.setSuspendTime(Alarm, long)  -> alarm.suspendTime = j;
// skip next = suspendTime = end of the occurrence being skipped
```

### 3.3 Offset

* `extendedConfig.offsetInMinutes` (int, minutes) + `extendedConfig.offsetValidTill` (ms epoch).
* `Alarm.getOffset(now)` returns the offset only while `offsetValidTill > now` and `offsetInMinutes != 0`.
* `Alarm.addOffset(int minutes, long validTill)` sets both.
* `Alarm.resetOffset()` / `resetoffsetIfExpired(long now)` clear it when expired.
* The offset is applied in `getOffsetCalendar()` by adding `getOffset()` minutes to the calendar, so the
  alarm *fires* at `alarmTime ± offset` while `hour`/`minutes` keep the nominal value.
* `Alarms.addOffset(Context, Alarm, int)` / `addOffset(Context, Alarm, int, long)` persist it and re-arm.

---

## Smart & gentle wake-up window

### 4.1 The window size

Global setting `non_deep_sleep_window` (minutes), **default 30**:

```java
// Settings.getSmartWakeupMinutes()
String v0 = "non_deep_sleep_window";
int v1 = 0x1e;                 // 30
return getPrefStringAsInt(v0, v1);
```

`Settings.getSmartWakeupNapMinutes()` → key `non_deep_sleep_window_nap`, default `0x5` (5).

Allowed values (`res/values/arrays.xml`):

```xml
<string-array name="non_deep_sleep_window_entries">
  <item>@string/disabled</item><item>Power nap</item><item>5 minutes</item><item>10 minutes</item>
  <item>15 minutes</item><item>20 minutes</item><item>25 minutes</item><item>30 minutes</item>
  <item>40 minutes</item><item>50 minutes</item><item>1 hour</item><item>1 hour 30 min</item><item>2 hours</item>
</string-array>
<string-array name="non_deep_sleep_window_values">
  <item>0</item><item>59</item><item>5</item><item>10</item><item>15</item><item>20</item><item>25</item>
  <item>30</item><item>40</item><item>50</item><item>60</item><item>90</item><item>120</item>
</string-array>
```

**Maximum window = 120 minutes (2 hours).** `0` = disabled, `59` = the special "Power nap" mode.
The nap-specific pref `non_deep_sleep_window_nap` uses the same value array (default 5).

Per-alarm override: column `ndswakeupwindow` (`Alarm.nonDeepsleepWakeupWindow`), `-1` = inherit global.

```java
// Alarm.resolveSmartPeriod(Context, Alarm)
public static int resolveSmartPeriod(Context context, Alarm alarm) {
    int i = alarm.nonDeepsleepWakeupWindow;
    return i >= 0 ? i : new Settings(context).getSmartWakeupMinutes();
}
```

### 4.2 How the window is used (adaptive, not a fixed early time)

The alarm is **not** scheduled earlier. It fires at the nominal time; the *smart* behaviour is to
**fire it early** once the tracker detects light sleep inside the window.

```java
// SleepService.isInSmartPeriod()
public boolean isInSmartPeriod() {
    Alarm alarm = this.alarm;
    boolean z = false;
    if (alarm == null) { return false; }
    if ((this.alarmStartedRingingId == alarm.id && this.alarmStartedRingingTs != -1
         && System.currentTimeMillis() - this.alarmStartedRingingTs < 3600000)   // 1 h
        || !isActOnTargetSleepFullFilled()) {
        return false;
    }
    boolean zIsSnoozing = Alarms.isSnoozing(this);
    int iResolveSmartPeriod = Alarm.resolveSmartPeriod(this, this.alarm);
    if (!zIsSnoozing && iResolveSmartPeriod > 0
        && System.currentTimeMillis() + ((long) (60000 * iResolveSmartPeriod)) > this.alarm.time) {
        z = true;
    }
    ...
}
```

The early trigger also requires the current sleep phase to be **light sleep** and the target sleep
time to be fulfilled (see `SleepService$1`, the smart-period branch):

```
if (isInSmartPeriod()
    && recorder.getSleepPhase().isLightSleep()
    && isActOnTargetSleepFullFilled()
    && CurrentSleepRecord.getInstance().getRecord() != null
    && TrialFilter.getInstance().isTrackingEnabledForRecord(record)) {
    -> fire the alarm early
}
```

The "not before ideal sleep" variant is exposed by `Alarm.getEarliesWakeTime(SleepRecord)`:

```java
public long getEarliesWakeTime(SleepRecord sleepRecord) {
    boolean zIsNotBeforeIdeal = SharedApplicationContext.getSettings().isNotBeforeIdeal();   // pref "act_on_target_sleep_time2", default false
    int idealSleepMinutes = SharedApplicationContext.getSettings().getIdealSleepMinutes();     // default 60
    int smartWakeupMinutes = this.nonDeepsleepWakeupWindow;
    if (smartWakeupMinutes == -1) { smartWakeupMinutes = SharedApplicationContext.getSettings().getSmartWakeupMinutes(); }
    long j = this.time;
    if (smartWakeupMinutes == 0) { return j; }
    long j2 = j - ((long) (smartWakeupMinutes * 60000));
    if (!zIsNotBeforeIdeal || sleepRecord == null) { return j2; }
    long j3 = idealSleepMinutes * 60000;
    long jMin = Math.min(Math.max(j2, sleepRecord.getFromTime() + j3), this.time);
    return jMin;
}
```

So the **earliest possible fire time** is
`min( max(alarmTime - windowMinutes, sleepStart + idealSleepMinutes), alarmTime )`.

### 4.3 The "gentle" settings screen (`SetAlarmGentle`)

`com.urbandroid.sleep.alarmclock.SetAlarmGentle` is **not** the window — it is the alarm-editor
sub-screen for the gentle-ramp options. `mapToAlarm(Alarm)` writes:

| Preference | Written to |
|---|---|
| `gentleVolumeIncrease` | `extendedConfig.setGradualVolumeIncrease(Integer)` |
| `alarmVibration` | `extendedConfig.setVibrationStart(Integer)` |
| `soundDelay` | `extendedConfig.setSoundDelay(Integer)` |
| `vibrationWatch` | `extendedConfig.setVibrationStartSmartWatch(Integer)` |

---

## Backup alarm, bedtime alarm, jet-lag alarm, nap alarm

### 5.1 "Backup alarm" = the *sirena* + alarm kill timer

There is no separate DB row for it. The feature is implemented in `AlarmKlaxon` with two `Handler`
messages:

| Message | Meaning | Action |
|---|---|---|
| `1000` (0x3E8) | **KILL** | `sendKillBroadcast(alarm)` + stop service |
| `1001` (0x3E9) | RESUME | `resumeAlarm()` |
| `1002` (0x3EA) | **SIRENA** | `playSirena()` + `enablePostSirenaKiller(alarm)` |
| `1003` (0x3EB) | — | `switchFlashlight()` |

```java
// AlarmKlaxon.enableKillerOrSirena(Alarm)
private void enableKillerOrSirena(Alarm alarm) {
    boolean v = isSirenaSilent();                       // siren ringtone == "silent"
    Handler h = this.mHandler;
    if (!v) {
        h.sendMessageDelayed(h.obtainMessage(1002, alarm), (long) this.timeoutSeconds * 1000);
        return;
    }
    h.sendMessageDelayed(h.obtainMessage(1000, alarm), (long) this.timeoutSeconds * 1000);
}

// AlarmKlaxon.enablePostSirenaKiller(Alarm)
private void enablePostSirenaKiller(Alarm alarm) {
    h.sendMessageDelayed(h.obtainMessage(1000, alarm), (long) this.sirenaTimeoutSeconds * 1000);
}
```

Timeouts:

```java
// AlarmKlaxon.<init>  (field defaults)
this.timeoutSeconds = 0x4b0;        // 1200 s = 20 min
this.sirenaTimeoutSeconds = 0x3c;   // 60 s

// AlarmKlaxon.onCreate
this.timeoutSeconds = SharedApplicationContext.getSettings().getAlarmTimeout();
// Settings.getAlarmTimeout(): pref "alarm_kill_time" (String), default "1200"
this.sirenaTimeoutSeconds = Integer.parseInt(
    PreferenceManager.getDefaultSharedPreferences(this)
        .getString("siren_kill_time", "60"));
```

Allowed values for both (`res/values/arrays.xml` `alarm_kill_time_values`):
`60, 120, 180, 300, 600, 1200, 1800, 2400, 3600, 7200` (1 min … 2 h); defaults: `alarm_kill_time`=1200,
`siren_kill_time`=60.

The "sirena" (backup siren) itself:

```java
// AlarmKlaxon.playSirena(boolean)
private void playSirena(boolean z) {
    String sirenRingtone = SharedApplicationContext.getSettings().getSirenRingtone();
    if (sirenRingtone.equals("silent")) { Logger.logInfo("AlarmKlaxon: Sirena set to silent."); return; }
    Uri uri = Uri.parse(sirenRingtone);
    Logger.logInfo("AlarmKlaxon: Forcing STREAM_ALARM");
    this.alarmAudioStream = 4;                       // STREAM_ALARM
    play(uri, true, false, true, z);                 // vibrate=true, silent=false, forceMax=true
}
```

The kill broadcast:

```java
// AlarmKlaxon.sendKillBroadcast(Alarm)
private void sendKillBroadcast(Alarm alarm) {
    Logger.logInfo("AlarmKlaxon: Broadcasting kill message");
    int iRound = (int) Math.round((System.currentTimeMillis() - this.mStartTime) / 60000.0d);
    Intent intent = new Intent("com.urbandroid.sleep.alarmclock.alarm_killed");
    intent.putExtra("intent.extra.alarm_raw", alarm.serializeToArray());
    intent.putExtra("alarm_killed_timeout", iRound);      // minutes the alarm rang
    ContextExtKt.sendExplicitBroadcast(getApplicationContext(), intent);
}
```

`AlarmReceiver` handles `alarm_killed` by auto-snoozing (up to `alarm_kill_snooze_count`, default 3)
and finally dismissing with `autoKill = true`:

```java
if ("com.urbandroid.sleep.alarmclock.alarm_killed".equals(intent.getAction())) {
    settings.increaseAutoSnoozeRepeat();
    if (settings.getAutoSnoozeRepeat() <= settings.getAutoKillSnoozeMaxCount()) {
        snoozeAfterKill(context, fromIntent);
    } else {
        settings.resetAutoSnoozeRepeat();
        Alarm.performDismiss(context, fromIntent, CurrentSleepRecord.getInstance().getRecord(), true);
    }
    updateNotification(context, fromIntent, intent.getIntExtra("alarm_killed_timeout", -1));
    return;
}
```

### 5.2 Bedtime alarm

Not a DB row either — a *notification* scheduled with `AlarmManager` for the "go to bed" time.

`Alarms.scheduleTimeToBedBedtime(Context, AlarmManager, Alarm, long bedtime, long timeToBedBeforeMs, long alarmTime)`:

```java
private static void scheduleTimeToBedBedtime(Context context, AlarmManager alarmManager, Alarm alarm,
                                             long j, long j2, long j3) {
    Logger.logInfo("Alarms:Scheduling bedtime: " + new Date(j));
    long now = System.currentTimeMillis();
    Intent intent = new Intent("com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALARM_ALERT");
    if (alarm != null) { intent.putExtra("alarm_id", alarm.id); }
    StringBuilder sb = new StringBuilder();
    if (j3 != -1) { sb.append(context.getString(R.string.time_to_bed_message, formatTime(context, j3))); }
    if (alarm != null && alarm.label != null) { sb.append(". "); sb.append(alarm.label); }
    if (sb.length() == 0) { sb.append(context.getString(R.string.bedtime_notification_expl)); }
    intent.putExtra("time_to_bed_message", sb.toString());
    intent.putExtra("time_to_bed_content_info", formatTime(context, j));
    PendingIntentBuilder pb  = PendingIntentBuilder.get(context, 0, intent, getPendingIntentFlags());
    PendingIntentBuilder pb2 = PendingIntentBuilder.get(context, 0, intent, getPendingIntentFlagsLegacy());
    long j4 = j - j2;                                  // fire time = bedtime - "time to bed before"
    if (j2 < 0) {
        Logger.logInfo("Alarms:Canceling bedtime -> Not enabled ( " + j2 + ")");
        pb.cancelAlarmBroadcast(); pb2.cancelAlarmBroadcast();
    } else if (now + 100 < j4) {
        Logger.logInfo("Alarms:Scheduling bedtime: " + new Date(j4));
        pb.cancelAlarmBroadcast(); pb2.cancelAlarmBroadcast();
        setAlarmCompat(alarmManager, 0, j4, pb.getExplicitBroadcast());
    } else {
        Logger.logInfo("Alarms:Canceling bedtime -> Past: " + j2 + ")");
        pb.cancelAlarmBroadcast(); pb2.cancelAlarmBroadcast();
    }
    ... settings.setNextTimeToBed(new Date(j));
    ContextExtKt.sendExplicitBroadcast(context, new Intent("com.urbandroid.sleep.alarmclock.ALARM_TIME_TO_BED_UPDATE"));
}
```

`Alarms.scheduleTimeToBed(ctx, am, alarm, idealSleepStart, timeToBedBeforeMs, alarmTime)` calls both
`scheduleTimeToBedBedtime(...)` and `scheduleTimeToBedAutoStart(...)`.

The bedtime time itself is derived from the alarm: `timeToBed = settings.getTimeToBed(alarm)` (minutes
before the alarm), or, in "smart bedtime" mode (`settings.isTimeToBedSmart()`, pref `time_to_bed_smart`,
default false), from an `AsyncTask` that adjusts by the tracking delay and the 5-day average sleep
deficit:

```java
long trackingDelay = perAlarmIdealSleepMinutes - SharedApplicationContext.getSettings().getTrackingDelay();
if (smartPeriod > -1) { trackingDelay -= (long) (smartPeriod * 60000); }
int deficit = new SleepRecords().calculateLastDaysAverageDeficit();
if (deficit > 0) {
    int iMin = Math.min(2700000, 60000 * deficit);     // cap at 45 min
    trackingDelay -= (long) iMin;
}
Alarms.scheduleTimeToBed(context, alarmManager, alarm, trackingDelay, timeToBedBefore, alarm.time);
```

`BedtimeReceiver` shows the notification on channel `bedtimeChannel` (importance 4), notification id
`33434343`, with three actions: snooze (`TIME_TO_BED_ALERT_SNOOZE_ACTION`, request 878202189),
dismiss (`TIME_TO_BED_ALERT_DISMISS_ACTION`, request 3284879) and "track"
(`START_SLEEP_WIDGET_TRACK`, request 9277632). Snooze schedules the bedtime notification again in
**600 000 ms (10 min)**:

```java
if ("com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALERT_SNOOZE_ACTION".equals(intent.getAction())) {
    cancelRepeatNotification(context);
    scheduleSnooze(context, intent.getStringExtra("time_to_bed_message"),
                   intent.getStringExtra("time_to_bed_content_info"), 600000L);
    return;
}
```

### 5.3 Jet-lag alarm

**There is no jet-lag alarm row and no jet-lag `AlarmManager` registration.**
`com.urbandroid.sleep.jetlag.JetLagService` only drives the **SmartLight** sunrise and broadcasts
`com.urbandroid.sleep.JETLAG_START` / `com.urbandroid.sleep.JETLAG_END`
(`JetLagService.start(TimeZone)` → `SunTimeUtil.isRemoteSunTime(...)` → `smartLight.sunrise*`).
The jet-lag *shift* of the wake-up time is realised through the ordinary alarm **offset** mechanism
(`extendedConfig.offsetInMinutes` / `offsetValidTill`) — **INFERRED** from the fact that jet-lag
services never touch `AlarmManager` while the offset fields are the only per-alarm time-shift
mechanism in the data model.

`com.urbandroid.sleep.alarmclock.settings.JetLagSettingsActivity` is the settings screen.

### 5.4 Nap / power nap

"Power nap" is the **special value 59** of the smart-window array. It is not a separate alarm row.

```java
// Alarm.isPowerNap(Alarm)
public static boolean isPowerNap(Alarm alarm) {
    int i = alarm.nonDeepsleepWakeupWindow;
    if (i != 59) { return i == -1 && SharedApplicationContext.getSettings().getSmartWakeupMinutes() == 59; }
    return true;
}

// Alarms.fixPowerNap(Alarm, boolean)
private static void fixPowerNap(Alarm alarm, boolean z) {
    if (Alarm.isPowerNap(alarm)) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(11, alarm.hour);
        calendar.set(12, alarm.minutes);
        calendar.add(12, z ? 59 : -59);       // shift the stored wall-clock by ±59 minutes
        alarm.hour = calendar.get(11);
        alarm.minutes = calendar.get(12);
    }
}
```

So in power-nap mode the persisted hour/minute is shifted by 59 minutes so that the *nap* wake-up
time is what the user sees, while the real alarm is 59 minutes later. **INFERRED** for the sign
convention (which of `z == true/false` corresponds to "create" vs "edit" was not traced).

The "nap" variant of the smart window uses `Settings.getSmartWakeupNapMinutes()` (default 5 minutes).

---

## Volume ramp (exact curve + constants + pseudocode)

There are **two** ramp engines plus a third, unrelated, "lullaby volume down" controller:

| Engine | File | Used for | Curve |
|---|---|---|---|
| `GentleAlarmRunnable` | `com/urbandroid/sleep/alarmclock/volume/GentleAlarmRunnable.smali` | gentle alarm (gradual ramp ≥ 30 s) — ramps the **MediaPlayer gain** | **logarithmic** `f = 1 − ln(100−v)/ln(100)` |
| `VolumeControlRunnable` | `com/urbandroid/sleep/alarmclock/volume/VolumeControlRunnable.smali` | fixed-system-volume alarms, Spotify/Google-Music alarms, lullaby fade-out | **linear** on the **system stream** |
| `LullabyVolumeDown` | `com/urbandroid/sleep/alarmclock/volume/LullabyVolumeDown.smali` | fades the sleep-time lullaby down in deep sleep | linear down, 1 step / 30 s |

### 6.1 Selection of engine and ramp duration

```java
// Alarm.getGradualVolumeIncrease(Context)
public int getGradualVolumeIncrease(Context context) {
    Integer gradualVolumeIncrease = this.extendedConfig.getGradualVolumeIncrease();
    return (gradualVolumeIncrease == null || gradualVolumeIncrease.intValue() == -2)
        ? new Settings(context).getGradualVolumeIncreaseDuration()
        : gradualVolumeIncrease.intValue();
}
// Settings.getGradualVolumeIncreaseDuration(): pref "alarm_increasing_volume_duration", default 0xea60 = 60 000 ms
```

```java
// Alarm.isGradualVolumeIncrease / isFixedSystemVolume
public boolean isGradualVolumeIncrease(Context context) { return getGradualVolumeIncrease(context) >= 30000; }
public boolean isFixedSystemVolume(Context context)     { return getGradualVolumeIncrease(context) <= 30000; }
```

**Threshold = 30 000 ms.** Allowed global values (`alarm_increasing_volume_duration_values`):
`-1` (disabled), `30000, 60000, 180000, 360000, 540000, 720000, 1080000, 1440000` (30 s … 24 min),
default `60000` (1 min).

`AlarmKlaxon.initializeVolumeControlThread(boolean gentle, boolean vibrate, boolean startOnMax,
int vibrateStart, boolean silent, boolean fixed, boolean isStreaming)`:

```java
int gradualVolumeIncrease = currentAlarm.getGradualVolumeIncrease(this);
int speed = VolumeControlRunnable.convertIncreaseDurationToIncreaseSpeed(this, gradualVolumeIncrease, this.alarmAudioStream);
if (gentle) {
    MediaPlayer mediaPlayer = this.mediaPlayer;
    Vibrator vibrator = vibrate ? this.vibrator : null;
    int i3 = fixed ? AppFunctionException.ERROR_RESOURCE_NOT_FOUND /* 1500 */ : gradualVolumeIncrease;
    int i2 = -1;
    if (!fixed && gradualVolumeIncrease > 30000) { i2 = this.alarmAudioStream; }
    this.volumeControlRunnable = new GentleAlarmRunnable(this, mediaPlayer, vibrator, i3, vibrateStart,
                                                         startOnMax, i2, this.originalVolume.intValue(),
                                                         Alarm.resolveSoundDelay(this, currentAlarm, this.isSnoozedAlarm),
                                                         silent, isStreaming);
    if (this.mediaPlayer != null) { this.mediaPlayer.setVolume(0.0f, 0.0f); }
    ...
} else {
    long soundDelay = Alarm.resolveSoundDelay(this, currentAlarm, this.isSnoozedAlarm);
    int initial = (soundDelay > 0 || !fixed) ? 0 : this.nonGradualAlarmVolume.intValue();
    int maxVol  = (fixed || gradualVolumeIncrease <= 30000) ? this.nonGradualAlarmVolume.intValue() : -1;
    volumeControlRunnable = new VolumeControlRunnable(this, this.mediaPlayer, speed, true, this.alarmAudioStream,
                                                      startOnMax, this.vibrator, this.originalVolume.intValue(),
                                                      initial, maxVol, vibrateStart, soundDelay);
    this.volumeControlRunnable = volumeControlRunnable;
}
new Thread(this.volumeControlRunnable, "Alarm increasing volume").start();
```

Notes:
* `gentle` is `true` only for **local** alerts (no Spotify / Google Music / Spotify inside the URI).
* For a gentle ramp the **system** stream is first zeroed
  (`VolumeUtil.setStreamVolume(getApplicationContext(), this.alarmAudioStream, 0)`) and the ramp is
  applied to the MediaPlayer gain.
* `GentleAlarmRunnable` is also used in "fixed" mode but with `increaseDuration = 1500 ms`
  (i.e. the ramp completes in ~1.5 s ≈ instant).

### 6.2 `GentleAlarmRunnable` — the logarithmic curve (the main "gentle volume" ramp)

Constructor signature:

```java
public GentleAlarmRunnable(Context context, MediaPlayer player, Vibrator vibrator,
                           int increaseDuration,      // p4  total ramp duration (ms)
                           int vibrationStart,         // p5  vibration start delay (ms)
                           boolean startOnMax,         // p6
                           int audioStream,            // p7  -1 => don't touch the system stream
                           int initialVolume,          // p8  system stream volume snapshot
                           long postponeSound,         // p9  delay before the ramp starts (ms)
                           boolean silent,             // p10
                           boolean isStreaming)        // p11
```

Constructor body (verbatim, abridged):

```java
this.stopRequested = false;  this.finished = false;  this.currentVolume = 0;
this.postponeSound = 0;  this.forcedVolume = null;  this.vibrating = false;  this.smartLightStart = false;
this.listeners = new HashSet<>();
this.touchSystemVolume = true;
this.postponeDone = false;
this.player = player;  this.vibrator = vibrator;  this.context = context;
this.increaseDuration = increaseDuration;
this.silent = silent;  this.isStreaming = isStreaming;
this.postponeSound = (startOnMax ? 0 : postponeSound);
this.vibrationStartAfter = System.currentTimeMillis() + vibrationStart;
this.audioStream = audioStream;
if (startOnMax) { this.currentVolume = 100; }
this.setVolume(this.currentVolume);
this.audioManager = (AudioManager) context.getSystemService("audio");
this.initialVolume = initialVolume;
setMaxVolume();
// AudioAttributes: contentType = 2 (CONTENT_TYPE_SONIFICATION),
//                  usage      = 4 (USAGE_ALARM),
//                  legacyStreamType = audioStream
this.attr = new AudioAttributes.Builder()
        .setContentType(2).setUsage(4).setLegacyStreamType(audioStream).build();
```

**The curve (`setVolume`) — this is the exact formula:**

```java
private synchronized void setVolume(int volume) {
    if (forcedVolume != null) { volume = forcedVolume.intValue(); }
    float f;
    if (volume < 100) {
        // f = 1 - ln(100 - volume) / ln(100)
        f = (float) (1.0 - Math.log(100.0 - volume) / Math.log(100.0));
    } else {
        f = 1.0f;
    }
    if (f < 0.0f) { f = 0.0f; }
    if (f > 1.0f) { f = 1.0f; }
    if (player != null && player.isPlaying()) { player.setVolume(f, f); }
    for (IVolumeChangeListener l : listeners) { l.volumeUpdated(f); }
}
```

i.e. **`f(v) = 1 − log₁₀(100 − v)`** for `0 ≤ v < 100` (because `ln(x)/ln(100) = log₁₀(x)`),
`f(v) = 1.0` for `v ≥ 100`.

Sample values: `f(0)=0.000`, `f(10)=0.049`, `f(25)=0.097`, `f(50)=0.301`, `f(75)=0.602`,
`f(90)=0.500`… *(note: `f(90) = 1 − log₁₀(10) = 0.500`)*, `f(95)=0.699`, `f(99)=1.000`.

**The ramp loop (`run()`):**

```java
public void run() {
    long step = increaseDuration / 100;                  // integer division, ms per 1 volume unit
    long start = System.currentTimeMillis();
    Logger.logDebug("GentleAlarmRunnable: Starting gentle alarm with initial volume: "
        + currentVolume + " and increase duration: " + increaseDuration
        + " Stream volume: " + initialVolume + " Vibration after: " + ...);
    while (true) {
        long elapsed = System.currentTimeMillis() - start;
        synchronized (this) {
            this.thread = Thread.currentThread();
            setMaxVolume();                               // system stream -> max (if audioStream != -1)
            if (isStopRequested()) { break; }
            if (vibrator != null && !vibrating && hasAlreadyProgressedToVibration() && !isSuspended()) {
                Logger.logInfo("GentleAlarmRunnable: vibrate()");
                vibrator.vibrate(AlarmKlaxon.sVibratePattern, 0xf /*15*/, attr);
                vibrating = true;
            }
            if (postponeSound > elapsed) {                // ramp start is postponed
                wait(Math.min(postponeSound - elapsed, 10000L));
                continue;
            }
            if (!postponeDone && postponeSound > 0 && !isStreaming) {
                postponeDone = true;
                if (player != null && player.getCurrentPosition() > 0) {
                    player.seekTo(0);                     // restart the track when the ramp starts
                }
            }
            if (currentVolume > 100) { wait(step); }     // stay pinned at max
            if (currentVolume < 0) { break; }
            if (currentVolume % 5 == 0) {
                if (currentVolume < 150) {
                    Logger.logInfo("GentleAlarmRunnable: Current GAR volume update: " + currentVolume);
                }
                Intent i = new Intent("com.urbandroid.sleep.ACTION_VOLUME_UPDATE");
                i.putExtra("EXTRA_VOLUME", silent ? -1 : currentVolume);
                LocalBroadcastManager.getInstance(context).sendBroadcast(i);
            }
            currentVolume = currentVolume + 1;            // +1 unit per tick
            if (smartLight != null) {
                if (!smartLightStart) { smartLightStart = true; smartLight.sunriseStart(); }
                smartLight.sunrise(currentVolume, 100);
            }
            if (!isStopRequested()) { setVolume(currentVolume); }
        }
        Thread.sleep(step);                               // tick interval = increaseDuration/100 ms
    }
    setFinished(true);
}
```

**So, exactly:**

* Tick interval `step = increaseDuration / 100` ms (integer division; e.g. 60 000 → 600 ms/tick,
  1 440 000 → 14 400 ms/tick).
* The ramp is **1 volume unit per tick**, from `currentVolume` (0, or 100 if `startOnMax`) up to 100.
* The audible gain is `f(currentVolume)` = `1 − ln(100−v)/ln(100)`, applied to **both** MediaPlayer
  channels (`player.setVolume(f, f)`), and mirrored to `IVolumeChangeListener`s
  (used by the binaural generator).
* Total ramp time ≈ `increaseDuration` ms (100 ticks × step). The **system** stream volume is set to
  `AudioManager.getStreamMaxVolume(audioStream)` immediately (`setMaxVolume()`) — so the effective
  loudness is `streamMax × f`.
* A `ACTION_VOLUME_UPDATE` local broadcast (`EXTRA_VOLUME` = current volume 0..100, or `-1` if the
  alarm is silent) is emitted every 5 volume units.
* If the ramp completes, the thread **keeps running** at `f = 1.0` (currentVolume > 100 → wait(step)
  each iteration) until `stop()`/`reset()`/`suspend()` is called — the alarm does **not** stop itself
  when the ramp finishes.

### 6.3 `VolumeControlRunnable` — linear ramp on the **system** stream

Constructor:

```java
public VolumeControlRunnable(Context context, MediaPlayer player, int sleep /*ms per step*/,
                              boolean increase, int streamtype, boolean shouldStartOnMaximumVolume,
                              Vibrator vibrator, int originalVolume, int initialVolume,
                              int maxVolume, int vibrateAfter /*ms*/, long postpone /*ms*/)
```

Defaults in the constructor: `sleep = 0x1388` (5000 ms), `increase = true`, `reachedTargetVolume=false`,
`initialVolume=-1`, `originalVolume=-1`, `currentVolume=0`, `forcedVolume=null`, `stop=false`,
`pause=-1`, `finished=false`, `vibrating=false`, `shouldStartOnMaximumVolume=false`.

Resolution rules:
* `initialVolume` = given value if ≥ 0, else `audioManager.getStreamVolume(streamtype)`.
* `originalVolume` = given value if ≥ 0, else `audioManager.getStreamVolume(streamtype)`.
* `maxVolume` = given value if ≥ 0 **and** not `startOnMax`, else `audioManager.getStreamMaxVolume(streamtype)`.
* `vibrateAfter` (absolute ms) = `now + vibrateAfter`.
* `postpone` = given value, forced to 0 when `startOnMax`.

Step size:

```java
// VolumeControlRunnable.convertIncreaseDurationToIncreaseSpeed(Context, int increaseDuration, int streamType)
int max = audioManager.getStreamMaxVolume(streamType);
if (max < 1) { max = 1; }
if (increaseDuration <= 0) { return 0; }
return increaseDuration / max;
```

`run()` (decompiled logic):

```java
public void run() {
    audioManager = (AudioManager) context.getSystemService("audio");
    if (increase) { currentVolume = initialVolume; }
    setVolumeFixNonZero(context, streamtype, initialVolume);
    if (currentVolume > 0 && postpone == 0) { updateVolume(); }
    else if (!increase) { currentVolume = audioManager.getStreamVolume(streamtype); }
    if (shouldStartOnMaximumVolume) {
        currentVolume = maxVolume;
        setVolumeFixNonZero(context, streamtype, maxVolume);
    }
    int wait = this.sleep;
    if (increase && currentVolume == 0) { wait = Math.min(15000, wait); }   // 0x3a98
    if (wait > 0) { wait(wait); }
    while (!Thread.interrupted()) {
        synchronized (this) {
            if (isStop()) { break; }
            if (currentVolume < 0) { break; }
            if (increase && vibrator != null && hasAlreadyProgressedToVibration() && !isSuspended() && !vibrating) {
                vibrator.vibrate(AlarmKlaxon.sVibratePattern, 0xf, attr);
            }
            if (increase) {
                if (postpone > 0 && (System.currentTimeMillis() - start) < postpone) {
                    wait(Math.min(postpone, 10000L));  continue;
                }
                currentVolume = currentVolume + 1;
                if (currentVolume > maxVolume) {
                    currentVolume = maxVolume;
                    setVolume(streamtype, maxVolume, true);
                    wait(5000L);                                  // 0x1388
                    Logger.logInfo(getClass().getSimpleName() + ": reached target volume " + currentVolume);
                    reachedTargetVolume = true;
                    updateVolume();
                    continue;
                }
                updateVolume();
            } else {
                currentVolume = audioManager.getStreamVolume(streamtype) - 1;
                if (currentVolume < 0) {
                    currentVolume = 0;
                    Logger.logInfo(getClass().getSimpleName() + ": reached target volume " + currentVolume);
                    reachedTargetVolume = true;
                }
            }
            if (!stop) { setVolume(streamtype, currentVolume, true); }
        }
        Thread.sleep(this.sleep);
        while (getPause() > -1) { int p = getPause(); setPause(-1); Thread.sleep(p); }
    }
    setFinished(true);
}
```

* Increase: **+1 stream-volume unit per tick**, tick = `sleep` ms (= `increaseDuration / streamMaxVolume`).
* When `currentVolume > maxVolume` it is clamped, `reachedTargetVolume = true`, and the thread then
  waits 5000 ms per iteration while holding max volume.
* Decrease (lullaby): `currentVolume = currentStreamVolume − 1` per tick, floor 0, then
  `reachedTargetVolume = true`.
* `updateVolume()` broadcasts `com.urbandroid.sleep.ACTION_VOLUME_UPDATE` with
  `EXTRA_VOLUME = round(currentVolume / getStreamMaxVolume(streamtype) * 100)`.
* `setVolume(streamtype, volume, force)`: if `force` and `forcedVolume != null` and
  `forcedVolume < volume`, the forced value wins; then `setVolumeFixNonZero` writes the system stream.
* `setVolumeFixNonZero(context, streamtype, volume)`: for `streamtype == 4` (ALARM) and `sleep == 0`
  it also sets the **MediaPlayer** gain to `0.0f` or `1.0f` (workaround for the "non-zero alarm
  stream problem"), then `VolumeUtil.setStreamVolume(context, streamtype, volume)`.

### 6.4 `LullabyVolumeDown` — fading the sleep lullaby down

```java
public LullabyVolumeDown(SleepService context, int streamType, int volumeDownAfterPref) {
    this.volumeDownAfter = 0xdbba0;      // 900 000 ms = 15 min  (default)
    ...
    this.volumeDownAfter = parseVolumeDownAfterPreferenceValue(volumeDownAfterPref);
    this.streamType = streamType;
    listenForVolumeDownAfterPreferenceChange();
}

private int parseVolumeDownAfterPreferenceValue(int value) {
    if (value < -1) { return 0x57e40; }   // 360 000 ms = 6 min
    if (value == -1) { return -1; }       // disabled
    if (value == 0)  { return 0x57e40; }  // 6 min
    return value;                         // seconds? -> used as ms; see below
}
```

`update(boolean inDeepSleep)`:

```java
if (!isEnabled()) { return; }                      // volumeDownAfter == -1 -> disabled
if (volumeDownFinished) { return; }
long now = System.currentTimeMillis();
if (lastUpdate == -1) { lastUpdate = now; return; }
long delta = now - lastUpdate;  lastUpdate = now;
elapsed += delta;
if (inDeepSleep || elapsed <= 0x5265c0 /* 5 400 000 ms = 90 min */) {
    if (!context.isPausedTracking()) {
        elapsedInDeepSleep += delta;
        volumeDownAfter = new Settings(context).getLullabyVolumeDownAfter();
        if (elapsedInDeepSleep > volumeDownAfter && volumeControlRunnable == null) {
            volumeControlRunnable = new VolumeControlRunnable(context, /*player*/ null,
                    /*sleep*/ 0x7530 /*30000 ms*/, /*increase*/ false, streamType,
                    /*startOnMax*/ false, /*vibrator*/ -1,
                    /*original*/ -1, /*initial*/ -1, /*max*/ -1, /*vibrateAfter*/ 0, /*postpone*/ 0);
            new Thread(volumeControlRunnable).start();
            ContextExtKt.sendExplicitBroadcast(context, new Intent("com.urbandroid.sleep.LULLABY_VOLUME_DOWN"));
        }
    } else if (volumeControlRunnable != null && !volumeControlRunnable.isFinished()) {
        volumeControlRunnable.setPause(0x15f90);      // 90 000 ms = 90 s pause
    }
}
if (volumeControlRunnable != null && volumeControlRunnable.isReachedTargetVolume()) {
    if (LullabyService.isRunning()) {
        ContextExtKt.sendExplicitBroadcast(context, new Intent("com.urbandroid.sleep.ACTION_LULLABY_AUTO_STOP_PLAYBACK"));
    } else if (new Settings(context).isLullabyTurnOffWiFi()) {
        WifiEnabler.getInstance().setWifi(context, false);
    }
    volumeDownFinished = true;
}
```

Allowed `media_decreasing_volume_after_values`: `-1, 300000, 600000, 900000, 1200000, 1500000, 1800000,
3600000, 5400000` (default 900 000 = 15 min).

**Lullaby fade-out = 1 stream-volume unit down per 30 000 ms, until the stream reaches 0, then the
lullaby is auto-stopped (and Wi-Fi optionally disabled).**

### 6.5 Volume ramp — pseudocode summary

```pseudo
# ---- Gentle (log) ramp, GentleAlarmRunnable ------------------------------
step_ms  = increaseDuration / 100                       # integer division
v        = startOnMax ? 100 : 0
while not stopRequested:
    setSystemStreamToMax()                              # only if audioStream != -1
    if postponeSound > elapsed: sleep(min(remaining,10s)); continue
    if v > 100: sleep(step_ms); continue
    if v % 5 == 0: broadcast(ACTION_VOLUME_UPDATE, EXTRA_VOLUME = silent ? -1 : v)
    v += 1
    if smartLight: smartLight.sunrise(v, 100)
    gain = (v < 100) ? 1 - ln(100 - v)/ln(100) : 1.0
    gain = clamp(gain, 0, 1)
    if player != null and player.isPlaying(): player.setVolume(gain, gain)
    sleep(step_ms)

# ---- Fixed / streaming (linear) ramp, VolumeControlRunnable ---------------
step_ms  = increaseDuration / max(1, getStreamMaxVolume(streamtype))
v        = startOnMax ? maxVolume : initialVolume
while not stop:
    v += 1
    if v > maxVolume: v = maxVolume; setStreamVolume(v); sleep(5000); reachedTarget = True; continue
    setStreamVolume(v)
    sleep(step_ms)

# ---- Lullaby fade-out ----------------------------------------------------
step_ms  = 30000
while not stop:
    v = getStreamVolume(streamType) - 1
    if v < 0: v = 0; setStreamVolume(0); reachedTarget = True; stop lullaby; break
    setStreamVolume(v)
    sleep(step_ms)
```

---

## Klaxon behaviour, streams, channels, silent-mode handling

### 7.1 Media stream

```java
// AlarmKlaxon.startKlaxon(Intent, boolean)
this.alarmAudioStream = SharedApplicationContext.getSettings().getAlarmOutput() == 1 ? 3 : 4;
// 3 = AudioManager.STREAM_MUSIC, 4 = AudioManager.STREAM_ALARM
// Settings.getAlarmOutput(): pref "alarm_output", default 0
if (isSpotifyAlarm(fromIntent)) {
    if (!settings.isSpotifyPremium() || !settings.isSpotifyAppRemoteScopeAllowed()
        || fromIntent.alert == null || "spotify-play-last-song".equals(fromIntent.alert.toString())) {
        this.alarmAudioStream = 3;                      // MUSIC
    } else {
        int i2 = (settings.getAlarmOutput() > 0 || Alarm.resolveSoundDelay(this, fromIntent, this.isSnoozedAlarm) > 0) ? 3 : 4;
        this.alarmAudioStream = i2;
    }
}
```

Audio attributes / stream type:

```java
// AlarmKlaxon.setDataSource(Uri, boolean)
mediaPlayer.setAudioAttributes(new AudioAttributes.Builder()
        .setContentType(2)                      // CONTENT_TYPE_SONIFICATION
        .setUsage(alarmAudioStream == 3 ? 1 : 4) // USAGE_MEDIA(1) / USAGE_ALARM(4)
        .setLegacyStreamType(alarmAudioStream)
        .build());

// AlarmKlaxon.startAlarm(MediaPlayer, boolean)
mediaPlayer.setAudioStreamType(this.alarmAudioStream);
if (shouldPlayInLoop()) { mediaPlayer.setLooping(true); }
```

`shouldPlayInLoop()`:

```java
private boolean shouldPlayInLoop() {
    return currentAlarm == null
        || !MultipleMediaUriUtil.isMultipleUri(currentAlarm.alert)
        || SharedApplicationContext.getSettings().isAlarmPlaylistLooping();
}
```

When not looping, an `OnCompletionListener` advances to the next track of the playlist
(`MultipleMediaUriUtil.decodePosition(uri, position)`), falling back to
`SleepUtils.getActualDefaultRingtoneUri(context)` and finally to `R.raw.fallbackring`
(`playFallback`), with a 2000 ms delay before handing over to Spotify.

### 7.2 Fade in / fade out

* **Fade in** = the volume ramp of §6 (player gain for gentle alarms, system stream for fixed ones).
  There is no separate fade-in code path.
* **Fade out** = the alarm is stopped abruptly via `stop()` → `volumeControlRunnable.reset()`
  (which restores `initialVolume` on the system stream) — **no fade-out ramp exists** for the alarm
  itself. `GentleAlarmRunnable.reset()`:

```java
public synchronized void reset() {
    Logger.logDebug("GentleAlarmRunnable: Resetting initial volume back to initial volume: " + initialVolume);
    ... "GentleAlarmRunnable: Cancelling vibrations"
    ... "GentleAlarmRunnable finished."
}
```

* The only real fade-out in the app is the lullaby fade-out of §6.4.

### 7.3 Dismiss vs snooze

`Alarm.performDismiss(Context, Alarm, SleepRecord, boolean autoKill)`:

```java
settings.setSnoozeAllowedTill(-1L);
settings.resetSnoozeRepeat();
Logger.logInfo(z ? "Alarm: Alarm killed" : "Alarm: Alarm dismissed by user");
requestAlarmSoundStop(context);                       // stops the AlarmKlaxon service
if (!z) {
    if (alarm != null && shouldDeleteAlarm(alarm) && !settings.isWakeUpCheck(alarm)) {
        Alarms.deleteAlarm(context, alarm.id);
    }
    if (sleepRecord == null || !(alarm == null || alarm.extendedConfig.isTerminatesTracking().booleanValue())) {
        Logger.logInfo("Null record in alarm alert");
    } else {
        RatingActivity.showRatingIfEnabled(context, sleepRecord);
    }
    if (alarm != null && SharedApplicationContext.getSettings().isWakeUpCheck(alarm)) {
        Alarms.scheduleWakeUpCheck(context, alarm, settings.getWakeUpCheckAfterAlarm());
    }
} finally {
    Intent intent = new Intent("com.urbandroid.sleep.alarmclock.ALARM_ALERT_DISMISS");
    if (alarm != null) { intent.putExtra("alarm_id", alarm.id); }
    ContextExtKt.sendExplicitBroadcast(context, intent);
    ...
}
```

`Alarm.performSnooze(Context, Alarm, int minutes, boolean autoKill)`:

```java
if (minutes == -39837) { /* "snooze till alarm" sentinel */
    long t = getCurrentRecordAlarmTime(alarm);
    if (t == 0 || System.currentTimeMillis() >= t - 60000) { return; }   // ignore
    minutes = (int) ((t - System.currentTimeMillis()) / 60000);
}
if (minutes <= 0) { minutes = 1; }
record.addEventLabel(autoKill ? EventLabel.ALARM_SNOOZE_AFTER_KILL : EventLabel.ALARM_SNOOZE, now);
long snoozeAt = 60000L * minutes + System.currentTimeMillis();
Alarms.saveSnoozeAlert(context, alarm.id, snoozeAt);
showSnoozeNotification(context, alarm, minutes);
Toast.makeText(context, context.getString(R.string.alarm_alert_snooze_set, minutes), 1).show();
Intent intent = new Intent(context, (Class<?>) AlarmKlaxon.class);
intent.setAction("com.urbandroid.sleep.alarmclock.ALARM_ALERT");
context.stopService(intent);
Intent intent2 = new Intent("com.urbandroid.sleep.alarmclock.ALARM_SNOOZE_CLICKED_ACTION");
intent2.putExtra("alarm_id", alarm.id);
ContextExtKt.sendExplicitBroadcast(context, intent2);
settings.increaseSnoozeRepeat();
settings.setLastSnooze(minutes);
```

The snooze is re-armed through the *same* machinery: `Alarms.saveSnoozeAlert` stores
`snooze_id`/`snooze_time` in the `AlarmClock` SharedPreferences and calls `Alarms.setNextAlert(ctx)`,
which finds the snooze alarm first (`enableSnoozeAlert`) and registers it with the same
`ALARM_ALERT` intent / request code 72849.

Snooze duration / limits:

```java
// Alarm.getSnoozeMinutes(Alarm, boolean)
int snoozeDuration = settings.getSnoozeDuration(alarm);
if (settings.isHalveSnooze() && snoozeDuration != 0) {
    for (int i = 0; i < settings.getSnoozeRepeat(); i++) { snoozeDuration /= 2; }
    snoozeDuration = Math.max(snoozeDuration, 1);
}
int limit = z ? Integer.MAX_VALUE : maxSnoozeMinutes(alarm);
return Math.min(Math.min(snoozeDuration, limit), calculateCurrentRemainingSnoozeTime(alarm));
```

`isSnoozeEnabled(alarm)` requires `snoozeMinutes > 0 && maxSnoozeMinutes > 0 && (snoozeLimit == 0 || snoozeLimit > snoozeRepeat)`.
Global snooze duration: pref `snooze_duration`, default `"10"` (minutes); per-alarm override lives in
`extendedConfig.snoozeDuration` (sentinel `-2` = inherit, `-1` = no snooze).

### 7.4 Alarm timeout logic (summary)

1. `AlarmKlaxon.playInitialAlarm` records `mStartTime = System.currentTimeMillis()` and calls
   `enableKillerOrSirena(alarm)`.
2. If the siren ringtone is **not** "silent": after `alarm_kill_time` (default 1200 s) the
   **SIRENA** (message 1002) fires → the siren ringtone is played at `STREAM_ALARM` with force-max.
3. `enablePostSirenaKiller` then schedules the **KILL** (message 1000) after `siren_kill_time`
   (default 60 s).
4. If the siren ringtone **is** "silent", the **KILL** fires directly after `alarm_kill_time`.
5. KILL → `sendKillBroadcast(alarm)` with `alarm_killed_timeout` (minutes the alarm rang) →
   `AlarmReceiver` auto-snoozes (up to `alarm_kill_snooze_count`, default 3) or dismisses with
   `autoKill = true`.

### 7.5 Notification channels and importance

From `com.urbandroid.sleep.notification.NotificationsKt` (all `NotificationManagerCompat.createNotificationChannel`):

| Channel id | Importance | Lights | Vibration | Sound |
|---|---|---|---|---|
| `alarmChannel` | **4** (`IMPORTANCE_HIGH`) | yes | no | none (silent) |
| `alarmNormalChannel` | 2 (`IMPORTANCE_DEFAULT`) | no | no | – |
| `beforeAlarmChannel` | 2 | no | no | – |
| `reteLateAlarmChannel` | 4 | yes | no | – |
| `wakeupCheckChannel2` | 4 | yes | no | set explicitly to 4 |
| `antiSnoringChannel` | 4 | yes | no | – |
| `sleepTrackingChannel` | 2 | no | no | – |
| `bedtimeChannel` | 4 | yes + light colour | yes + pattern | – |
| `lullabyChannel` | 2 | no | no | – |
| `backupChannel` | 2 | no | no | – |
| `sleepTimeSuggestionChannel` | 2 | yes | yes | – |
| `servicesChannel` | 2 | no | no | – |
| `calendarChannel` | 4 | yes | yes | – |
| `bkgRestrictedChannel` | 4 | yes | yes | – |

The alarm alert notification id is `34377266`; the bedtime notification id is `33434343`;
the wake-up-check notification id is `28777382`.

### 7.6 Silent mode / DND handling

```java
// AlarmKlaxon.startKlaxon
if (SharedApplicationContext.getSettings().isAlarmInSilent() && fromIntent != null
    && fromIntent.alert != null && !"silent".equals(fromIntent.alert.toString())) {
    if (!Environment.isMOrGreater() && Environment.isLollipopOrGreater()) {
        AudioManager audioManager = (AudioManager) getSystemService("audio");
        if (audioManager.getRingerMode() == 0) {          // RINGER_MODE_SILENT
            Logger.logInfo("AlarmKlaxon: Unmuting ringer, for alarm ");
            audioManager.setRingerMode(2);               // RINGER_MODE_NORMAL
            this.ringerModeChanged = true;
        } else {
            this.ringerModeChanged = false;
        }
    } else if (Environment.isMOrGreater() && !VolumeUtil.cancelDndAll(getApplicationContext())) {
        Logger.logInfo("Cannot cancel DND all - alarm may not play - we rely here on backup alarm");
    }
}
```

* `isAlarmInSilent()` → pref `alarm_in_silent_mode`, **default true**.
* On API 21–22 the ringer mode is forced to NORMAL (and restored later — the restore call was not
  traced → **UNKNOWN** where it is undone, though `ringerModeChanged` exists as a flag).
* On API ≥ 23 the app calls `VolumeUtil.cancelDndAll(context)` to lift Do-Not-Disturb; if that fails
  the log explicitly says it **relies on the backup alarm** (the direct-boot `BackupAlarmService`).
* `playInitialAlarm` additionally un-silences an alarm that was marked silent when
  `PowerManager.isPowerSaveMode()` is on (API ≥ 21, and only when no smart-light/smart-watch is used).
* `RingerModeUtil.resetAlarmSilentSettings(context, settings, alarmAudioStream)` is called after the
  original volume has been captured.

### 7.7 Vibration

```java
// AlarmKlaxon.<clinit>
sVibratePattern = {100,100,5000,100,5000,100,5000,200,4000,300,3000,400,2000,500,1000,500,500};  // 17 entries, ms
sVibratePatternResume = {500,500};
```

Both `GentleAlarmRunnable` and `VolumeControlRunnable` vibrate with
`vibrator.vibrate(AlarmKlaxon.sVibratePattern, 0xf /*15 = repeat index*/, attr)` once the
configured vibration-start delay has elapsed.

---

## Dismiss / unlock flow with intent extras table

### 8.1 The two "unlock" concepts

* **`com.urbandroid.sleep.alarmclock.UnlockFlow`** is the **paywall / subscription screen**
  (monthly / yearly / lifetime cards, trial extension via a rewarded ad, `restore_purchase_layout`,
  `use_free` button). It is *not* the alarm dismissal gate. `UnlockFlow.onCreate()` /
  `onStart()` only set up the billing UI.
* The **alarm dismissal gate** is the **captcha** (`CaptchaInfo` / `CaptchaManager`), implemented in
  `AlarmAlertFullScreen`.

### 8.2 Gate order on dismiss

```
AlarmAlertFullScreen.dismissOrStartCaptcha()        // the "Dismiss" button
    ├─ settings.getCaptchaInfo(alarm) == null OR captchaPassed
    │     → settings.cleanLastNonSnoozeAlarm()
    │     → handleCaptchaProvenDismissClick()
    └─ else
          → CaptchaManager.getLauncher(alarm).addFlags(131072).start(captchaInfo)
          → captchaInProgress = true
```

```java
private void handleCaptchaProvenDismissClick() {
    Logger.logDebug("AlarmAlertfullscreen: Captcha dismiss proven. Release notification with id: " + this.alarm);
    SleepRecord record = CurrentSleepRecord.getInstance().getRecord();
    if (record != null) { record.addEventLabel(EventLabel.ALARM_DISMISS, System.currentTimeMillis()); }
    ContextExtKt.sendExplicitBroadcast(getApplicationContext(),
        new Intent("com.urbandroid.sleep.alarmclock.ALARM_DISMISS_CLICKED_ACTION"));
    SharedApplicationContext.getSettings().setLastCaptchaSolvedTimestampNow();
    dismiss(false, record);
}
```

Captcha result comes back via `onCaptchaResult(Intent)`:

```java
public void onCaptchaResult(Intent intent) {
    if (intent != null && (intent.hasExtra("captcha_result_left") || intent.hasExtra("captcha_result_success"))) {
        this.captchaInProgress = false;  CAPTCHA_IN_PROGRESS = false;
        if (!intent.hasExtra("captcha_result_success")) {
            this.cancelRestart = false;
            ContextExtKt.sendExplicitBroadcast(this, new Intent("com.urbandroid.sleep.alarmclock.ALARM_RESUME"));
        } else {
            this.captchaPassed = true;
            SharedApplicationContext.getSettings().cleanLastNonSnoozeAlarm();
            handleCaptchaProvenDismissClick();
        }
    }
}
```

**Order of gates:** *dismiss button* → *captcha* → (optional) *wake-up check* → *dismiss*.
The **wake-up check** is scheduled *after* a successful dismiss:

```java
// Alarm.performDismiss
if (alarm != null && SharedApplicationContext.getSettings().isWakeUpCheck(alarm)) {
    Alarms.scheduleWakeUpCheck(context, alarm, SharedApplicationContext.getSettings().getWakeUpCheckAfterAlarm());
}
```

and it re-arms the alarm with the `ALARM_WAKE_UP_CHECK` intent (request code 3). The user then has to
confirm being awake (`cancel_snooze_no_captcha` clears the snooze and marks the wake-up check as done;
a self-disposable alarm is then deleted).

The **shake / "cheating" detection** is the `LockView` (`com.urbandroid.sleep.captcha.cheating.LockView`)
plus `AlarmKlaxon.doNoEscape(...)`; when it triggers, `scheduleCheckEscapeCaptcha()` is armed.

### 8.3 Intent extras table (alarm pipeline)

| Extra key | Type | Producer | Consumer |
|---|---|---|---|
| `intent.extra.alarm_raw` | `byte[]` | `Alarms.enableAlert`, `Alarms.fireSmartAlarm`, `AlarmKlaxon.sendKillBroadcast`, `Alarms.scheduleWakeUpCheck` | `Alarm.parseFromIntent` → `Alarm.deserializeFromArray` |
| `intent.extra.alarm` | `Parcelable`/`Serializable` `Alarm` | `AlarmReceiver` → `AlarmAlertFullScreen` / `AlarmKlaxon`; `AlarmKlaxon.startKlaxon` (restart) | `AlarmAlertFullScreen.handleStartExtra`, `AlarmKlaxon.startKlaxon` |
| `intent.extra.alarm_restarted` | `boolean` | `AlarmKlaxon.startKlaxon` (restart path) | `AlarmReceiver.onReceive` (skips re-start of the klaxon) |
| `use_headsup_extra` | `boolean` | `AlarmReceiver` | `AlarmKlaxon.startKlaxon` → heads-up notification |
| `dissmis_or_captcha_extra` | `boolean` | `AlarmReceiver` (notification dismiss), `AlarmAlertFullScreen.handleStartExtra` | `AlarmAlertFullScreen.dismissOrStartCaptcha()` |
| `headsup_notif_clicked` | `boolean` | notification | `AlarmAlertFullScreen.handleStartExtra` |
| `CREATION_SOURCE` | `String` | `AlarmReceiver` (`"AlarmReceiver-Main-Code"`, `"AlarmReceiver-NOTIF-DISMISS"`, `"AlarmReceiver-NOTIF-DISMISS-STANDARD"`) | analytics |
| `captcha_result_success` | present (no value) | captcha activity | `AlarmAlertFullScreen.onCaptchaResult` |
| `captcha_result_left` | present (no value) | captcha activity | `AlarmAlertFullScreen.onCaptchaResult` |
| `alarm_id` | `int` | `Alarms.enableAlert` (bedtime), `AlarmReceiver`, `Alarm.performDismiss`, `Alarm.performSnooze`, `Alarms.setNextAlert` | many receivers |
| `alarm_killed_timeout` | `int` (minutes) | `AlarmKlaxon.sendKillBroadcast` | `AlarmReceiver` |
| `alarm_label` | `String` | `Alarms.setNextAlert` (`ALARM_RESCHEDULED`) | widgets |
| `alarm_time` | `long` | `Alarms.setNextAlert` (`ALARM_RESCHEDULED`) | widgets |
| `time_to_bed_message` | `String` | `Alarms.scheduleTimeToBedBedtime` | `BedtimeReceiver` |
| `time_to_bed_content_info` | `String` | `Alarms.scheduleTimeToBedBedtime` | `BedtimeReceiver` |
| `next_alarm` | `long` | `LockedBootReceiver.getBackupAlarmIntent` | `BackupAlarmService` |
| `SCHEDULED_AUTO_START` | `boolean` | `Alarms.enableAlert` | `AutoStartTrackReceiver` |
| `extra_snooze_time` | `int` (minutes, clamped to ≤ 60) | watch / notification snooze | `AlarmReceiver` (`ALARM_SNOOZE`) |
| `set_time_extra` | `boolean` | `Alarms.setAlarmClockCompat` (`SetAlarm` activity) | `SetAlarm` |
| `SleepRecord` | `Parcelable` | `Alarms.showRateSleepLaterNotification` path | `AlarmReceiver` (`RATE_SLEEP_LATER`) |
| `notification_tapped` | `boolean` | `BedtimeReceiver` notification | `AlarmClock` activity |
| `extra_broadcast_action` | `String` | `BedtimeReceiver` | `DummyBroadcastActivity` |

### 8.4 Full action strings used in the alarm pipeline

```
com.urbandroid.sleep.alarmclock.ALARM_ALERT              (main alarm; broadcast + foreground service)
com.urbandroid.sleep.alarmclock.ALARM_ALERT_START
com.urbandroid.sleep.alarmclock.ALARM_ALERT_START_INTERNAL
com.urbandroid.sleep.alarmclock.ALARM_ALERT_DISMISS
com.urbandroid.sleep.alarmclock.ALARM_DISMISS_CLICKED_ACTION
com.urbandroid.sleep.alarmclock.ALARM_DISMISS_CAPTCHA
com.urbandroid.sleep.alarmclock.ALARM_SNOOZE
com.urbandroid.sleep.alarmclock.ALARM_SNOOZE_CLICKED_ACTION
com.urbandroid.sleep.alarmclock.ALARM_NOTIF_SNOOZE
com.urbandroid.sleep.alarmclock.ALARM_NOTIF_DISMISS
com.urbandroid.sleep.alarmclock.ALARM_RESUME
com.urbandroid.sleep.alarmclock.ALARM_SUSPEND
com.urbandroid.sleep.alarmclock.ALARM_RESCHEDULED
com.urbandroid.sleep.alarmclock.ALARM_STATE_CHANGE
com.urbandroid.sleep.alarmclock.ALARM_WAKE_UP_CHECK
com.urbandroid.sleep.alarmclock.alarm_killed
com.urbandroid.sleep.alarmclock.cancel_snooze
com.urbandroid.sleep.alarmclock.cancel_snooze_no_captcha
com.urbandroid.sleep.alarmclock.cancel_snooze_finished
com.urbandroid.sleep.alarmclock.SKIP_NEXT_ALARM_ACTION
com.urbandroid.sleep.alarmclock.SHOW_SKIP_NEXT_ALARM_ACTION
com.urbandroid.sleep.alarmclock.AUTO_START_SLEEP_TRACK
com.urbandroid.sleep.alarmclock.AUTO_START_SLEEP_TRACK_BEDTIME
com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALARM_ALERT
com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALERT_REPEAT_ACTION
com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALERT_SNOOZE_ACTION
com.urbandroid.sleep.alarmclock.TIME_TO_BED_ALERT_DISMISS_ACTION
com.urbandroid.sleep.alarmclock.ALARM_TIME_TO_BED_UPDATE
com.urbandroid.sleep.alarmclock.DELAYED_BOOT_COMPLETED
com.urbandroid.sleep.alarmclock.RECALCULATE_ALARM
com.urbandroid.sleep.alarmclock.TIME_CHANGED
com.urbandroid.sleep.alarmclock.TIME_CHANGED_EXTRA   (long extra)
com.urbandroid.sleep.alarmclock.RANDOM_ALARM_DIAGNOSTICS
com.urbandroid.sleep.alarmclock.RATE_SLEEP_LATER
com.urbandroid.sleep.ACTION_VOLUME_UPDATE          (+ EXTRA_VOLUME int)
com.urbandroid.sleep.LULLABY_VOLUME_DOWN
com.urbandroid.sleep.ACTION_LULLABY_AUTO_STOP_PLAYBACK
com.urbandroid.sleep.SMART_PERIOD
com.urbandroid.sleep.JETLAG_START / JETLAG_END
com.urbandroid.sleep.ACTION_FINISH_CAPTCHA
```

### 8.5 The "alarm fired" flow in `AlarmReceiver.onReceive`

```java
Alarm fromIntent = Alarm.parseFromIntent(intent);
...
if (now > fromIntent.time + 1800000) {                 // 30 min -> stale alarm
    Logger.logDebug("AlarmReceiver: ignoring stale alarm");
    return;
}
settings.updateLastNonSnoozeAlarm(now);
if (reliableAlarmExperiment && settings.isReliableAlarmScheduled()) {
    AlarmAlertWakeLock.acquireCpuWakeLock(context, 10000);   // the service will do the work
    return;
}
AlarmAlertWakeLock.acquireCpuWakeLock(context);
record.addEventLabel(EventLabel.ALARM_STARTED, now);
if (Build.VERSION.SDK_INT < 31) { context.sendBroadcast(new Intent("android.intent.action.CLOSE_SYSTEM_DIALOGS")); }
...
Intent intent6 = new Intent(context, cls2);            // AlarmAlertFullScreen
intent6.putExtra("intent.extra.alarm", (Serializable) fromIntent);
intent6.putExtra("CREATION_SOURCE", "AlarmReceiver-Main-Code");
intent6.setFlags(268697600);
context.startActivity(intent6);
Alarms.disableSnoozeAlert(context, fromIntent.id);
Alarms.scheduleNewAlertAfterOldFinished(context, fromIntent);
if (!intent.getBooleanExtra("intent.extra.alarm_restarted", false)) {
    Intent intent7 = new Intent(context, (Class<?>) AlarmKlaxon.class);
    intent7.setAction("com.urbandroid.sleep.alarmclock.ALARM_ALERT");
    intent7.setPackage(context.getPackageName());
    intent7.putExtra("intent.extra.alarm", (Serializable) fromIntent);
    if (useHeadupsNotification) { intent7.putExtra("use_headsup_extra", true); }
    WakefulForegroundBroadcastReceiver.INSTANCE.startWakefulService(context, intent7);
}
ContextExtKt.sendExplicitBroadcast(context, new Intent("com.urbandroid.sleep.alarmclock.ALARM_ALERT_START"));
Intent intent8 = new Intent("com.urbandroid.sleep.alarmclock.ALARM_ALERT_START_INTERNAL");
intent8.putExtra("intent.extra.alarm", (Serializable) fromIntent);
ContextExtKt.sendExplicitBroadcast(context, intent8);
AlarmStatusReceiver.alarmIsRinging = true;
```

---

## Post-boot / locked-boot rescheduling

### 9.1 Normal boot (`AlarmInitReceiver`)

Registered for `BOOT_COMPLETED`, `DELAYED_BOOT_COMPLETED`, `TIME_SET`, `TIMEZONE_CHANGED`,
`LOCALE_CHANGED`, `SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED`,
`com.urbandroid.sleep.alarmclock.RECALCULATE_ALARM`.

```java
if ("android.intent.action.BOOT_COMPLETED".equals(action)) {
    Logger.logInfo("Boot completed");
    if (Environment.isNOrGreater()) { LockedBootReceiver.cancelBackupAlarm(context); }
    Alarms.saveSnoozeAlert(context, -1, -1L);       // clear the snooze
    Alarms.disableExpiredAlarms(context);
    settings.setTimeDifference();
    settings.resetSnoozeRepeatIfNoSnoozeScheduled();
    settings.resetAutoSnoozeRepeat();
    Alarms.setNextAlert(context);                  // <-- re-arm everything
    restartTrackOnRebootIfRequired(context);
    ... start FitbitHttpServerService / ZeppHttpServerService ...
    ((AlarmManager) context.getSystemService("alarm")).set(0,
        System.currentTimeMillis() + 180000,
        PendingIntentBuilder.get(context, 0,
            new Intent("com.urbandroid.sleep.alarmclock.DELAYED_BOOT_COMPLETED"),
            134217728).getExplicitBroadcast());    // +3 min second pass
    if (rebootRestartingExperiment) {
        int currentAlarm = settings.getCurrentAlarm();
        long currentAlarmTime = settings.getCurrentAlarmTime();
        boolean tooOld = currentAlarmTime == 0
            || System.currentTimeMillis() - currentAlarmTime > ((long) settings.getAlarmTimeout()) * 1000;
        if (tooOld) { settings.setCurrentAlarm(-1, 0L); }
        Alarm alarm = Alarms.getAlarm(context.getContentResolver(), currentAlarm);
        if (alarm != null && !tooOld) {
            settings.clearActiveAlarm();
            Alarms.fireSmartAlarm(context, alarm);  // re-fire the alarm that was ringing at reboot
        }
    }
}
```

`DELAYED_BOOT_COMPLETED` (fired 3 min after boot) simply calls `Alarms.setNextAlert(context)`.
`TIME_SET` recomputes the alarm times for the new clock, resets the reschedule cache when the
drift exceeds `RESCHEDULE_ALARM_NEAR_IGNORE_MAX_DIFF`, and broadcasts
`com.urbandroid.sleep.alarmclock.TIME_CHANGED` with `com.urbandroid.sleep.alarmclock.TIME_CHANGED_EXTRA`.

```java
// AlarmInitReceiver.<clinit>
RESCHEDULE_ALARM_NEAR_IGNORE_LOOKBACK = 0x57e40;   // 360 000 ms = 6 min
RESCHEDULE_ALARM_NEAR_IGNORE_MAX_DIFF = 0x7530;    //  30 000 ms = 30 s
```

### 9.2 Direct boot (`LockedBootReceiver`)

Registered for `android.intent.action.LOCKED_BOOT_COMPLETED`. It runs in the **device-protected
storage** and re-arms the alarm using two files written earlier by the app:

```java
@Override
public void onReceive(Context context, Intent intent) {
    Context ctx = context.createDeviceProtectedStorageContext();
    if (!ctx.isDeviceProtectedStorage()) { return; }
    if (!"android.intent.action.LOCKED_BOOT_COMPLETED".equals(intent.getAction())) { return; }
    String nextAlarm = InputStreamUtil.read(ctx.openFileInput("next_alarm"));
    String running  = InputStreamUtil.read(ctx.openFileInput("running_alarm"));
    boolean hasActiveAlarm = false;
    if (running != null && !"".equals(running)) {
        long t = Long.parseLong(running);
        if (System.currentTimeMillis() - t < 300000) {      // 5 min
            nextAlarm = String.valueOf(System.currentTimeMillis());
            hasActiveAlarm = true;
        }
    }
    if (nextAlarm != null && !"".equals(nextAlarm)) {
        long when = Long.parseLong(nextAlarm);
        if (System.currentTimeMillis() - when < 180000) {   // 3 min
            when = System.currentTimeMillis() + 30000;
        }
        if (System.currentTimeMillis() < when) {
            AlarmManager am = (AlarmManager) ctx.getSystemService("alarm");
            PendingIntent show = PendingIntentBuilder.get(ctx, 666,
                new Intent(ctx, (Class<?>) AlarmClock.class), 134217728).getActivity();
            if (Build.VERSION.SDK_INT >= 31 && !am.canScheduleExactAlarms()) {
                am.setAndAllowWhileIdle(0, when, show);
            } else {
                long j2 = hasActiveAlarm ? -1 : when;
                am.setAlarmClock(new AlarmManager.AlarmClockInfo(when, show),
                                 getBackupAlarmIntent(ctx, j2));
            }
        }
    }
}
```

The **backup alarm** PendingIntent (direct-boot fallback, request code 666):

```java
public static PendingIntent getBackupAlarmIntent(Context context, long nextAlarm) {
    Intent v0 = new Intent(context, (Class<?>) BackupAlarmService.class);
    if (nextAlarm != -1) { v0.putExtra("next_alarm", nextAlarm); }
    v0.setPackage(context.getPackageName());
    return PendingIntentBuilder.get(context, 0x29a /*666*/, v0, 0x08000000).getForegroundService();
}
```

`BackupAlarmService`:

```java
@Override
public int onStartCommand(Intent intent, int i, int i2) {
    startForeground(666, getNotificationBuilder().build());
    if (intent == null) { return 1; }
    this.nextAlarm = intent.getLongExtra("next_alarm", -1L);
    Log.i("SleepAsAndroidDB", "BackupAlarm: next alarm to start " + this.nextAlarm);
    return 1;    // START_STICKY
}
```

It plays the fallback ringtone (`R.raw.fallbackring`) on the `alarmChannel` (importance 4) and
shows `BackupAlarmActivity` / `ScreenUnlockActivity` so the user can unlock and re-arm the real alarm.
`LockedBootReceiver.cancelBackupAlarm(context)` cancels it — it is called from `Alarms.enableAlert`
(API ≥ 24) and from `AlarmInitReceiver` on boot.

### 9.3 Package replaced

`com.urbandroid.sleep.alarmclock.ReplacedReceiver` listens to
`android.intent.action.PACKAGE_REPLACED` / `MY_PACKAGE_REPLACED` and re-arms the alarms
(`Alarms.setNextAlert`) — its body was not fully traced → **UNKNOWN** in detail.

---

## Pseudocode summary

```pseudo
# ============ SCHEDULING ============
enable_alarm(alarm, enabled):
    write DB row (enabled, hour, minutes, daysofweek, alarmtime, vibrate, message, alert,
                  suspendtime, ndswakeupwindow, captcha, generic_extension)
    set_next_alert()

set_next_alert(now):
    if snooze pending (snooze_id/snooze_time in prefs) and snooze_time > now - 60_000:
        enable_alert(snooze_alarm, snooze_alarm.time); return
    next = calculate_next_alert(now)          # earliest enabled, non-skipped alarm
    if next != null:
        enable_alert(next, next.time)
    else:
        disable_alert()
    if "no alarm bedtime" enabled: schedule_time_to_bed_bedtime(...)
    if next_alarm changed: broadcast ALARM_RESCHEDULED

enable_alert(alarm, time):                      # Alarms.enableAlert
    t = fix_daylight_saving_remove(time)
    intent = Intent("com.urbandroid.sleep.alarmclock.ALARM_ALERT")
    intent.putExtra("intent.extra.alarm_raw", alarm.serializeToArray())
    # reliable-alarm experiment: also register a foreground service PendingIntent
    set_alarm_clock_compat(am, ctx, alarm.id, 0, t, PI(ctx, 72849, intent))   # setAlarmClock
    # plus, if status-bar-icon disabled / no exact-alarm permission:
    #   setExactAndAllowWhileIdle(...) or setAndAllowWhileIdle(0, ...)
    schedule_time_to_bed_bedtime(...)
    schedule_auto_start_sleep_track(alarm.time - (smartPeriod + 45) min)

calculate_alarm(alarm, base):
    cal = Calendar(base)
    h = alarm.getOffsetHour(cal.time)       # applies offsetInMinutes
    m = alarm.getOffsetMinutes(cal.time)
    if h < cal.hour or (h == cal.hour and m <= cal.minute): cal += 1 day
    cal.set(h, m, 0, 0)
    d = daysOfWeek.getNextAlarm(cal)        # 0..13 days; -1 => one-shot
    if d > 0: cal += d weeks
    if alarm.suspendTime > result: recalculate from suspendTime

# ============ FIRING ============
on ALARM_ALERT:
    alarm = Alarm.parseFromIntent(intent)
    if now > alarm.time + 1_800_000: ignore (stale)
    start AlarmAlertFullScreen (extra "intent.extra.alarm")
    start AlarmKlaxon service (action ALARM_ALERT, extra "intent.extra.alarm")
    broadcast ALARM_ALERT_START / ALARM_ALERT_START_INTERNAL

on ALARM_KLaxon.start:
    stream = (alarm_output == 1) ? MUSIC(3) : ALARM(4)
    if alarm_in_silent_mode:
        API 21-22: ringerMode SILENT -> NORMAL
        API 23+  : cancelDndAll(); if it fails -> rely on the backup alarm
    originalVolume = getStreamVolume(stream)
    postDelayed(2000) -> playInitialAlarm -> play(alert)
    player.setAudioStreamType(stream); setLooping(shouldPlayInLoop())
    ramp = GentleAlarmRunnable (log curve) if local && duration>=30_000
         = VolumeControlRunnable (linear on stream) otherwise
    enableKillerOrSirena: SIRENA@alarm_kill_time (if siren != "silent") -> KILL@siren_kill_time
                          else KILL@alarm_kill_time

on DISMISS:
    if captcha required and not passed: launch captcha -> on success -> dismiss
    dismiss: stop sound, optionally delete alarm, optionally schedule wake-up check
            broadcast ALARM_ALERT_DISMISS (extra alarm_id)
on SNOOZE(minutes):
    minutes = clamp(minutes, 1, ...)
    snooze_at = now + minutes*60_000
    save prefs snooze_id/snooze_time; set_next_alert()  -> re-arms via ALARM_ALERT
    stop AlarmKlaxon; broadcast ALARM_SNOOZE_CLICKED_ACTION (extra alarm_id)

# ============ BOOT ============
BOOT_COMPLETED:   clear snooze; disable expired alarms; set_next_alert(); +3 min second pass
LOCKED_BOOT:      read "next_alarm"/"running_alarm" from device-protected storage;
                  setAlarmClock(when, PI(666 -> BackupAlarmService, extra next_alarm))
```

---

## Evidence table

| # | Claim | Class | Method / field |
|---|---|---|---|
| 1 | DB DDL `alarms` table, 13 columns | `com.urbandroid.sleep.alarmclock.AlarmProvider$DatabaseHelper` | `onCreate`, `onUpgrade` |
| 2 | `ALARM_QUERY_COLUMNS` order | `com.urbandroid.sleep.alarmclock.AlarmColumns` | `<clinit>` |
| 3 | Alarm field defaults (`id=-1`, `legacyVibrate=true`, `nonDeepsleepWakeupWindow=-1`, `captcha=-1`, `suspendTime=-1`) | `Alarm` | `<init>()` |
| 4 | Cursor → field mapping + year>2050 clamp | `Alarm` | `<init>(Cursor)` |
| 5 | Parcel (de)serialisation incl. `BadParcelableException` fallback | `Alarm` | `<init>(Parcel)`, `writeToParcel` |
| 6 | `generic_extension` = serialised `AlarmExtendedConfig` | `Alarm` / `AlarmExtendedConfig` | `Alarm(Cursor)`, `AlarmExtendedConfig` fields |
| 7 | Column ↔ field write mapping | `Alarms` | `createContentValues(Context,Alarm,long,boolean)` |
| 8 | `AlarmColumns.ALARM_QUERY_COLUMNS` content | `AlarmColumns` | `<clinit>` |
| 9 | `setAlarmClock` used on API≥21 with status-bar icon | `Alarms` | `setAlarmClockCompat` |
| 10 | `setExactAndAllowWhileIdle` / `setExact` / `set` fallbacks | `Alarms` | `setAlarmCompat`; `com.urbandroid.util.AlarmManagerCompat` |
| 11 | App compat shim for exact alarms | `com.urbandroid.util.AlarmManagerCompat` | `setExactAndAllowWhileIdle`, `canScheduleExactAlarms` |
| 12 | Request code 72849, action `…ALARM_ALERT`, extra `intent.extra.alarm_raw` | `Alarms` | `enableAlert` |
| 13 | PendingIntent flags `0x0C000000` / `0x08000000` | `Alarms` | `getPendingIntentFlags`, `getPendingIntentFlagsLegacy` |
| 14 | `FLAG_IMMUTABLE` auto-added on API≥31 | `com.urbandroid.sleep.PendingIntentBuilder` | `<init>` |
| 15 | `SetAlarm` show-intent extras `alarm_id`, `set_time_extra` | `Alarms` | `setAlarmClockCompat` |
| 16 | Next-time computation with repeat + offset | `Alarms` | `calculateAlarm` (3 overloads) |
| 17 | Weekly bitmask `1<<i`, `DAY_MAP`, non-weekly "every N days" | `Alarm$DaysOfWeek` | `isSet`, `getNextAlarm`, `<clinit>` |
| 18 | Skip-next = `suspendTime` | `Alarms` | `isSkipped`, `setSkipNext`, `setSuspendTime` |
| 19 | Offset fields + validity | `Alarm` / `AlarmExtendedConfig` | `getOffset`, `getOffsetCalendar`, `addOffset`, `resetoffsetIfExpired` |
| 20 | Smart window default 30, max 120, nap 5 | `com.urbandroid.sleep.service.Settings` | `getSmartWakeupMinutes`, `getSmartWakeupNapMinutes`; `res/values/arrays.xml` |
| 21 | Allowed smart-window values incl. `59` (Power nap) | `res/values/arrays.xml` | `non_deep_sleep_window_values` |
| 22 | Per-alarm window override (`ndswakeupwindow`) | `Alarm` | `resolveSmartPeriod`, `nonDeepsleepWakeupWindow` |
| 23 | Early-fire condition (light sleep + target fulfilled + inside window) | `com.urbandroid.sleep.SleepService` / `SleepService$1` | `isInSmartPeriod` |
| 24 | Earliest wake time formula | `Alarm` | `getEarliesWakeTime(SleepRecord)` |
| 25 | `SetAlarmGentle` writes gradual volume / vibration / sound delay / watch vibration | `com.urbandroid.sleep.alarmclock.SetAlarmGentle` | `mapToAlarm` |
| 26 | Gradual ramp duration default 60 000 ms, threshold 30 000 ms | `Settings`, `Alarm` | `getGradualVolumeIncreaseDuration`, `isGradualVolumeIncrease`, `isFixedSystemVolume` |
| 27 | Allowed ramp durations 30 s … 24 min | `res/values/arrays.xml` | `alarm_increasing_volume_duration_values` |
| 28 | **Log curve `f = 1 − ln(100−v)/ln(100)`** | `com.urbandroid.sleep.alarmclock.volume.GentleAlarmRunnable` | `setVolume(int)` |
| 29 | Ramp tick = `increaseDuration / 100` ms, +1 unit/tick | `GentleAlarmRunnable` | `run()` |
| 30 | Gentle ramp keeps running at max after completion | `GentleAlarmRunnable` | `run()` (`currentVolume > 100` branch) |
| 31 | `ACTION_VOLUME_UPDATE` / `EXTRA_VOLUME` broadcast every 5 units | `GentleAlarmRunnable` | `run()` |
| 32 | System stream forced to max during gentle ramp | `GentleAlarmRunnable` | `setMaxVolume()` |
| 33 | Linear system-stream ramp, `reachedTargetVolume`, 5000 ms hold | `com.urbandroid.sleep.alarmclock.volume.VolumeControlRunnable` | `run()`, `setVolume`, `updateVolume` |
| 34 | Step = `increaseDuration / max(1, streamMaxVolume)` | `VolumeControlRunnable` | `convertIncreaseDurationToIncreaseSpeed` |
| 35 | Lullaby fade-out: 30 000 ms/step down to 0 then auto-stop | `com.urbandroid.sleep.alarmclock.volume.LullabyVolumeDown` | `update(boolean)`, `parseVolumeDownAfterPreferenceValue` |
| 36 | Lullaby default 900 000 ms, 90 min deep-sleep gate, 90 s pause | `LullabyVolumeDown` | `<init>`, `update` |
| 37 | Stream selection MUSIC vs ALARM | `com.urbandroid.sleep.alarmclock.AlarmKlaxon` | `startKlaxon` |
| 38 | AudioAttributes contentType=2, usage=1/4, legacy stream type | `AlarmKlaxon` | `setDataSource(Uri,boolean)`, `startAlarm` |
| 39 | Looping rules | `AlarmKlaxon` | `shouldPlayInLoop`, `startAlarm` |
| 40 | Alarm timeout 1200 s / siren 60 s, prefs `alarm_kill_time` / `siren_kill_time` | `AlarmKlaxon`, `Settings` | `onCreate`, `enableKillerOrSirena`, `enablePostSirenaKiller`, `getAlarmTimeout` |
| 41 | Handler messages 1000/1001/1002/1003 | `AlarmKlaxon$1` | `handleMessage` |
| 42 | Kill broadcast + `alarm_killed_timeout` | `AlarmKlaxon` | `sendKillBroadcast` |
| 43 | Auto-snooze after kill up to `alarm_kill_snooze_count` | `com.urbandroid.sleep.alarmclock.AlarmReceiver` | `onReceive` (`alarm_killed` branch) |
| 44 | Sirena ringtone forced onto STREAM_ALARM | `AlarmKlaxon` | `playSirena` |
| 45 | Notification channel ids + importance | `com.urbandroid.sleep.notification.NotificationsKt` | channel-creation block |
| 46 | Silent-mode / DND handling | `AlarmKlaxon` | `startKlaxon` |
| 47 | Power-save mode un-silences the alarm | `AlarmKlaxon` | `playInitialAlarm` |
| 48 | Dismiss gate order (captcha → dismiss) | `com.urbandroid.sleep.alarmclock.AlarmAlertFullScreen` | `dismissOrStartCaptcha`, `onCaptchaResult`, `handleCaptchaProvenDismissClick` |
| 49 | `UnlockFlow` is the paywall, not the alarm gate | `com.urbandroid.sleep.alarmclock.UnlockFlow` | `onCreate`, `onStart` |
| 50 | Wake-up check scheduled after dismiss | `Alarm` | `performDismiss` |
| 51 | Wake-up check registration (request code 3, `ALARM_WAKE_UP_CHECK`) | `Alarms` | `scheduleWakeUpCheck` |
| 52 | Snooze persistence + re-arm | `Alarms`, `Alarm` | `saveSnoozeAlert`, `getSnoozeAlarm`, `enableSnoozeAlert`, `performSnooze` |
| 53 | Snooze minutes / limits / halving | `Alarm` | `getSnoozeMinutes`, `maxSnoozeMinutes`, `isSnoozeEnabled` |
| 54 | Bedtime notification scheduling | `Alarms` | `scheduleTimeToBedBedtime`, `scheduleTimeToBed`, `scheduleTimeToBedAutoStart` |
| 55 | Smart-bedtime adjustment (tracking delay + 5-day deficit, cap 45 min) | `Alarms` | `enableAlert` (AsyncTask) |
| 56 | Bedtime notification + snooze 10 min | `com.urbandroid.sleep.alarmclock.BedtimeReceiver` | `onReceive`, `scheduleSnooze` |
| 57 | Direct-boot rescheduling + backup alarm intent (666) | `com.urbandroid.sleep.alarmclock.lockedboot.LockedBootReceiver` | `onReceive`, `getBackupAlarmIntent` |
| 58 | Backup alarm foreground service | `com.urbandroid.sleep.alarmclock.lockedboot.BackupAlarmService` | `onStartCommand` |
| 59 | Boot rescheduling | `com.urbandroid.sleep.alarmclock.AlarmInitReceiver` | `onReceive` |
| 60 | Power-nap = window value 59, ±59 min shift | `Alarm`, `Alarms` | `isPowerNap`, `fixPowerNap` |
| 61 | Jet-lag service does not touch AlarmManager | `com.urbandroid.sleep.jetlag.JetLagService` | `start`, `JetLagService$1` |
| 62 | Vibration pattern | `AlarmKlaxon` | `<clinit>` (`sVibratePattern`, `sVibratePatternResume`) |
| 63 | "Alarms only" mode flag | `Settings` | `isAlarmOnly` (pref `alarm_only`, default false) |
| 64 | Auto-start mode default 3 | `Settings` | `getAutoStartMode` |
| 65 | Auto-start scheduled at `alarm.time − (smartPeriod + 45) min` | `Alarms` | `enableAlert` |

### UNKNOWNs

* The exact `AlarmClockInfo.showIntent` target class for the normal alarm is `SetAlarm` (the alarm
  editor), verified from `setAlarmClockCompat`.
* `AppFunctionException.ERROR_RESOURCE_NOT_FOUND` == `1500` — used as the "fixed volume" ramp
  duration in `GentleAlarmRunnable`; the constant's numeric value was not independently confirmed
  (it is inferred from `const/16 v6, 0x5dc` in the smali, which *is* 1500 — confirmed).
* The `ringerModeChanged` flag is set but the code that restores `RINGER_MODE_SILENT` was not located.
* `ReplacedReceiver` body was not traced in detail.
* Whether the `alarm_kill_snooze_count` "backup alarm" uses `Alarm.performSnooze(..., autoKill=true)`
  exactly was inferred from `EventLabel.ALARM_SNOOZE_AFTER_KILL`.
* Jet-lag's interaction with the alarm **offset** fields is **INFERRED** (no direct call site found).
