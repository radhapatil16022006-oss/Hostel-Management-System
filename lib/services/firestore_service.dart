import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firebase_initializer.dart';
import '../models/student_model.dart';
import '../models/room_model.dart';
import '../models/fee_model.dart';
import '../models/complaint_model.dart';

abstract class FirestoreService {
  // Students
  Stream<List<StudentModel>> streamStudents();
  Future<void> addStudent(StudentModel student);
  Future<void> updateStudent(StudentModel student);
  Future<void> deleteStudent(String studentId);

  // Rooms & Allocation
  Stream<List<RoomModel>> streamRooms();
  Future<void> createRoom(RoomModel room);
  Future<void> allocateStudentToRoom({
    required String roomId,
    required String studentId,
    required String studentName,
  });
  Future<void> removeStudentFromRoom({
    required String roomId,
    required String studentId,
  });

  // Fees
  Stream<List<FeeModel>> streamFees();
  Stream<FeeModel?> streamFeeForStudent(String studentId);
  Future<void> recordFeePayment({
    required String studentId,
    required num amount,
    required String paymentMode,
  });

  // Complaints
  Stream<List<ComplaintModel>> streamComplaints();
  Stream<List<ComplaintModel>> streamComplaintsForStudent(String studentId);
  Future<void> submitComplaint(ComplaintModel complaint);
  Future<void> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
    String? rectorResponse,
  });
}

class AppFirestoreService implements FirestoreService {
  final FirebaseFirestore? _firestore =
      FirebaseInitializer.isInitialized ? FirebaseFirestore.instance : null;

  // Stream controllers for reactive updates
  final StreamController<List<StudentModel>> _studentsCtrl =
      StreamController<List<StudentModel>>.broadcast();
  final StreamController<List<RoomModel>> _roomsCtrl =
      StreamController<List<RoomModel>>.broadcast();
  final StreamController<List<FeeModel>> _feesCtrl =
      StreamController<List<FeeModel>>.broadcast();
  final StreamController<List<ComplaintModel>> _complaintsCtrl =
      StreamController<List<ComplaintModel>>.broadcast();

  // In-memory persistent state (pre-populated with professional hostel sample data)
  final List<StudentModel> _students = [];
  final List<RoomModel> _rooms = [];
  final List<FeeModel> _fees = [];
  final List<ComplaintModel> _complaints = [];

  AppFirestoreService() {
    _seedInitialData();
  }

