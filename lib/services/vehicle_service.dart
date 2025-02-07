import 'package:http/http.dart' as http;
import 'dart:convert';
import 'preference_service.dart';
import 'dart:io';

class VehicleService {
  // static const String baseUrl = 'http://192.168.1.8:8000/api';
  // static const String baseUrl = 'http://192.168.5.157:8000/api';

  static const String baseUrl = 'https://agl-heights.online/api';

  Future<void> addVehicle({
    String? brand,
    String? color,
    String? model,
    String? plateNumber,
    String? or_number,
    String? cr_number,
    String? car_type,
    File? vehicleImage, // New parameter for vehicle image
    File? orImage, // New parameter for OR image
    File? crImage, // New parameter for CR image
  }) async {
    final String apiUrl = '$baseUrl/vehicles';

    // Get the token from preferences
    final token = await PreferenceService.getToken();

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['brand'] = brand ?? ''
        ..fields['car_type'] = brand ?? ''
        ..fields['color'] = color ?? ''
        ..fields['model'] = model ?? ''
        ..fields['or_number'] = or_number ?? ''
        ..fields['cr_number'] = cr_number ?? ''
        ..fields['plate_number'] = plateNumber ?? '';

      // Add files if they are provided
      if (vehicleImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'vehicle_img',
          vehicleImage.path,
        ));
      }
      if (orImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'or_img',
          orImage.path,
        ));
      }
      if (crImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cr_img',
          crImage.path,
        ));
      }

      // Send the request
      final response = await request.send();

      if (response.statusCode != 201) {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to add vehicle: $responseBody');
      }
    } catch (e) {
      throw Exception('Error occurred while adding vehicle: $e');
    }
  }

  // Method to get the vehicles of the authenticated homeowner
  Future<List<dynamic>> getVehicles() async {
    final String apiUrl = '$baseUrl/vehicle';

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

  Future<void> updateVehicle(
    int id,
    String brand,
    String color,
    String model,
    String or_number,
    String cr_number,
    String plateNumber,
    File? vehicleImage, // Optional parameter for vehicle image
    File? orImage, // Optional parameter for OR image
    File? crImage, // Optional parameter for CR image
  ) async {
    final String apiUrl = '$baseUrl/vehicle/$id';
    final token = await PreferenceService.getToken();

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['_method'] =
            'PUT' // Indicate that this should be treated as a PUT request
        ..fields['brand'] = brand
        ..fields['color'] = color
        ..fields['model'] = model
        ..fields['or_number'] = or_number
        ..fields['cr_number'] = cr_number
        ..fields['plate_number'] = plateNumber;

      print("Request fields: ${request.fields}");

      // Add files if they are provided
      if (vehicleImage != null) {
        print("Adding vehicle image: ${vehicleImage.path}");
        request.files.add(await http.MultipartFile.fromPath(
          'vehicle_img',
          vehicleImage.path,
        ));
      }
      if (orImage != null) {
        print("Adding OR image: ${orImage.path}");
        request.files.add(await http.MultipartFile.fromPath(
          'or_img',
          orImage.path,
        ));
      }
      if (crImage != null) {
        print("Adding CR image: ${crImage.path}");
        request.files.add(await http.MultipartFile.fromPath(
          'cr_img',
          crImage.path,
        ));
      }

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        // Parse responseBody to retrieve updated vehicle data if needed
        final updatedVehicle = json.decode(responseBody);

        print("Updated Vehicle: $updatedVehicle");
      } else {
        final responseBody = await response.stream.bytesToString();
        // Log the error response for debugging
        print("Error response: $responseBody");
        throw Exception('Failed to update vehicle: $responseBody');
      }
    } catch (e) {
      // Catch any errors and print them for debugging
      print("Error occurred: $e");
      throw Exception('Error occurred while updating vehicle: $e');
    }
  }

  Future<void> deleteVehicle(int id) async {
    final String apiUrl = '$baseUrl/vehicles/$id';
    final token = await PreferenceService.getToken();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete vehicle: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while deleting vehicle: $e');
    }
  }
}
