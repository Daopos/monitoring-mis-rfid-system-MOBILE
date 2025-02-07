import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:agl_heights_app/services/household_service.dart'; // Assuming you have this service

class AddHouseholdPage extends StatefulWidget {
  const AddHouseholdPage({super.key});

  @override
  State<AddHouseholdPage> createState() => _AddHouseholdPageState();
}

class _AddHouseholdPageState extends State<AddHouseholdPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  String? _selectedRelationship;
  String? _selectedGender;
  DateTime? _selectedBirthdate;
  bool _isLoading = false; // Track the loading state

  final List<String> _relationships = [
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Grandfather',
    'Grandmother',
    'Cousin',
    'Niece',
    'Uncle',
    'Aunt',
    'Husband',
    'Wife',
    'Other',
  ];

  final List<String> _genders = ['Female', 'Male', 'Other'];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading to true when submitting
      });

      try {
        await HouseholdService().createHouseholdMember(
          name: _nameController.text,
          relationship: _selectedRelationship!,
          birthdate: _selectedBirthdate!,
          gender: _selectedGender!,
        );
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Household member added successfully!')),
        );
      } catch (e) {
        String errorMessage = e.toString();

        // Remove "Exception:" if it is part of the message
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage
              .substring(11); // Remove the first 11 characters ("Exception: ")
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false; // Set loading to false after submission
        });
      }
    }
  }

  void _pickBirthdate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedBirthdate = pickedDate;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _updateGenderBasedOnRelationship(String? relationship) {
    setState(() {
      // Male relationships
      if (relationship == 'Father' ||
          relationship == 'Husband' ||
          relationship == 'Brother' ||
          relationship == 'Grandfather' ||
          relationship == 'Uncle' ||
          relationship == 'Son' ||
          relationship == 'Cousin') {
        _selectedGender = 'Male';
      }
      // Female relationships
      else if (relationship == 'Mother' ||
          relationship == 'Wife' ||
          relationship == 'Sister' ||
          relationship == 'Grandmother' ||
          relationship == 'Aunt' ||
          relationship == 'Daughter' ||
          relationship == 'Niece') {
        _selectedGender = 'Female';
      }
      // Default gender for unspecified relationships
      else {
        _selectedGender = 'Other';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true,
        title: const Text(
          'Add Household Member',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedRelationship,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRelationship = newValue;
                  });
                  _updateGenderBasedOnRelationship(newValue);
                },
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: _relationships
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                validator: (value) =>
                    value == null ? 'Select relationship' : null,
              ),
              GestureDetector(
                onTap: _pickBirthdate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _birthdateController,
                    decoration: InputDecoration(
                      labelText: 'Birthdate',
                      hintText: _selectedBirthdate == null
                          ? 'Select birthdate'
                          : DateFormat('yyyy-MM-dd')
                              .format(_selectedBirthdate!),
                    ),
                    validator: (value) =>
                        _selectedBirthdate == null ? 'Select birthdate' : null,
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Gender'),
                items: _genders.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                validator: (value) => value == null ? 'Select gender' : null,
              ),
              const SizedBox(height: 16.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Add Member'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
