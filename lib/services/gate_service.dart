import 'dart:convert';

import 'package:agl_heights_app/services/preference_service.dart';
import 'package:http/http.dart' as http;

class GateService {
  // final String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';

  static const String baseUrl = 'https://agl-heights.online/api';

  Future<List<dynamic>> getGate() async {
    final String apiUrl = '$baseUrl/all/entry';

    // Get the token from preferences
    final token = await PreferenceService.getToken();

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token in the headers
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print(data);
        return json.decode(response.body); // Return the list of messages
      } else {
        throw Exception('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching messages: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOfficers() async {
    final String apiUrl = '$baseUrl/officers/all';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load officers');
      }
    } catch (e) {
      throw Exception('Error fetching officers: $e');
    }
  }
}
