import 'dart:io';
import 'package:agl_heights_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class testing extends StatefulWidget {
  const testing({super.key});

  @override
  State<testing> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<testing> {
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
  final List<String> blockOption = ['Phase 1', 'Phase 2', 'Phase 3'];
  final List<String> lotOptions = ['Phase 1', 'Phase 2', 'Phase 3'];

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
      // Proceed with registration if validation passes and _documentImage is non-null
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
        documentImage:
            _documentImage!, // This is now safe because we check for null above
      );

      if (response.statusCode == 201) {
        showToast("Registration successful");
      } else {
        var responseData = await response.stream.bytesToString();
        showToast("Registration failed: $responseData");
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
                        onTap: () => Navigator.pop(context),
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
      children: List.generate(3, (index) {
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
            buildInputField("First name", fnameController),
            buildInputField("Middle Name", mnameController),
            buildInputField("Last Name", lnameController),
            buildInputField("Extension name", extensionController),
            buildBirthDateField(context),
            buildDropdownField("Gender", genderOptions, selectedGender,
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
            buildInputField("Phone Number", phoneController),
            buildInputField("Email", emailController),
          ],
        );
      case 2:
        return Column(
          children: [
            const Text('Step 3: Additional Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            buildDropdownField("Phase", phaseOptions, selectedPhase,
                (String? newValue) {
              setState(() {
                selectedPhase = newValue;
              });
            }),
            buildDropdownField("Block", blockOption, selectedBlock,
                (String? newValue) {
              setState(() {
                selectedBlock = newValue;
              });
            }),
            buildDropdownField("Lot", lotOptions, selectedLot,
                (String? newValue) {
              setState(() {
                selectedLot = newValue;
              });
            }),
            ElevatedButton.icon(
              onPressed: () => _pickImage(isDocument: true),
              icon: Icon(Icons.upload_file),
              label: Text("Upload Document Image"),
            ),
            if (_documentImage != null) Image.file(_documentImage!),
            buildInputField("Password", passwordController, isPassword: true),
            buildInputField("Confirm Password", confirmPasswordController,
                isPassword: true),
          ],
        );
      default:
        return Container();
    }
  }

  Widget buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          onPressed: () {
            if (currentStep == 2) {
              _submitForm(); // Corrected to call _submitForm()
            } else {
              setState(() {
                currentStep++;
              });
            }
          },
          child: Text(currentStep == 2 ? 'Submit' : 'Next'),
        ),
      ],
    );
  }

  Widget buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label cannot be empty';
        }
        return null;
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
