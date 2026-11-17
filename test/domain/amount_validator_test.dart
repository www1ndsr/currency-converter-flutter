import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:currency_converter_flutter/domain/validators/amount_validator.dart';

void main() {
  group('AmountValidator', () {
    test('accepts valid positive integers', () {
      expect(AmountValidator.validate('100'), isNull);
      expect(AmountValidator.validate('1'), isNull);
      expect(AmountValidator.validate(' 2500 '), isNull);
      expect(AmountValidator.tryParse('100'), Decimal.fromInt(100));
    });

    test('accepts valid decimal numbers with dot', () {
      expect(AmountValidator.validate('123.45'), isNull);
      expect(AmountValidator.validate('0.05'), isNull);
      expect(AmountValidator.tryParse('123.45'), Decimal.parse('123.45'));
    });

    test('accepts valid decimal numbers with comma', () {
      expect(AmountValidator.validate('123,45'), isNull);
      expect(AmountValidator.validate('0,99'), isNull);
      expect(AmountValidator.tryParse('123,45'), Decimal.parse('123.45'));
    });

    test('rejects empty or null input', () {
      expect(AmountValidator.validate(null), 'Введите сумму для конвертации');
      expect(AmountValidator.validate(''), 'Введите сумму для конвертации');
      expect(AmountValidator.validate('   '), 'Введите сумму для конвертации');
      expect(AmountValidator.tryParse(''), isNull);
    });

    test('rejects negative numbers', () {
      expect(AmountValidator.validate('-100'), 'Сумма не может быть отрицательной');
      expect(AmountValidator.validate('-0.5'), 'Сумма не может быть отрицательной');
      expect(AmountValidator.tryParse('-10'), isNull);
    });

    test('rejects zero amounts', () {
      expect(AmountValidator.validate('0'), 'Сумма должна быть строго больше нуля');
      expect(AmountValidator.validate('0.00'), 'Сумма должна быть строго больше нуля');
      expect(AmountValidator.validate('0,0'), 'Сумма должна быть строго больше нуля');
      expect(AmountValidator.tryParse('0'), isNull);
    });

    test('rejects alphabetic characters and special symbols', () {
      expect(AmountValidator.validate('100abc'), contains('только из цифр'));
      expect(AmountValidator.validate('abc'), contains('только из цифр'));
      expect(AmountValidator.validate('10\$'), contains('только из цифр'));
      expect(AmountValidator.validate('12!4'), contains('только из цифр'));
      expect(AmountValidator.tryParse('100abc'), isNull);
    });

    test('rejects multiple decimal separators', () {
      expect(
        AmountValidator.validate('12.34.56'),
        'Сумма содержит несколько десятичных разделителей',
      );
      expect(
        AmountValidator.validate('12,34,56'),
        'Сумма содержит несколько десятичных разделителей',
      );
      expect(
        AmountValidator.validate('12.34,56'),
        'Сумма содержит несколько десятичных разделителей',
      );
      expect(AmountValidator.tryParse('12.3.4'), isNull);
    });

    test('rejects amounts exceeding upper limit (1 trillion)', () {
      expect(
        AmountValidator.validate('1000000000001'),
        contains('превышает допустимый предел'),
      );
      expect(AmountValidator.tryParse('1000000000001'), isNull);
    });
  });
}
