import 'package:flutter/material.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/bg1.png'), // Replace with your background image path
              fit: BoxFit.cover, // Makes the image cover the entire background
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 50, // Adjust this value to position the image correctly
                bottom: 0,
                left: 0, // You can also adjust this value if needed
                right: 0,
                child: Image.asset('assets/images/agllogo.png'),
              ),
              // Other widgets can be added here as needed
              Positioned(
                bottom: 30, // Example of positioning another widget
                right: 20,
                child: Center(
                    child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Get Started'),
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xff2F80ED),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: Color(0xff0A2C42))),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
