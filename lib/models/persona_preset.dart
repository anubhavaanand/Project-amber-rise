import '../models/alarm.dart';

/// How much friction the morning routine adds.
///
/// This is the ADHD lever: it is a dial any persona can set, and the user can
/// change it independently of their persona. It is deliberately not a persona
/// of its own.
enum Friction {
  /// One tap to dismiss. No captcha by default, no streak pressure.
  low('low'),

  /// A captcha is required. Streaks are shown.
  normal('normal'),

  /// Multi-step challenge, anti-escape on, wake-up check on.
  high('high');

  const Friction(this.storageValue);

  /// Value persisted in the settings store.
  final String storageValue;

  static Friction fromStorage(Object? value) {
    for (final friction in Friction.values) {
      if (friction.storageValue == value) return friction;
    }
    return Friction.normal;
  }
}

/// A persona preset.
///
/// A preset is **data, never a branch**: selecting one writes its [defaults]
/// into the ordinary settings store exactly once, and from then on it only
/// influences mission ordering and copy tone. There is no `if (persona == ...)`
/// anywhere in the app.
///
/// Adding a new persona means adding an entry to [presets]; no core change.
class PersonaPreset {
  const PersonaPreset({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.icon,
    required this.friction,
    required this.defaults,
    required this.missionWeights,
  });

  /// Stable identifier, persisted in the settings store.
  final String id;

  /// Shown at onboarding.
  final String displayName;

  /// One line explaining who this is for.
  final String tagline;

  /// Emoji or asset key.
  final String icon;

  /// Default morning friction for this persona.
  final Friction friction;

  /// Setting key -> value, written once when the preset is selected.
  final Map<String, Object> defaults;

  /// Which missions are offered first, by relative weight.
  ///
  /// Missions absent from this map sort last. Weights are not a hard filter:
  /// every mission stays reachable from settings.
  final Map<MissionType, double> missionWeights;

  /// Missions ordered by descending weight, then by enum order for stability.
  List<MissionType> get orderedMissions {
    final missions = MissionType.values.toList();
    missions.sort((a, b) {
      final weightA = missionWeights[a] ?? 0;
      final weightB = missionWeights[b] ?? 0;
      if (weightA != weightB) return weightB.compareTo(weightA);
      return a.index.compareTo(b.index);
    });
    return missions;
  }
}

/// The built-in presets. All five ship; the user picks one at onboarding and
/// can change it later in Settings > Persona.
final List<PersonaPreset> presets = List.unmodifiable(const [
  PersonaPreset(
    id: 'student',
    displayName: 'Student',
    tagline: 'Survive exam season without wrecking your sleep.',
    icon: '🎓',
    friction: Friction.normal,
    defaults: {
      'bedtime_reminder': true,
      'bedtime_hour': 23,
      'bedtime_minute': 30,
      'sleep_goal_hours': 8.0,
      'auto_sleep_tracking': true,
      'gentle_wake_enabled': true,
      'gentle_wake_duration_seconds': 60,
      'smart_alarm_enabled': true,
      'smart_alarm_window_minutes': 30,
      'wake_up_check_enabled': false,
      'backup_alarm_enabled': false,
      'captcha_required': true,
      'max_snooze_count': 3,
    },
    missionWeights: {
      MissionType.math: 5,
      MissionType.typing: 4,
      MissionType.memory: 4,
      MissionType.shake: 2,
      MissionType.walking: 1,
    },
  ),
  PersonaPreset(
    id: 'worker',
    displayName: '9-to-6 worker',
    tagline: 'A fixed schedule you cannot move. Never oversleep on it.',
    icon: '💼',
    friction: Friction.high,
    defaults: {
      'bedtime_reminder': true,
      'bedtime_hour': 23,
      'bedtime_minute': 0,
      'sleep_goal_hours': 8.0,
      'auto_sleep_tracking': true,
      'gentle_wake_enabled': true,
      'gentle_wake_duration_seconds': 90,
      'smart_alarm_enabled': true,
      'smart_alarm_window_minutes': 30,
      'wake_up_check_enabled': true,
      'wake_up_check_delay_minutes': 10,
      'backup_alarm_enabled': true,
      'captcha_required': true,
      'max_snooze_count': 2,
    },
    missionWeights: {
      MissionType.math: 5,
      MissionType.barcode: 4,
      MissionType.shake: 4,
      MissionType.walking: 2,
    },
  ),
  PersonaPreset(
    id: 'heavy-sleeper',
    displayName: 'Heavy sleeper',
    tagline: 'You physically cannot stay in bed. So the app makes it hard.',
    icon: '😴',
    friction: Friction.high,
    defaults: {
      'bedtime_reminder': true,
      'bedtime_hour': 22,
      'bedtime_minute': 45,
      'sleep_goal_hours': 8.5,
      'auto_sleep_tracking': true,
      'gentle_wake_enabled': true,
      'gentle_wake_duration_seconds': 120,
      'smart_alarm_enabled': false,
      'wake_up_check_enabled': true,
      'wake_up_check_delay_minutes': 5,
      'backup_alarm_enabled': true,
      'captcha_required': true,
      'no_escape_enabled': true,
      'max_snooze_count': 1,
    },
    missionWeights: {
      MissionType.shake: 5,
      MissionType.barcode: 5,
      MissionType.walking: 4,
      MissionType.math: 3,
      MissionType.memory: 2,
    },
  ),
  PersonaPreset(
    id: 'shift-worker',
    displayName: 'Shift worker',
    tagline: 'Irregular hours, no fixed bedtime, still needs real sleep.',
    icon: '🌙',
    friction: Friction.low,
    defaults: {
      'bedtime_reminder': false,
      'sleep_goal_hours': 7.5,
      'auto_sleep_tracking': true,
      'gentle_wake_enabled': true,
      'gentle_wake_duration_seconds': 60,
      'smart_alarm_enabled': true,
      'smart_alarm_window_minutes': 20,
      'wake_up_check_enabled': false,
      'backup_alarm_enabled': false,
      'captcha_required': false,
      'max_snooze_count': 3,
    },
    missionWeights: {
      MissionType.typing: 5,
      MissionType.memory: 4,
      MissionType.math: 3,
      MissionType.walking: 2,
    },
  ),
  PersonaPreset(
    id: 'biohacker',
    displayName: 'Biohacker',
    tagline: 'You want the data, not just the alarm.',
    icon: '📊',
    friction: Friction.normal,
    defaults: {
      'bedtime_reminder': true,
      'bedtime_hour': 23,
      'bedtime_minute': 0,
      'sleep_goal_hours': 8.0,
      'auto_sleep_tracking': true,
      'full_tracking_enabled': true,
      'gentle_wake_enabled': true,
      'gentle_wake_duration_seconds': 60,
      'smart_alarm_enabled': true,
      'smart_alarm_window_minutes': 45,
      'wake_up_check_enabled': false,
      'backup_alarm_enabled': true,
      'captcha_required': true,
      'max_snooze_count': 2,
    },
    missionWeights: {
      MissionType.memory: 4,
      MissionType.typing: 4,
      MissionType.math: 4,
      MissionType.shake: 2,
    },
  ),
]);

/// Looks up a preset by id, falling back to the first preset.
PersonaPreset presetById(String? id) {
  if (id == null) return presets.first;
  for (final preset in presets) {
    if (preset.id == id) return preset;
  }
  return presets.first;
}