import 'package:agl_heights_app/services/message_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MessageService messageService = MessageService();
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  Timer? _timer; // Timer for polling new messages

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Fetch messages when the page loads
    _startPolling(); // Start polling for new messages
  }

  // Start polling for new messages
  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMessages(); // Fetch messages every 5 seconds
    });
  }

  // Function to fetch messages
  void _fetchMessages() async {
    try {
      final List<dynamic> fetchedMessages = await messageService.getMessages();

      setState(() {
        messages.clear();
        messages.addAll(
          fetchedMessages.map<Map<String, dynamic>>((msg) {
            // Mark messages as seen if they are from the admin
            if (msg['sender_role'] == 'admin' && msg['is_seen'] == 0) {
              messageService.markAsSeen(msg['id']); // Mark this message as seen
            }

            return {
              'id': msg['id'],
              'message': msg['message'].toString(),
              'sender': msg['sender_role'],
              'created_at': msg['created_at'],
              'is_seen': msg['is_seen'],
            };
          }).toList(),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final String message = _controller.text;
      final String recipientRole = 'admin'; // Set this based on your logic

      // Update the state locally for homeowner's message
      setState(() {
        messages.add({
          'message': message,
          'sender': 'home_owner',
          'created_at':
              DateTime.now().toIso8601String(), // Add current timestamp
        }); // Add homeowner message
        _controller.clear();
      });

      // Send the message to the API
      try {
        await messageService.sendMessage(message, recipientRole);
      } catch (e) {
        print(e); // Handle error (show an error message)
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff85C1E7),
        appBar: AppBar(
          backgroundColor: const Color(0xff0A2C42),
          centerTitle: true,
          title: const Text(
            'Admin',
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
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  // Determine alignment based on sender role
                  bool isHomeOwner =
                      messages[index]['sender'] == 'home_owner'; // Check sender
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: isHomeOwner
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: isHomeOwner
                            ? MainAxisAlignment
                                .end // Align messages to the right
                            : MainAxisAlignment
                                .start, // Align messages to the left
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isHomeOwner
                                  ? CrossAxisAlignment
                                      .end // Align text to the right
                                  : CrossAxisAlignment
                                      .start, // Align text to the left
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isHomeOwner
                                        ? Colors.grey[
                                            200] // Customize for homeowner
                                        : Colors
                                            .grey[200], // Customize for admin
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    messages[index]['message'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                                // Add the timestamp below the message container
                                const SizedBox(height: 5),
                                Text(
                                  _formatDate(messages[index]['created_at']),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                if (messages[index]['is_seen'] == 1 &&
                                    isHomeOwner)
                                  const Text(
                                    'Seen',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  // Helper method to format the timestamp

  String _formatDate(String date) {
    try {
      final DateTime parsedDate =
          DateTime.parse(date).toLocal(); // Convert to local time
      final DateTime now = DateTime.now();
      final DateFormat timeFormat = DateFormat('h:mm a'); // Format for time
      final DateFormat fullDateFormat =
          DateFormat('d MMM yyyy, h:mm a'); // Format for full date
      final DateFormat weekdayFormat =
          DateFormat('EEEE, h:mm a'); // Weekday and time

      // Calculate the difference between the parsed date and now
      final Duration difference = now.difference(parsedDate);

      if (difference.inDays < 7) {
        // If the date is within the past week
        return weekdayFormat.format(parsedDate);
      } else {
        // If the date is older than a week
        return fullDateFormat.format(parsedDate);
      }
    } catch (e) {
      return ''; // Return empty string if parsing fails
    }
  }
}
