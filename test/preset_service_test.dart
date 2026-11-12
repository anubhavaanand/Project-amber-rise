import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rise/models/alarm.dart';
import 'package:rise/models/persona_preset.dart';
import 'package:rise/services/preset_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('presets', () {
    test('ships all five personas', () {
      expect(presets.map((p) => p.id).toSet(), {
        'student',
        'worker',
        'heavy-sleeper',
        'shift-worker',
        'biohacker',
      });
    });

    test('every preset has a unique id and a tagline', () {
      final ids = presets.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final preset in presets) {
        expect(preset.tagline, isNotEmpty);
        expect(preset.displayName, isNotEmpty);
      }
    });

    test('presetById falls back to the first preset for unknown ids', () {
      expect(presetById('nope').id, presets.first.id);
      expect(presetById(null).id, presets.first.id);
      expect(presetById('biohacker').id, 'biohacker');
    });

    test('mission ordering puts weighted missions first', () {
      final ordered = presetById('heavy-sleeper').orderedMissions;
      // shake and barcode both weigh 5; shake wins the tie by enum order.
      expect(ordered.first, MissionType.shake);
      expect(ordered[1], MissionType.barcode);
      // Unweighted missions (squat, photo, typing) sort last in enum order.
      expect(ordered.last, MissionType.typing);
      expect(ordered.sublist(5), [MissionType.squat, MissionType.photo, MissionType.typing]);
    });

    test('every preset only references real missions', () {
      final valid = MissionType.values.toSet();
      for (final preset in presets) {
        for (final mission in preset.missionWeights.keys) {
          expect(valid.contains(mission), isTrue,
              reason: '${preset.id} references unknown mission $mission');
        }
      }
    });

    test('every preset only sets known setting keys', () {
      const known = {
        'bedtime_reminder',
        'bedtime_hour',
        'bedtime_minute',
        'sleep_goal_hours',
        'auto_sleep_tracking',
        'full_tracking_enabled',
        'gentle_wake_enabled',
        'gentle_wake_duration_seconds',
        'smart_alarm_enabled',
        'smart_alarm_window_minutes',
        'wake_up_check_enabled',
        'wake_up_check_delay_minutes',
        'backup_alarm_enabled',
        'captcha_required',
        'no_escape_enabled',
        'max_snooze_count',
      };
      for (final preset in presets) {
        for (final key in preset.defaults.keys) {
          expect(known.contains(key), isTrue,
              reason: '${preset.id} sets unknown key "$key"');
        }
      }
    });

    test('friction values round-trip through storage', () {
      for (final friction in Friction.values) {
        expect(Friction.fromStorage(friction.storageValue), friction);
      }
      expect(Friction.fromStorage('garbage'), Friction.normal);
      expect(Friction.fromStorage(null), Friction.normal);
    });

    test('heavy sleeper is the highest-friction preset', () {
      expect(presetById('heavy-sleeper').friction, Friction.high);
      expect(presetById('shift-worker').friction, Friction.low);
    });
  });

  group('PresetService', () {
    test('isConfigured is false before a preset is applied', () async {
      expect(await PresetService.isConfigured(), isFalse);
    });

    test('applyPreset writes every default and marks it configured', () async {
      const preset = PersonaPreset(
        id: 'student',
        displayName: 'Student',
        tagline: 'test',
        icon: '🎓',
        friction: Friction.normal,
        defaults: {
          'smart_alarm_enabled': true,
          'smart_alarm_window_minutes': 30,
          'sleep_goal_hours': 8.0,
        },
        missionWeights: {},
      );

      await PresetService.applyPreset(preset);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('smart_alarm_enabled'), isTrue);
      expect(prefs.getInt('smart_alarm_window_minutes'), 30);
      expect(prefs.getDouble('sleep_goal_hours'), 8.0);
      expect(await PresetService.isConfigured(), isTrue);
      expect(await PresetService.activePresetId(), 'student');
      expect((await PresetService.activePreset()).id, 'student');
      expect(await PresetService.friction(), Friction.normal);
    });

    test('the friction dial is independent of the persona', () async {
      const preset = PersonaPreset(
        id: 'worker',
        displayName: 'Worker',
        tagline: 'test',
        icon: '💼',
        friction: Friction.high,
        defaults: {},
        missionWeights: {},
      );

      await PresetService.applyPreset(preset);
      expect(await PresetService.friction(), Friction.high);

      await PresetService.setFriction(Friction.low);
      expect(await PresetService.friction(), Friction.low);
      // Persona is unchanged.
      expect(await PresetService.activePresetId(), 'worker');
    });

    test('selecting a second preset overwrites the first', () async {
      await PresetService.applyPreset(presetById('student'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('wake_up_check_enabled'), isFalse);

      await PresetService.applyPreset(presetById('worker'));
      expect(prefs.getBool('wake_up_check_enabled'), isTrue);
      expect(await PresetService.activePresetId(), 'worker');
    });

    test('a preset never touches unrelated keys', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_custom_note', 'keep me');

      await PresetService.applyPreset(presetById('student'));

      expect(prefs.getString('user_custom_note'), 'keep me');
    });
  });
}