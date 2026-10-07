import '../core/constants/app_constants.dart';

/// Letter-style student leave application model.
class LeaveModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? roomNumber;
  final String? branch;
  final String? year;
  final DateTime leaveFrom;
  final DateTime leaveTo;
  final String reason;
  final String? leaveType;
  final String? parentContact;
  final DateTime applicationDate;
  final LeaveStatus status;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  const LeaveModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.roomNumber,
    this.branch,
    this.year,
    required this.leaveFrom,
    required this.leaveTo,
    required this.reason,
    this.leaveType,
    this.parentContact,
    required this.applicationDate,
    this.status = LeaveStatus.pending,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
  });

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
  bool get isRejected => status == LeaveStatus.rejected;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'branch': branch,
      'year': year,
      'leaveFrom': leaveFrom.toIso8601String(),
      'leaveTo': leaveTo.toIso8601String(),
      'reason': reason,
      'leaveType': leaveType,
      'parentContact': parentContact,
      'applicationDate': applicationDate.toIso8601String(),
      'status': status.name,
      'rejectionReason': rejectionReason,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory LeaveModel.fromMap(Map<String, dynamic> map, String id) {
    return LeaveModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'],
      branch: map['branch'],
      year: map['year'],
      leaveFrom: map['leaveFrom'] != null
          ? DateTime.tryParse(map['leaveFrom']) ?? DateTime.now()
          : DateTime.now(),
      leaveTo: map['leaveTo'] != null
          ? DateTime.tryParse(map['leaveTo']) ?? DateTime.now()
          : DateTime.now(),
      reason: map['reason'] ?? '',
      leaveType: map['leaveType'],
      parentContact: map['parentContact'],
      applicationDate: map['applicationDate'] != null
          ? DateTime.tryParse(map['applicationDate']) ?? DateTime.now()
          : DateTime.now(),
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LeaveStatus.pending,
      ),
      rejectionReason: map['rejectionReason'],
      reviewedBy: map['reviewedBy'],
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.tryParse(map['reviewedAt'])
          : null,
    );
  }
}
