import '../core/constants/app_constants.dart';

/// Student complaint data model.
class ComplaintModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? roomNumber;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final ComplaintStatus status;
  final String? rectorResponse;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ComplaintModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.roomNumber,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    this.status = ComplaintStatus.pending,
    this.rectorResponse,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'status': status.name,
      'rectorResponse': rectorResponse,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String id) {
    return ComplaintModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      imageUrl: map['imageUrl'],
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplaintStatus.pending,
      ),
      rectorResponse: map['rectorResponse'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
    );
  }
}
