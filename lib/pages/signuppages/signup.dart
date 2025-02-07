import 'dart:convert';
import 'dart:io';
import 'package:agl_heights_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  final _birthdateController = TextEditingController();
  File? _profileImage;
  File? _documentImage;
  final _picker = ImagePicker();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController lotController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController extensionController = TextEditingController();
  final TextEditingController mnameController = TextEditingController();

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> phaseOptions = ['Phase 1', 'Phase 2', 'Phase 3'];
  final List<String> blockOption =
      List.generate(50, (index) => 'Block ${index + 1}');
  final List<String> lotOptions =
      List.generate(50, (index) => 'Lot ${index + 1}');

  String? selectedGender;
  String? selectedPhase;
  String? selectedBlock;
  String? selectedLot;
  int currentStep = 0;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _birthdateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> _pickImage({required bool isDocument}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isDocument) {
          _documentImage = File(pickedFile.path);
        } else {
          _profileImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_documentImage == null) {
        showToast("Please upload the required document image.");
        return;
      }

      setState(() {
        isSubmitting = true; // Disable the button
      });

      try {
        var response = await AuthService.registerHomeOwner(
          email: emailController.text,
          password: passwordController.text,
          fname: fnameController.text,
          lname: lnameController.text,
          phone: phoneController.text,
          birthdate: _birthdateController.text,
          gender: selectedGender ?? '',
          phase: selectedPhase ?? '',
          block: selectedBlock ?? '',
          lot: selectedLot ?? '',
          profileImage: _profileImage,
          documentImage: _documentImage!,
        );

        if (response.statusCode == 201) {
          // Success
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Registration Successful'),
                content: Text(
                    'Wait for your account to be confirmed. We will email you once your account is successful.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          var responseData = await response.stream.bytesToString();

          // Try to parse JSON response first
          try {
            var jsonData = jsonDecode(responseData);
            String errorMessage = jsonData['message'] ?? 'An error occurred';
            showToast("Registration failed: $errorMessage");
          } catch (e) {
            // If JSON parsing fails, try parsing the HTML response
            try {
              var document = html.parse(responseData);
              var errorMessage =
                  document.querySelector('h1')?.text ?? 'An error occurred';
              showToast("Registration failed: $errorMessage");
            } catch (htmlParseError) {
              showToast("Registration failed: Unable to parse response");
            }
          }
        }
      } catch (e) {
        showToast("An error occurred: $e");
      } finally {
        setState(() {
          isSubmitting = false; // Re-enable the button
        });
      }
    } else {
      showToast("Please fill all required fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg3.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Icon(Icons.chevron_left),
                      ),
                    ),
                    const SizedBox(height: 50),
                    stepIndicator(),
                    const SizedBox(height: 20),
                    buildStepContent(),
                    const SizedBox(height: 20),
                    buildNavigationButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: index <= currentStep ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget buildStepContent() {
    switch (currentStep) {
      case 0:
        return Column(
          children: [
            const Text('Step 1: Personal Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            buildInputField("First name*", fnameController),
            buildInputField("Middle Name(optional)", mnameController),
            buildInputField("Last Name*", lnameController),
            buildInputField("Extension name(optional)", extensionController),
            buildBirthDateField(context),
            buildDropdownField("Gender*", genderOptions, selectedGender,
                (String? newValue) {
              setState(() {
                selectedGender = newValue;
              });
            }),
          ],
        );
      case 1:
        return Column(
          children: [
            const Text('Step 2: Contact Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            buildInputField("Phone Number*", phoneController),
            buildInputField("Email*", emailController),
          ],
        );
      case 2:
        return Column(
          children: [
            const Text('Step 3: Additional Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            buildDropdownField("Phase*", phaseOptions, selectedPhase,
                (String? newValue) {
              setState(() {
                selectedPhase = newValue;
              });
            }),
            buildDropdownField("Block*", blockOption, selectedBlock,
                (String? newValue) {
              setState(() {
                selectedBlock = newValue;
              });
            }),
            buildDropdownField("Lot*", lotOptions, selectedLot,
                (String? newValue) {
              setState(() {
                selectedLot = newValue;
              });
            }),
            SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(isDocument: true),
              icon: Icon(Icons.upload_file),
              label: Text("Upload Document Image*"),
            ),
            if (_documentImage != null) Image.file(_documentImage!),
          ],
        );
      case 3:
        return Column(
          children: [
            const Text('Step 4: Create password',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            buildInputField("Password*", passwordController, isPassword: true),
            buildInputField("Confirm Password*", confirmPasswordController,
                isPassword: true),
          ],
        );
      default:
        return Container();
    }
  }

  Widget buildNavigationButtons() {
    return Row(
      mainAxisAlignment: currentStep > 0
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      children: [
        if (currentStep > 0)
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentStep--;
              });
            },
            child: const Text('Back'),
          ),
        ElevatedButton(
          onPressed: isSubmitting
              ? null // Disable button during submission
              : () {
                  if (_validateStepFields()) {
                    if (currentStep == 3) {
                      _submitForm();
                    } else {
                      setState(() {
                        currentStep++;
                      });
                    }
                  }
                },
          child: isSubmitting
              ? CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : Text(currentStep == 3 ? 'Submit' : 'Next'),
        ),
      ],
    );
  }

  bool _validateStepFields() {
    if (currentStep == 0) {
      if (fnameController.text.isEmpty ||
          lnameController.text.isEmpty ||
          _birthdateController.text.isEmpty ||
          selectedGender == null) {
        showToast("Please fill all required fields in Step 1");
        return false;
      }
    } else if (currentStep == 1) {
      if (phoneController.text.isEmpty || emailController.text.isEmpty) {
        showToast("Please fill all required fields in Step 2");
        return false;
      }
      if (!isValidEmail(emailController.text)) {
        showToast("Please enter a valid email address");
        return false;
      }
      if (phoneController.text.length != 11) {
        showToast("Phone number must be exactly 11 digits");
        return false;
      }
      if (!phoneController.text.startsWith("09")) {
        showToast("Phone number must start with '09'");
        return false;
      }
    } else if (currentStep == 2) {
      if (selectedPhase == null ||
          selectedBlock == null ||
          selectedLot == null ||
          _documentImage == null) {
        showToast("Please fill all required fields in Step 3");
        return false;
      }
    }
    return true;
  }

  Widget buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    bool isPasswordVisible = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: label == "Phone Number*"
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: label == "Phone Number*"
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ]
              : null,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label cannot be empty';
            }
            if (label == "Password*" && value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            if (label == "Confirm Password*" &&
                value != passwordController.text) {
              return 'Passwords do not match';
            }
            if (label == "Phone Number*") {
              if (value.length != 11) {
                return 'Phone number must be exactly 11 digits';
              }
              if (!value.startsWith("09")) {
                return 'Phone number must start with "09"';
              }
            }
            return null;
          },
        );
      },
    );
  }

  Widget buildDropdownField(String label, List<String> options,
      String? selectedValue, Function onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: onChanged as void Function(String?)?,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget buildBirthDateField(BuildContext context) {
    return TextField(
      controller: _birthdateController,
      readOnly: true,
      onTap: () => _pickDate(context),
      decoration: InputDecoration(
        labelText: 'Birth Date',
        suffixIcon: Icon(Icons.calendar_today),
      ),
    );
  }
}
