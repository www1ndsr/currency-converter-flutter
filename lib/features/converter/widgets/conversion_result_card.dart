import 'package:decimal/decimal.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/services/conversion_service.dart';

class ConversionResultCard extends StatelessWidget {
  final ConversionResult result;

  const ConversionResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Inverse rate calculation for display
    String inverseRateText = '';
    if (result.appliedRate.toString() != '0' && result.sourceCurrency != result.targetCurrency) {
      try {
        final invRational = result.targetRatePerUnit.toRational() / result.sourceRatePerUnit.toRational();
        final invDecimal = invRational.toDecimal(scaleOnInfinitePrecision: 6);
        inverseRateText = '1 ${result.targetCurrency} = $invDecimal ${result.sourceCurrency}';
      } catch (_) {}
    }

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Результат конвертации',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: result.isFromCache
                        ? AppColors.cachedBadgeBackground
                        : AppColors.onlineBadgeBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    result.isFromCache ? 'Из кэша' : 'BNM Онлайн',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: result.isFromCache
                          ? AppColors.cachedBadgeText
                          : AppColors.onlineBadgeText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${result.sourceAmount} ${result.sourceCurrency} =',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${result.roundedAmount} ${result.targetCurrency}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const Divider(height: 24, color: AppColors.border),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '1 ${result.sourceCurrency} = ${result.appliedRate} ${result.targetCurrency}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (inverseRateText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 22.0),
                child: Text(
                  inverseRateText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Text(
                'Курс действует на ${DateFormatter.toDisplayDate(result.effectiveDate)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
