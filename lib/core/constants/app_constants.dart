class AppConstants {
  static const String appName = 'BNM Currency Converter';
  static const String bnmBaseUrl = 'https://www.bnm.md/en/official_exchange_rates';
  static const String baseCurrencyCode = 'MDL';
  static const String baseCurrencyName = 'Moldovan Leu';

  static const List<String> primaryCurrencies = [
    'MDL',
    'EUR',
    'USD',
    'RON',
    'UAH',
    'GBP',
    'CHF',
    'PLN',
    'TRY',
    'RUB',
  ];

  static const Duration networkTimeout = Duration(seconds: 15);
  static const int maxRetryAttempts = 2;
  static const int maxHistoricalDays = 30;
}
