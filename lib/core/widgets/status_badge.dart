import 'package:material_ui/material_ui.dart';
import '../constants/app_colors.dart';
import '../utils/date_formatter.dart';

class StatusBadge extends StatelessWidget {
  final bool isFromCache;
  final DateTime effectiveDate;
  final DateTime? fetchedAt;

  const StatusBadge({
    super.key,
    required this.isFromCache,
    required this.effectiveDate,
    this.fetchedAt,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isFromCache
        ? AppColors.cachedBadgeBackground
        : AppColors.onlineBadgeBackground;
    final textColor = isFromCache
        ? AppColors.cachedBadgeText
        : AppColors.onlineBadgeText;
    final iconData = isFromCache ? Icons.offline_pin_outlined : Icons.cloud_done_outlined;
    final label = isFromCache ? 'Кэш (офлайн)' : 'Онлайн (BNM)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            '$label • курс на ${DateFormatter.toDisplayDate(effectiveDate)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
