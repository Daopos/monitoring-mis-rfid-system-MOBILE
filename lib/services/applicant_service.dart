import 'dart:convert';
import 'package:agl_heights_app/services/preference_service.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class ApplicantService {
  // static const String baseUrl = 'http://192.168.1.8:8000/api';
  static const String baseUrl = 'https://agl-heights.online/api';

  Future<void> createApplicant({
    required int homeownerId,
    required String mobilizationDate,
    required String completionDate,
    required String projectDescription,
    required String selection,
    required List<Map<String, dynamic>> neighbors,
  }) async {
    final token = await PreferenceService.getToken();

    final url = Uri.parse('$baseUrl/applicant/store');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // Include the token in the headers
    };
    final body = json.encode({
      'homeowner_id': homeownerId,
      'mobilization_date': mobilizationDate,
      'completion_date': completionDate,
      'project_description': projectDescription,
      'selection': selection,
      'neighbors': neighbors,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: 'Applicant created successfully!');
      } else {
        final errorResponse = json.decode(response.body);
        print(errorResponse);
        Fluttertoast.showToast(
          msg:
              'Error: ${errorResponse['message'] ?? 'Failed to create applicant'}',
        );
      }
    } catch (e) {
      print(e);

      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchNeighbors() async {
    final String apiUrl = '$baseUrl/neighbors';

    try {
      final token = await PreferenceService.getToken();

      print(token);
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) {
          return {
            'id': e['id'],
            'name': '${e['fname']} ${e['lname']}', // Combine fname and lname
          };
        }).toList();
      } else {
        throw Exception('Failed to load neighbors: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading neighbors: $e');
    }
  }

  static Future<Map<String, dynamic>> getApplicantsWithNeighbors() async {
    try {
      final token = await PreferenceService.getToken();
      // Get the token from PreferenceService

      // Define the endpoint for getting applicants with neighbors
      final String url = '$baseUrl/applicant/homeowner';

      // Send the request to the backend with the Authorization token
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse the response body into a Map
        return json.decode(response.body);
      } else {
        // If the request failed, return the error message
        return {
          'message': 'Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      // Handle any exceptions that may occur
      return {
        'message': 'Error: $e',
      };
    }
  }

  Future<void> deleteApplicant(int id) async {
    final String apiUrl = '$baseUrl/applicant/$id';
    final token = await PreferenceService.getToken();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to applicant: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while deleting applicant: $e');
    }
  }

  // Fetch application data by ID
  static Future<Map<String, dynamic>> fetchApplication(int id) async {
    final url = Uri.parse('$baseUrl/applicants/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch application data: ${response.body}');
    }
  }

  Future<void> updateApplicant({
    required int id,
    required String mobilizationDate,
    required String completionDate,
    required String projectDescription,
    required String selection,
    required List<Map<String, dynamic>> neighbors,
  }) async {
    final url = Uri.parse('$baseUrl/applicants/$id');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_TOKEN', // Add token if required
    };
    final body = jsonEncode({
      'mobilization_date': mobilizationDate,
      'completion_date': completionDate,
      'project_description': projectDescription,
      'selection': selection,
      'neighbors': neighbors,
    });
    print(id);

    print(body);
    final response = await http.put(url, headers: headers, body: body);

    // Print the response body when data is received
    print('Status code: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to update applicant: ${response.body}');
    }
  }
}
