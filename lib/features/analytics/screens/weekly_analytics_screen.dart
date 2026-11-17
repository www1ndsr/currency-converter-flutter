import 'package:material_ui/material_ui.dart';
import '../../../data/repositories/exchange_rate_repository.dart';
import '../../../domain/services/statistics_service.dart';
import '../widgets/analytics_view.dart';

class WeeklyAnalyticsScreen extends StatelessWidget {
  final ExchangeRateRepository repository;
  final StatisticsService statisticsService;

  const WeeklyAnalyticsScreen({
    super.key,
    required this.repository,
    required this.statisticsService,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsView(
      days: 7,
      title: 'Аналитика за 7 дней',
      repository: repository,
      statisticsService: statisticsService,
    );
  }
}
