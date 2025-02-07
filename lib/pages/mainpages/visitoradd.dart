import 'package:flutter/material.dart';
import 'package:agl_heights_app/services/visitor_service.dart';
import 'package:intl/intl.dart';

class AddVisitorPage extends StatefulWidget {
  const AddVisitorPage({super.key});

  @override
  State<AddVisitorPage> createState() => _AddVisitorPageState();
}

class _AddVisitorPageState extends State<AddVisitorPage> {
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _dateVisitController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Date format
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Relationship options
  final List<String> _relationshipOptions = [
    'Family',
    'Friend',
    'Colleague',
    'Business Partner',
    'Other'
  ];
  String? _selectedRelationship;

  // List to hold members
  List<Map<String, String>> _members = [];

  // Function to handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await VisitorService().addVisitor(
          name: _nameController.text,
          brand: _brandController.text,
          color: _colorController.text,
          model: _modelController.text,
          plateNumber: _plateNumberController.text,
          relationship: _selectedRelationship!,
          dateVisit: _dateVisitController.text,
          members: _members, // Pass only manually added members
        );
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visitor added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add visitor: $e')),
        );
      }
    }
  }

  // Function to pick date from the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateVisitController.text = _dateFormat.format(pickedDate);
      });
    }
  }

  // Function to add a new member
  void _addMember() {
    if (_members.isNotEmpty && _members.last['name']!.isEmpty) {
      // Show a message if the last member field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please fill up the current member\'s name before adding another.'),
        ),
      );
      return;
    }
    setState(() {
      _members.add({'name': ''});
    });
  }

  // Function to delete a member
  void _deleteMember(int index) {
    setState(() {
      _members.removeAt(index);
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
          'Add Visitor',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visitor Details Section
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visitor Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Visitor Name (representative)*',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the visitor\'s name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: _selectedRelationship,
                        items: _relationshipOptions
                            .map((relationship) => DropdownMenuItem<String>(
                                  value: relationship,
                                  child: Text(relationship),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRelationship = value;
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: 'Relationship*'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a relationship';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _dateVisitController,
                            decoration: const InputDecoration(
                              labelText: 'Date of Visit*',
                              hintText: 'Pick a date',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Members Section
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Members',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ..._members.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> member = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: TextFormField(
                            initialValue: member['name'],
                            decoration: const InputDecoration(
                              labelText: 'Member Name',
                            ),
                            onChanged: (value) {
                              setState(() {
                                member['name'] = value;
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMember(index),
                          ),
                        );
                      }),
                      const SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: _addMember,
                        child: const Text('Add Member'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Vehicle Details Section
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Details (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _brandController,
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Brand'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _colorController,
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Color'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _modelController,
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Model'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _plateNumberController,
                        decoration: const InputDecoration(
                            labelText: 'Vehicle Plate Number'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Visitor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
