/// Daily mess menu model.
class MessMenuModel {
  final String id;
  final String dayOfWeek;
  final String breakfast;
  final String lunch;
  final String dinner;
  final DateTime updatedAt;
  final String updatedBy;

  const MessMenuModel({
    required this.id,
    required this.dayOfWeek,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.updatedAt,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory MessMenuModel.fromMap(Map<String, dynamic> map, String id) {
    return MessMenuModel(
      id: id,
      dayOfWeek: map['dayOfWeek'] ?? '',
      breakfast: map['breakfast'] ?? '',
      lunch: map['lunch'] ?? '',
      dinner: map['dinner'] ?? '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedBy: map['updatedBy'] ?? '',
    );
  }
}

/// Student mess feedback submission.
class MessFeedbackModel {
  final String id;
  final String studentId;
  final String studentName;
  final double rating;
  final String comments;
  final DateTime date;

  const MessFeedbackModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rating,
    required this.comments,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'rating': rating,
      'comments': comments,
      'date': date.toIso8601String(),
    };
  }

  factory MessFeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return MessFeedbackModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      comments: map['comments'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
