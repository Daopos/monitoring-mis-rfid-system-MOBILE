import 'dart:async'; // Import for Timer
import 'package:agl_heights_app/models/event.dart';
import 'package:agl_heights_app/models/user.dart';
import 'package:agl_heights_app/services/auth_service.dart';
import 'package:agl_heights_app/services/event_service.dart';
import 'package:agl_heights_app/services/notification_service.dart';
import 'package:agl_heights_app/services/payment_service.dart';
import 'package:agl_heights_app/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;

  int _unreadNotificationCount = 0;

  final ProfileService _profileService =
      ProfileService(); // Create an instance of ProfileService

  Future<void> _loadUser() async {
    try {
      user = await _profileService.fetchUserProfile(); // Fetch user profile
    } catch (e) {
      // Handle error (optional)
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error loading profile: $e')),
      // );
    }
  }

  final List<String> _carouselImages = [
    'assets/caro/a.jfif',
    'assets/caro/e.jfif',
    'assets/caro/i.jfif',
    'assets/caro/o.jfif',
    'assets/caro/p.jfif',
    'assets/caro/q.jfif',
    'assets/caro/r.jfif',
    'assets/caro/t.jfif',
    'assets/caro/u.jfif',
    'assets/caro/w.jfif',
    'assets/caro/y.jfif',
  ];

  List<Event>? _events; // Store fetched events
  String? _error; // Store error if any
  Timer? _timer;
  List<dynamic>? _paymentReminders; // Store fetched payment reminders
  @override
  void initState() {
    super.initState();
    _fetchEvents(); // Fetch events initially
    _fetchPaymentReminders(); // Fetch payment reminders initially
    _startPolling(); // Start polling
    _loadUser();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer on dispose
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      _fetchEvents();
      _fetchPaymentReminders();
      _fetchNotifications(); // Add this line
    });
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await EventService().fetchEvents();
      setState(() {
        _events = events; // Update the state with fetched events
        _error = null; // Reset error state
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events'; // Update error state
      });
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifications = await NotificationService.fetchNotifications();

      if (notifications == null || notifications.isEmpty) {
        print('No notifications fetched.');
        return;
      }

      // Count all notifications (not filtering by read/unread)
      final allNotificationCount = notifications.length;
      final unreadNotificationCount = notifications
          .where((notification) => notification['is_read'] == 0)
          .length;

      if (mounted) {
        setState(() {
          _unreadNotificationCount = unreadNotificationCount;
        });

        // Log counts for debugging
        print('Total notifications: $allNotificationCount');
        print('Unread notifications: $unreadNotificationCount');
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to fetch notifications: $e')),
        // );
      }
    }
  }

  Future<void> _fetchPaymentReminders() async {
    try {
      final reminders = await PaymentService().getVehicles();
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _paymentReminders = reminders
              .where((reminder) => reminder['status'] == 'unpaid')
              .toList();
        });
      }
    } catch (e) {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _error = 'Failed to load payment reminders';
        });
      }
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat.jm().format(date); // Format to 12-hour time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notification');
                },
              ),
              if (_unreadNotificationCount > 0) // Only show if there's a count
                Positioned(
                  right: 10,
                  top: 5,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                    child: Text(
                      '$_unreadNotificationCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xff85C1E7),
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  user == null
                      ? CircularProgressIndicator() // Show loading indicator
                      : CircleAvatar(
                          radius: 30,
                          backgroundImage: user!.image != null
                              ? NetworkImage(user!.image!)
                              : NetworkImage(
                                  'https://example.com/placeholder.png'),
                        ),
                  SizedBox(height: 10),
                  Text(
                    '${user?.fname ?? "Loading"} ${user?.lname ?? ""}',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  Text(
                    '${user?.email ?? "Loading"}',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ListTile(
            //   leading: Icon(Icons.home),
            //   title: Text('Home'),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Gate in & out'),
              onTap: () {
                Navigator.pushNamed(context, '/gate');
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Payment History'),
              onTap: () {
                Navigator.pushNamed(context, '/paymenthistory');
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.settings),
            //   title: Text('Rfid Registration'),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.person_2_outlined),
              title: Text('Visitors'),
              onTap: () {
                Navigator.pushNamed(context, '/visitors');
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('Vehicles'),
              onTap: () {
                Navigator.pushNamed(context, '/vehicles');
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Family Members'),
              onTap: () {
                Navigator.pushNamed(context, '/members');
              },
            ),
            ListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text('Officers'),
              onTap: () {
                Navigator.pushNamed(context, '/officers');
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.picture_as_pdf),
            //   title: Text('PDF'),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/pdf');
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('Permit'),
              onTap: () {
                Navigator.pushNamed(context, '/application');
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                // Log out the user
                await AuthService.logout();

                // Navigate to the login page
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Reminder Section
              // Payment Reminder Section
              if (_paymentReminders != null && _paymentReminders!.isNotEmpty)
                Column(
                  children: [
                    CarouselSlider(
                      items: _paymentReminders!.map((reminder) {
                        return SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: Colors.orange.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Payment Reminder",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Title: ${reminder['title']}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Amount: ₱${reminder['amount']}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Due Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(reminder['due_date']))}",
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 180.0,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        viewportFraction: 0.9,
                        enableInfiniteScroll: false, // Disable looping
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),

              // Carousel section
              CarouselSlider(
                items: _carouselImages
                    .map(
                      (url) => ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    )
                    .toList(),
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(seconds: 1),
                  viewportFraction: 0.8,
                ),
              ),
              SizedBox(height: 20),

              // Event Title
              Text(
                "Activities",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),

              // Display Events or Error Message
              if (_error != null)
                Center(child: Text(_error!))
              else if (_events == null)
                Center(
                    child:
                        Text('Loading activties...')) // Initial loading message
              else if (_events!.isEmpty)
                Center(child: Text('No activties available.'))
              else
                Column(
                  children: _events!.map((event) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.date_range,
                                    color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text(
                                  'Start: ${formatDate(event.start)} at ${formatTime(event.start)}',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.date_range,
                                    color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text(
                                  'End: ${formatDate(event.end)} at ${formatTime(event.end)}',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            // Row(
                            //   children: [
                            //     Icon(Icons.check_circle,
                            //         color: event.status == 'Active'
                            //             ? Colors.green
                            //             : Colors.red),
                            //     SizedBox(width: 8),
                            //     Text(
                            //       'Status: ${event.status}',
                            //       style: TextStyle(
                            //           fontSize: 15, color: Colors.black54),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
