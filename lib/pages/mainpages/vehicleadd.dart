import 'dart:io';
import 'package:agl_heights_app/services/vehicle_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final TextEditingController brandController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController orNumberController =
      TextEditingController(); // New
  final TextEditingController crNumberController =
      TextEditingController(); // New
  final TextEditingController carTypeController =
      TextEditingController(); // New

  final VehicleService vehicleService = VehicleService();
  final _formKey = GlobalKey<FormState>();

  File? vehicleImage;
  File? orImage;
  File? crImage;

  final ImagePicker _picker = ImagePicker();

  // List of car types for the dropdown
  final List<String> carTypes = [
    'Sedan',
    'SUV',
    'Truck',
    'Van',
    'Motorcycle',
  ];

  Future<void> _pickImage(ImageSource source, String type) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (type == 'vehicle') {
          vehicleImage = File(pickedFile.path);
        } else if (type == 'or') {
          orImage = File(pickedFile.path);
        } else if (type == 'cr') {
          crImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final String brand = brandController.text;
      final String color = colorController.text;
      final String model = modelController.text;
      final String plateNumber = plateNumberController.text;
      final String orNumber = orNumberController.text; // New
      final String crNumber = crNumberController.text; // New
      final String carType = carTypeController.text; // New

      if (vehicleImage == null || orImage == null || crImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All images are required')),
        );
        return; // Prevent submission if any image is missing
      }

      try {
        await vehicleService.addVehicle(
          brand: brand,
          color: color,
          model: model,
          plateNumber: plateNumber,
          or_number: orNumber, // New
          cr_number: crNumber, // New
          car_type: carType, // New
          vehicleImage: vehicleImage,
          orImage: orImage,
          crImage: crImage,
        );
        Navigator.pop(context, true); // Signal success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true,
        title: const Text(
          "Add Vehicle",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Car Type',
                ),
                value: carTypeController.text.isEmpty
                    ? null
                    : carTypeController.text,
                onChanged: (value) {
                  setState(() {
                    carTypeController.text = value!;
                  });
                },
                items: carTypes.map((String carType) {
                  return DropdownMenuItem<String>(
                    value: carType,
                    child: Text(carType),
                  );
                }).toList(),
                validator: (value) => value == null || value.isEmpty
                    ? 'Car Type is required'
                    : null,
              ),
              // Text fields for brand, color, model, and plate number
              TextFormField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Brand is required' : null,
              ),
              TextFormField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Color is required' : null,
              ),
              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Model is required' : null,
              ),
              TextFormField(
                controller: plateNumberController,
                decoration: const InputDecoration(labelText: 'Plate Number'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Plate Number is required'
                    : null,
              ),
              TextFormField(
                controller: orNumberController,
                decoration:
                    const InputDecoration(labelText: 'OR Number'), // New
                validator: (value) => value == null || value.isEmpty
                    ? 'OR Number is required'
                    : null,
              ),
              TextFormField(
                controller: crNumberController,
                decoration:
                    const InputDecoration(labelText: 'CR Number'), // New
                validator: (value) => value == null || value.isEmpty
                    ? 'CR Number is required'
                    : null,
              ),
              const SizedBox(height: 20),

              // Car Type Dropdown

              const SizedBox(height: 20),

              // Image pickers
              _buildImagePicker(
                  'Upload Vehicle Image', vehicleImage, 'vehicle'),
              const SizedBox(height: 10),
              _buildImagePicker('Upload OR Image', orImage, 'or'),
              const SizedBox(height: 10),
              _buildImagePicker('Upload CR Image', crImage, 'cr'),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _saveVehicle,
                  child: const Text("Save Vehicle"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, File? file, String type) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        if (file != null)
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
        TextButton(
          onPressed: () => _pickImage(ImageSource.gallery, type),
          child: Text(file == null ? 'Choose' : 'Replace'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    brandController.dispose();
    colorController.dispose();
    modelController.dispose();
    plateNumberController.dispose();
    orNumberController.dispose(); // Dispose of new controller
    crNumberController.dispose(); // Dispose of new controller
    carTypeController.dispose(); // Dispose of car type controller
    super.dispose();
  }
}
