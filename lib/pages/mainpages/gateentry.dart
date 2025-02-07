import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:agl_heights_app/services/gate_service.dart'; // Import your GateService

class GateEntryPage extends StatefulWidget {
  const GateEntryPage({super.key});

  @override
  State<GateEntryPage> createState() => _GateEntryPageState();
}

class _GateEntryPageState extends State<GateEntryPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDate; // For start date filter
  DateTime? _endDate; // For end date filter
  List<dynamic> _gateEntries = []; // List to store fetched entries
  bool _isLoading = true; // To show loading indicator

  @override
  void initState() {
    super.initState();
    // Fetch gate entries when the page is first loaded
    _fetchGateEntries();
  }

  // Method to fetch gate entries using GateService
  Future<void> _fetchGateEntries() async {
    try {
      final gateService = GateService();
      final entries = await gateService.getGate();
      setState(() {
        _gateEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // You can show an error message here if needed
      print('Error fetching data: $e');
    }
  }

  // Format date using DateFormat
  String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMMM dd, yyyy hh:mm a');
    return formatter.format(dateTime);
  }

  // Filter entries based on the selected date range
  List<dynamic> _filterEntries() {
    return _gateEntries.where((entry) {
      final entryDate = DateTime.parse(entry['in']);

      if (_startDate != null && entryDate.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && entryDate.isAfter(_endDate!)) {
        return false;
      }

      return true; // If no filtering criteria, include the entry
    }).toList();
  }

  // Method to clear the date filters
  void _clearDateFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter entries based on the selected date range
    List<dynamic> filteredEntries = _filterEntries();

    return Scaffold(
      backgroundColor: Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true, // Ce
        title: const Text(
          'Gate Entry History',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold, // Make the text bold
            fontSize: 20, // Adjust the font size if needed
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker for start date and end date
            Row(
              children: [
                Flexible(
                  child: Text(
                    _startDate != null
                        ? 'Start Date: ${formatDateTime(_startDate!)}'
                        : 'Start Date: Not selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _startDate) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                    _endDate != null
                        ? 'End Date: ${formatDateTime(_endDate!)}'
                        : 'End Date: Not selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _endDate) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Clear button to reset date filters
            ElevatedButton(
              onPressed: _clearDateFilters,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0A2C42),
                  foregroundColor: Colors.white),
              child: const Text('Clear Date Filters'),
            ),

            const SizedBox(height: 10),

            // Gate Entry History List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator while data is being fetched
                  : filteredEntries.isEmpty
                      ? const Center(
                          child: Text('No entries for this date range.'))
                      : ListView.builder(
                          itemCount: filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = filteredEntries[index];
                            final entryIn = DateTime.parse(entry['in']);
                            final entryOut = entry['out'] != null
                                ? DateTime.parse(entry['out'])
                                : null;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title:
                                    Text('Entry: ${formatDateTime(entryIn)}'),
                                subtitle: entryOut != null
                                    ? Text('Exit: ${formatDateTime(entryOut)}')
                                    : const Text('Exit: N/A'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
