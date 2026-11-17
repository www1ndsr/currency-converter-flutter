import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _bnmApiFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _displayDateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _displayDateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
  static final DateFormat _shortDateFormat = DateFormat('dd.MM');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'ru');

  static String toBnmApi(DateTime date) => _bnmApiFormat.format(date);

  static DateTime parseBnmApi(String text) => _bnmApiFormat.parse(text.trim());

  static DateTime? tryParseBnmApi(String text) {
    try {
      return _bnmApiFormat.parse(text.trim());
    } catch (_) {
      return null;
    }
  }

  static String toDisplayDate(DateTime date) => _displayDateFormat.format(date);

  static String toDisplayDateTime(DateTime date) => _displayDateTimeFormat.format(date);

  static String toShortDate(DateTime date) => _shortDateFormat.format(date);

  static String toMonthYear(DateTime date) {
    try {
      return _monthYearFormat.format(date);
    } catch (_) {
      return '${date.month}.${date.year}';
    }
  }
}
