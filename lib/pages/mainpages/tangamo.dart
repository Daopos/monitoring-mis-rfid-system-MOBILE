import 'package:agl_heights_app/services/applicant_service.dart';
import 'package:flutter/material.dart';

class ApplicationAddPage extends StatefulWidget {
  const ApplicationAddPage({super.key});

  @override
  State<ApplicationAddPage> createState() => _ApplicationAddPageState();
}

class _ApplicationAddPageState extends State<ApplicationAddPage> {
  DateTime? _mobilizationDate; // Stores Mobilization Date
  DateTime? _completionDate; // Stores Completion Date
  String _selectedType = 'Major Repair'; // Default selection
  final TextEditingController _projectDescriptionController =
      TextEditingController(); // For project description
  final List<TextEditingController> _neighborControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ]; // Minimum 3 neighbors

  // Create an instance of ApplicantService

  void _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  void _addNeighborField() {
    setState(() {
      _neighborControllers.add(TextEditingController());
    });
  }

  void _removeNeighborField(int index) {
    if (_neighborControllers.length > 3) {
      setState(() {
        _neighborControllers.removeAt(index);
      });
    }
  }

  void _submitApplication() async {
    // Collect data from the form
    String mobilizationDate = _mobilizationDate != null
        ? '${_mobilizationDate!.year}-${_mobilizationDate!.month}-${_mobilizationDate!.day}'
        : '';
    String completionDate = _completionDate != null
        ? '${_completionDate!.year}-${_completionDate!.month}-${_completionDate!.day}'
        : '';

    // Prepare neighbor list
    List<Map<String, dynamic>> neighbors = _neighborControllers
        .map((controller) => {
              'homeowner_id': int.tryParse(controller.text) ??
                  0, // Assuming it's a homeowner ID
              'status': 'Pending', // Default status
            })
        .toList();

    // Call the ApplicantService to create the applicant
    await ApplicantService().createApplicant(
      homeownerId: 1, // Replace with actual homeowner ID
      mobilizationDate: mobilizationDate,
      completionDate: completionDate,
      projectDescription: _projectDescriptionController.text,
      selection: _selectedType,
      neighbors: neighbors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true,
        title: const Text(
          'Applications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Application Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16.0),

                  // Mobilization Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mobilization Date:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () =>
                            _selectDate(context, _mobilizationDate, (date) {
                          setState(() {
                            _mobilizationDate = date;
                          });
                        }),
                        child: Text(
                          _mobilizationDate == null
                              ? 'Select Date'
                              : '${_mobilizationDate!.year}-${_mobilizationDate!.month}-${_mobilizationDate!.day}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Completion Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Completion Date:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () =>
                            _selectDate(context, _completionDate, (date) {
                          setState(() {
                            _completionDate = date;
                          });
                        }),
                        child: Text(
                          _completionDate == null
                              ? 'Select Date'
                              : '${_completionDate!.year}-${_completionDate!.month}-${_completionDate!.day}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Repair Type Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Type of Repair:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        items: <String>[
                          'Major Repair',
                          'General Repair',
                          'Reconstruction'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Project Description
                  const Text(
                    'Project Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _projectDescriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter project description',
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Neighbors Fields
                  const Text(
                    'Neighbor Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  ..._neighborControllers.asMap().entries.map((entry) {
                    int i = entry.key;
                    TextEditingController controller = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Neighbor ${i + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        if (_neighborControllers.length > 3)
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () => _removeNeighborField(i),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8.0),
                  TextButton.icon(
                    onPressed: _addNeighborField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Neighbor'),
                  ),

                  // Submit Button
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _submitApplication,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
