import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timetable_manager/models/models.dart';

class ApiService {
  static const String baseUrl = 'https://bell-backend-c07af688258c.herokuapp.com/api';

  // Fetch all timetables - Modified to handle null safety
  Future<List<Timetable>> fetchTimetables() async {
    final response = await http.get(Uri.parse('$baseUrl/timetables'));
    
    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Timetable.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Failed to parse timetables: $e');
      }
    } else {
      throw Exception('Failed to load timetables. Status code: ${response.statusCode}');
    }
  }

  // Add a new timetable - Modified to handle your API's expected format
  Future<Timetable> addTimetable(Timetable timetable) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/timetables'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': timetable.name,
          'days': timetable.days,
          // Note: is_active is handled by the API, no need to send it
        }),
      );
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Your API returns {"message": "...", "id": "..."} on success
        return Timetable(
          id: responseData['id']?.toString() ?? '',
          name: timetable.name,
          days: timetable.days,
          isActive: false, // New timetables are not active by default
        );
      } else {
        // Try to parse error message if possible
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to add timetable');
        } catch (jsonError) {
          // If response isn't valid JSON
          throw Exception('Failed to add timetable: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Failed to add timetable: $e');
    }
  }

  // Update an existing timetable - With improved error handling
  Future<Timetable> updateTimetable(Timetable timetable) async {
    try {
      // Print debug info
      
      final response = await http.put(
        Uri.parse('$baseUrl/timetables/${timetable.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': timetable.name,
          'days': timetable.days,
        }),
      );

      // Debug output for response

      if (response.statusCode == 200) {
        try {
          return Timetable.fromJson(json.decode(response.body));
        } catch (parseError) {
          throw Exception('Error parsing server response: $parseError');
        }
      } else {
        // Safely handle error - don't assume JSON response
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to update timetable');
        } catch (jsonError) {
          // If response isn't valid JSON
          throw Exception('Server returned status code ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error updating timetable: $e');
    }
  }

  // Delete a timetable - With improved error handling
  Future<void> deleteTimetable(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/timetables/$id'));
      
      if (response.statusCode != 200) {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to delete timetable');
        } catch (jsonError) {
          throw Exception('Failed to delete timetable: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error deleting timetable: $e');
    }
  }

  // Set a timetable as active - With improved error handling
  Future<void> setActiveTimetable(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/timetables/$id/set-active'),
      );
      
      if (response.statusCode != 200) {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to set active timetable'); 
        } catch (jsonError) {
          throw Exception('Failed to set active timetable: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error setting active timetable: $e');
    }
  }

  // Keep all other functions exactly the same as they were
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

  Future<void> deleteSchedule(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/schedules/$id'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete schedule');
    }
  }
}

// Helper function for string length safety
int min(int a, int b) {
  return (a < b) ? a : b;
}