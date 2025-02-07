import 'dart:convert';
import 'package:agl_heights_app/services/preference_service.dart';
import 'package:http/http.dart' as http;

class HouseholdService {
  // final String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';

  static const String baseUrl = 'https://agl-heights.online/api';

  Future<String?> getToken() async {
    return await PreferenceService.getToken();
  }

  // Get all household members for the authenticated user
  Future<List<Map<String, dynamic>>> getHouseholdMembers() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/households'), // Endpoint to get all members
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data
          .cast<Map<String, dynamic>>(); // Return list of household members
    } else {
      throw Exception('Failed to load household members');
    }
  }

  Future<void> createHouseholdMember({
    required String name,
    required String relationship,
    required DateTime birthdate, // Updated from int age to DateTime birthdate
    required String gender,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/households'), // Endpoint to create new member
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'relationship': relationship,
        'birthdate':
            birthdate.toIso8601String(), // Convert DateTime to ISO 8601 format
        'gender': gender,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> successData = json.decode(response.body);
      // Return success response
      return successData['data'];
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception('${errorData['message']}');
    }
  }

  // Delete a household member by ID
  Future<void> deleteHouseholdMember(int memberId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse(
          '$baseUrl/households/$memberId'), // Endpoint to delete member by ID
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> successData = json.decode(response.body);
      // Return success message
      return successData['message'];
    } else {
      throw Exception('Failed to delete household member');
    }
  }

  // Update an existing household member
  Future<void> updateHouseholdMember(
    int memberId,
    String name,
    String relationship,
    DateTime birthdate, // Updated from int age to DateTime birthdate
    String gender,
  ) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse(
          '$baseUrl/households/$memberId'), // Endpoint to update member by ID
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'relationship': relationship,
        'birthdate':
            birthdate.toIso8601String(), // Convert DateTime to ISO 8601 format
        'gender': gender,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> successData = json.decode(response.body);
      // Return updated data
      return successData['data'];
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(
          'Failed to update household member: ${errorData['message']}');
    }
  }
}
