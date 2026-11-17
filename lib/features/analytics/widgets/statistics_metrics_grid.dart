import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/services/statistics_service.dart';

class StatisticsMetricsGrid extends StatelessWidget {
  final RateStatistics statistics;
  final String charCode;

  const StatisticsMetricsGrid({
    super.key,
    required this.statistics,
    required this.charCode,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = switch (statistics.trend) {
      RateTrend.growth => AppColors.trendGrowth,
      RateTrend.decline => AppColors.trendDecline,
      RateTrend.noChange => AppColors.trendNeutral,
    };

    final trendIcon = switch (statistics.trend) {
      RateTrend.growth => Icons.trending_up,
      RateTrend.decline => Icons.trending_down,
      RateTrend.noChange => Icons.trending_flat,
    };

    final isPositiveChange = statistics.absoluteChange > Decimal.zero;
    final changePrefix = isPositiveChange ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Trend Banner Card
        Card(
          color: trendColor.withAlpha(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: trendColor.withAlpha(80), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: trendColor.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(trendIcon, color: trendColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Направление тенденции',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statistics.trend.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: trendColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Изменение за период: $changePrefix${statistics.percentageChange}% ($changePrefix${statistics.absoluteChange} MDL)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 2x2 Grid for Min, Max, Avg, Change
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Минимум',
                value: '${statistics.minimum}',
                unit: 'MDL',
                icon: Icons.arrow_downward,
                iconColor: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Максимум',
                value: '${statistics.maximum}',
                unit: 'MDL',
                icon: Icons.arrow_upward,
                iconColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Среднее значение',
                value: '${statistics.average}',
                unit: 'MDL',
                icon: Icons.functions,
                iconColor: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Абсолютное изм.',
                value: '$changePrefix${statistics.absoluteChange}',
                unit: 'MDL',
                icon: Icons.compare_arrows,
                iconColor: trendColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
