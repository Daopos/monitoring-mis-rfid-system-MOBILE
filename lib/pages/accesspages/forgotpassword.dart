import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:agl_heights_app/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendPasswordResetLink() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;

    // Validate email
    if (email.isEmpty || !email.contains('@')) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    bool success = await AuthService.sendResetLink(email);

    if (success) {
      Fluttertoast.showToast(
        msg: "Password reset link sent!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pop(context); // Close the page after success
    } else {
      Fluttertoast.showToast(
        msg: "Failed to send reset link. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg2.png'), // Background image
              fit: BoxFit.cover, // Makes the image cover the entire background
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.chevron_left),
                          ),
                        ),
                        SizedBox(height: 200),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(
                                fontSize: 30,
                                color: Color(0xff0A2C42),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Form(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            child: Column(
                              children: [
                                _textField("Email", false, Icon(Icons.email),
                                    _emailController),
                                SizedBox(height: 20),
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 45,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _sendPasswordResetLink();
                                          },
                                          child: Text('Send Reset Link'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xff0A2C42),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.black),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                          ),
                                        ),
                                      ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(
      String hint, bool obscure, Icon icon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon,
        filled: true,
        fillColor: Color(0xffD9D9D9),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
