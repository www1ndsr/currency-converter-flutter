import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:currency_converter_flutter/app/app.dart';
import 'package:currency_converter_flutter/data/models/exchange_rate.dart';
import 'package:currency_converter_flutter/data/models/historical_rate_point.dart';
import 'package:currency_converter_flutter/data/models/rate_snapshot.dart';
import 'package:currency_converter_flutter/data/repositories/exchange_rate_repository.dart';
import 'package:currency_converter_flutter/domain/services/conversion_service.dart';
import 'package:currency_converter_flutter/domain/services/statistics_service.dart';
import 'package:currency_converter_flutter/features/analytics/screens/monthly_analytics_screen.dart';
import 'package:currency_converter_flutter/features/analytics/screens/weekly_analytics_screen.dart';
import 'package:currency_converter_flutter/features/converter/screens/converter_screen.dart';
import 'package:currency_converter_flutter/features/settings/screens/settings_screen.dart';
import 'package:currency_converter_flutter/features/shell/main_shell_screen.dart';

class FakeExchangeRateRepository extends ExchangeRateRepository {
  final RateSnapshot dummySnapshot;
  final List<HistoricalRatePoint> dummyHistory;

  FakeExchangeRateRepository(this.dummySnapshot, this.dummyHistory);

  @override
  Future<RateSnapshot> getLatestRates({bool forceRefresh = false}) async {
    return dummySnapshot;
  }

  @override
  Future<List<HistoricalRatePoint>> getHistoricalRates({
    required String charCode,
    required int days,
    bool forceRefresh = false,
  }) async {
    return dummyHistory;
  }

  @override
  Future<RateSnapshot?> getCachedSnapshot() async {
    return dummySnapshot;
  }

  @override
  Future<bool> clearCache() async {
    return true;
  }
}

void main() {
  testWidgets('MainShellScreen renders navigation bar and switches tabs', (WidgetTester tester) async {
    final now = DateTime(2024, 11, 15);
    final dummySnapshot = RateSnapshot(
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
          value: Decimal.parse('19.00'),
        ),
      },
    );

    final dummyHistory = [
      HistoricalRatePoint(
        date: now.subtract(const Duration(days: 1)),
        effectiveDate: now.subtract(const Duration(days: 1)),
        charCode: 'EUR',
        ratePerUnit: Decimal.parse('18.90'),
      ),
      HistoricalRatePoint(
        date: now,
        effectiveDate: now,
        charCode: 'EUR',
        ratePerUnit: Decimal.parse('19.00'),
      ),
    ];

    final fakeRepo = FakeExchangeRateRepository(dummySnapshot, dummyHistory);
    final conversionService = ConversionService();
    final statisticsService = StatisticsService();

    await tester.pumpWidget(
      CurrencyApp(
        home: MainShellScreen(
          screens: [
            ConverterScreen(
              repository: fakeRepo,
              conversionService: conversionService,
            ),
            WeeklyAnalyticsScreen(
              repository: fakeRepo,
              statisticsService: statisticsService,
            ),
            MonthlyAnalyticsScreen(
              repository: fakeRepo,
              statisticsService: statisticsService,
            ),
            SettingsScreen(
              repository: fakeRepo,
            ),
          ],
        ),
      ),
    );

    // Initial frame and async operations completion
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify navigation tabs exist
    expect(find.text('Конвертер'), findsWidgets);
    expect(find.text('7 дней'), findsOneWidget);
    expect(find.text('30 дней'), findsOneWidget);
    expect(find.text('Инфо'), findsOneWidget);

    // Tap on Info tab
    await tester.tap(find.text('Инфо'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Info screen content rendered
    expect(find.text('Информация и настройки'), findsOneWidget);
    expect(find.text('Banca Națională a Moldovei'), findsOneWidget);
  });
}
