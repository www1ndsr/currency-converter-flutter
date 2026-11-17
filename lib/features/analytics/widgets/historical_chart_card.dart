import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/historical_rate_point.dart';
import '../../../domain/services/statistics_service.dart';

class HistoricalChartCard extends StatelessWidget {
  final List<HistoricalRatePoint> points;
  final RateStatistics statistics;
  final String charCode;

  const HistoricalChartCard({
    super.key,
    required this.points,
    required this.statistics,
    required this.charCode,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final double minRate = points
        .map((p) => p.ratePerUnit.toDouble())
        .reduce((a, b) => a < b ? a : b);
    final double maxRate = points
        .map((p) => p.ratePerUnit.toDouble())
        .reduce((a, b) => a > b ? a : b);

    final double range = maxRate - minRate;
    final double margin = range == 0 ? (minRate * 0.02 == 0 ? 0.1 : minRate * 0.02) : range * 0.2;
    final double chartMinY = (minRate - margin) > 0 ? (minRate - margin) : 0;
    final double chartMaxY = maxRate + margin;

    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.ratePerUnit.toDouble());
    }).toList();

    final Color lineColor = switch (statistics.trend) {
      RateTrend.growth => AppColors.trendGrowth,
      RateTrend.decline => AppColors.trendDecline,
      RateTrend.noChange => AppColors.primary,
    };

    final double xInterval = points.length <= 7 ? 1.0 : (points.length / 5).ceilToDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Динамика курса $charCode/MDL',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${DateFormatter.toShortDate(points.first.date)} - ${DateFormatter.toShortDate(points.last.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: chartMinY,
                  maxY: chartMaxY,
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: ((chartMaxY - chartMinY) / 4).abs() == 0
                        ? 0.1
                        : ((chartMaxY - chartMinY) / 4),
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: AppColors.surfaceVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: xInterval > 0 ? xInterval : 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormatter.toShortDate(points[idx].date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: ((chartMaxY - chartMinY) / 4).abs() == 0
                            ? 0.1
                            : ((chartMaxY - chartMinY) / 4),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: lineColor,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: points.length <= 10,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: lineColor,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            lineColor.withAlpha(50),
                            lineColor.withAlpha(5),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.textPrimary,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          if (idx >= 0 && idx < points.length) {
                            final pt = points[idx];
                            return LineTooltipItem(
                              '${DateFormatter.toDisplayDate(pt.date)}\n${pt.ratePerUnit} MDL',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
