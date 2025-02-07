import 'package:agl_heights_app/services/applicant_service.dart';
import 'package:flutter/material.dart';

class ApplicationAddPage extends StatefulWidget {
  const ApplicationAddPage({super.key});

  @override
  State<ApplicationAddPage> createState() => _ApplicationAddPageState();
}

class _ApplicationAddPageState extends State<ApplicationAddPage> {
  DateTime? _mobilizationDate;
  DateTime? _completionDate;
  String _selectedType = 'Major Repair';
  final TextEditingController _projectDescriptionController =
      TextEditingController();

  // List to store selected neighbors
  final List<Map<String, dynamic>> _selectedNeighbors = [
    {'homeowner_id': null, 'status': 'Pending'},
    {'homeowner_id': null, 'status': 'Pending'},
    {'homeowner_id': null, 'status': 'Pending'},
  ]; // Ensure minimum 3 neighbors

  // Neighbor list fetched from API
  List<Map<String, dynamic>> _neighborList = [];
  bool _isLoadingNeighbors = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _fetchNeighbors();
  }

  Future<void> _fetchNeighbors() async {
    try {
      final neighbors = await ApplicantService.fetchNeighbors();
      setState(() {
        _neighborList = neighbors;
        _isLoadingNeighbors = false;
      });
    } catch (e) {
      setState(() {
        _loadingError = e.toString();
        _isLoadingNeighbors = false;
      });
    }
  }

  void _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime?) onDateSelected) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: now, // Disable past dates
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
      _selectedNeighbors.add({'homeowner_id': null, 'status': 'Pending'});
    });
  }

  void _removeNeighborField(int index) {
    if (_selectedNeighbors.length > 3) {
      setState(() {
        _selectedNeighbors.removeAt(index);
      });
    }
  }

  void _submitApplication() async {
    // Check if required fields are filled

    final DateTime now = DateTime.now(); // Define 'now' here

    // if (_mobilizationDate != null && _mobilizationDate!.isBefore(now)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Mobilization date cannot be in the past.'),
    //     ),
    //   );
    //   return;
    // }

    if (_completionDate != null && _completionDate!.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completion date cannot be in the past.'),
        ),
      );
      return;
    }

    if (_mobilizationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mobilization date.'),
        ),
      );
      return;
    }

    if (_completionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a completion date.'),
        ),
      );
      return;
    }

    // Validate if completion date is not earlier than mobilization date
    if (_completionDate!.isBefore(_mobilizationDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Completion date cannot be earlier than mobilization date.'),
        ),
      );
      return;
    }

    if (_projectDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a project description.'),
        ),
      );
      return;
    }

    if (_selectedNeighbors
        .any((neighbor) => neighbor['homeowner_id'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a neighbor for each neighbor field.'),
        ),
      );
      return;
    }

    String mobilizationDate =
        '${_mobilizationDate!.year}-${_mobilizationDate!.month}-${_mobilizationDate!.day}';
    String completionDate =
        '${_completionDate!.year}-${_completionDate!.month}-${_completionDate!.day}';

    // Filter neighbors with valid IDs
    List<Map<String, dynamic>> neighbors = _selectedNeighbors
        .where((neighbor) => neighbor['homeowner_id'] != null)
        .toList();

    try {
      // Mock API Call
      await ApplicantService().createApplicant(
        homeownerId: 1, // Replace with actual homeowner ID
        mobilizationDate: mobilizationDate,
        completionDate: completionDate,
        projectDescription: _projectDescriptionController.text,
        selection: _selectedType,
        neighbors: neighbors,
      );

      // Show success snackbar and navigate back
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            duration: const Duration(seconds: 2),
          ),
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

                  // Type of Repair Dropdown
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

                  // Neighbor Details
                  const Text(
                    'Neighbor Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_isLoadingNeighbors)
                    const Center(child: CircularProgressIndicator())
                  else if (_loadingError != null)
                    Text(
                      _loadingError!,
                      style: const TextStyle(color: Colors.red),
                    )
                  else
                    ..._selectedNeighbors.asMap().entries.map((entry) {
                      int i = entry.key;
                      Map<String, dynamic> neighbor = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButton<int?>(
                              value: neighbor['homeowner_id'],
                              hint: const Text('Select Neighbor'),
                              onChanged: (value) {
                                setState(() {
                                  neighbor['homeowner_id'] = value;
                                });
                              },
                              items: _neighborList.map((n) {
                                return DropdownMenuItem<int>(
                                  value: n['id'],
                                  child: Text(n['name']),
                                );
                              }).toList(),
                            ),
                          ),
                          if (_selectedNeighbors.length > 3)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => _removeNeighborField(i),
                            ),
                        ],
                      );
                    }),
                  TextButton.icon(
                    onPressed: _addNeighborField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Neighbor'),
                  ),

                  // Submit Button
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
