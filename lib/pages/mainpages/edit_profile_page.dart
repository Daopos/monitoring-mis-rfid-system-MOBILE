import 'dart:io';
import 'package:agl_heights_app/models/user.dart';
import 'package:agl_heights_app/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late String _fname, _lname, _email, _phone, _birthdate, _gender, _phase;
  late String _block, _lot;
  String? _mname, _extension, _imagePath, _status, _position, _documentPath;

  TextEditingController datePickerController = TextEditingController();

  // Dropdown options
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> phaseOptions = ['Phase 1', 'Phase 2', 'Phase 3'];
  final List<String> blockOption =
      List.generate(50, (index) => 'Block ${index + 1}');
  final List<String> lotOptions =
      List.generate(50, (index) => 'Lot ${index + 1}');

  @override
  void initState() {
    super.initState();
    _fname = widget.user.fname;
    _lname = widget.user.lname;
    _email = widget.user.email;
    _phone = widget.user.phone;
    _birthdate = widget.user.birthdate;
    _gender = widget.user.gender;
    _phase = widget.user.phase;
    _mname = widget.user.mname;
    _extension = widget.user.extension;
    _imagePath = widget.user.image;
    _status = widget.user.status;
    _position = widget.user.position;
    _documentPath = widget.user.document;

    // Ensure that _block and _lot values are within the available options
    _block = blockOption.contains(widget.user.block)
        ? widget.user.block
        : blockOption.first;
    _lot = lotOptions.contains(widget.user.lot)
        ? widget.user.lot
        : lotOptions.first;

    datePickerController.text = _birthdate;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    } else {
      // Reset the image if the user doesn't pick one
      setState(() {
        _imagePath = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        datePickerController.text =
            pickedDate.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // If the image is not updated, set it to null
      String? imageToUpload =
          (_imagePath == widget.user.image) ? null : _imagePath;

      // Create the updated user object with the image set to null if not updated
      User updatedUser = User(
        id: widget.user.id,
        fname: _fname,
        lname: _lname,
        email: _email,
        phone: _phone,
        mname: _mname,
        birthdate: datePickerController.text,
        gender: _gender,
        phase: _phase,
        block: _block,
        lot: _lot,
        extension: _extension,
        image: imageToUpload, // Set image to null if no new image is selected
        status: _status,
        position: _position,
        document: _documentPath,
      );

      print('Request Body: ${updatedUser.toJson()}');

      try {
        await _profileService.updateUserProfile(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        // Send the updated user data back to the previous page
        Navigator.pop(context, updatedUser); // Pass the updated user data
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Widget buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _imagePath != null
            ? (_imagePath!.startsWith('http') // Check if it's a URL
                ? NetworkImage(_imagePath!) // Use NetworkImage for URLs
                : FileImage(File(_imagePath!)) as ImageProvider)
            : null,
        child: _imagePath == null ? const Icon(Icons.person, size: 50) : null,
      ),
    );
  }

  Widget buildTextField(
      String label, String initialValue, Function(String) onChanged,
      {bool isOptional = false}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget buildDropdownField(String label, List<String> options,
      String selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: options.contains(selectedValue) ? selectedValue : options.first,
      decoration: InputDecoration(labelText: label),
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true, //
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold, // Make the text bold
            fontSize: 20, // Adjust the font size if needed
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildImagePicker(),
                const SizedBox(height: 20),
                buildTextField('First Name', _fname, (value) => _fname = value),
                buildTextField('Last Name', _lname, (value) => _lname = value),
                buildTextField('Email', _email, (value) => _email = value),
                buildTextField('Phone', _phone, (value) => _phone = value),
                buildTextField(
                  'Middle Name',
                  _mname ??
                      '', // Ensure that this value is being passed correctly
                  (value) => _mname = value,
                  isOptional: true,
                ),
                buildTextField(
                  'Extension',
                  _extension ?? '', // Ensure this is being updated properly
                  (value) => _extension = value,
                  isOptional: true,
                ),
                buildDropdownField(
                  'Block',
                  blockOption,
                  _block,
                  (value) => setState(() => _block = value!),
                ),
                buildDropdownField(
                  'Lot',
                  lotOptions,
                  _lot,
                  (value) => setState(() => _lot = value!),
                ),
                TextFormField(
                  controller: datePickerController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(labelText: 'Birthdate'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your birthdate';
                    }
                    return null;
                  },
                ),
                buildDropdownField('Gender', genderOptions, _gender,
                    (value) => setState(() => _gender = value!)),
                buildDropdownField('Phase', phaseOptions, _phase,
                    (value) => setState(() => _phase = value!)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
