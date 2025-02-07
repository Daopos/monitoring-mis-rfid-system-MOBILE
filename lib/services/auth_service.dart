// lib/services/auth_service.dart

import 'dart:io';
import 'package:agl_heights_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'preference_service.dart'; // Import the preference service
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  // static const String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';
  static const String baseUrl = 'https://agl-heights.online/api';

  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/home-owner/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user'] != null) {
          User user = User.fromJson(data['user']);
          String token = data['token'];

          // print(user.toJson());
          print(token);

          // Save the token using PreferenceService
          await PreferenceService.saveToken(token);
          await PreferenceService.saveUser(user);
          return true;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  // Method to send data to the backend, including file upload

  Future<http.Response> registerUser(User user,
      {File? imageFile, File? documentFile}) async {
    final uri = Uri.parse('$baseUrl/home-owner/register');

    var request = http.MultipartRequest('POST', uri);

    // Attach the user data as fields
    request.fields['email'] = user.email;
    request.fields['password'] = user.password ?? '';
    request.fields['fname'] = user.fname;
    request.fields['lname'] = user.lname;
    request.fields['phone'] = user.phone;
    request.fields['birthdate'] = user.birthdate;
    request.fields['gender'] = user.gender;
    request.fields['phase'] = user.phase;
    request.fields['block'] = user.block;
    request.fields['lot'] = user.lot;

    // Attach optional fields
    if (user.plate != null) request.fields['plate'] = user.plate!;
    if (user.extension != null) request.fields['extension'] = user.extension!;
    if (user.mname != null) request.fields['mname'] = user.mname!;

    // Attach image file
    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    // Attach document file
    if (documentFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('document', documentFile.path));
    }

    // Send the request
    try {
      final response = await request.send();
      return await http.Response.fromStream(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> logout() async {
    print('test'); // Initial test print

    final url = Uri.parse('$baseUrl/home-owner/logout');
    print('test');

    try {
      // Await the token properly
      final token = await PreferenceService.getToken();
      print('test $token'); // Print the token to check its value

      if (token == null || token.isEmpty) {
        print('No token found, unable to log out.');
        return false;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Set token here
        },
      );

      // Debug the response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Clear user data on logout
        await PreferenceService.clearUser();
        await PreferenceService.clearToken();
        return true;
      } else {
        print('Failed to log out. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  static Future<http.StreamedResponse> registerHomeOwner({
    required String email,
    required String password,
    required String fname,
    required String lname,
    required String phone,
    required String birthdate,
    required String gender,
    required String phase,
    required String block,
    required String lot,
    File? profileImage,
    required File documentImage,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/home-owner/register'),
    );

    // Add text fields
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['fname'] = fname;
    request.fields['lname'] = lname;
    request.fields['phone'] = phone;
    request.fields['birthdate'] = birthdate;
    request.fields['gender'] = gender;
    request.fields['phase'] = phase;
    request.fields['block'] = block;
    request.fields['lot'] = lot;

    // Attach images
    request.files.add(
      await http.MultipartFile.fromPath('document_image', documentImage.path),
    );
    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', profileImage.path),
      );
    }

    return await request.send();
  }

  static Future<bool> sendResetLink(String email) async {
    final url = Uri.parse('$baseUrl/password/email');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<void> downloadPdf() async {
    try {
      // API endpoint to download the single PDF
      final url = '$baseUrl/pdfs/download';

      // Use Dio to download the file
      Dio dio = Dio();
      Response response = await dio.get(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      // Get the directory to save the file
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/downloaded_pdf.pdf';

      // Open the file for writing
      File file = File(filePath);
      await file.writeAsBytes(await response.data.stream.toBytes());

      print('PDF downloaded to $filePath');
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }
}
