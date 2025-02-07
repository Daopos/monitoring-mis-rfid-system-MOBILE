import 'package:flutter/material.dart';

class OptionPage extends StatefulWidget {
  const OptionPage({super.key});

  @override
  State<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
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
                fit:
                    BoxFit.cover, // Makes the image cover the entire background
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 210,
                  left: 30,
                  child: Text(
                    "Welcome!",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 150.0), // Adjust the top margin here
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // To only take up as much space as needed
                      children: [
                        SizedBox(
                          height: 100,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              "HOMEOWNER",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xff0A2C42)),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 100,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "VISITOR",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color(0xff0A2C42),
                              backgroundColor: Color(0xff2F80ED),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
