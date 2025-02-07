import 'dart:async';
import 'package:agl_heights_app/services/applicant_service.dart';
import 'package:flutter/material.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  List<Map<String, dynamic>> applicants = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchApplicants();
    // Set up the periodic fetch
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchApplicants();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchApplicants() async {
    final data = await ApplicantService.getApplicantsWithNeighbors();
    if (data['message'] == null) {
      setState(() {
        applicants = List<Map<String, dynamic>>.from(data['applicants']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  void _deleteApplicant(int id) {
    ApplicantService().deleteApplicant(id).then((_) {
      setState(() {
        fetchApplicants();
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

  void _showNeighborsDialog(List neighbors) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neighbors'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: neighbors.length,
              itemBuilder: (context, index) {
                final neighbor = neighbors[index];
                final homeowner = neighbor['homeowner'];
                return ListTile(
                  title: Text(
                    '${homeowner['fname']} ${homeowner['lname']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      'Block: ${homeowner['block']}, Lot: ${homeowner['lot']}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
          'Application Permit',
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
      body: applicants.isEmpty
          ? const Center(
              child: Text(
                'No application permit',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: applicants.length,
              itemBuilder: (context, index) {
                final applicant = applicants[index];
                final neighbors = applicant['neighbors'] as List;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${applicant['project_description']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                                'Application Date: ${applicant['application_date']}'),
                            const SizedBox(height: 8.0),
                            Text(
                                'Mobilization Date: ${applicant['mobilization_date']}'),
                            const SizedBox(height: 8.0),
                            Text(
                                'Completion Date: ${applicant['completion_date']}'),
                            const SizedBox(height: 8.0),
                            Text('${applicant['selection']}'),
                            const SizedBox(height: 8.0),
                            Text('Status: ${applicant['status']}'),
                            const SizedBox(height: 8.0),
                            Text('Neighbors: ${neighbors.length}'),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: PopupMenuButton<int>(
                          onSelected: (value) async {
                            if (value == 1) {
                              // Navigate to the Edit Application screen and wait for the result
                              final result = await Navigator.pushNamed(
                                context,
                                '/editApplication',
                                arguments: applicant['id'],
                              );
                              if (result == true) {
                                // Refresh the applicants if an application was edited
                                fetchApplicants();
                              }
                            } else if (value == 2) {
                              _deleteApplicant(applicant['id']);
                            } else if (value == 3) {
                              _showNeighborsDialog(neighbors);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<int>(
                              value: 3,
                              child: Text('View Neighbors'),
                            ),
                            const PopupMenuItem<int>(
                              value: 1,
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<int>(
                              value: 2,
                              child: Text('Delete'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the Add Application screen and wait for the result
          final result = await Navigator.pushNamed(context, '/add/application');
          if (result == true) {
            // Refresh the applicants if an application was added
            fetchApplicants();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Application',
      ),
    );
  }
}
