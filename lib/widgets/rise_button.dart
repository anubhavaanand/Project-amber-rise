import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rise's button.
///
/// Deliberately not a Material default: a capsule with a soft press animation
/// so it feels physical rather than like a rectangle that changes colour.
///
/// Three weights, because a screen should never offer two equally loud choices:
///   [RiseButton.primary]   filled amber, the one thing to do
///   [RiseButton.secondary] outlined, a real alternative
///   [RiseButton.ghost]     text only, an escape hatch
class RiseButton extends StatefulWidget {
  const RiseButton._({
    super.key,
    required this.label,
    required this.weight,
    this.icon,
    this.onPressed,
    this.expand = false,
  });

  /// The one thing to do on the screen.
  factory RiseButton.primary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool expand = false,
  }) =>
      RiseButton._(
        key: key,
        label: label,
        icon: icon,
        onPressed: onPressed,
        expand: expand,
        weight: _Weight.primary,
      );

  /// A real alternative, but not the main action.
  factory RiseButton.secondary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool expand = false,
  }) =>
      RiseButton._(
        key: key,
        label: label,
        icon: icon,
        onPressed: onPressed,
        expand: expand,
        weight: _Weight.secondary,
      );

  /// An escape hatch: cancel, skip, back.
  factory RiseButton.ghost({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool expand = false,
  }) =>
      RiseButton._(
        key: key,
        label: label,
        icon: icon,
        onPressed: onPressed,
        expand: expand,
        weight: _Weight.ghost,
      );

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;
  final _Weight weight;

  @override
  State<RiseButton> createState() => _RiseButtonState();
}

enum _Weight { primary, secondary, ghost }

class _RiseButtonState extends State<RiseButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final pressed = _pressed && enabled;

    // Press feedback: a small scale, 100ms. Micro tier.
    final scale = pressed ? 0.97 : 1.0;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            height: 52,
            padding: EdgeInsets.symmetric(
              horizontal: widget.weight == _Weight.ghost ? 14 : 22,
            ),
            decoration: _decoration(enabled, pressed),
            child: Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 19, color: _foreground(enabled)),
                  const SizedBox(width: 9),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: _foreground(enabled),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration(bool enabled, bool pressed) {
    final base = BorderRadius.circular(26); // capsule

    switch (widget.weight) {
      case _Weight.primary:
        return BoxDecoration(
          borderRadius: base,
          color: !enabled
              ? AppColors.surfaceHigh
              : pressed
                  ? AppColors.primary.withValues(alpha: 0.82)
                  : AppColors.primary,
        );
      case _Weight.secondary:
        return BoxDecoration(
          borderRadius: base,
          color: pressed
              ? AppColors.onSurfaceGhost
              : Colors.transparent,
          border: Border.all(
            color: enabled ? AppColors.outline : AppColors.outline,
            width: 1.5,
          ),
        );
      case _Weight.ghost:
        return BoxDecoration(
          borderRadius: base,
          color: pressed ? AppColors.onSurfaceGhost : Colors.transparent,
        );
    }
  }

  Color _foreground(bool enabled) {
    if (!enabled) return AppColors.onSurfaceGhost;
    switch (widget.weight) {
      case _Weight.primary:
        return AppColors.onPrimary;
      case _Weight.secondary:
      case _Weight.ghost:
        return AppColors.onSurface;
    }
  }
}