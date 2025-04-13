// Timetable Model
class Timetable {
  final String id;
  final String name;
  final List<String> days;
  final bool isActive;

  Timetable({
    required this.id,
    required this.name,
    required this.days,
    this.isActive = false,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'] as String,
      name: json['name'] as String,
      days: List<String>.from(json['days']),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'days': days,
    };
  }
}

// Schedule Model
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
    required this.bellType,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      time: json['time'] as String,
      days: List<String>.from(json['days']),
      timetableId: json['timetable_id'] as String,
      bellType: json['bell_type'] as String? ?? 'shortbell',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'days': days,
      'timetable_id': timetableId,
      'bell_type': bellType,
    };
  }
}