// models.dart

/// Timetable Model with proper null safety and API matching
class Timetable {
  final String id;
  final String name;
  final List<String> days;
  bool isActive;

  Timetable({
    required this.id,
    required this.name,
    required this.days,
    this.isActive = false,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Timetable',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((day) => day?.toString() ?? '')
          .where((day) => day.isNotEmpty)
          .toList(),
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'days': days,
      // 'id' and 'isActive' are typically managed server-side and not sent when creating/updating
    };
  }
}

/// Schedule Model with proper null safety and API mapping
class Schedule {
  final String? id;
  final String time;
  final List<String> days;
  final String timetableId;
  final String bellType;

  Schedule({
    this.id,
    required this.time,
    required this.days,
    required this.timetableId,
    this.bellType = 'shortbell',
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString(),
      time: json['time']?.toString() ?? '',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((day) => day?.toString() ?? '')
          .where((day) => day.isNotEmpty)
          .toList(),
      timetableId: json['timetable_id']?.toString() ?? '',
      bellType: json['bell_type']?.toString() ?? 'shortbell',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'time': time,
      'days': days,
      'timetable_id': timetableId,
      'bell_type': bellType,
    };
  }
}
