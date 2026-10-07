/// Digital visitor register model.
class VisitorModel {
  final String id;
  final String visitorName;
  final String visitorPlace;
  final String relation;
  final String studentName;
  final String? studentId;
  final DateTime date;
  final String entryTime;
  final String? exitTime;
  final String purpose;
  final String? recordedBy;

  const VisitorModel({
    required this.id,
    required this.visitorName,
    required this.visitorPlace,
    required this.relation,
    required this.studentName,
    this.studentId,
    required this.date,
    required this.entryTime,
    this.exitTime,
    required this.purpose,
    this.recordedBy,
  });

  bool get hasExited => exitTime != null && exitTime!.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visitorName': visitorName,
      'visitorPlace': visitorPlace,
      'relation': relation,
      'studentName': studentName,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'entryTime': entryTime,
      'exitTime': exitTime,
      'purpose': purpose,
      'recordedBy': recordedBy,
    };
  }

  factory VisitorModel.fromMap(Map<String, dynamic> map, String id) {
    return VisitorModel(
      id: id,
      visitorName: map['visitorName'] ?? '',
      visitorPlace: map['visitorPlace'] ?? '',
      relation: map['relation'] ?? '',
      studentName: map['studentName'] ?? '',
      studentId: map['studentId'],
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      entryTime: map['entryTime'] ?? '',
      exitTime: map['exitTime'],
      purpose: map['purpose'] ?? '',
      recordedBy: map['recordedBy'],
    );
  }
}
