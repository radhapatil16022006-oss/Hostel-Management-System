/// Application-wide domain constants, enums, and dropdown lists.
enum UserRole {
  rector,
  student,
}

enum AdmissionStatus {
  newAdmission,
  oldAdmission,
  deletedAdmission,
}

enum FeeStatus {
  paid,
  partiallyPaid,
  pending,
}

enum AttendanceStatus {
  present,
  absent,
}

enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
}

enum NoticePriority {
  low,
  medium,
  high,
  urgent,
}

enum AccountStatus {
  active,
  inactive,
}

class AppConstants {
  AppConstants._();

  static const List<String> branches = [
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Telecommunication',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Artificial Intelligence & Data Science',
    'Robotics & Automation',
  ];

  static const List<String> academicYears = [
    'First Year (FE)',
    'Second Year (SE)',
    'Third Year (TE)',
    'Final Year (BE)',
  ];

  static const List<int> roomCapacities = [1, 2, 3, 4, 6];

  static const List<String> complaintCategories = [
    'Room',
    'Mess',
    'Maintenance',
    'Electricity',
    'Water',
    'Cleanliness',
    'Wi-Fi / Internet',
    'Other',
  ];

  static const List<String> leaveTypes = [
    'Home Visit',
    'Academic / Seminar',
    'Medical',
    'Family Event',
    'Emergency',
    'Other',
  ];

  static const List<String> paymentModes = [
    'UPI / QR',
    'Net Banking',
    'Debit / Credit Card',
    'Demand Draft',
    'Cash',
  ];
}
