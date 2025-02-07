import 'package:agl_heights_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Added state for password visibility

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    // Validate email and password before making the API call
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

    if (password.length < 6) {
      Fluttertoast.showToast(
        msg: "Password should be at least 6 characters long",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    bool success = await AuthService.login(email, password);

    if (success) {
      Navigator.pushReplacementNamed(context, '/navpage');
    } else {
      Fluttertoast.showToast(
        msg: "Invalid email or password",
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
              image: AssetImage(
                  'assets/images/bg2.png'), // Replace with your background image path
              fit: BoxFit.cover, // Makes the image cover the entire background
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
              ),
              SingleChildScrollView(
                // Make the entire content scrollable
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 30,
                                color: Color(0xff0A2C42),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Form(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          child: Column(
                            children: [
                              _textField("Email", false, Icon(Icons.email),
                                  _emailController),
                              SizedBox(height: 20),
                              _textField("Password", true, Icon(Icons.lock),
                                  _passwordController,
                                  isPasswordField: true),
                              SizedBox(height: 40),
                              _isLoading
                                  ? CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _login();
                                        },
                                        child: Text('Log In'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xff0A2C42),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            side:
                                                BorderSide(color: Colors.black),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              SizedBox(height: 30),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/forgotpassword');
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 30),
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Don’t have an account?  ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            Navigator.pushReplacementNamed(
                                                context, '/signup'),
                                      text: "Sign Up",
                                      style: TextStyle(
                                          color: Color(0xff0A2C42),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
      String hint, bool obs, Icon icon, TextEditingController controller,
      {bool isPasswordField = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPasswordField ? !_isPasswordVisible : obs,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon,
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Color(0xffD9D9D9),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );
  }
}
