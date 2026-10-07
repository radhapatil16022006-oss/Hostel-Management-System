import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/attendance_model.dart';
import '../models/complaint_model.dart';
import '../models/fee_model.dart';
import '../models/mess_model.dart';
import '../models/notice_model.dart';
import '../models/room_model.dart';
import '../models/student_model.dart';
import '../models/visitor_model.dart';

class HostelStore extends ChangeNotifier {
  HostelStore() {
    _seed();
  }

  final List<StudentModel> _students = [];
  final List<RoomModel> _rooms = [];
  final List<FeeModel> _fees = [];
  final List<ComplaintModel> _complaints = [];
  final List<NoticeModel> _notices = [];
  final List<AttendanceModel> _attendance = [];
  final List<VisitorModel> _visitors = [];
  late MessMenuModel _todayMenu;

  List<StudentModel> get students => List.unmodifiable(_students);
  List<RoomModel> get rooms => List.unmodifiable(_rooms);
  List<FeeModel> get fees => List.unmodifiable(_fees);
  List<ComplaintModel> get complaints => List.unmodifiable(_complaints);
  List<NoticeModel> get notices => List.unmodifiable(_notices);
  List<AttendanceModel> get attendance => List.unmodifiable(_attendance);
  List<VisitorModel> get visitors => List.unmodifiable(_visitors);
  MessMenuModel get todayMenu => _todayMenu;

  int get occupiedBeds => _rooms.fold(0, (sum, room) => sum + room.occupied);
  int get availableBeds =>
      _rooms.fold(0, (sum, room) => sum + room.availableBeds);
  int get availableRooms => _rooms.where((room) => !room.isFull).length;
  num get pendingFees => _fees.fold(0, (sum, fee) => sum + fee.pendingAmount);
  int get activeComplaints => _complaints
      .where((item) => item.status != ComplaintStatus.resolved)
      .length;
  int get pendingComplaintCount => _complaints
      .where((item) => item.status == ComplaintStatus.pending)
      .length;

  StudentModel? studentById(String id) {
    for (final student in _students) {
      if (student.id == id) return student;
    }
    return null;
  }

  RoomModel? roomForStudent(String studentId) {
    for (final room in _rooms) {
      if (room.studentIds.contains(studentId)) return room;
    }
    return null;
  }

  FeeModel? feeForStudent(String studentId) {
    for (final fee in _fees) {
      if (fee.studentId == studentId) return fee;
    }
    return null;
  }

  void addStudent({
    required String fullName,
    required String phone,
    required String email,
    required String branch,
    required String year,
  }) {
    final id = 'student_${DateTime.now().microsecondsSinceEpoch}';
    _students.insert(
      0,
      StudentModel(
        id: id,
        fullName: fullName,
        phone: phone,
        email: email,
        parentPhone: '',
        branch: branch,
        year: year,
        address: '',
        username: id,
        createdAt: DateTime.now(),
      ),
    );
    _fees.insert(
      0,
      FeeModel(
        id: 'fee_$id',
        studentId: id,
        studentName: fullName,
        academicYear: '2026-27',
        totalFee: 72000,
        paidAmount: 0,
      ),
    );
    _attendance.insert(
      0,
      AttendanceModel(
        id: 'attendance_${id}_${_dateKey(DateTime.now())}',
        studentId: id,
        studentName: fullName,
        branch: branch,
        year: year,
        date: DateTime.now(),
        status: AttendanceStatus.present,
        markedBy: 'Warden',
      ),
    );
    notifyListeners();
  }

  void updateStudent(StudentModel updated) {
    final index = _students.indexWhere((student) => student.id == updated.id);
    if (index < 0) return;
    final existing = _students[index];
    final student = _copyStudentDetails(updated, existing);
    _students[index] = student;
    final currentRoom = roomForStudent(student.id);
    if (currentRoom != null) {
      final roomIndex = _rooms.indexWhere((room) => room.id == currentRoom.id);
      _rooms[roomIndex] = _copyRoom(
        currentRoom,
        studentIds: currentRoom.studentIds,
        studentNames: currentRoom.studentIds
            .map((id) => studentById(id)?.fullName ?? '')
            .toList(),
      );
    }
    final feeIndex = _fees.indexWhere((fee) => fee.studentId == student.id);
    if (feeIndex >= 0) {
      final fee = _fees[feeIndex];
      _fees[feeIndex] = FeeModel(
        id: fee.id,
        studentId: fee.studentId,
        studentName: student.fullName,
        roomNumber: student.roomNumber,
        academicYear: fee.academicYear,
        totalFee: fee.totalFee,
        paidAmount: fee.paidAmount,
        transactions: fee.transactions,
      );
    }
    notifyListeners();
  }

