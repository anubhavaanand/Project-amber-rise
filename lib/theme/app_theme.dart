import 'package:flutter/material.dart';

/// Rise's colour system.
///
/// The surface and text tokens are measured from the reference implementation
/// (Sleep as Android 20261016), then pushed deeper toward black as the brief
/// asked. The accent is our own — amber, taken from the launcher icon — so the
/// app and its icon read as one object. Teal is reserved for sleep data, where
/// it separates the hypnogram from the interface.
///
/// Token provenance is noted per group so the origin of each value is auditable.
class AppColors {
  AppColors._();

  // ── Surfaces ───────────────────────────────────────────────────────────────
  // Reference dark window background is #263238; pushed much deeper here while
  // keeping its faint blue-grey cast.
  static const background = Color(0xFF070A0E); // near-black
  static const surface = Color(0xFF0E1319); // cards, sheets
  static const surfaceHigh = Color(0xFF161D25); // inputs, switches, chips
  static const surfaceHighest = Color(0xFF1E262E);
  static const outline = Color(0xFF232C36); // hairlines

  // ── Accent: brand ─────────────────────────────────────────────────────────
  // Our own, from the launcher icon (sun #FFB347).
  static const primary = Color(0xFFFFB347);
  static const onPrimary = Color(0xFF1A1206);
  static const primaryContainer = Color(0xFF3A2A12);
  static const onPrimaryContainer = Color(0xFFFFD9A0);

  // ── Accent: data ──────────────────────────────────────────────────────────
  // Reference sleep-phase hues, used only for sleep data.
  static const teal = Color(0xFF4DB6AC); // reference rem_sleep
  static const tealLight = Color(0xFF80CBC4); // reference light_sleep
  static const tealPale = Color(0xFFB2DFDB); // reference awake

  static const error = Color(0xFFFF5C5C);

  // ── Text ramp ─────────────────────────────────────────────────────────────
  // Reference uses exactly these four alphas of white (white, white_secondary,
  // white_tertiary, white_quaternary) = 100/70/33/12%.
  static const onSurface = Color(0xFFFFFFFF);
  static const onSurfaceVariant = Color(0xB2FFFFFF);
  static const onSurfaceFaint = Color(0x54FFFFFF);
  static const onSurfaceGhost = Color(0x1EFFFFFF);

  // ── Sleep phases (hypnogram) ──────────────────────────────────────────────
  // Reference: deep #E5E5E5, light #80CBC4, rem #4DB6AC, awake #B2DFDB.
  static const phaseDeep = Color(0xFFE5E5E5);
  static const phaseLight = tealLight;
  static const phaseRem = teal;
  static const phaseAwake = tealPale;

  // ── Alternate phase palette (reference theme variant) ─────────────────────
  // The reference app ships more than one graph palette. This is its
  // olive/lime variant, recorded for completeness: deep #5A713C,
  // light #799B33, awake #A6D725, actigraph #7FA31D. Not used yet; it needs a
  // contrast check against our dark surfaces before it could be a user option.
  static const altPhaseDeep = Color(0xFF5A713C);
  static const altPhaseLight = Color(0xFF799B33);
  static const altPhaseAwake = Color(0xFFA6D725);

  // ── Shape ─────────────────────────────────────────────────────────────────
  // Reference card_corner is 24dp, button_radius 8dp, activity margin 16dp.
  static const radiusCard = 24.0;
  static const radiusButton = 8.0;
  static const radiusSheet = 28.0;
  static const gutter = 16.0;
}

/// Replaces the weight on a style with an explicit variable-font axis.
///
/// Inter is a variable font; setting `fontWeight` alone does not move the
/// `wght` axis, so the axis is set explicitly.
TextStyle _w(TextStyle? base, double weight) {
  final style = base ?? const TextStyle();
  return style.copyWith(
    fontWeight: FontWeight.values.firstWhere(
      (w) => w.value == weight,
      orElse: () => FontWeight.w400,
    ),
    fontVariations: [FontVariation('wght', weight)],
  );
}

/// Rise is dark-first. A light theme is deliberately absent: a half-built one
/// would look worse than none, and the deep-black palette is the product.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
  );

  final colorScheme = const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.teal,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceHigh,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    error: AppColors.error,
    onError: AppColors.onPrimary,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    // Inter is bundled as an asset (assets/fonts/Inter.ttf), not fetched at
    // runtime. GoogleFonts downloaded it on first launch and swapped it in,
    // which caused a visible reflow and needed network on a cold start.
    textTheme: base.textTheme
        .apply(
          fontFamily: 'Inter',
          bodyColor: AppColors.onSurface,
          displayColor: AppColors.onSurface,
        )
        .copyWith(
          displayLarge: _w(base.textTheme.displayLarge, 700),
          displayMedium: _w(base.textTheme.displayMedium, 600),
          displaySmall: _w(base.textTheme.displaySmall, 600),
          headlineMedium: _w(base.textTheme.headlineMedium, 600),
          headlineSmall: _w(base.textTheme.headlineSmall, 600),
          titleLarge: _w(base.textTheme.titleLarge, 600),
          titleMedium: _w(base.textTheme.titleMedium, 600),
          titleSmall: _w(base.textTheme.titleSmall, 600),
          bodyLarge: _w(base.textTheme.bodyLarge, 400),
          bodyMedium: _w(base.textTheme.bodyMedium, 400),
          bodySmall: _w(base.textTheme.bodySmall, 400),
          labelLarge: _w(base.textTheme.labelLarge, 600),
          labelMedium: _w(base.textTheme.labelMedium, 500),
          labelSmall: _w(base.textTheme.labelSmall, 600),
        ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: AppColors.onSurfaceVariant),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        side: const BorderSide(color: AppColors.outline, width: 1),
      ),
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.onSurfaceVariant,
      textColor: AppColors.onSurface,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: 0.14),
      elevation: 0,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
        );
      }),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
        return AppColors.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.surfaceHigh;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.outline;
      }),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusButton),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusButton),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHigh,
      hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppColors.radiusSheet)),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppColors.radiusSheet),
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
      space: 1,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceHigh,
      circularTrackColor: AppColors.surfaceHigh,
    ),

    splashFactory: InkSparkle.splashFactory,
  );
}