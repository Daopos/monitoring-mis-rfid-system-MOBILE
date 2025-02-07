// api_service.dart
import 'dart:convert';
import 'package:agl_heights_app/models/event.dart';
import 'package:http/http.dart' as http;

class EventService {
  // static const String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';
  static const String baseUrl = 'https://agl-heights.online/api';

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/all/event'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }
}
