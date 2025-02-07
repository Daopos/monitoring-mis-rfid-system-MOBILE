import 'package:flutter/material.dart';
import 'package:agl_heights_app/services/visitor_service.dart';
import 'dart:async'; // Add this for Timer

class VisitorPage extends StatefulWidget {
  const VisitorPage({super.key});

  @override
  State<VisitorPage> createState() => _VisitorPageState();
}

class _VisitorPageState extends State<VisitorPage> {
  late Future<List<dynamic>> _visitors;
  Timer? _pollingTimer;

  List<dynamic> _visitorList = [];

  @override
  void initState() {
    super.initState();
    _fetchVisitors();

    // Start polling to fetch data every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchVisitors();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
    @override
    Widget build(BuildContext context) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          // Other code here
          body: TabBarView(
            children: [
              _buildVisitorList(_visitorList
                  .where((visitor) => visitor['status'] != 'requested')
                  .toList()),
              _buildVisitorList(
                  _visitorList
                      .where((visitor) => visitor['status'] == 'requested')
                      .toList(),
                  isRequested: true),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/add/visitor');
              if (result == true) {
                _fetchVisitors();
              }
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Visitor',
          ),
        ),
      );
    }
  }

  void _fetchVisitors() {
    VisitorService().getVisitors().then((data) {
      setState(() {
        _visitorList = data;
      });
    }).catchError((error) {
      // Handle the error
    });
  }

  void _refreshVisitors() {
    _fetchVisitors();
  }

  void _deleteVisitor(int id) {
    VisitorService().deleteVisitor(id).then((_) {
      setState(() {
        // Refresh the visitor list after deletion
        _visitors = VisitorService().getVisitors();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  final List<String> _relationshipOptions = [
    'Family',
    'Friend',
    'Colleague',
    'Business Partner',
    'Other'
  ];
  void _editVisitor(
      int id,
      String name,
      String? relationship,
      String? rfid,
      String? brand,
      String? color,
      String? model,
      String? plateNumber,
      List<Map<String, String>>? members) {
    // Initialize controllers with existing values
    final nameController = TextEditingController(text: name);
    final brandController = TextEditingController(text: brand);
    final colorController = TextEditingController(text: color);
    final modelController = TextEditingController(text: model);
    final plateNumberController = TextEditingController(text: plateNumber);

    // Selected relationship dropdown value
    String? selectedRelationship = relationship;

    // Show a dialog to edit the visitor
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Visitor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedRelationship,
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: _relationshipOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRelationship = value;
                  });
                },
              ),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: plateNumberController,
                decoration: const InputDecoration(labelText: 'Plate Number'),
              ),
              // Add a way to input or select members
              // For example, you could use a ListView or a TextField to input members
              // This is a placeholder for your members input logic
              // You might want to create a separate widget for managing members
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Call the updateVisitor method from the service
              VisitorService()
                  .updateVisitor(
                id,
                nameController.text,
                brandController.text.isNotEmpty ? brandController.text : null,
                colorController.text.isNotEmpty ? colorController.text : null,
                modelController.text.isNotEmpty ? modelController.text : null,
                plateNumberController.text.isNotEmpty
                    ? plateNumberController.text
                    : null,
                rfid, // Pass the RFID value
                selectedRelationship, // Use the selected relationship
                null, // If dateVisit is not available, pass null or existing value
                null, // If status is not available, pass null or existing value
                members, // Pass the members list
              )
                  .then((_) {
                // On success, refresh the visitor list and close the dialog
                setState(() {
                  _visitors = VisitorService().getVisitors();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Visitor updated successfully')));
              }).catchError((error) {
                // On error, show an error message
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

  void _approveVisitor(int id) {
    VisitorService().approveVisitor(id).then((_) {
      _refreshVisitors();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor approved successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  void _rejectVisitor(int id) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Decline Visitor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for declining this visitor:'),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLength: 200,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the dialog without doing anything
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Reason is required to decline.')),
                  );
                  return;
                }

                // Proceed with rejecting the visitor
                VisitorService().rejectVisitor(id, reason).then((_) {
                  _refreshVisitors();
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Visitor declined successfully.')),
                  );
                }).catchError((error) {
                  Navigator.pop(context); // Close the dialog on error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                });
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVisitorList(List<dynamic> visitors,
      {bool isRequested = false, bool isHistory = false}) {
    if (visitors.isEmpty) {
      return const Center(child: Text('No visitors found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];

        bool isGuarded = visitor['guard'] == 1;
        bool isApproved = visitor['status'] == 'approved';

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVisitorDetail("Name", visitor['name']),
                    _buildVisitorDetail(
                        "Relationship", visitor['relationship']),
                    _buildVisitorDetail(
                      "RFID",
                      visitor['rfid'] != null && visitor['rfid'].isNotEmpty
                          ? "Issued"
                          : "Not Issued",
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    if (isRequested) ...[
                      PopupMenuButton<String>(
                        icon:
                            const Icon(Icons.more_vert), // Three-dot menu icon
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              _showVisitorDetailsModal(visitor);
                              break;
                            case 'approve':
                              _approveVisitor(visitor['id']);
                              break;
                            case 'reject':
                              _rejectVisitor(visitor['id']);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: ListTile(
                              leading: const Icon(Icons.remove_red_eye,
                                  color: Colors.blue),
                              title: const Text('View Details'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'approve',
                            child: ListTile(
                              leading: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              title: const Text('Approve Visitor'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'reject',
                            child: ListTile(
                              leading:
                                  const Icon(Icons.cancel, color: Colors.red),
                              title: const Text('Reject Visitor'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (isHistory) ...[
                      // Show only the eye icon for History Visitors
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye,
                            color: Colors.blue),
                        onPressed: () => _showVisitorDetailsModal(visitor),
                        tooltip: 'View Details',
                      ),
                    ] else ...[
                      // Show three-dot menu for All Visitors
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'view') {
                            _showVisitorDetailsModal(visitor);
                          } else if (value == 'edit') {
                            _editVisitor(
                              visitor['id'],
                              visitor['name'],
                              visitor['relationship'],
                              visitor['rfid'],
                              visitor['brand'],
                              visitor['color'],
                              visitor['model'],
                              visitor['plate_number'],
                              visitor['visitor_groups'],
                            );
                          } else if (value == 'delete') {
                            _deleteVisitor(visitor['id']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: ListTile(
                              leading: Icon(Icons.remove_red_eye,
                                  color: Colors.blue),
                              title: Text('View Details'),
                            ),
                          ),
                          if (!isGuarded && !isApproved)
                            // const PopupMenuItem(
                            //   value: 'edit',
                            //   child: ListTile(
                            //     leading: Icon(Icons.edit, color: Colors.blue),
                            //     title: Text('Edit Visitor'),
                            //   ),
                            // ),
                            if (!isGuarded && !isApproved)
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete Visitor'),
                                ),
                              ),
                        ],
                        icon: const Icon(Icons.more_vert, color: Colors.black),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVisitorDetailsModal(Map<String, dynamic> visitor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Details of ${visitor['name']}"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVisitorDetail("Date of Visit", visitor['date_visit']),
                if (visitor['brand'] != null)
                  _buildVisitorDetail("Brand", visitor['brand']),
                if (visitor['color'] != null)
                  _buildVisitorDetail("Color", visitor['color']),
                if (visitor['model'] != null)
                  _buildVisitorDetail("Model", visitor['model']),
                if (visitor['plate_number'] != null)
                  _buildVisitorDetail("Plate Number", visitor['plate_number']),
                const Divider(),

                // Display the Reason
                _buildVisitorDetail("Reason", visitor['reason']),

                const Divider(),

                // Display Profile Image
                const Text(
                  "Profile Image:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (visitor['profile_img_url'] != null)
                  Image.network(visitor['profile_img_url']),

                const Divider(),

                // Display Valid ID Image
                const Text(
                  "Valid ID Image:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (visitor['valid_id_url'] != null)
                  Image.network(visitor['valid_id_url']),

                const Divider(),
                const Text(
                  "Visitor Groups:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...visitor['visitor_groups']?.map<Widget>((group) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("- Group: ${group['name']}"),
                            if (group['profile_img_url'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Group Profile Image:"),
                                  Image.network(group['profile_img_url']),
                                ],
                              ),
                            if (group['valid_id_url'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Group Valid ID Image:"),
                                  Image.network(group['valid_id_url']),
                                ],
                              ),
                          ],
                        ),
                      );
                    }).toList() ??
                    [const Text("No groups available.")],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Update the length to 3 for the new tab
      child: Scaffold(
        backgroundColor: const Color(0xff85C1E7),
        appBar: AppBar(
          backgroundColor: const Color(0xff0A2C42),
          centerTitle: true,
          title: const Text(
            "Visitor Details",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All Visitors'),
              Tab(text: 'Requested Visitors'),
              Tab(text: 'History Visitors'), // Add the new tab
            ],
            labelColor: Color(0xff85C1E7),
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // All Visitors Tab
            _buildVisitorList(
              _visitorList
                  .where((visitor) =>
                      visitor['status'] == 'pending' ||
                      visitor['status'] == 'approved')
                  .toList(),
            ),
            // Requested Visitors Tab
            _buildVisitorList(
              _visitorList
                  .where((visitor) => visitor['status'] == 'requested')
                  .toList(),
              isRequested: true,
            ),
            // History Visitors Tab (status 'return')
            _buildVisitorList(
              _visitorList.where((visitor) => visitor['guard'] == 1).toList(),
              isHistory: true,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/add/visitor');
            if (result == true) {
              _fetchVisitors(); // Refresh visitors after adding a new one
            }
          },
          child: const Icon(Icons.add),
          tooltip: 'Add Visitor',
        ),
      ),
    );
  }

  Widget _buildVisitorDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
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
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
