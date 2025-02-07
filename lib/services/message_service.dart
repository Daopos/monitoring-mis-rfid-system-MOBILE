import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agl_heights_app/services/preference_service.dart'; // Adjust the import path if necessary

class MessageService {
  // final String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';

  static const String baseUrl = 'https://agl-heights.online/api';

  // Function to send a message
  Future<void> sendMessage(String message, String recipientRole) async {
    final String apiUrl = '$baseUrl/home-owner/message';

    // Get the token from preferences
    final token = await PreferenceService.getToken();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token in the headers
        },
        body: json.encode({
          'message': message,
          'recipient_role': recipientRole,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while sending message: $e');
    }
  }

  // Function to get messages
  Future<List<dynamic>> getMessages() async {
    final String apiUrl = '$baseUrl/home-owner/message';

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

  Future<void> sendMessageGuard(String message, String recipientRole) async {
    final String apiUrl = '$baseUrl/home-owner/message/guard';

    // Get the token from preferences
    final token = await PreferenceService.getToken();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the token in the headers
        },
        body: json.encode({
          'message': message,
          'recipient_role': recipientRole,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while sending message: $e');
    }
  }

  // Function to get messages
  Future<List<dynamic>> getMessagesGuard() async {
    final String apiUrl = '$baseUrl/home-owner/message/guard';

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

  Future<void> markAsSeen(int messageId) async {
    final token = await PreferenceService.getToken();

    final url = Uri.parse('$baseUrl/messages/mark-as-seen');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'message_id': messageId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark message as seen');
    }
  }
}
