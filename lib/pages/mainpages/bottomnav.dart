import 'package:agl_heights_app/pages/mainpages/home.dart';
import 'package:agl_heights_app/pages/mainpages/message.dart';
import 'package:agl_heights_app/pages/mainpages/profile.dart';
import 'package:flutter/material.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [HomePage(), MessagePage(), ProfilePage()];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff86C1E8),
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Color(0xff0A2C42),
          unselectedItemColor: Color(0xffD9D9D9),
          selectedItemColor: Color(0xff0DB2D3),
          onTap: (index) => setState(() {
            currentIndex = index;
          }),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Color(0xff0A2C42),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Message',
              backgroundColor: Color(0xff0A2C42),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
              backgroundColor: Color(0xff0A2C42),
            ),
          ],
        ),
      ),
    );
  }
}
