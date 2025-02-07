import 'dart:convert';
import 'package:agl_heights_app/services/preference_service.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = 'https://agl-heights.online/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';
  // static const String baseUrl = 'http://192.168.1.8:8000/api';

  static Future<List<dynamic>> fetchNotifications() async {
    try {
      // Retrieve the auth token from shared preferences
      final token = await PreferenceService.getToken();

      // Make the API request to fetch notifications
      final response = await http.get(
        Uri.parse('$baseUrl/homeowner/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse and return the notifications
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to fetch notifications.");
      }
    } catch (e) {
      throw Exception("Error fetching notifications: $e");
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      final token = await PreferenceService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/homeowner/notifications/delete/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true; // Successfully deleted
      } else {
        throw Exception("Failed to delete notification.");
      }
    } catch (e) {
      throw Exception("Error deleting notification: $e");
    }
  }

  static Future<void> markNotificationsAsRead(List<int> notificationIds) async {
    final String apiUrl =
        '$baseUrl/homeowner/notifications/seen'; // Update with your API URL

    final token = await PreferenceService.getToken();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include token in the header
        },
        body: json.encode({
          'notification_ids':
              notificationIds, // Send notification IDs in the request body
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to mark notifications as read: ${response.body}');
      }

      print('Notifications marked as read');
    } catch (e) {
      throw Exception('Error occurred while marking notifications as read: $e');
    }
  }
}
