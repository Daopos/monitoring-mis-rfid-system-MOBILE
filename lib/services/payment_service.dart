import 'package:agl_heights_app/services/preference_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  // final String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';

  static const String baseUrl = 'https://agl-heights.online/api';

  Future<List<dynamic>> getVehicles() async {
    final String apiUrl = '$baseUrl/payment-reminders';

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
        throw Exception('${token}Failed to load payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching vehicles: $e');
    }
  }
}
