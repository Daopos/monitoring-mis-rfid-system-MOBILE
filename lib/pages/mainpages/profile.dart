import 'package:agl_heights_app/models/user.dart';
import 'package:agl_heights_app/services/auth_service.dart';
import 'package:agl_heights_app/services/profile_service.dart'; // Import the ProfileService
import 'package:flutter/material.dart';
import 'edit_profile_page.dart'; // Import the edit profile page

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  bool _isLoading = true; // Variable to manage loading state
  bool _isLoggingOut = false; // Variable to manage logout loading state
  final ProfileService _profileService =
      ProfileService(); // Create an instance of ProfileService

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      user = await _profileService.fetchUserProfile(); // Fetch user profile
    } catch (e) {
      // Handle error (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after fetching user
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get full screen height and width
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Full-Screen Background Image
          SizedBox(
            height: screenHeight, // Use the full screen height
            width: screenWidth, // Use the full screen width
            child: Image.asset(
              'assets/images/bg4.png', // Path to your background image
              fit: BoxFit.cover, // Ensures the image covers the whole screen
            ),
          ),
          // Profile Content
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: _isLoading // Check if loading
                  ? Center(
                      child:
                          CircularProgressIndicator(), // Show loading indicator
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          'Profile',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(
                                  0xff3A3A3A) // Ensure text is visible against the background
                              ),
                        ),
                        const SizedBox(height: 25),
                        // Display user profile image or a person icon
                        Row(
                          children: [
                            ClipOval(
                              child: user?.image != null &&
                                      user!.image!.isNotEmpty
                                  ? Image.network(
                                      user!
                                          .image!, // Use user image if available
                                      width: 50, // Set width of the image
                                      height: 50, // Set height of the image
                                      fit: BoxFit
                                          .cover, // Ensure the image covers the oval
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child; // Image loaded
                                        }
                                        return CircularProgressIndicator(); // Show loading indicator
                                      },
                                    )
                                  : Container(
                                      width: 50, // Set width of the circle
                                      height: 50, // Set height of the circle
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors
                                            .grey[300], // Background color
                                      ),
                                      child: const Icon(
                                        Icons.person, // Default person icon
                                        size: 30, // Size of the icon
                                        color: Color(
                                            0xff2743FD), // Color of the icon
                                      ),
                                    ),
                            ),
                            const SizedBox(
                                width: 10), // Spacing between image and text
                            Text(
                              '${user?.fname ?? "Loading"} ${user?.lname ?? ""}', // Use user data if available
                              style: const TextStyle(
                                fontSize: 18,
                                color:
                                    Color(0xff2743FD), // Ensure text is visible
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        textCard('Email', user?.email ?? 'Loading...'),
                        const SizedBox(height: 20),
                        textCard('First Name', user?.fname ?? 'Loading...'),
                        const SizedBox(height: 20),
                        textCard('Last Name', user?.lname ?? 'Loading...'),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              // Navigate to Edit Profile Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                      user: user!), // Pass the user object
                                ),
                              ).then((_) {
                                // Reload user data after coming back from edit page
                                _loadUser();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Edit Profile",
                                  style: TextStyle(color: Color(0xff2743FD)),
                                ),
                                const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xff2743FD),
                                ),
                              ],
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xff2743FD)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoggingOut
                                ? null // Disable button while logging out
                                : () async {
                                    setState(() {
                                      _isLoggingOut =
                                          true; // Set logging out state
                                    });
                                    try {
                                      await AuthService
                                          .logout(); // Call the logout method
                                      // Navigate to the login page
                                      Navigator.pushReplacementNamed(
                                          context, '/login');
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error logging out: $e')), // Handle error
                                      );
                                    } finally {
                                      setState(() {
                                        _isLoggingOut =
                                            false; // Reset logging out state
                                      });
                                    }
                                  },
                            child:
                                _isLoggingOut // Show loading indicator if logging out
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Colors
                                                .white, // Change the color if needed
                                            strokeWidth:
                                                2, // Adjust the stroke width
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Signing out...",
                                            style: TextStyle(
                                                color: Color(0xff2743FD)),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Sign out",
                                            style: TextStyle(
                                                color: Color(0xff2743FD)),
                                          ),
                                          const Icon(
                                            Icons.logout_outlined,
                                            color: Color(0xff2743FD),
                                          ),
                                        ],
                                      ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xff2743FD)),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget textCard(String title, String text) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xff2743FD), // Ensure text is visible
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(),
        ),
        const Divider(color: Color(0xffDEE1EF)), // Make the divider visible
      ]),
    );
  }
}
