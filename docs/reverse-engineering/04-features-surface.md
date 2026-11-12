# Feature Surface — Sleep as Android 20261016

Source: `com.urbandroid.sleep` v20261016 (versionCode 2311729), SHA-256 `e1dc93bf...`
Evidence: decoded AndroidManifest.xml, res/values/strings.xml (1948 entries), res/xml/*.xml (42 preference screens).

## 1. Component map

| Kind | Count | Notable |
|---|---|---|
| Activities | 145 | 16 CAPTCHA activities, 42 settings screens, 4 app widgets, 12 dashboard/preview |
| Services | 53 | SleepService, AlarmKlaxon, LullabyService, AutomationService, 12 JobService workers |
| BroadcastReceivers | 48 | AlarmReceiver, BedtimeReceiver, StartTrackReceiver, ApneaReceiver, SnoringReceiver, HrReceiver, LucidReceiver, AutoStartTrackReceiver, LockedBootReceiver |
| ContentProviders | 10 | AlarmProvider, DbContentProvider, StatsContentProvider, PreferenceContentProvider, ExportContentProvider |

## 2. Settings screens (code-driven navigation, XML = nav only)

Every leaf preference is constructed in Kotlin (`alarmclock.settings.*Activity`); `res/xml/settings_*.xml`
only declares the category tree. Screenshot: 42 XML screens -> 30 Kotlin Settings activities.

### `alarm_prefs.xml`
- Categories: Wake up, App settings
- Keys: `settings_category_next_alarm`, `settings_category_alarm_ringtone`, `feedback`, `global_preference`

### `alarm_prefs_bedtime.xml`
- Keys: `timeline_segment_bedtime`, `timeline_bedtime`, `timeline_segment_sleep`, `timeline_segment_wake_up`, `timeline_alarm`, `timeline_segment4`

### `alarm_prefs_gentle.xml`
- Categories: Vibration
- Keys: `settings_category_vibe`

### `settings_alarm.xml`
- Keys: `alarm_default_settings_expl`, `settings_category_ringtone`, `settings_category_smart`, `settings_category_captcha`, `ringtone_pref_single`, `settings_category_snooze`, `settings_siren_category`

### `settings_automation.xml`
- Categories: Tasker, IFTTT, Webhooks, MQTT, Intent API
- Keys: `automation_doc`, `webhooks_url`, `mqtt_server_url`, `mqtt_topic`, `mqtt_client_id`, `mqtt_test`, `intent_api_read_more`

### `settings_awake.xml`
- Categories: Pause tracking
- Keys: `settings_category_awake`, `settings_category_pause`

### `settings_backup_alarm.xml`
- Keys: `settings_siren_category`, `siren_ringtone`

### `settings_bedtime.xml`
- Categories: Sleep, Advanced, Notification ringtone
- Keys: `bedtime_expl`, `settings_category_bedtime`, `timeline_segment_bedtime`, `timeline_bedtime`, `timeline_segment_sleep`, `timeline_segment_wake_up`, `timeline_alarm`, `settings_category_advanced`, `settings_category_no_alarm_bedtime`, `settings_category_time_to_bed_notification`, `time_to_bed_ringtone`, `time_to_bed_channel`

### `settings_bedtime_no_alarm.xml`
- Keys: `bedtime_expl`, `settings_category_wake_up_check`, `no_alarm_bedtime_1`, `no_alarm_bedtime_2`, `no_alarm_bedtime_3`, `no_alarm_bedtime_4`, `no_alarm_bedtime_5`, `no_alarm_bedtime_6`, `no_alarm_bedtime_0`

### `settings_captcha.xml`
- Categories: CAPTCHA No cheating
- Keys: `settings_category_captcha`, `capctha_expl`, `captcha_mode`, `captcha_config`, `settings_category_no_cheating`, `settings_category_alarm_avoid`, `settings_category_wake_up_check`

### `settings_captcha_cheating.xml`
- Keys: `settings_category_alarm_avoid`, `alarm_avoid_tip`, `nfc_warning`

### `settings_captcha_wake_up_check.xml`
- Keys: `settings_category_wake_up_check`, `capctha_expl`, `notification_channel`

### `settings_gentle.xml`
- Categories: Vibration, Light
- Keys: `settings_category_gentle`, `settings_category_vibe`, `settings_category_smartlight`, `settings_category_smartlight_link`

### `settings_google_calendar.xml`
- Keys: `google_calendar_account`

### `settings_jetlag.xml`
- Categories: Add-ons
- Keys: `settings_category_jetlag`, `jetlag_tutorial`, `settings_category_purchase`, `smartlight_mask_purchase`, `smartlight_phaser_purchase`

### `settings_lucid.xml`
- Keys: `settings_category_lucid`, `lucid_expl`, `lucid_preview`, `lucid_ringtone`

### `settings_lucid_without_sensitivity.xml`
- Keys: `settings_category_lucid`, `lucid_expl`, `lucid_preview`, `lucid_ringtone`

### `settings_lullaby.xml`
- Categories: Playlist, Turn off, Play
- Keys: `lullabies_expl`, `settings_category_lullaby`, `lullaby_preview`, `lullaby_addon`, `settings_category_playlist`, `settings_category_turnoff`, `settings_category_play`, `key_meditation_session`, `key_voice_setup`, `key_meditation_install_rate`, `mindroid`

### `settings_misc.xml`
- Categories: Localization, Alarms
- Keys: `settings_category_misc`, `settings_category_stats`, `settings_category_privacy`, `settings_entry_tune_tabs`, `settings_category_morning_screen`, `key_voice_setup`, `settings_category_localization`, `settings_category_alarm_misc`

### `settings_misc_30.xml`
- Categories: Localization, Alarms
- Keys: `settings_category_misc`, `settings_category_stats`, `settings_category_privacy`, `settings_entry_tune_tabs`, `settings_category_morning_screen`, `key_voice_setup`, `settings_category_localization`, `settings_category_alarm_misc`

### `settings_morning_screen.xml`
- Categories: Rating
- Keys: `settings_category_stats`, `settings_category_rate`

### `settings_noise.xml`
- Categories: Recording
- Keys: `settings_category_noise_master_switch`, `noise_expl`, `snoring_category`, `sound_recognition`, `snoring_ringtone`, `antisnoring_preview`, `settings_category_noise`, `noise_storage_path`, `noise_storage_lollipop_path`

### `settings_noise_old.xml`
- Categories: Sound recognition
- Keys: `settings_category_noise_master_switch`, `noise_expl`, `settings_category_noise`, `snoring_category`, `snoring_ringtone`, `antisnoring_preview`, `noise_storage_path`, `noise_storage_lollipop_path`

### `settings_pair.xml`
- Keys: `pair_expl`, `settings_category_pair_tracking`, `pair_tracking_token`, `pair_tracking_read_more`

### `settings_privacy.xml`
- Categories: Analytics, Ads, Location
- Keys: `privacy_policy_summary`, `settings_category_main`, `privacy_policy`, `terms`, `settings_ads`, `settings_ads`, `ads_opt_out`, `gdpr_consent`, `ad_inspector`, `ads_settings`, `sleepcloud`, `backup_storage_path`, `restore_settings`, `settings_category_location`, `reset_home`

### `settings_service.xml`
- Categories: Experimental
- Keys: `services_expl`, `settings_category_services`, `settings_category_smartlight`, `settings_category_backup_local`, `settings_category_backup`, `settings_category_social`, `settings_category_automation`, `settings_category_support`, `services_sync_now`, `settings_category_services`, `settings_google_home_automation`

### `settings_service_google_home.xml`
- Keys: `settings_category_google_home_enabled`, `settings_category_google_home_automation`, `settings_google_home_automation_bedtime`, `settings_google_home_automation_alarm`, `settings_google_home_automation_wake_up`

### `settings_simple.xml`
- Keys: `settings_expl`, `settings_category_sleep`, `settings_category_alarm`, `settings_category_track`, `settings_category_noise`, `settings_category_services`, `settings_category_addons`, `settings_category_misc`

### `settings_simple_alarm_only.xml`
- Keys: `settings_expl`, `settings_category_sleep`, `settings_category_alarm`, `settings_category_services`, `settings_category_addons`, `settings_category_misc`

### `settings_sleepsync.xml`
- Keys: `sleepsync_account`, `terms`, `open_browser`

### `settings_smart.xml`
- Keys: `smart_expl`, `settings_category_smart`

### `settings_smartlight.xml`
- Categories: Google Home, Smartlight, Phone
- Keys: `settings_category_smartlight`, `smartlight_hue`, `smartlight_test`, `smartlight_off`, `settings_category_google_home`, `settings_google_home_smartlight_select`, `sleep_phaser_connect`, `sleep_phaser_purchase`, `sleep_mask_bt_connect`, `smartlight_mask_purchase`

### `settings_smartwatch.xml`
- Categories: Vibrate
- Keys: `smartwatch_expl`, `settings_category_smartwatch`, `selected_wearable`, `vibe`, `oximeter_read_more_2`, `hr_alarm_ringtone`, `apnea_alarm_ringtone`

### `settings_snooze.xml`
- Keys: `settings_category_snooze`

### `settings_social.xml`
- Categories: Sharing service
- Keys: `settings_category_social`, `share_twitter`

### `settings_sound_recognition.xml`
- Keys: `settings_category_noise_master_switch`

### `settings_stats.xml`
- Categories: Sleep score, Graphs
- Keys: `settings_category_stats`, `settings_category_score`, `key_measure_order`, `settings_category_graphs`

### `settings_track.xml`
- Keys: `track_expl`, `settings_category_track`, `settings_category_awake`, `settings_category_automagic`, `selected_wearable`, `settings_category_pair_tracking`, `tutorial`, `settings_category_lullaby`, `settings_category_lucid`, `settings_category_jetlag`

### `settings_track_29.xml`
- Keys: `track_expl`, `settings_category_track`, `settings_category_awake`, `settings_category_automagic`, `selected_wearable`, `settings_category_pair_tracking`, `tutorial`, `settings_category_lullaby`, `settings_category_lucid`, `settings_category_jetlag`

### `settings_track_auto.xml`
- Keys: `settings_category_auto_start`

## 3. Permission surface (target vs. this project)

Target requests 82 permissions. This project's manifest declares 13.

| Capability | Target permission | Present in wake_me_up_pro |
|---|---|---|
| Exact alarms | `SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM` | yes |
| Wake lock | `WAKE_LOCK` | yes |
| Boot reschedule | `RECEIVE_BOOT_COMPLETED` | yes |
| Foreground service | `FOREGROUND_SERVICE (+mediaPlayback, microphone, health, systemExempted, connectedDevice, dataSync, shortService)` | partial (mediaPlayback only) |
| Full-screen intent | `USE_FULL_SCREEN_INTENT` | yes |
| Overlay | `SYSTEM_ALERT_WINDOW` | yes |
| Keyguard disable | `DISABLE_KEYGUARD` | yes |
| Camera | `CAMERA` | yes |
| Notifications | `POST_NOTIFICATIONS` | yes |
| Vibrate | `VIBRATE` | yes |
| Microphone (snore/lullaby/record) | `RECORD_AUDIO` | NO |
| Body sensors (HR) | `BODY_SENSORS` | NO |
| High-freq sensors | `HIGH_SAMPLING_RATE_SENSORS` | NO |
| Activity recognition | `ACTIVITY_RECOGNITION + com.google.android.gms` | NO |
| Bluetooth (wearables/BT Smart) | `BLUETOOTH_SCAN/CONNECT/ADVERTISE` | NO |
| BLE scan | `NEARBY_WIFI_DEVICES` | NO |
| NFC (NFC captcha) | `NFC` | NO |
| Location | `ACCESS_FINE_LOCATION` | NO |
| Health Connect | `health.* (sleep/HR/SpO2)` | NO |
| S Health | `via Samsung service` | NO |
| Storage / media | `READ_MEDIA_AUDIO, READ/WRITE_EXTERNAL_STORAGE` | NO |
| Device admin (no-escape) | `BIND_DEVICE_ADMIN receiver` | NO |
| Accessibility (anti-cheat lock) | `BIND_ACCESSIBILITY_SERVICE` | NO |
| Phone state | `READ_PHONE_STATE / READ_BASIC_PHONE_STATE` | NO |
| Play billing | `com.android.vending.BILLING` | NO |
| App Actions | `androidx.appfunctions service` | NO |
| Wake lock / shortcut | `GET_TASKS` | NO |

## 4. Feature inventory (from strings.xml — every user-visible feature name)

### 4.1 Alarms
- Regular alarm, **bedtime alarm** (wake across the night), **backup alarm** (fires after main alarm times out),
  **nap alarm**, **jet-lag alarm**, **No-Alarm bedtime**, **time-to-bed notification**
- Per-alarm: name, repeat days, skip-next, offset/advance, vibe, ringtone, volume, orientation lock,
  fullscreen, silent-mode override, delete-after-ringing, smart wake-up, gentle volume, captcha
- Global: default alarm settings, backup alarm settings, snooze settings, alarm timeout, alarm sorting,
  alarms-only mode, alarm output (music/natural wake), morning screen, morning briefing

### 4.2 Smart wake-up
- `smart`, `smart_alarm`, `feature_wake_up_in_light_sleep`, `settings_category_smart`
- `alarm_increasing_volume_title` (Gentle volume) + `alarm_increasing_volume_duration_summary`
- `alarm_kill_time_summary` (Alarm timeout), `alarm_sound_delay`, `alarm_sound_delay_after_snooze`
- `alarm_offset_title` (Adjust next time), `alarm_with_flashlight_title` (Flashlight wake up)

### 4.3 Sleep tracking
- Actigraph graph, smart wake-up, awake detection (incl. 'Awake when using phone'), automatic sleep tracking,
  delayed sleep tracking ('typical fall asleep delay'), pair tracking, sensor batching ('Battery optimized'),
  force screen-off tracking, sonar tracking (contactless), light level detection, sound recognition,
  anti-snoring, sleep talk recording, snoring statistics, room noise statistics

### 4.4 Health signals
- Heart rate + HRV (before/after/gain), apnea detection, low heart-rate alarm, low breath-rate alarm (SpO2),
  oximeter, blood oxygen, chronotype, social jetlag, sleep regularity index, sleep debt (deficit),
  sleep score, sleep irregularity, RDI

### 4.5 Captcha (17)
Dream diary, Smile (say cheese), Barcode/QR, Simple math, Typed math, NFC tag, Zombie walk,
Let there be light, Wake the droid, Maze, Agent sheep, Memoji, Shake it, Sleeping sheep,
Awake the sleeping sheep, Laugh Out Loud, Flags — plus difficulty, 'no cheating' protection, wake-up check

### 4.6 Integrations
Google Fit, Health Connect, Samsung Health, Google Calendar, Spotify, Philips Hue smartlight,
Sleep Phaser, Sleep Mask, Garmin, Pebble, Wear OS, Fitbit, Zepp/Amazfit, Mi Band, Polar, OnePlus,
Tasker, Automate, IFTTT, webhooks, MQTT, Home Assistant, Alexa/Google Assistant App Actions,
Smartwatch heart-rate streaming, SleepCloud/SleepSync

### 4.7 Stats & extras
Sleep score, charts/trends, chronotype trend, debt chart, deep-sleep trend, irregularity, social jetlag,
snoring chart, wake-up hour, goal tracking (deposit refund mechanic), achievements, tags, ratings,
morning briefing, AI assistant (score/today/trends briefs), auto sleep tracking, lunar/sun calculations
