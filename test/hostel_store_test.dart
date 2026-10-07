import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_management_system/core/constants/app_constants.dart';
import 'package:hostel_management_system/models/room_model.dart';
import 'package:hostel_management_system/models/student_model.dart';
import 'package:hostel_management_system/services/auth_service.dart';
import 'package:hostel_management_system/services/hostel_store.dart';

void main() {
  late HostelStore store;

  setUp(() {
    store = HostelStore();
  });

  test('room allocation and deallocation stay in sync', () {
    expect(store.allocateStudent('room_203', 'student_009'), isTrue);

    expect(store.roomForStudent('student_009')?.roomNumber, '203');

    expect(store.studentById('student_009')?.roomNumber, '203');

    expect(store.roomForStudent('student_009')?.occupied, 1);

    store.deallocateStudent('room_203', 'student_009');

    expect(store.roomForStudent('student_009'), isNull);

    expect(store.studentById('student_009')?.roomNumber, isNull);

    expect(store.rooms.firstWhere((room) => room.id == 'room_203').occupied, 0);
  });

  test('allocation refuses a full room without moving the student', () {
    expect(store.allocateStudent('room_201', 'student_009'), isFalse);

    expect(store.roomForStudent('student_009')?.roomNumber, '204');
  });

  test('student and room edits update linked room and fee details', () {
    final student = store.studentById('student_001')!;

    store.updateStudent(
      StudentModel(
        id: student.id,
        fullName: 'Rahul D. Updated',
        dob: student.dob,
        phone: student.phone,
        email: student.email,
        parentPhone: student.parentPhone,
        branch: student.branch,
        year: student.year,
        address: student.address,
        roomNumber: student.roomNumber,
        username: student.username,
        admissionStatus: student.admissionStatus,
        accountStatus: student.accountStatus,
        createdAt: student.createdAt,
      ),
    );

    expect(
      store.rooms
          .firstWhere((room) => room.id == 'room_101')
          .studentNames
          .first,
      'Rahul D. Updated',
    );

    final room = store.rooms.firstWhere((item) => item.id == 'room_101');

    store.updateRoom(
      RoomModel(
        id: room.id,
        roomNumber: '110',
        floor: room.floor,
        capacity: room.capacity,
        occupied: room.occupied,
        studentIds: room.studentIds,
        studentNames: room.studentNames,
      ),
    );

    expect(store.studentById('student_001')?.roomNumber, '110');

    expect(store.feeForStudent('student_001')?.roomNumber, '110');
  });

  test('payments cap at the outstanding balance', () {
    final fee = store.feeForStudent('student_002')!;

    expect(fee.pendingAmount, 24000);

    store.recordFeePayment(fee.id, 30000, 'Cash');

    final updated = store.feeForStudent('student_002')!;

    expect(updated.paidAmount, 72000);

    expect(updated.pendingAmount, 0);

    expect(updated.status, FeeStatus.paid);
  });

  test('complaint status changes are reflected in active counts', () {
    final initialActive = store.activeComplaints;

    store.updateComplaintStatus('complaint_002', ComplaintStatus.resolved);

    expect(store.activeComplaints, initialActive - 1);
  });

  test('authentication resolves a student account', () async {
    final auth = AppAuthService();

    final user = await auth.login(
      emailOrUsername: 'student',
      password: 'demo123',
      expectedRole: UserRole.student,
    );

    expect(user.role, UserRole.student);

    expect(user.accountStatus, AccountStatus.active);
  });
}
