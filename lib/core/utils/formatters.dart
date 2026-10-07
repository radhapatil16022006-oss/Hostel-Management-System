import 'package:intl/intl.dart';

/// Formatting utilities for currency, dates, percentages, and names.
class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  static String currency(num amount) {
    try {
      return _currencyFormat.format(amount);
    } catch (_) {
      return '₹$amount';
    }
  }

  static String date(DateTime? date) {
    if (date == null) return '-';
    try {
      return _dateFormat.format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String dateTime(DateTime? date) {
    if (date == null) return '-';
    try {
      return _dateTimeFormat.format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    }
  }

  static String time(DateTime? date) {
    if (date == null) return '-';
    try {
      return _timeFormat.format(date);
    } catch (_) {
      return '${date.hour}:${date.minute}';
    }
  }

  static String percentage(double percent) {
    return '${percent.toStringAsFixed(1)}%';
  }
}
