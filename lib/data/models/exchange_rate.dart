import 'package:decimal/decimal.dart';

class ExchangeRate {
  final String charCode;
  final int numCode;
  final int nominal;
  final String name;
  final Decimal value;
  final Decimal ratePerUnit;

  const ExchangeRate({
    required this.charCode,
    required this.numCode,
    required this.nominal,
    required this.name,
    required this.value,
    required this.ratePerUnit,
  });

  factory ExchangeRate.create({
    required String charCode,
    required int numCode,
    required int nominal,
    required String name,
    required Decimal value,
  }) {
    if (nominal <= 0) {
      throw ArgumentError('Nominal must be greater than zero, got $nominal');
    }
    if (value <= Decimal.zero) {
      throw ArgumentError('Rate value must be positive, got $value');
    }

    final rationalRate = value / Decimal.fromInt(nominal);
    // Use high precision for rate per unit
    final ratePerUnit = rationalRate.toDecimal(scaleOnInfinitePrecision: 8);

    return ExchangeRate(
      charCode: charCode.trim().toUpperCase(),
      numCode: numCode,
      nominal: nominal,
      name: name.trim(),
      value: value,
      ratePerUnit: ratePerUnit,
    );
  }

  factory ExchangeRate.mdl() {
    return ExchangeRate(
      charCode: 'MDL',
      numCode: 498,
      nominal: 1,
      name: 'Leu moldovenesc',
      value: Decimal.one,
      ratePerUnit: Decimal.one,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'charCode': charCode,
      'numCode': numCode,
      'nominal': nominal,
      'name': name,
      'value': value.toString(),
      'ratePerUnit': ratePerUnit.toString(),
    };
  }

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      charCode: (json['charCode'] as String).trim().toUpperCase(),
      numCode: json['numCode'] as int? ?? 0,
      nominal: json['nominal'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      value: Decimal.parse(json['value'].toString()),
      ratePerUnit: Decimal.parse(json['ratePerUnit'].toString()),
    );
  }

  @override
  String toString() =>
      'ExchangeRate(code: $charCode, nom: $nominal, name: $name, value: $value, perUnit: $ratePerUnit)';
}
