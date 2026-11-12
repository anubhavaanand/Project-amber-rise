import 'package:shared_preferences/shared_preferences.dart';

import '../models/persona_preset.dart';

/// Applies persona presets to the settings store.
///
/// A preset is applied **once**, when the user selects it. After that the user's
/// own settings win: [applyPreset] is never called again unless the user
/// explicitly re-selects a preset.
class PresetService {
  static const String _presetIdKey = 'persona_preset_id';
  static const String _presetAppliedKey = 'persona_preset_applied';
  static const String _frictionKey = 'friction';

  /// The id of the currently selected preset, or null if none was chosen.
  static Future<String?> activePresetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_presetIdKey);
  }

  /// The currently selected preset, falling back to the first preset.
  static Future<PersonaPreset> activePreset() async {
    return presetById(await activePresetId());
  }

  /// The morning friction dial. Defaults to the active preset's friction.
  static Future<Friction> friction() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_frictionKey);
    if (stored != null) return Friction.fromStorage(stored);
    return (await activePreset()).friction;
  }

  /// Sets the friction dial independently of the persona.
  static Future<void> setFriction(Friction friction) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_frictionKey, friction.storageValue);
  }

  /// Writes the preset's defaults into the settings store.
  ///
  /// Existing user values are overwritten: this is an explicit user action
  /// (selecting a preset), not a silent refresh.
  static Future<void> applyPreset(PersonaPreset preset) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in preset.defaults.entries) {
      final value = entry.value;
      if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is double) {
        await prefs.setDouble(entry.key, value);
      } else if (value is String) {
        await prefs.setString(entry.key, value);
      }
    }

    await prefs.setString(_presetIdKey, preset.id);
    await prefs.setString(_frictionKey, preset.friction.storageValue);
    await prefs.setBool(_presetAppliedKey, true);
  }

  /// Whether a preset has ever been applied. Used to decide whether onboarding
  /// should ask the user to pick one.
  static Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_presetAppliedKey) ?? false;
  }
}