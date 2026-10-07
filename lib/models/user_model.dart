import '../core/constants/app_constants.dart';

/// Base user model for Rector and Student.
class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String phone;
  final DateTime? dob;
  final String? profilePictureUrl;
  final UserRole role;
  final AccountStatus accountStatus;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.phone,
    this.dob,
    this.profilePictureUrl,
    required this.role,
    this.accountStatus = AccountStatus.active,
    required this.createdAt,
  });

  bool get isRector => role == UserRole.rector;
  bool get isStudent => role == UserRole.student;
  bool get isActive => accountStatus == AccountStatus.active;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'phone': phone,
      'dob': dob?.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
      'role': role.name,
      'accountStatus': accountStatus.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      username: map['username'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      profilePictureUrl: map['profilePictureUrl'],
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.student,
      ),
      accountStatus: AccountStatus.values.firstWhere(
        (s) => s.name == map['accountStatus'],
        orElse: () => AccountStatus.active,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
