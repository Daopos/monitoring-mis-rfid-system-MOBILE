import 'package:agl_heights_app/services/preference_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VisitorService {
  // static const String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';

  static const String baseUrl = 'https://agl-heights.online/api';

  Future<void> addVisitor({
    required String name,
    String? brand,
    String? color,
    String? model,
    String? plateNumber,
    String? rfid,
    String? relationship,
    String? dateVisit,
    List<Map<String, String>>? members, // List of members with names
  }) async {
    final String apiUrl =
        '$baseUrl/add/visitor'; // Correct endpoint for adding visitors

    // Get the token from preferences
    final token = await PreferenceService.getToken();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'brand': brand,
          'color': color,
          'model': model,
          'plate_number': plateNumber,
          'rfid': rfid,
          'relationship': relationship,
          'date_visit': dateVisit,
          'status': 'pending', // Assuming default status as 'pending'
          'members': members ?? [], // Ensure members are passed as an array
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add visitor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while adding visitor: $e');
    }
  }

  Future<List<dynamic>> getVisitors() async {
    final String apiUrl = '$baseUrl/visitors';

    // Get the token from preferences
    final token = await PreferenceService.getToken();

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response body into a list of vehicles
        return json.decode(response.body);
      } else {
        throw Exception('${token}Failed to load vehicles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching vehicles: $e');
    }
  }

  Future<void> updateVisitor(
    int id,
    String name,
    String? brand,
    String? color,
    String? model,
    String? plateNumber,
    String? rfid,
    String? relationship,
    String? dateVisit,
    String? status,
    List<Map<String, String>>? members,
  ) async {
    final String apiUrl =
        '$baseUrl/visitor/$id'; // Adjust URL to match the backend route
    final token = await PreferenceService.getToken();

    try {
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'name': name,
        'brand': brand,
        'color': color,
        'model': model,
        'plate_number': plateNumber,
        'rfid': rfid,
        'relationship': relationship,
        'date_visit': dateVisit,
        'status': status,
        'members': members ?? [], // Ensure members are passed as an array
      };

      // Remove null values from the request body
      requestBody.removeWhere((key, value) => value == null);

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update visitor: ${response.body}');
      }

      // After updating the visitor, handle the visitor group members update
      if (members != null) {
        // Make another API call or logic to update the visitor group members
        final visitorGroupUrl =
            '$baseUrl/visitor-group/$id'; // Adjust URL for visitor group

        // Prepare the request body for visitor group members update
        final visitorGroupRequestBody = {
          'members': members,
        };

        // Remove null values from the visitor group request body
        visitorGroupRequestBody.removeWhere((key, value) => value == null);

        final groupResponse = await http.put(
          Uri.parse(visitorGroupUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(visitorGroupRequestBody),
        );

        if (groupResponse.statusCode != 200) {
          throw Exception(
              'Failed to update visitor group: ${groupResponse.body}');
        }
      }
    } catch (e) {
      throw Exception('Error occurred while updating visitor: $e');
    }
  }

  Future<void> deleteVisitor(int id) async {
    final String apiUrl = '$baseUrl/visitor/$id';
    final token = await PreferenceService.getToken();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete visitor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while deleting visitor: $e');
    }
  }

  Future<void> approveVisitor(int id) async {
    final String apiUrl = '$baseUrl/visitor/approved/$id';
    final token = await PreferenceService.getToken();

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete visitor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while deleting visitor: $e');
    }
  }

  Future<void> rejectVisitor(int id, String reason) async {
    final String apiUrl = '$baseUrl/visitor/denied/$id';
    final token = await PreferenceService.getToken();

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'reason': reason}));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete visitor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while deleting visitor: $e');
    }
  }
}
