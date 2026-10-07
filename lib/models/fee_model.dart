import '../core/constants/app_constants.dart';

/// Fee transaction item.
class FeePaymentTransaction {
  final String id;
  final num amount;
  final DateTime date;
  final String paymentMode;
  final String? receiptNumber;

  const FeePaymentTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.paymentMode,
    this.receiptNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentMode': paymentMode,
      'receiptNumber': receiptNumber,
    };
  }

  factory FeePaymentTransaction.fromMap(Map<String, dynamic> map) {
    return FeePaymentTransaction(
      id: map['id'] ?? '',
      amount: map['amount'] ?? 0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      paymentMode: map['paymentMode'] ?? 'Cash',
      receiptNumber: map['receiptNumber'],
    );
  }
}

/// Hostel fee model for students.
class FeeModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? roomNumber;
  final String academicYear;
  final num totalFee;
  final num paidAmount;
  final List<FeePaymentTransaction> transactions;

  const FeeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.roomNumber,
    required this.academicYear,
    required this.totalFee,
    required this.paidAmount,
    this.transactions = const [],
  });

  num get pendingAmount => (totalFee - paidAmount).clamp(0, totalFee);

  FeeStatus get status {
    if (paidAmount >= totalFee && totalFee > 0) return FeeStatus.paid;
    if (paidAmount > 0) return FeeStatus.partiallyPaid;
    return FeeStatus.pending;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'academicYear': academicYear,
      'totalFee': totalFee,
      'paidAmount': paidAmount,
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }

  factory FeeModel.fromMap(Map<String, dynamic> map, String id) {
    final rawList = map['transactions'] as List<dynamic>? ?? [];
    return FeeModel(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      roomNumber: map['roomNumber'],
      academicYear: map['academicYear'] ?? '',
      totalFee: map['totalFee'] ?? 0,
      paidAmount: map['paidAmount'] ?? 0,
      transactions: rawList
          .map((t) => FeePaymentTransaction.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
    );
  }
}
