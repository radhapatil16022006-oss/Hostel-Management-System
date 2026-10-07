import '../core/constants/app_constants.dart';

/// Comprehensive student data model.
class StudentModel {
  final String id;
  final String fullName;
  final DateTime? dob;
  final String phone;
  final String email;
  final String parentPhone;
  final String branch;
  final String year;
  final String address;
  final String? roomNumber;
  final String username;
  final String? profilePictureUrl;
  final AdmissionStatus admissionStatus;
  final AccountStatus accountStatus;
  final DateTime createdAt;

  const StudentModel({
    required this.id,
    required this.fullName,
    this.dob,
    required this.phone,
    required this.email,
    required this.parentPhone,
    required this.branch,
    required this.year,
    required this.address,
    this.roomNumber,
    required this.username,
    this.profilePictureUrl,
    this.admissionStatus = AdmissionStatus.newAdmission,
    this.accountStatus = AccountStatus.active,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'dob': dob?.toIso8601String(),
      'phone': phone,
      'email': email,
      'parentPhone': parentPhone,
      'branch': branch,
      'year': year,
      'address': address,
      'roomNumber': roomNumber,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'admissionStatus': admissionStatus.name,
      'accountStatus': accountStatus.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      id: id,
      fullName: map['fullName'] ?? '',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
      branch: map['branch'] ?? '',
      year: map['year'] ?? '',
      address: map['address'] ?? '',
      roomNumber: map['roomNumber'],
      username: map['username'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      admissionStatus: AdmissionStatus.values.firstWhere(
        (e) => e.name == map['admissionStatus'],
        orElse: () => AdmissionStatus.newAdmission,
      ),
      accountStatus: AccountStatus.values.firstWhere(
        (e) => e.name == map['accountStatus'],
        orElse: () => AccountStatus.active,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
