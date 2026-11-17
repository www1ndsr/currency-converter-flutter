import 'exchange_rate.dart';

class RateSnapshot {
  final DateTime requestedDate;
  final DateTime effectiveDate;
  final DateTime fetchedAt;
  final Map<String, ExchangeRate> rates;
  final bool isFromCache;
  final String source;

  const RateSnapshot({
    required this.requestedDate,
    required this.effectiveDate,
    required this.fetchedAt,
    required this.rates,
    this.isFromCache = false,
    this.source = 'Banca Națională a Moldovei',
  });

  ExchangeRate? getRate(String charCode) {
    return rates[charCode.trim().toUpperCase()];
  }

  List<String> get availableCurrencies => rates.keys.toList()..sort();

  RateSnapshot copyWith({
    DateTime? requestedDate,
    DateTime? effectiveDate,
    DateTime? fetchedAt,
    Map<String, ExchangeRate>? rates,
    bool? isFromCache,
    String? source,
  }) {
    return RateSnapshot(
      requestedDate: requestedDate ?? this.requestedDate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rates: rates ?? this.rates,
      isFromCache: isFromCache ?? this.isFromCache,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestedDate': requestedDate.toIso8601String(),
      'effectiveDate': effectiveDate.toIso8601String(),
      'fetchedAt': fetchedAt.toIso8601String(),
      'isFromCache': isFromCache,
      'source': source,
      'rates': rates.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory RateSnapshot.fromJson(Map<String, dynamic> json) {
    final ratesMap = <String, ExchangeRate>{};
    if (json['rates'] is Map) {
      final rawRates = json['rates'] as Map<String, dynamic>;
      rawRates.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          ratesMap[key.toUpperCase()] = ExchangeRate.fromJson(val);
        }
      });
    }

    return RateSnapshot(
      requestedDate: DateTime.parse(json['requestedDate'] as String),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      isFromCache: json['isFromCache'] as bool? ?? true,
      source: json['source'] as String? ?? 'Banca Națională a Moldovei',
      rates: ratesMap,
    );
  }
}
