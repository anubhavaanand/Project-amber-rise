import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'rise_button.dart';

/// An Apple-style scroll-wheel time picker, in Rise's dark palette.
///
/// Uses Flutter's Cupertino wheel (the same interaction as iOS's clock), wrapped
/// in a bottom sheet with a plain Cancel/Done header. Nothing here is Apple
/// artwork or layout - it is a stock Flutter widget in our own colours.
///
/// Returns the picked time, or null if the user cancelled.
Future<TimeOfDay?> showRiseTimePicker(
  BuildContext context, {
  required TimeOfDay initial,
  String title = 'Alarm time',
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      var selected = initial;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // Grab handle.
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      RiseButton.ghost(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      RiseButton.primary(
                        label: 'Done',
                        onPressed: () => Navigator.of(context).pop(selected),
                      ),
                    ],
                  ),
                ),
                // The wheel. Fixed height so it does not jump.
                SizedBox(
                  height: 216,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.dark,
                      primaryColor: AppColors.primary,
                      scaffoldBackgroundColor: AppColors.surface,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      showTimeSeparator: true,
                      backgroundColor: AppColors.surface,
                      initialDateTime: DateTime(
                        2020,
                        1,
                        1,
                        initial.hour,
                        initial.minute,
                      ),
                      onDateTimeChanged: (value) {
                        selected = TimeOfDay(hour: value.hour, minute: value.minute);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}