  void _seedInitialData() {
    // 1. Initial Students
    _students.addAll([
      StudentModel(
        id: 'student_01',
        fullName: 'Rahul Deshmukh',
        dob: DateTime(2004, 3, 22),
        phone: '9123456780',
        email: 'rahul.deshmukh@hostel.com',
        parentPhone: '9876543211',
        branch: 'Computer Science & Engineering',
        year: 'Second Year (SE)',
        address: 'Pune, Maharashtra',
        roomNumber: '101',
        username: 'rahul.deshmukh',
        admissionStatus: AdmissionStatus.oldAdmission,
        accountStatus: AccountStatus.active,
        createdAt: DateTime(2025, 1, 15),
      ),
      StudentModel(
        id: 'student_02',
        fullName: 'Priya Sharma',
        dob: DateTime(2004, 8, 14),
        phone: '9876543210',
        email: 'priya.sharma@hostel.com',
        parentPhone: '9822334455',
        branch: 'Information Technology',
        year: 'Third Year (TE)',
        address: 'Mumbai, Maharashtra',
        roomNumber: '101',
        username: 'priya.sharma',
        admissionStatus: AdmissionStatus.oldAdmission,
        accountStatus: AccountStatus.active,
        createdAt: DateTime(2024, 8, 20),
      ),
      StudentModel(
        id: 'student_03',
        fullName: 'Ananya Patel',
        dob: DateTime(2005, 1, 10),
        phone: '9988776655',
        email: 'ananya.patel@hostel.com',
        parentPhone: '9911223344',
        branch: 'Electronics & Telecommunication',
        year: 'First Year (FE)',
        address: 'Ahmedabad, Gujarat',
        roomNumber: '102',
        username: 'ananya.patel',
        admissionStatus: AdmissionStatus.newAdmission,
        accountStatus: AccountStatus.active,
        createdAt: DateTime(2025, 7, 5),
      ),
      StudentModel(
        id: 'student_04',
        fullName: 'Aarav Mehta',
        dob: DateTime(2003, 11, 29),
        phone: '9833445566',
        email: 'aarav.mehta@hostel.com',
        parentPhone: '9877001122',
        branch: 'Artificial Intelligence & Data Science',
        year: 'Final Year (BE)',
        address: 'Nagpur, Maharashtra',
        roomNumber: '102',
        username: 'aarav.mehta',
        admissionStatus: AdmissionStatus.oldAdmission,
        accountStatus: AccountStatus.active,
        createdAt: DateTime(2023, 8, 10),
      ),
    ]);

    // 2. Initial Rooms
    _rooms.addAll([
      const RoomModel(
        id: 'room_101',
        roomNumber: '101',
        floor: 1,
        capacity: 3,
        occupied: 2,
        studentIds: ['student_01', 'student_02'],
        studentNames: ['Rahul Deshmukh', 'Priya Sharma'],
        notes: 'East wing facing garden',
      ),
      const RoomModel(
        id: 'room_102',
        roomNumber: '102',
        floor: 1,
        capacity: 2,
        occupied: 2,
        studentIds: ['student_03', 'student_04'],
        studentNames: ['Ananya Patel', 'Aarav Mehta'],
        notes: 'Spacious balcony attached',
      ),
      const RoomModel(
        id: 'room_103',
        roomNumber: '103',
        floor: 1,
        capacity: 3,
        occupied: 0,
        studentIds: [],
        studentNames: [],
        notes: 'Recently painted, ready for allocation',
      ),
      const RoomModel(
        id: 'room_201',
        roomNumber: '201',
        floor: 2,
        capacity: 4,
        occupied: 1,
        studentIds: [],
        studentNames: ['Sneha Joshi'],
        notes: 'Second floor corner room',
      ),
    ]);

    // 3. Initial Fees
    _fees.addAll([
      FeeModel(
        id: 'fee_01',
        studentId: 'student_01',
        studentName: 'Rahul Deshmukh',
        roomNumber: '101',
        academicYear: '2025-2026',
        totalFee: 50000,
        paidAmount: 30000,
        transactions: [
          FeePaymentTransaction(
            id: 'tx_01',
            amount: 30000,
            date: DateTime.now().subtract(const Duration(days: 30)),
            paymentMode: 'UPI / Online',
            receiptNumber: 'REC-2025-001',
          ),
        ],
      ),
      FeeModel(
        id: 'fee_02',
        studentId: 'student_02',
        studentName: 'Priya Sharma',
        roomNumber: '101',
        academicYear: '2025-2026',
        totalFee: 50000,
        paidAmount: 50000,
        transactions: [
          FeePaymentTransaction(
            id: 'tx_02',
            amount: 50000,
            date: DateTime.now().subtract(const Duration(days: 60)),
            paymentMode: 'Net Banking',
            receiptNumber: 'REC-2025-002',
          ),
        ],
      ),
      const FeeModel(
        id: 'fee_03',
        studentId: 'student_03',
        studentName: 'Ananya Patel',
        roomNumber: '102',
        academicYear: '2025-2026',
        totalFee: 50000,
        paidAmount: 0,
        transactions: [],
      ),
    ]);

    // 4. Initial Complaints
    _complaints.addAll([
      ComplaintModel(
        id: 'cmp_01',
        studentId: 'student_01',
        studentName: 'Rahul Deshmukh',
        roomNumber: '101',
        title: 'Ceiling Fan Regulator Malfunction',
        description: 'The ceiling fan does not change speed from step 2 and makes vibrating noise.',
        category: 'Electricity',
        status: ComplaintStatus.inProgress,
        rectorResponse: 'Electrician assigned for inspection today at 4 PM.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ComplaintModel(
        id: 'cmp_02',
        studentId: 'student_02',
        studentName: 'Priya Sharma',
        roomNumber: '101',
        title: 'Low Water Pressure in Bathroom',
        description: 'Water flow from shower and tap is very low in the morning hours.',
        category: 'Water',
        status: ComplaintStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ComplaintModel(
        id: 'cmp_03',
        studentId: 'student_03',
        studentName: 'Ananya Patel',
        roomNumber: '102',
        title: 'Wi-Fi Signal Drops in Balcony Corner',
        description: 'Wi-Fi router on floor 1 disconnects frequently in evening peak hours.',
        category: 'Wi-Fi / Internet',
        status: ComplaintStatus.resolved,
        rectorResponse: 'Access point rebooted and additional range extender configured.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);

    _emitAll();
  }

  void _emitAll() {
    _studentsCtrl.add(List.unmodifiable(_students));
    _roomsCtrl.add(List.unmodifiable(_rooms));
    _feesCtrl.add(List.unmodifiable(_fees));
    _complaintsCtrl.add(List.unmodifiable(_complaints));
  }

  // STUDENTS
  @override
  Stream<List<StudentModel>> streamStudents() {
    if (FirebaseInitializer.isInitialized && _firestore != null) {
      return _firestore.collection('students').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return _students;
        return snapshot.docs.map((doc) => StudentModel.fromMap(doc.data(), doc.id)).toList();
      });
    }
    return _studentsCtrl.stream;
  }

  @override
  Future<void> addStudent(StudentModel student) async {
    _students.removeWhere((s) => s.id == student.id);
    _students.insert(0, student);
    _emitAll();

    if (FirebaseInitializer.isInitialized && _firestore != null) {
      try {
        await _firestore.collection('students').doc(student.id).set(student.toMap());
      } catch (_) {}
    }
  }

  @override
  Future<void> updateStudent(StudentModel student) async {
    final idx = _students.indexWhere((s) => s.id == student.id);
    if (idx != -1) {
      _students[idx] = student;
      _emitAll();
    }
    if (FirebaseInitializer.isInitialized && _firestore != null) {
      try {
        await _firestore.collection('students').doc(student.id).update(student.toMap());
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    _students.removeWhere((s) => s.id == studentId);
    _emitAll();
    if (FirebaseInitializer.isInitialized && _firestore != null) {
      try {
        await _firestore.collection('students').doc(studentId).delete();
      } catch (_) {}
    }
  }

  // ROOMS & ALLOCATION
  @override
  Stream<List<RoomModel>> streamRooms() {
    if (FirebaseInitializer.isInitialized && _firestore != null) {
      return _firestore.collection('rooms').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return _rooms;
        return snapshot.docs.map((doc) => RoomModel.fromMap(doc.data(), doc.id)).toList();
      });
    }
    return _roomsCtrl.stream;
  }

  @override
  Future<void> createRoom(RoomModel room) async {
    _rooms.add(room);
    _emitAll();
    if (FirebaseInitializer.isInitialized && _firestore != null) {
      try {
        await _firestore.collection('rooms').doc(room.id).set(room.toMap());
      } catch (_) {}
    }
  }

  @override
  Future<void> allocateStudentToRoom({
    required String roomId,
    required String studentId,
    required String studentName,
  }) async {
    final roomIdx = _rooms.indexWhere((r) => r.id == roomId || r.roomNumber == roomId);
    if (roomIdx != -1) {
      final room = _rooms[roomIdx];
      if (room.isFull) {
        throw 'Room ${room.roomNumber} is already at full capacity (${room.capacity} beds)!';
      }
      final newStudentIds = List<String>.from(room.studentIds)..add(studentId);
      final newStudentNames = List<String>.from(room.studentNames)..add(studentName);
      final updatedRoom = RoomModel(
        id: room.id,
        roomNumber: room.roomNumber,
        floor: room.floor,
        capacity: room.capacity,
        occupied: room.occupied + 1,
        studentIds: newStudentIds,
        studentNames: newStudentNames,
        notes: room.notes,
      );
      _rooms[roomIdx] = updatedRoom;

      // Update student's room number
      final studIdx = _students.indexWhere((s) => s.id == studentId);
      if (studIdx != -1) {
        final st = _students[studIdx];
        _students[studIdx] = StudentModel(
          id: st.id,
          fullName: st.fullName,
          dob: st.dob,
          phone: st.phone,
          email: st.email,
          parentPhone: st.parentPhone,
          branch: st.branch,
          year: st.year,
          address: st.address,
          roomNumber: room.roomNumber,
          username: st.username,
          admissionStatus: st.admissionStatus,
          accountStatus: st.accountStatus,
          createdAt: st.createdAt,
        );
      }
      _emitAll();

      if (FirebaseInitializer.isInitialized && _firestore != null) {
        try {
          await _firestore.collection('rooms').doc(room.id).set(updatedRoom.toMap());
          await _firestore.collection('students').doc(studentId).update({'roomNumber': room.roomNumber});
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> removeStudentFromRoom({
    required String roomId,
    required String studentId,
  }) async {
    final roomIdx = _rooms.indexWhere((r) => r.id == roomId || r.roomNumber == roomId);
    if (roomIdx != -1) {
      final room = _rooms[roomIdx];
      final newIds = List<String>.from(room.studentIds)..remove(studentId);
      final newNames = List<String>.from(room.studentNames);
      // Remove corresponding name
      final stud = _students.firstWhere((s) => s.id == studentId, orElse: () => _students.first);
      newNames.remove(stud.fullName);

      final updatedRoom = RoomModel(
        id: room.id,
        roomNumber: room.roomNumber,
        floor: room.floor,
        capacity: room.capacity,
        occupied: (room.occupied - 1).clamp(0, room.capacity),
        studentIds: newIds,
        studentNames: newNames,
        notes: room.notes,
      );
      _rooms[roomIdx] = updatedRoom;

      final studIdx = _students.indexWhere((s) => s.id == studentId);
      if (studIdx != -1) {
        final st = _students[studIdx];
        _students[studIdx] = StudentModel(
          id: st.id,
          fullName: st.fullName,
          dob: st.dob,
          phone: st.phone,
          email: st.email,
          parentPhone: st.parentPhone,
          branch: st.branch,
          year: st.year,
          address: st.address,
          roomNumber: null,
          username: st.username,
          admissionStatus: st.admissionStatus,
          accountStatus: st.accountStatus,
          createdAt: st.createdAt,
        );
      }
      _emitAll();

      if (FirebaseInitializer.isInitialized && _firestore != null) {
        try {
          await _firestore.collection('rooms').doc(room.id).set(updatedRoom.toMap());
          await _firestore.collection('students').doc(studentId).update({'roomNumber': null});
        } catch (_) {}
      }
    }
  }

  // FEES
  @override
  Stream<List<FeeModel>> streamFees() {
    if (FirebaseInitializer.isInitialized && _firestore != null) {
      return _firestore.collection('fees').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return _fees;
        return snapshot.docs.map((doc) => FeeModel.fromMap(doc.data(), doc.id)).toList();
      });
    }
    return _feesCtrl.stream;
  }

  @override
  Stream<FeeModel?> streamFeeForStudent(String studentId) {
    return streamFees().map((fees) {
      try {
        return fees.firstWhere((f) => f.studentId == studentId);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<void> recordFeePayment({
    required String studentId,
    required num amount,
    required String paymentMode,
  }) async {
    final idx = _fees.indexWhere((f) => f.studentId == studentId);
    if (idx != -1) {
      final fee = _fees[idx];
      final newPaid = fee.paidAmount + amount;
      final newTx = FeePaymentTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        date: DateTime.now(),
        paymentMode: paymentMode,
        receiptNumber: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      );
      final updatedTransactions = List<FeePaymentTransaction>.from(fee.transactions)..add(newTx);
      final updatedFee = FeeModel(
        id: fee.id,
        studentId: fee.studentId,
        studentName: fee.studentName,
        roomNumber: fee.roomNumber,
        academicYear: fee.academicYear,
        totalFee: fee.totalFee,
        paidAmount: newPaid,
        transactions: updatedTransactions,
      );
      _fees[idx] = updatedFee;
      _emitAll();

      if (FirebaseInitializer.isInitialized && _firestore != null) {
        try {
          await _firestore.collection('fees').doc(fee.id).set(updatedFee.toMap());
        } catch (_) {}
      }
    } else {
      // Create new fee ledger
      final student = _students.firstWhere(
        (s) => s.id == studentId,
        orElse: () => _students.first,
      );
      final newTx = FeePaymentTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        date: DateTime.now(),
        paymentMode: paymentMode,
        receiptNumber: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      );
      final newFee = FeeModel(
        id: 'fee_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        studentName: student.fullName,
        roomNumber: student.roomNumber,
        academicYear: '2025-2026',
        totalFee: 50000,
        paidAmount: amount,
        transactions: [newTx],
      );
      _fees.add(newFee);
      _emitAll();

      if (FirebaseInitializer.isInitialized && _firestore != null) {
        try {
          await _firestore.collection('fees').doc(newFee.id).set(newFee.toMap());
        } catch (_) {}
      }
    }
  }

  // COMPLAINTS
  @override
  Stream<List<ComplaintModel>> streamComplaints() {
    if (FirebaseInitializer.isInitialized && _firestore != null) {
      return _firestore.collection('complaints').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return _complaints;
        return snapshot.docs.map((doc) => ComplaintModel.fromMap(doc.data(), doc.id)).toList();
      });
    }
    return _complaintsCtrl.stream;
  }

  @override
  Stream<List<ComplaintModel>> streamComplaintsForStudent(String studentId) {
    return streamComplaints().map((list) => list.where((c) => c.studentId == studentId).toList());
  }

  @override
  Future<void> submitComplaint(ComplaintModel complaint) async {
    _complaints.insert(0, complaint);
    _emitAll();

    if (FirebaseInitializer.isInitialized && _firestore != null) {
      try {
        await _firestore.collection('complaints').doc(complaint.id).set(complaint.toMap());
      } catch (_) {}
    }
  }

  @override
  Future<void> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
    String? rectorResponse,
  }) async {
    final idx = _complaints.indexWhere((c) => c.id == complaintId);
    if (idx != -1) {
      final old = _complaints[idx];
      final updated = ComplaintModel(
        id: old.id,
        studentId: old.studentId,
        studentName: old.studentName,
        roomNumber: old.roomNumber,
        title: old.title,
        description: old.description,
        category: old.category,
        imageUrl: old.imageUrl,
        status: status,
        rectorResponse: rectorResponse ?? old.rectorResponse,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      _complaints[idx] = updated;
      _emitAll();

      if (FirebaseInitializer.isInitialized && _firestore != null) {
        try {
          await _firestore.collection('complaints').doc(complaintId).set(updated.toMap());
        } catch (_) {}
      }
    }
  }
}