  void deleteStudent(String studentId) {
    final room = roomForStudent(studentId);
    if (room != null) deallocateStudent(room.id, studentId);
    _students.removeWhere((student) => student.id == studentId);
    _fees.removeWhere((fee) => fee.studentId == studentId);
    _attendance.removeWhere((record) => record.studentId == studentId);
    _complaints.removeWhere((item) => item.studentId == studentId);
    notifyListeners();
  }

  void addRoom({
    required String roomNumber,
    required int floor,
    required int capacity,
  }) {
    _rooms.add(
      RoomModel(
        id: 'room_${roomNumber.toLowerCase()}',
        roomNumber: roomNumber,
        floor: floor,
        capacity: capacity,
        occupied: 0,
      ),
    );
    notifyListeners();
  }

  void updateRoom(RoomModel updated) {
    final index = _rooms.indexWhere((room) => room.id == updated.id);
    if (index < 0) return;
    final current = _rooms[index];
    _rooms[index] = RoomModel(
      id: current.id,
      roomNumber: updated.roomNumber,
      floor: updated.floor,
      capacity: updated.capacity < current.occupied
          ? current.occupied
          : updated.capacity,
      occupied: current.occupied,
      studentIds: current.studentIds,
      studentNames: current.studentNames,
      notes: updated.notes,
    );
    if (current.roomNumber != updated.roomNumber) {
      for (final studentId in current.studentIds) {
        final studentIndex = _students.indexWhere(
          (student) => student.id == studentId,
        );
        if (studentIndex >= 0) {
          _students[studentIndex] = _copyStudent(
            _students[studentIndex],
            roomNumber: updated.roomNumber,
          );
          _syncFeeRoom(studentId, updated.roomNumber);
        }
      }
    }
    notifyListeners();
  }

  void deleteRoom(String roomId) {
    final room = _rooms.firstWhere((item) => item.id == roomId);
    if (room.occupied > 0) return;
    _rooms.removeWhere((item) => item.id == roomId);
    notifyListeners();
  }

  bool allocateStudent(String roomId, String studentId) {
    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
    final studentIndex = _students.indexWhere(
      (student) => student.id == studentId,
    );
    if (roomIndex < 0 || studentIndex < 0) return false;
    final room = _rooms[roomIndex];
    if (room.isFull || room.studentIds.contains(studentId)) return false;
    final student = _students[studentIndex];
    final previousRoom = roomForStudent(studentId);
    if (previousRoom != null) deallocateStudent(previousRoom.id, studentId);
    final target = _rooms[roomIndex];
    _rooms[roomIndex] = _copyRoom(
      target,
      studentIds: [...target.studentIds, studentId],
      studentNames: [...target.studentNames, student.fullName],
    );
    _students[studentIndex] = _copyStudent(
      student,
      roomNumber: target.roomNumber,
    );
    _syncFeeRoom(studentId, target.roomNumber);
    notifyListeners();
    return true;
  }

  void deallocateStudent(String roomId, String studentId) {
    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
    if (roomIndex < 0) return;
    final room = _rooms[roomIndex];
    if (!room.studentIds.contains(studentId)) return;
    final studentIndex = _students.indexWhere(
      (student) => student.id == studentId,
    );
    _rooms[roomIndex] = _copyRoom(
      room,
      studentIds: room.studentIds.where((id) => id != studentId).toList(),
      studentNames: [
        for (var index = 0; index < room.studentIds.length; index++)
          if (room.studentIds[index] != studentId &&
              index < room.studentNames.length)
            room.studentNames[index],
      ],
    );
    if (studentIndex >= 0) {
      _students[studentIndex] = _copyStudent(
        _students[studentIndex],
        roomNumber: null,
      );
      _syncFeeRoom(studentId, null);
    }
    notifyListeners();
  }

