class RfidRequest {
  final String? rfid;
  final DateTime? expiryDate;
  final String status;

  RfidRequest({this.rfid, this.expiryDate, required this.status});

  factory RfidRequest.fromJson(Map<String, dynamic> json) {
    return RfidRequest(
      rfid: json['rfid'],
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      status: json['status'],
    );
  }
}

class Visitor {
  final int id;
  final String name;
  final String? plateNumber;
  final RfidRequest? rfidRequest;

  Visitor({
    required this.id,
    required this.name,
    this.plateNumber,
    this.rfidRequest,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'],
      name: json['name'],
      plateNumber: json['plate_number'],
      rfidRequest: json['rfid_request'] != null
          ? RfidRequest.fromJson(json['rfid_request'])
          : null,
    );
  }
}
