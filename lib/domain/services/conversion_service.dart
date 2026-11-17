import 'package:decimal/decimal.dart';
import '../../core/errors/app_exceptions.dart';
import '../../data/models/rate_snapshot.dart';

class ConversionResult {
  final Decimal sourceAmount;
  final String sourceCurrency;
  final String targetCurrency;
  final Decimal sourceRatePerUnit;
  final Decimal targetRatePerUnit;
  final Decimal appliedRate;
  final Decimal roundedAmount;
  final Decimal rawAmount;
  final DateTime effectiveDate;
  final bool isFromCache;

  const ConversionResult({
    required this.sourceAmount,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.sourceRatePerUnit,
    required this.targetRatePerUnit,
    required this.appliedRate,
    required this.roundedAmount,
    required this.rawAmount,
    required this.effectiveDate,
    required this.isFromCache,
  });

  @override
  String toString() =>
      '$sourceAmount $sourceCurrency = $roundedAmount $targetCurrency (Rate: $appliedRate)';
}

class ConversionService {
  /// Converts [amount] from [sourceCurrency] to [targetCurrency] using rates from [snapshot].
  ///
  /// Mathematical formula:
  /// targetAmount = amount * sourceRatePerUnit / targetRatePerUnit
  ConversionResult convert({
    required Decimal amount,
    required String sourceCurrency,
    required String targetCurrency,
    required RateSnapshot snapshot,
  }) {
    final src = sourceCurrency.trim().toUpperCase();
    final dst = targetCurrency.trim().toUpperCase();

    if (amount <= Decimal.zero) {
      throw const ValidationException('Сумма для конвертации должна быть строго больше нуля');
    }

    final srcRateObj = snapshot.getRate(src);
    if (srcRateObj == null) {
      throw ValidationException('Курс для исходной валюты $src не найден в источнике');
    }

    final dstRateObj = snapshot.getRate(dst);
    if (dstRateObj == null) {
      throw ValidationException('Курс для целевой валюты $dst не найден в источнике');
    }

    final srcRatePerUnit = srcRateObj.ratePerUnit;
    final dstRatePerUnit = dstRateObj.ratePerUnit;

    if (dstRatePerUnit <= Decimal.zero) {
      throw const ValidationException('Курс целевой валюты равен нулю или отрицательный (деление на ноль невозможно)');
    }

    // Direct match: same currency
    if (src == dst) {
      return ConversionResult(
        sourceAmount: amount,
        sourceCurrency: src,
        targetCurrency: dst,
        sourceRatePerUnit: srcRatePerUnit,
        targetRatePerUnit: dstRatePerUnit,
        appliedRate: Decimal.one,
        roundedAmount: amount,
        rawAmount: amount,
        effectiveDate: snapshot.effectiveDate,
        isFromCache: snapshot.isFromCache,
      );
    }

    // targetAmount = (amount * srcRatePerUnit) / dstRatePerUnit
    final product = amount * srcRatePerUnit;
    final targetRational = product / dstRatePerUnit;

    // High precision raw amount
    final rawAmount = targetRational.toDecimal(scaleOnInfinitePrecision: 8);

    // Standard currency rounding: 2 decimal places
    final roundedAmount = targetRational.toDecimal(scaleOnInfinitePrecision: 2);

    // Applied exchange rate: srcRatePerUnit / dstRatePerUnit
    final rateRatio = srcRatePerUnit / dstRatePerUnit;
    final appliedRate = rateRatio.toDecimal(scaleOnInfinitePrecision: 6);

    return ConversionResult(
      sourceAmount: amount,
      sourceCurrency: src,
      targetCurrency: dst,
      sourceRatePerUnit: srcRatePerUnit,
      targetRatePerUnit: dstRatePerUnit,
      appliedRate: appliedRate,
      roundedAmount: roundedAmount,
      rawAmount: rawAmount,
      effectiveDate: snapshot.effectiveDate,
      isFromCache: snapshot.isFromCache,
    );
  }
}
