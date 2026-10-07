import '../core/constants/app_constants.dart';

/// Attendance record model.
class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? roomNumber;
  final String? branch;
  final String? year;
  final DateTime date;
  final AttendanceStatus status;
  final String markedBy;

  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.roomNumber,
    this.branch,
    this.year,
    required this.date,
    required this.status,
    required this.markedBy,
  });

  bool get isPresent => status == AttendanceStatus.present;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'branch': branch,
      'year': year,
      'date': date.toIso8601String(),
      'status': status.name,
      'markedBy': markedBy,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'],
      branch: map['branch'],
      year: map['year'],
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.present,
      ),
      markedBy: map['markedBy'] ?? '',
    );
  }
}
