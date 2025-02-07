import 'package:flutter/material.dart';
import 'package:agl_heights_app/services/applicant_service.dart';

class ApplicationEditPage extends StatefulWidget {
  const ApplicationEditPage({super.key});

  @override
  State<ApplicationEditPage> createState() => _ApplicationEditPageState();
}

class _ApplicationEditPageState extends State<ApplicationEditPage> {
  DateTime? _mobilizationDate;
  DateTime? _completionDate;
  String _selectedType = 'Major Repair';
  final TextEditingController _projectDescriptionController =
      TextEditingController();

  final List<Map<String, dynamic>> _selectedNeighbors = [];
  List<Map<String, dynamic>> _neighborList = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadingError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the ID from arguments
    final id = ModalRoute.of(context)?.settings.arguments as int?;
    if (id != null) {
      _fetchApplicationData(id);
    }
  }

  Future<void> _fetchApplicationData(int id) async {
    try {
      final application = await ApplicantService.fetchApplication(id);

      // Ensure neighbors are properly parsed as List<Map<String, dynamic>>
      final neighbors = await ApplicantService.fetchNeighbors();

      setState(() {
        _mobilizationDate = application['mobilization_date'] != null
            ? DateTime.tryParse(
                application['mobilization_date']) // Safely parse date
            : null;

        _completionDate = application['completion_date'] != null
            ? DateTime.tryParse(
                application['completion_date']) // Safely parse date
            : null;

        _selectedType =
            application['type'] ?? 'Major Repair'; // Default value if null
        _projectDescriptionController.text =
            application['description'] ?? ''; // Default empty string if null

        // Ensure neighbors list is properly typed
        _selectedNeighbors.addAll(
          (application['neighbors'] as List)
              .map((n) => n as Map<String, dynamic>)
              .toList(),
        );

        _neighborList =
            (neighbors as List).map((n) => n as Map<String, dynamic>).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadingError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime?) onDateSelected) async {
    final picked = await showDatePicker(
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

  void _submitApplication(int id) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      String mobilizationDate = _mobilizationDate != null
          ? '${_mobilizationDate!.year}-${_mobilizationDate!.month}-${_mobilizationDate!.day}'
          : '';
      String completionDate = _completionDate != null
          ? '${_completionDate!.year}-${_completionDate!.month}-${_completionDate!.day}'
          : '';

      // Filter neighbors with valid IDs
      List<Map<String, dynamic>> neighbors = _selectedNeighbors
          .where((neighbor) => neighbor['homeowner_id'] != null)
          .toList();

      await ApplicantService().updateApplicant(
        id: id,
        mobilizationDate: mobilizationDate,
        completionDate: completionDate,
        projectDescription: _projectDescriptionController.text,
        selection: _selectedType,
        neighbors: neighbors,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application updated successfully!')),
      );
      // Navigate back or show success notification
      Navigator.pop(context, true); // Pass `true` to indicate successful edit
    } catch (e) {
      // Handle error (e.g., show a toast)
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadingError != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _loadingError!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final id = ModalRoute.of(context)?.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Application'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Mobilization Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mobilization Date:'),
              TextButton(
                onPressed: () =>
                    _selectDate(context, _mobilizationDate, (date) {
                  _mobilizationDate = date;
                }),
                child: Text(
                  _mobilizationDate == null
                      ? 'Select Date'
                      : '${_mobilizationDate!.year}-${_mobilizationDate!.month}-${_mobilizationDate!.day}',
                ),
              ),
            ],
          ),

          // Completion Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Completion Date:'),
              TextButton(
                onPressed: () => _selectDate(context, _completionDate, (date) {
                  _completionDate = date;
                }),
                child: Text(
                  _completionDate == null
                      ? 'Select Date'
                      : '${_completionDate!.year}-${_completionDate!.month}-${_completionDate!.day}',
                ),
              ),
            ],
          ),

          // Type Dropdown
          DropdownButton<String>(
            value: _selectedType.isNotEmpty
                ? _selectedType
                : 'Major Repair', // Fallback to default value
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
            items: ['Major Repair', 'General Repair', 'Reconstruction']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          // Project Description
          TextField(
            controller: _projectDescriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter project description',
            ),
          ),

          // Neighbors
          const Text('Neighbors:'),
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
              ],
            );
          }),

          const SizedBox(height: 16.0),

          // Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : () => _submitApplication(id),
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Update'),
          ),
        ],
      ),
    );
  }
}
