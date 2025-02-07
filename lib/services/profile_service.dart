import 'dart:convert';
import 'package:agl_heights_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'preference_service.dart'; // Make sure to import your PreferenceService
import 'dart:io';

class ProfileService {
  // final String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';

  static const String baseUrl = 'https://agl-heights.online/api';

  Future<User?> fetchUserProfile() async {
    final String apiUrl = '$baseUrl/home-owner/profile';
    try {
      String? token = await PreferenceService
          .getToken(); // Get the token from PreferenceService

      if (token == null) {
        throw Exception('No token found'); // Handle case where token is missing
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Include the token
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        return User.fromJson(data); // Return the User object
      } else {
        // Handle error response
        throw Exception('Failed to load profile: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // Future<bool> updateUserProfile(User user) async {
  //   final String apiUrl = '$baseUrl/home-owner/profile';

  //   try {
  //     String? token = await PreferenceService
  //         .getToken(); // Get the token from PreferenceService

  //     if (token == null) {
  //       throw Exception('No token found'); // Handle case where token is missing
  //     }

  //     final response = await http.put(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Authorization': 'Bearer $token', // Include the token
  //         'Content-Type': 'application/json', // Specify content type
  //       },
  //       body: json.encode(user.toJson()), // Convert User object to JSON
  //     );

  //     if (response.statusCode == 200) {
  //       return true; // Indicate success
  //     } else {

  //       // Handle error response
  //       throw Exception('Failed to update profile: ${response.reasonPhrase}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error updating profile: $e');
  //   }
  // }

  Future<bool> updateUserProfile(User user) async {
    final String apiUrl = '$baseUrl/home-owner/profile'; // API endpoint

    try {
      String? token = await PreferenceService
          .getToken(); // Get the token from PreferenceService

      if (token == null) {
        throw Exception('No token found'); // Handle case where token is missing
      }

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $token' // Include the token
        ..fields['_method'] =
            'PUT' // Indicate that this should be treated as a PUT request
        ..fields['fname'] = user.fname
        ..fields['lname'] = user.lname
        ..fields['email'] = user.email
        ..fields['phone'] = user.phone
        ..fields['birthdate'] = user.birthdate
        ..fields['gender'] = user.gender
        ..fields['phase'] = user.phase
        ..fields['block'] = user.block
        ..fields['lot'] = user.lot
        ..fields['status'] = user.status ?? ''
        ..fields['position'] = user.position ?? ''
        ..fields['mname'] = user.mname ?? ''
        ..fields['extension'] = user.extension ?? '';

      // Add the image file if it exists
      if (user.image != null) {
        var imageFile = File(user.image!);
        var image = await http.MultipartFile.fromPath('image', imageFile.path);
        request.files.add(image);
      }

      // Send the request
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        return true; // Indicate success
      } else {
        var responseBody = await response.stream.bytesToString();
        print('Failed to update profile. Response body: $responseBody');
        throw Exception('Failed to update profile: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
