import 'package:material_ui/material_ui.dart';
import 'app/app.dart';
import 'data/repositories/exchange_rate_repository.dart';
import 'domain/services/conversion_service.dart';
import 'domain/services/statistics_service.dart';
import 'features/analytics/screens/monthly_analytics_screen.dart';
import 'features/analytics/screens/weekly_analytics_screen.dart';
import 'features/converter/screens/converter_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/shell/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = ExchangeRateRepository();
  final conversionService = ConversionService();
  final statisticsService = StatisticsService();

  runApp(
    CurrencyApp(
      home: MainShellScreen(
        screens: [
          ConverterScreen(
            repository: repository,
            conversionService: conversionService,
          ),
          WeeklyAnalyticsScreen(
            repository: repository,
            statisticsService: statisticsService,
          ),
          MonthlyAnalyticsScreen(
            repository: repository,
            statisticsService: statisticsService,
          ),
          SettingsScreen(
            repository: repository,
          ),
        ],
      ),
    ),
  );
}
