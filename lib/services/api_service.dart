import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timetable_manager/models/models.dart';

class ApiService {
  static const String baseUrl = 'https://bell-backend-c07af688258c.herokuapp.com/api';

  // Fetch all timetables
  Future<List<Timetable>> fetchTimetables() async {
    final response = await http.get(Uri.parse('$baseUrl/timetables'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Timetable.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load timetables');
    }
  }

  // Fetch schedules, optionally filtered by timetable ID
  Future<List<Schedule>> fetchSchedules({String? timetableId}) async {
    final url = timetableId != null 
        ? '$baseUrl/schedules?timetable_id=$timetableId'
        : '$baseUrl/schedules';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Schedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  // Add a new timetable
  Future<Timetable> addTimetable(Timetable timetable) async {
    final response = await http.post(
      Uri.parse('$baseUrl/timetables'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(timetable.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Timetable.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to add timetable');
    }
  }

  // Add a new schedule
  Future<Schedule> addSchedule(Schedule schedule) async {
    final response = await http.post(
      Uri.parse('$baseUrl/schedules'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(schedule.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Schedule.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to add schedule');
    }
  }

  // Delete a timetable
  Future<void> deleteTimetable(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/timetables/$id'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete timetable');
    }
  }

  // Delete a schedule
  Future<void> deleteSchedule(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/schedules/$id'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete schedule');
    }
  }

  // Set a timetable as active
  Future<void> setActiveTimetable(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/timetables/$id/set-active'),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to set active timetable');
    }
  }
}