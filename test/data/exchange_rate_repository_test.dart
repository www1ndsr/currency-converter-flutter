import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decimal/decimal.dart';
import 'package:currency_converter_flutter/data/models/exchange_rate.dart';
import 'package:currency_converter_flutter/data/models/rate_snapshot.dart';
import 'package:currency_converter_flutter/data/repositories/exchange_rate_repository.dart';
import 'package:currency_converter_flutter/data/services/bnm_api_service.dart';
import 'package:currency_converter_flutter/data/services/cache_service.dart';

void main() {
  const validXmlFixture = '''<?xml version="1.0" encoding="UTF-8"?>
<ValCurs Date="15.11.2024" name="Official exchange rate">
  <Valute ID="47">
    <NumCode>978</NumCode>
    <CharCode>EUR</CharCode>
    <Nominal>1</Nominal>
    <Name>Euro</Name>
    <Value>19.0274</Value>
  </Valute>
</ValCurs>''';

  group('ExchangeRateRepository', () {
    late CacheService cacheService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cacheService = CacheService();
    });

    test('returns fresh data on successful network response and updates cache', () async {
      final mockClient = MockClient((request) async {
        return http.Response(validXmlFixture, 200);
      });
      final apiService = BnmApiService(client: mockClient);
      final repo = ExchangeRateRepository(
        apiService: apiService,
        cacheService: cacheService,
      );

      final snapshot = await repo.getLatestRates();

      expect(snapshot.isFromCache, isFalse);
      expect(snapshot.getRate('EUR')!.ratePerUnit, Decimal.parse('19.0274'));

      // Check that cache was updated
      final cached = await cacheService.getLatestSnapshot();
      expect(cached, isNotNull);
      expect(cached!.isFromCache, isTrue);
      expect(cached.getRate('EUR')!.ratePerUnit, Decimal.parse('19.0274'));
    });

    test('falls back to cache when network request fails', () async {
      // Pre-populate cache
      final now = DateTime(2024, 11, 14);
      final cachedSnapshot = RateSnapshot(
        requestedDate: now,
        effectiveDate: now,
        fetchedAt: now,
        rates: {
          'MDL': ExchangeRate.mdl(),
          'EUR': ExchangeRate.create(
            charCode: 'EUR',
            numCode: 978,
            nominal: 1,
            name: 'Euro',
            value: Decimal.parse('18.9000'),
          ),
        },
      );
      await cacheService.saveLatestSnapshot(cachedSnapshot);

      // Network returns error
      final mockClient = MockClient((request) async {
        throw http.ClientException('No Internet connection');
      });
      final apiService = BnmApiService(client: mockClient);
      final repo = ExchangeRateRepository(
        apiService: apiService,
        cacheService: cacheService,
      );

      final result = await repo.getLatestRates();

      expect(result.isFromCache, isTrue);
      expect(result.getRate('EUR')!.ratePerUnit, Decimal.parse('18.9000'));
    });

    test('falls back to built-in seed data when network fails and no cache exists', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('No Internet');
      });
      final apiService = BnmApiService(client: mockClient);
      final repo = ExchangeRateRepository(
        apiService: apiService,
        cacheService: cacheService,
      );

      // Repository now has built-in seed data (real BNM rates for 18.11.2026)
      // so it should NOT throw — it returns seed snapshot marked as from cache.
      final result = await repo.getLatestRates();
      expect(result.isFromCache, isTrue);
      // EUR and USD must be present in seed data
      expect(result.getRate('EUR'), isNotNull);
      expect(result.getRate('USD'), isNotNull);
    });
  });
}
