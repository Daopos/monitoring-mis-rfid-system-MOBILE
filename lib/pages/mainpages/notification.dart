import 'package:agl_heights_app/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final fetchedNotifications =
          await NotificationService.fetchNotifications();

      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });

      // Collect the notification IDs to mark as read
      List<int> notificationIds = notifications
          .where((notif) => notif['is_read'] == 0) // Only unread notifications
          .map<int>((notif) => notif['id'])
          .toList();

      if (notificationIds.isNotEmpty) {
        // Mark the notifications as read on the backend
        await NotificationService.markNotificationsAsRead(notificationIds);

        setState(() {
          // Update the local list to mark notifications as read
          notifications.forEach((notif) {
            if (notificationIds.contains(notif['id'])) {
              notif['is_read'] = 1; // Mark as read locally
            }
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications marked as read')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching notifications: $e");
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      bool success =
          await NotificationService.deleteNotification(notificationId);

      if (success) {
        setState(() {
          notifications.removeWhere((notif) => notif['id'] == notificationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted successfully')),
        );
      }
    } catch (e) {
      print("Error deleting notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete notification')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true,
        title: const Text(
          'Notifications',
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("No notifications available."))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    // Convert the 'is_read' value from int to bool
                    bool isRead = (notification['is_read'] == 1);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Stack(
                        children: [
                          ListTile(
                            title: Text(notification['title']),
                            subtitle: Text(notification['message']),
                            trailing: Icon(
                              isRead ? Icons.check_circle : Icons.circle,
                              color: isRead ? Colors.green : Colors.grey,
                            ),
                          ),
                          Positioned(
                            top: -5.0,
                            right: -5.0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.black, // Black icon color
                              ),
                              onPressed: () {
                                // Call the delete method
                                deleteNotification(notification['id']);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
