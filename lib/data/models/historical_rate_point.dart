import 'package:decimal/decimal.dart';

class HistoricalRatePoint {
  final DateTime date;
  final DateTime effectiveDate;
  final String charCode;
  final Decimal ratePerUnit;

  const HistoricalRatePoint({
    required this.date,
    required this.effectiveDate,
    required this.charCode,
    required this.ratePerUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'effectiveDate': effectiveDate.toIso8601String(),
      'charCode': charCode,
      'ratePerUnit': ratePerUnit.toString(),
    };
  }

  factory HistoricalRatePoint.fromJson(Map<String, dynamic> json) {
    return HistoricalRatePoint(
      date: DateTime.parse(json['date'] as String),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      charCode: json['charCode'] as String,
      ratePerUnit: Decimal.parse(json['ratePerUnit'].toString()),
    );
  }

  @override
  String toString() =>
      'HistoricalRatePoint($charCode on ${date.toIso8601String().substring(0, 10)}: $ratePerUnit)';
}
