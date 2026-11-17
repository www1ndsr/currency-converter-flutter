import 'package:material_ui/material_ui.dart';
import '../../../data/repositories/exchange_rate_repository.dart';
import '../../../domain/services/statistics_service.dart';
import '../widgets/analytics_view.dart';

class MonthlyAnalyticsScreen extends StatelessWidget {
  final ExchangeRateRepository repository;
  final StatisticsService statisticsService;

  const MonthlyAnalyticsScreen({
    super.key,
    required this.repository,
    required this.statisticsService,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsView(
      days: 30,
      title: 'Аналитика за 30 дней',
      repository: repository,
      statisticsService: statisticsService,
    );
  }
}
