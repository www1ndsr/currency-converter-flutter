import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:currency_converter_flutter/core/errors/app_exceptions.dart';
import 'package:currency_converter_flutter/data/models/exchange_rate.dart';
import 'package:currency_converter_flutter/data/models/rate_snapshot.dart';
import 'package:currency_converter_flutter/domain/services/conversion_service.dart';

void main() {
  group('ConversionService', () {
    late ConversionService service;
    late RateSnapshot snapshot;

    setUp(() {
      service = ConversionService();

      final now = DateTime(2024, 11, 15);
      final rates = <String, ExchangeRate>{
        'MDL': ExchangeRate.mdl(),
        'EUR': ExchangeRate.create(
          charCode: 'EUR',
          numCode: 978,
          nominal: 1,
          name: 'Euro',
          value: Decimal.parse('20.00'),
        ),
        'USD': ExchangeRate.create(
          charCode: 'USD',
          numCode: 840,
          nominal: 1,
          name: 'US Dollar',
          value: Decimal.parse('18.00'),
        ),
        'HUF': ExchangeRate.create(
          charCode: 'HUF',
          numCode: 348,
          nominal: 100,
          name: 'Hungarian Forint',
          value: Decimal.parse('4.85'), // nominal 100 -> per unit 0.0485
        ),
      };

      snapshot = RateSnapshot(
        requestedDate: now,
        effectiveDate: now,
        fetchedAt: now,
        rates: rates,
      );
    });

    test('converts MDL to EUR correctly', () {
      // 100 MDL / 20.00 EUR rate = 5.00 EUR
      final result = service.convert(
        amount: Decimal.fromInt(100),
        sourceCurrency: 'MDL',
        targetCurrency: 'EUR',
        snapshot: snapshot,
      );

      expect(result.sourceAmount, Decimal.fromInt(100));
      expect(result.roundedAmount, Decimal.parse('5.00'));
      expect(result.appliedRate, Decimal.parse('0.05'));
      expect(result.sourceCurrency, 'MDL');
      expect(result.targetCurrency, 'EUR');
    });

    test('converts EUR to MDL correctly', () {
      // 10 EUR * 20.00 = 200.00 MDL
      final result = service.convert(
        amount: Decimal.fromInt(10),
        sourceCurrency: 'EUR',
        targetCurrency: 'MDL',
        snapshot: snapshot,
      );

      expect(result.roundedAmount, Decimal.parse('200.00'));
      expect(result.appliedRate, Decimal.parse('20.00'));
    });

    test('converts USD to EUR correctly (cross-rate)', () {
      // 100 USD @ 18 MDL = 1800 MDL -> 1800 / 20 EUR rate = 90.00 EUR
      final result = service.convert(
        amount: Decimal.fromInt(100),
        sourceCurrency: 'USD',
        targetCurrency: 'EUR',
        snapshot: snapshot,
      );

      expect(result.roundedAmount, Decimal.parse('90.00'));
      expect(result.appliedRate, Decimal.parse('0.9'));
    });

    test('converts EUR to USD correctly (cross-rate)', () {
      // 100 EUR @ 20 MDL = 2000 MDL -> 2000 / 18 USD = 111.1111... -> 111.11 USD
      final result = service.convert(
        amount: Decimal.fromInt(100),
        sourceCurrency: 'EUR',
        targetCurrency: 'USD',
        snapshot: snapshot,
      );

      expect(result.roundedAmount, Decimal.parse('111.11'));
      expect(result.appliedRate, Decimal.parse('1.111111'));
    });

    test('same source and target currency returns identical amount', () {
      final result = service.convert(
        amount: Decimal.parse('123.45'),
        sourceCurrency: 'EUR',
        targetCurrency: 'EUR',
        snapshot: snapshot,
      );

      expect(result.roundedAmount, Decimal.parse('123.45'));
      expect(result.appliedRate, Decimal.one);
    });

    test('handles nominal greater than 1 correctly (HUF)', () {
      // 1000 HUF (rate per unit = 0.0485) -> 48.50 MDL
      final result = service.convert(
        amount: Decimal.fromInt(1000),
        sourceCurrency: 'HUF',
        targetCurrency: 'MDL',
        snapshot: snapshot,
      );

      expect(result.roundedAmount, Decimal.parse('48.50'));
    });

    test('throws ValidationException on zero or negative amount', () {
      expect(
        () => service.convert(
          amount: Decimal.zero,
          sourceCurrency: 'EUR',
          targetCurrency: 'MDL',
          snapshot: snapshot,
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => service.convert(
          amount: Decimal.parse('-10'),
          sourceCurrency: 'EUR',
          targetCurrency: 'MDL',
          snapshot: snapshot,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException when currency code is not in snapshot', () {
      expect(
        () => service.convert(
          amount: Decimal.fromInt(100),
          sourceCurrency: 'XYZ',
          targetCurrency: 'MDL',
          snapshot: snapshot,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
