import 'package:flutter/material.dart';

class TimeUtils {
  /// Converts a TimeOfDay to a "HH:mm" string format (24-hour clock).
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Converts a "HH:mm" string back to TimeOfDay.
  static TimeOfDay parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
