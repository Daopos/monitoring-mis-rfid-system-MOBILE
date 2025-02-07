import 'package:agl_heights_app/services/vehicle_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  late Future<List<dynamic>> _vehicles;
  final ImagePicker _picker = ImagePicker();
  File? _vehicleImage;
  File? _orImage;
  File? _crImage;

  // Controllers for the input fields
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _orNumberController = TextEditingController();
  final TextEditingController _crNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vehicles = VehicleService().getVehicles(); // Fetch vehicles from API
  }

  void _refreshVehicles() {
    setState(() {
      _vehicles = VehicleService().getVehicles();
    });
  }

  void _deleteVehicle(int id) {
    VehicleService().deleteVehicle(id).then((_) {
      setState(() {
        _vehicles = VehicleService().getVehicles();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (imageType == 'vehicle') {
          _vehicleImage = File(pickedFile.path);
        } else if (imageType == 'or') {
          _orImage = File(pickedFile.path);
        } else if (imageType == 'cr') {
          _crImage = File(pickedFile.path);
        }
      });
    }
  }

  // Function to show the images in a dialog when the eye icon is clicked
  void _showImagesDialog(String vehicleImg, String orImg, String crImg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vehicle Images'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            vehicleImg.isNotEmpty
                ? Image.network(
                    vehicleImg,
                    height: 100, // Set the height of the image
                    width: 100, // Set the width of the image
                    fit: BoxFit
                        .cover, // Optionally, use BoxFit to control how the image scales
                  )
                : const Text('No vehicle image available'),
            const SizedBox(height: 10),
            orImg.isNotEmpty
                ? Image.network(
                    orImg,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : const Text('No OR image available'),
            const SizedBox(height: 10),
            crImg.isNotEmpty
                ? Image.network(
                    crImg,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : const Text('No CR image available'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(
      String label, File? file, String type, String? imageUrl) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        // Show a checkmark if the image file is selected or image URL is provided
        if (file != null || (imageUrl != null && imageUrl.isNotEmpty))
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
        TextButton(
          onPressed: () {
            // Open the gallery to select an image
            _pickImage(ImageSource.gallery, type);
          },
          child: Text(file == null && (imageUrl == null || imageUrl.isEmpty)
              ? 'Choose'
              : 'Replace'), // Update text to replace if an image exists
        ),
      ],
    );
  }

  void _editVehicle(
    int id,
    String brand,
    String color,
    String model,
    String plateNumber,
    String orNumber,
    String crNumber, {
    String? vehicleImg,
    String? orImg,
    String? crImg,
  }) {
    _brandController.text = brand;
    _colorController.text = color;
    _modelController.text = model;
    _plateNumberController.text = plateNumber;

    // Initialize OR and CR number fields
    _orNumberController.text = orNumber;
    _crNumberController.text = crNumber;

    // Reset image files
    _vehicleImage = null;
    _orImage = null;
    _crImage = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Vehicle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: _plateNumberController,
                decoration: const InputDecoration(labelText: 'Plate Number'),
              ),
              TextField(
                controller: _orNumberController,
                decoration: const InputDecoration(labelText: 'OR Number'),
              ),
              TextField(
                controller: _crNumberController,
                decoration: const InputDecoration(labelText: 'CR Number'),
              ),

              // Image pickers for vehicle, OR, and CR images
              _buildImagePicker(
                  'Vehicle Image', _vehicleImage, 'vehicle', vehicleImg),
              _buildImagePicker('OR Image', _orImage, 'or', orImg),
              _buildImagePicker('CR Image', _crImage, 'cr', crImg),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              VehicleService()
                  .updateVehicle(
                id,
                _brandController.text,
                _colorController.text,
                _modelController.text,
                _plateNumberController.text,
                _orNumberController.text,
                _crNumberController.text,
                _vehicleImage,
                _orImage,
                _crImage,
              )
                  .then((_) {
                setState(() {
                  _vehicles = VehicleService().getVehicles();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Vehicle updated successfully')));
              }).catchError((error) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $error')));
              });
            },
            child: const Text('Save'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true,
        title: const Text(
          "Vehicle Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _vehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vehicles found.'));
          } else {
            final vehicles = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVehicleDetail(
                                "Car type", vehicle['car_type']),
                            _buildVehicleDetail("Brand", vehicle['brand']),
                            _buildVehicleDetail("Color", vehicle['color']),
                            _buildVehicleDetail("Model", vehicle['model']),
                            _buildVehicleDetail(
                                "Plate Number", vehicle['plate_number']),
                            _buildVehicleDetail(
                                "O.R Number", vehicle['or_number']),
                            _buildVehicleDetail(
                                "C.R Number", vehicle['cr_number']),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: PopupMenuButton<int>(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.black),
                            onSelected: (value) {
                              switch (value) {
                                case 0: // Edit Vehicle
                                  _editVehicle(
                                    vehicle['id'],
                                    vehicle['brand'],
                                    vehicle['color'],
                                    vehicle['model'],
                                    vehicle['plate_number'],
                                    vehicle['or_number'],
                                    vehicle['cr_number'],
                                  );
                                  break;
                                case 1: // Delete Vehicle
                                  _deleteVehicle(vehicle['id']);
                                  break;
                                case 2: // View Images
                                  _showImagesDialog(
                                    vehicle['vehicle_img'],
                                    vehicle['or_img'],
                                    vehicle['cr_img'],
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<int>(
                                value: 0,
                                child: Text('Edit Vehicle'),
                              ),
                              const PopupMenuItem<int>(
                                value: 1,
                                child: Text('Delete Vehicle'),
                              ),
                              const PopupMenuItem<int>(
                                value: 2,
                                child: Text('View Images'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add/vehicle');
          if (result == true) {
            _refreshVehicles();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Vehicle',
      ),
    );
  }

  Widget _buildVehicleDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value ?? "N/A",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
