import 'package:agl_heights_app/services/gate_service.dart';
import 'package:flutter/material.dart';

class OfficerPage extends StatefulWidget {
  const OfficerPage({super.key});

  @override
  State<OfficerPage> createState() => _OfficerPageState();
}

class _OfficerPageState extends State<OfficerPage> {
  late Future<List<Map<String, dynamic>>> _officersFuture;

  @override
  void initState() {
    super.initState();
    _officersFuture = GateService().getOfficers(); // Initialize the future
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true,
        title: const Text(
          'Officer List',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _officersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No officers found.'));
            } else {
              List<Map<String, dynamic>> officers = snapshot.data!;

              // Separate guards and officers
              List<Map<String, dynamic>> activeGuards = officers
                  .where((officer) =>
                      officer['type'] == 'guard' && officer['active'] == '1')
                  .toList();
              List<Map<String, dynamic>> inactiveGuards = officers
                  .where((officer) =>
                      officer['type'] == 'guard' && officer['active'] != '1')
                  .toList();
              List<Map<String, dynamic>> officerPositions = officers
                  .where((officer) => officer['position'] != null)
                  .toList();

              return ListView(
                children: [
                  // Active Guards Section
                  if (activeGuards.isNotEmpty) ...[
                    const Text(
                      'Active Guards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeGuards.length,
                      itemBuilder: (context, index) {
                        var officer = activeGuards[index];
                        return _buildGuardTile(officer, Colors.blue);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Inactive Guards Section
                  if (inactiveGuards.isNotEmpty) ...[
                    const Text(
                      'Inactive Guards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: inactiveGuards.length,
                      itemBuilder: (context, index) {
                        var officer = inactiveGuards[index];
                        return _buildGuardTile(officer, Colors.red);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Officers Section
                  if (officerPositions.isNotEmpty) ...[
                    const Text(
                      'Officers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: officerPositions.length,
                      itemBuilder: (context, index) {
                        var officer = officerPositions[index];
                        String position = officer['position'] ?? 'No position';
                        return ListTile(
                          title: Text(
                              '${officer['fname']} ${officer['mname'] ?? ''} ${officer['lname']}'),
                          subtitle: Text(position),
                          trailing: Text(officer['phone'] ?? 'No Phone'),
                          onTap: () {
                            // Handle tap event for officers
                          },
                        );
                      },
                    ),
                  ],
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // Helper widget to build guard tiles
  Widget _buildGuardTile(Map<String, dynamic> officer, Color backgroundColor) {
    return ListTile(
      title: Text(
          '${officer['fname']} ${officer['mname'] ?? ''} ${officer['lname']}'),
      subtitle: Text(officer['position'] ?? 'Guard'),
      trailing: Text(officer['phone'] ?? 'No Phone'),
      leading: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Text(
          officer['fname']?.substring(0, 1) ?? '',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      onTap: () {
        // Handle tap event
      },
    );
  }
}
