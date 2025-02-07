import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        elevation: 0,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildMessageItem(
                'Admin',
                Icons.account_circle,
                () => Navigator.pushNamed(context, '/chat'),
              ),
              SizedBox(height: 16),
              _buildMessageItem(
                'Guard',
                Icons.account_circle,
                () => Navigator.pushNamed(context, '/guard/chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(String name, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          radius: 25,
          child: Icon(icon, size: 30, color: Colors.white),
          backgroundColor: Color(0xff0A2C42),
        ),
        title: Text(
          name,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right, color: Color(0xff0A2C42)),
      ),
    );
  }
}