  void recordFeePayment(String feeId, num amount, String mode) {
    final index = _fees.indexWhere((fee) => fee.id == feeId);
    if (index < 0 || amount <= 0) return;
    final fee = _fees[index];
    final boundedAmount = amount > fee.pendingAmount
        ? fee.pendingAmount
        : amount;
    if (boundedAmount <= 0) return;
    _fees[index] = FeeModel(
      id: fee.id,
      studentId: fee.studentId,
      studentName: fee.studentName,
      roomNumber: fee.roomNumber,
      academicYear: fee.academicYear,
      totalFee: fee.totalFee,
      paidAmount: fee.paidAmount + boundedAmount,
      transactions: [
        ...fee.transactions,
        FeePaymentTransaction(
          id: 'txn_${DateTime.now().microsecondsSinceEpoch}',
          amount: boundedAmount,
          date: DateTime.now(),
          paymentMode: mode,
          receiptNumber: 'HMS-${DateTime.now().millisecondsSinceEpoch}',
        ),
      ],
    );
    notifyListeners();
  }

  void addComplaint({
    required String studentId,
    required String title,
    required String description,
    required String category,
  }) {
    final student = studentById(studentId);
    if (student == null) return;
    _complaints.insert(
      0,
      ComplaintModel(
        id: 'complaint_${DateTime.now().microsecondsSinceEpoch}',
        studentId: student.id,
        studentName: student.fullName,
        roomNumber: student.roomNumber,
        title: title,
        description: description,
        category: category,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateComplaintStatus(
    String complaintId,
    ComplaintStatus status, {
    String? response,
  }) {
    final index = _complaints.indexWhere((item) => item.id == complaintId);
    if (index < 0) return;
    final item = _complaints[index];
    _complaints[index] = ComplaintModel(
      id: item.id,
      studentId: item.studentId,
      studentName: item.studentName,
      roomNumber: item.roomNumber,
      title: item.title,
      description: item.description,
      category: item.category,
      imageUrl: item.imageUrl,
      status: status,
      rectorResponse: response ?? item.rectorResponse,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void addNotice({
    required String title,
    required String description,
    required NoticePriority priority,
  }) {
    _notices.insert(
      0,
      NoticeModel(
        id: 'notice_${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        description: description,
        date: DateTime.now(),
        priority: priority,
        postedBy: 'Warden',
      ),
    );
    notifyListeners();
  }

  void deleteNotice(String noticeId) {
    _notices.removeWhere((notice) => notice.id == noticeId);
    notifyListeners();
  }

  void markAttendance(String studentId, AttendanceStatus status) {
    final student = studentById(studentId);
    if (student == null) return;
    final today = DateTime.now();
    final index = _attendance.indexWhere(
      (record) =>
          record.studentId == studentId &&
          _dateKey(record.date) == _dateKey(today),
    );
    final record = AttendanceModel(
      id: index >= 0
          ? _attendance[index].id
          : 'attendance_${studentId}_${_dateKey(today)}',
      studentId: student.id,
      studentName: student.fullName,
      roomNumber: student.roomNumber,
      branch: student.branch,
      year: student.year,
      date: today,
      status: status,
      markedBy: 'Warden',
    );
    if (index >= 0) {
      _attendance[index] = record;
    } else {
      _attendance.add(record);
    }
    notifyListeners();
  }

  void addVisitor({
    required String visitorName,
    required String studentId,
    required String relation,
    required String purpose,
  }) {
    final student = studentById(studentId);
    if (student == null) return;
    final now = DateTime.now();
    _visitors.insert(
      0,
      VisitorModel(
        id: 'visitor_${now.microsecondsSinceEpoch}',
        visitorName: visitorName,
        visitorPlace: 'Local visitor',
        relation: relation,
        studentName: student.fullName,
        studentId: student.id,
        date: now,
        entryTime: _timeLabel(now),
        purpose: purpose,
        recordedBy: 'Warden',
      ),
    );
    notifyListeners();
  }

  void recordVisitorExit(String visitorId) {
    final index = _visitors.indexWhere((visitor) => visitor.id == visitorId);
    if (index < 0) return;
    final visitor = _visitors[index];
    _visitors[index] = VisitorModel(
      id: visitor.id,
      visitorName: visitor.visitorName,
      visitorPlace: visitor.visitorPlace,
      relation: visitor.relation,
      studentName: visitor.studentName,
      studentId: visitor.studentId,
      date: visitor.date,
      entryTime: visitor.entryTime,
      exitTime: _timeLabel(DateTime.now()),
      purpose: visitor.purpose,
      recordedBy: visitor.recordedBy,
    );
    notifyListeners();
  }

  void updateTodayMenu({
    required String breakfast,
    required String lunch,
    required String dinner,
  }) {
    _todayMenu = MessMenuModel(
      id: _todayMenu.id,
      dayOfWeek: _todayMenu.dayOfWeek,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      updatedAt: DateTime.now(),
      updatedBy: 'Warden',
    );
    notifyListeners();
  }

  void _syncFeeRoom(String studentId, String? roomNumber) {
    final index = _fees.indexWhere((fee) => fee.studentId == studentId);
    if (index < 0) return;
    final fee = _fees[index];
    _fees[index] = FeeModel(
      id: fee.id,
      studentId: fee.studentId,
      studentName: fee.studentName,
      roomNumber: roomNumber,
      academicYear: fee.academicYear,
      totalFee: fee.totalFee,
      paidAmount: fee.paidAmount,
      transactions: fee.transactions,
    );
  }

  RoomModel _copyRoom(
    RoomModel room, {
    required List<String> studentIds,
    required List<String> studentNames,
  }) {
    return RoomModel(
      id: room.id,
      roomNumber: room.roomNumber,
      floor: room.floor,
      capacity: room.capacity,
      occupied: studentIds.length,
      studentIds: studentIds,
      studentNames: studentNames,
      notes: room.notes,
    );
  }

  StudentModel _copyStudent(
    StudentModel student, {
    required String? roomNumber,
  }) {
    return StudentModel(
      id: student.id,
      fullName: student.fullName,
      dob: student.dob,
      phone: student.phone,
      email: student.email,
      parentPhone: student.parentPhone,
      branch: student.branch,
      year: student.year,
      address: student.address,
      roomNumber: roomNumber,
      username: student.username,
      profilePictureUrl: student.profilePictureUrl,
      admissionStatus: student.admissionStatus,
      accountStatus: student.accountStatus,
      createdAt: student.createdAt,
    );
  }

  StudentModel _copyStudentDetails(
    StudentModel updated,
    StudentModel existing,
  ) {
    return StudentModel(
      id: updated.id,
      fullName: updated.fullName,
      dob: updated.dob,
      phone: updated.phone,
      email: updated.email,
      parentPhone: updated.parentPhone,
      branch: updated.branch,
      year: updated.year,
      address: updated.address,
      roomNumber: existing.roomNumber,
      username: updated.username,
      profilePictureUrl: updated.profilePictureUrl,
      admissionStatus: updated.admissionStatus,
      accountStatus: updated.accountStatus,
      createdAt: existing.createdAt,
    );
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  String _timeLabel(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  void _seed() {
    final today = DateTime.now();
    final sampleStudents = <StudentModel>[
      _student(
        'student_001',
        'Rahul Deshmukh',
        '9876543210',
        'rahul@campus.edu',
        'Computer Science & Engineering',
        'Second Year (SE)',
        '101',
      ),
      _student(
        'student_002',
        'Aditi Kulkarni',
        '9823014567',
        'aditi@campus.edu',
        'Information Technology',
        'Third Year (TE)',
        '101',
      ),
      _student(
        'student_003',
        'Neha Patil',
        '9765432108',
        'neha@campus.edu',
        'Electronics & Telecommunication',
        'First Year (FE)',
        '102',
      ),
      _student(
        'student_004',
        'Arjun Mehta',
        '9890123456',
        'arjun@campus.edu',
        'Mechanical Engineering',
        'Final Year (BE)',
        '102',
      ),
      _student(
        'student_005',
        'Sara Khan',
        '9812345607',
        'sara@campus.edu',
        'Artificial Intelligence & Data Science',
        'Second Year (SE)',
        '201',
      ),
      _student(
        'student_006',
        'Ishaan Joshi',
        '9930456123',
        'ishaan@campus.edu',
        'Civil Engineering',
        'Third Year (TE)',
        '201',
      ),
      _student(
        'student_007',
        'Mira Shah',
        '9867012345',
        'mira@campus.edu',
        'Computer Science & Engineering',
        'Final Year (BE)',
        '201',
      ),
      _student(
        'student_008',
        'Dev Nair',
        '9898765432',
        'dev@campus.edu',
        'Electrical Engineering',
        'First Year (FE)',
        '202',
      ),
      _student(
        'student_009',
        'Priya Iyer',
        '9819087654',
        'priya@campus.edu',
        'Robotics & Automation',
        'Second Year (SE)',
        '204',
      ),
    ];
    _students.addAll(sampleStudents);
    _rooms.addAll([
      _room('room_101', '101', 1, 3, [
        'student_001',
        'student_002',
      ], sampleStudents),
      _room('room_102', '102', 1, 2, [
        'student_003',
        'student_004',
      ], sampleStudents),
      _room('room_201', '201', 2, 3, [
        'student_005',
        'student_006',
        'student_007',
      ], sampleStudents),
      _room('room_202', '202', 2, 2, ['student_008'], sampleStudents),
      _room('room_203', '203', 2, 3, [], sampleStudents),
      _room('room_204', '204', 2, 2, ['student_009'], sampleStudents),
      _room('room_301', '301', 3, 4, [], sampleStudents),
    ]);
    const paidAmounts = [
      72000,
      48000,
      72000,
      24000,
      60000,
      0,
      72000,
      36000,
      72000,
    ];
    for (var index = 0; index < sampleStudents.length; index++) {
      final student = sampleStudents[index];
      final paid = paidAmounts[index];
      _fees.add(
        FeeModel(
          id: 'fee_${student.id}',
          studentId: student.id,
          studentName: student.fullName,
          roomNumber: student.roomNumber,
          academicYear: '2026-27',
          totalFee: 72000,
          paidAmount: paid,
          transactions: paid > 0
              ? [
                  FeePaymentTransaction(
                    id: 'txn_${student.id}',
                    amount: paid,
                    date: today.subtract(const Duration(days: 18)),
                    paymentMode: 'UPI / QR',
                    receiptNumber: 'HMS-${2400 + index}',
                  ),
                ]
              : const [],
        ),
      );
      _attendance.add(
        AttendanceModel(
          id: 'attendance_${student.id}_${_dateKey(today)}',
          studentId: student.id,
          studentName: student.fullName,
          roomNumber: student.roomNumber,
          branch: student.branch,
          year: student.year,
          date: today,
          status: index == 5
              ? AttendanceStatus.absent
              : AttendanceStatus.present,
          markedBy: 'Warden',
        ),
      );
    }
    _complaints.addAll([
      ComplaintModel(
        id: 'complaint_001',
        studentId: 'student_003',
        studentName: 'Neha Patil',
        roomNumber: '102',
        title: 'Bathroom tap is leaking',
        description: 'The washbasin tap has been dripping since yesterday and needs a washer replacement.',
        category: 'Maintenance',
        status: ComplaintStatus.inProgress,
        createdAt: today.subtract(const Duration(hours: 5)),
        rectorResponse: 'Maintenance team assigned for today.',
      ),
      ComplaintModel(
        id: 'complaint_002',
        studentId: 'student_005',
        studentName: 'Sara Khan',
        roomNumber: '201',
        title: 'Wi-Fi signal in second floor',
        description:
            'The connection drops frequently near the east wing study area.',
        category: 'Wi-Fi / Internet',
        createdAt: today.subtract(const Duration(days: 1)),
      ),
      ComplaintModel(
        id: 'complaint_003',
        studentId: 'student_001',
        studentName: 'Rahul Deshmukh',
        roomNumber: '101',
        title: 'Desk lamp replacement',
        description: 'The study lamp in the room is no longer working.',
        category: 'Electricity',
        status: ComplaintStatus.resolved,
        createdAt: today.subtract(const Duration(days: 3)),
        rectorResponse: 'Replaced by the electrician.',
      ),
      ComplaintModel(
        id: 'complaint_004',
        studentId: 'student_008',
        studentName: 'Dev Nair',
        roomNumber: '202',
        title: 'Dining hall water dispenser',
        description:
            'Please check the dispenser near the dining hall entrance.',
        category: 'Water',
        createdAt: today.subtract(const Duration(hours: 16)),
      ),
    ]);
    _notices.addAll([
      NoticeModel(
        id: 'notice_001',
        title: 'Annual hostel meeting',
        description: 'Residents are requested to attend the common hall meeting on Friday at 6:00 PM.',
        date: today.subtract(const Duration(hours: 3)),
        priority: NoticePriority.high,
        postedBy: 'Dr. Sunita Sharma',
        isPinned: true,
      ),
      NoticeModel(
        id: 'notice_002',
        title: 'Mess menu feedback',
        description: 'Share your suggestions for next month\'s menu with the mess committee by Wednesday.',
        date: today.subtract(const Duration(days: 1)),
        priority: NoticePriority.medium,
        postedBy: 'Mess Committee',
      ),
      NoticeModel(
        id: 'notice_003',
        title: 'Quiet hours reminder',
        description: 'Please observe quiet hours from 10:30 PM to 6:00 AM in all residential wings.',
        date: today.subtract(const Duration(days: 2)),
        priority: NoticePriority.low,
        postedBy: 'Warden',
      ),
    ]);
    _visitors.addAll([
      VisitorModel(
        id: 'visitor_001',
        visitorName: 'Anita Patil',
        visitorPlace: 'Pune',
        relation: 'Parent',
        studentName: 'Neha Patil',
        studentId: 'student_003',
        date: today,
        entryTime: '10:25',
        purpose: 'Student visit',
        recordedBy: 'Front desk',
      ),
      VisitorModel(
        id: 'visitor_002',
        visitorName: 'Rohan Deshmukh',
        visitorPlace: 'Nashik',
        relation: 'Sibling',
        studentName: 'Rahul Deshmukh',
        studentId: 'student_001',
        date: today,
        entryTime: '09:10',
        exitTime: '09:45',
        purpose: 'Document drop-off',
        recordedBy: 'Front desk',
      ),
    ]);
    _todayMenu = MessMenuModel(
      id: 'menu_${today.weekday}',
      dayOfWeek: _weekdayName(today.weekday),
      breakfast: 'Poha, boiled eggs, bananas and tea',
      lunch: 'Dal tadka, jeera rice, chapati and seasonal vegetables',
      dinner: 'Paneer curry, pulao, salad and fruit',
      updatedAt: today,
      updatedBy: 'Mess Committee',
    );
  }

  StudentModel _student(
    String id,
    String name,
    String phone,
    String email,
    String branch,
    String year,
    String room,
  ) {
    return StudentModel(
      id: id,
      fullName: name,
      dob: DateTime(2005, 4, 12),
      phone: phone,
      email: email,
      parentPhone: '98${phone.substring(2)}',
      branch: branch,
      year: year,
      address: 'Maharashtra, India',
      roomNumber: room,
      username: id,
      admissionStatus: AdmissionStatus.oldAdmission,
      createdAt: DateTime(2024, 6, 15),
    );
  }

  RoomModel _room(
    String id,
    String number,
    int floor,
    int capacity,
    List<String> occupants,
    List<StudentModel> students,
  ) {
    return RoomModel(
      id: id,
      roomNumber: number,
      floor: floor,
      capacity: capacity,
      occupied: occupants.length,
      studentIds: occupants,
      studentNames: occupants
          .map(
            (studentId) => students
                .firstWhere((student) => student.id == studentId)
                .fullName,
          )
          .toList(),
    );
  }

  String _weekdayName(int weekday) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}
