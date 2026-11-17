import 'package:decimal/decimal.dart';

class AmountValidator {
  static final Decimal maxAllowedAmount = Decimal.parse('1000000000000'); // 1 trillion

  /// Validates a raw user input string for currency conversion.
  /// Returns null if the input is valid, or a localized error message string.
  static String? validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Введите сумму для конвертации';
    }

    final trimmed = input.trim().replaceAll(' ', '');

    // Check for negative sign
    if (trimmed.startsWith('-')) {
      return 'Сумма не может быть отрицательной';
    }

    // Replace comma with dot for uniform decimal parsing
    final normalized = trimmed.replaceAll(',', '.');

    // Check for multiple dots
    final dotCount = '.'.allMatches(normalized).length;
    if (dotCount > 1) {
      return 'Сумма содержит несколько десятичных разделителей';
    }

    // Check regex pattern: allows integer or float
    final validPattern = RegExp(r'^\d+(\.\d+)?$');
    if (!validPattern.hasMatch(normalized)) {
      return 'Сумма должна состоять только из цифр и десятичной точки или запятой';
    }

    final parsedDecimal = Decimal.tryParse(normalized);
    if (parsedDecimal == null) {
      return 'Некорректный числовой формат суммы';
    }

    if (parsedDecimal <= Decimal.zero) {
      return 'Сумма должна быть строго больше нуля';
    }

    if (parsedDecimal > maxAllowedAmount) {
      return 'Сумма превышает допустимый предел (1 трлн)';
    }

    return null;
  }

  /// Tries to parse the raw input into a positive [Decimal].
  /// Returns null if invalid or <= 0.
  static Decimal? tryParse(String? input) {
    if (validate(input) != null) return null;
    final normalized = input!.trim().replaceAll(' ', '').replaceAll(',', '.');
    return Decimal.tryParse(normalized);
  }
}
