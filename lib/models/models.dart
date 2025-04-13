// Timetable Model with proper null safety and API matching
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
      id: json['id']?.toString() ?? '', // Handle null and conversion
      name: json['name']?.toString() ?? 'Unnamed Timetable', // Handle null
      days: (json['days'] as List<dynamic>? ?? []) // Handle null and type conversion
          .map((day) => day?.toString() ?? '') // Ensure each day is String
          .where((day) => day.isNotEmpty) // Filter out empty strings
          .toList(),
      isActive: json['is_active'] as bool? ?? false, // Handle null and different field name
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'days': days,
      // Note: We don't include id or isActive when sending to API
      // as your API handles these server-side
    };
  }
}

// Schedule Model with proper null safety
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
    this.bellType = 'shortbell', // Default value
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString(), // Handle null
      time: json['time']?.toString() ?? '', // Handle null
      days: (json['days'] as List<dynamic>? ?? []) // Handle null
          .map((day) => day?.toString() ?? '') // Ensure String
          .where((day) => day.isNotEmpty) // Filter empty
          .toList(),
      timetableId: json['timetable_id']?.toString() ?? '', // Handle null
      bellType: json['bell_type']?.toString() ?? 'shortbell', // Handle null with default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // Only include if not null
      'time': time,
      'days': days,
      'timetable_id': timetableId,
      'bell_type': bellType,
    };
  }
}