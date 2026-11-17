import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/exchange_rate.dart';

class CurrencyPickerSheet extends StatefulWidget {
  final List<ExchangeRate> rates;
  final String selectedCode;

  const CurrencyPickerSheet({
    super.key,
    required this.rates,
    required this.selectedCode,
  });

  static Future<String?> show(
    BuildContext context, {
    required List<ExchangeRate> rates,
    required String selectedCode,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => CurrencyPickerSheet(
        rates: rates,
        selectedCode: selectedCode,
      ),
    );
  }

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRates = widget.rates.where((r) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return r.charCode.toLowerCase().contains(q) ||
          r.name.toLowerCase().contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Выберите валюту',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск по коду или названию...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _query = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() {
                    _query = val.trim();
                  });
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredRates.isEmpty
                    ? const Center(
                        child: Text(
                          'Валюта не найдена',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filteredRates.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          color: AppColors.surfaceVariant,
                        ),
                        itemBuilder: (context, index) {
                          final rate = filteredRates[index];
                          final isSelected = rate.charCode == widget.selectedCode;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                rate.charCode,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            title: Text(
                              rate.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${rate.nominal} ${rate.charCode} = ${rate.value} MDL',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                                : null,
                            onTap: () => Navigator.of(context).pop(rate.charCode),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
