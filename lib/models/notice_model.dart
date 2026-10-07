import '../core/constants/app_constants.dart';

/// Notice board announcement model.
class NoticeModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final NoticePriority priority;
  final String? attachmentUrl;
  final String? attachmentType;
  final String? attachmentName;
  final String postedBy;
  final bool isPinned;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.priority = NoticePriority.medium,
    this.attachmentUrl,
    this.attachmentType,
    this.attachmentName,
    required this.postedBy,
    this.isPinned = false,
  });

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  bool get isUrgent =>
      priority == NoticePriority.urgent || priority == NoticePriority.high;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'priority': priority.name,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'attachmentName': attachmentName,
      'postedBy': postedBy,
      'isPinned': isPinned,
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map, String id) {
    return NoticeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      priority: NoticePriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NoticePriority.medium,
      ),
      attachmentUrl: map['attachmentUrl'],
      attachmentType: map['attachmentType'],
      attachmentName: map['attachmentName'],
      postedBy: map['postedBy'] ?? '',
      isPinned: map['isPinned'] ?? false,
    );
  }
}
