import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:agl_heights_app/services/household_service.dart';

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  late Future<List<Map<String, dynamic>>> _householdMembers;
  final List<String> _genders = ['Male', 'Female', 'Other'];
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

  @override
  void initState() {
    super.initState();
    _fetchHouseholdMembers();
  }

  void _fetchHouseholdMembers() {
    setState(() {
      _householdMembers = HouseholdService().getHouseholdMembers();
    });
  }

  void _refreshHouseholdMembers() {
    setState(() {
      _householdMembers = HouseholdService().getHouseholdMembers();
    });
  }

  void _deleteMember(int memberId) async {
    try {
      await HouseholdService().deleteHouseholdMember(memberId);
      _refreshHouseholdMembers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Household member deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting member: $e')),
      );
    }
  }

  void _showUpdateDialog(Map<String, dynamic> member) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController =
        TextEditingController(text: member['name']);
    final TextEditingController _birthdateController = TextEditingController(
      text: member['birthdate'] != null
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(member['birthdate']))
          : '',
    );
    String? _selectedGender = member['gender'];
    String? _selectedRelationship = member['relationship'];

    void _pickBirthdate() async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _birthdateController.text.isNotEmpty
            ? DateTime.parse(_birthdateController.text)
            : DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        setState(() {
          _birthdateController.text =
              DateFormat('yyyy-MM-dd').format(pickedDate);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Household Member'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter name' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRelationship,
                  decoration: const InputDecoration(labelText: 'Relationship'),
                  items: _relationships.map((relationship) {
                    return DropdownMenuItem<String>(
                      value: relationship,
                      child: Text(relationship),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRelationship = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select relationship' : null,
                ),
                GestureDetector(
                  onTap: _pickBirthdate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _birthdateController,
                      decoration: const InputDecoration(labelText: 'Birthdate'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Select birthdate'
                          : null,
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: _genders.map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) => value == null ? 'Select gender' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await HouseholdService().updateHouseholdMember(
                      member['id'],
                      _nameController.text,
                      _selectedRelationship!,
                      DateTime.parse(_birthdateController.text),
                      _selectedGender!,
                    );
                    Navigator.pop(context);
                    _refreshHouseholdMembers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Household member updated successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating member: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true,
        title: const Text(
          'Family Members',
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _householdMembers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load members: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No members found.'));
          }

          final members = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${member['name'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8.0),
                              Text('Birthdate: ${member['birthdate']}'),
                              const SizedBox(height: 8.0),
                              Text('Relationship: ${member['relationship']}'),
                              const SizedBox(height: 8.0),
                              Text('Gender: ${member['gender']}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: PopupMenuButton<int>(
                        onSelected: (value) {
                          if (value == 1) {
                            _showUpdateDialog(member);
                          } else if (value == 2) {
                            _deleteMember(member['id']);
                          }
                        },
                        itemBuilder: (context) => [
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add/household');
          if (result == true) {
            _refreshHouseholdMembers();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Household Member',
      ),
    );
  }
}
