import 'package:intl/intl.dart';

/// Utilitas format tanggal menggunakan package intl
class DateFormatter {
  DateFormatter._();

  /// Format: Senin, 28 Juli 2025
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  /// Format: 28 Juli 2025
  static String formatLongDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  /// Format: 28/07/2025
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format: 08:30
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format: 08:30 - 10:00
  static String formatTimeRange(String start, String end) {
    return '$start - $end';
  }

  /// Format: Senin
  static String formatDayName(DateTime date) {
    return DateFormat('EEEE', 'id_ID').format(date);
  }

  /// Format: Juli 2025
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  /// Parse dari string ke DateTime
  static DateTime? parseDate(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Format ISO ke full date
  static String isoToFullDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return formatFullDate(date);
  }

  /// Format ISO ke short date
  static String isoToShortDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return formatShortDate(date);
  }

  /// Format ISO ke long date
  static String isoToLongDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return formatLongDate(date);
  }
}
