class User {
  String? id;
  String email;
  String? password;
  String fname;
  String lname;
  String phone;
  String birthdate;
  String gender;
  String phase;
  String block;
  String lot;
  String? plate;
  String? extension;
  String? mname;
  String? image; // Store the image URL or path
  String? position;
  String? status;
  String? imageBase64; // Optional field to store image as base64
  String? document; // Corresponds to `document_image` in the database
  String? documentBase64; // For document image in base64 format

  User({
    this.id,
    required this.email,
    this.password,
    required this.fname,
    required this.lname,
    required this.phone,
    required this.birthdate,
    required this.gender,
    required this.phase,
    required this.block,
    required this.lot,
    this.plate,
    this.extension,
    this.mname,
    this.image,
    this.position,
    this.status,
    this.imageBase64,
    this.document,
    this.documentBase64,
  });

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fname': fname,
      'lname': lname,
      'phone': phone,
      'birthdate': birthdate,
      'gender': gender,
      'phase': phase,
      'block': block,
      'lot': lot,
      'plate': plate,
      'extension': extension,
      'mname': mname,
      'image': image,
      'position': position,
      'status': status,
      'imageBase64': imageBase64,
      'document': document,
      'documentBase64': documentBase64,
    };
  }

  // Create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      email: json['email'] ?? '',
      password: json['password'],
      fname: json['fname'] ?? '',
      lname: json['lname'] ?? '',
      phone: json['phone'] ?? '',
      birthdate: json['birthdate'] ?? '',
      gender: json['gender'] ?? '',
      phase: json['phase'] ?? '',
      block: json['block'] ?? '',
      lot: json['lot'] ?? '',
      plate: json['plate'],
      extension: json['extension'],
      mname: json['mname'],
      image: json['image'],
      position: json['position'],
      status: json['status'],
      imageBase64: json['imageBase64'],
      document: json['document'], // Maps to `document_image`
      documentBase64: json['documentBase64'],
    );
  }
}
