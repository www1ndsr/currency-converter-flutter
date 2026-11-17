import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/rate_snapshot.dart';
import '../../../data/repositories/exchange_rate_repository.dart';

class SettingsScreen extends StatefulWidget {
  final ExchangeRateRepository repository;

  const SettingsScreen({super.key, required this.repository});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  RateSnapshot? _cachedSnapshot;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _checkCacheStatus();
  }

  Future<void> _checkCacheStatus() async {
    final cached = await widget.repository.getCachedSnapshot();
    if (mounted) {
      setState(() {
        _cachedSnapshot = cached;
      });
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _isClearing = true;
    });

    await widget.repository.clearCache();
    await _checkCacheStatus();

    if (!mounted) return;
    setState(() {
      _isClearing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Локальный кэш успешно очищен'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация и настройки'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BNM Source Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Источник данных',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Banca Națională a Moldovei',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Все котировки валют получаются через официальный XML API Национального банка Молдовы без сторонних прокси и поддельных значений.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Формулы расчёта:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• Курс за 1 единицу: ratePerUnit = Value / Nominal\n'
                            '• Конвертация: target = amount * sourceRate / targetRate\n'
                            '• Базовая валюта: MDL (курс = 1.00)',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Cache Management Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.storage_outlined, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Локальный офлайн-кэш',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _cachedSnapshot != null
                          ? 'Сохранён снимок котировок на дату: ${DateFormatter.toDisplayDate(_cachedSnapshot!.effectiveDate)} '
                            '(${_cachedSnapshot!.rates.length} валют, получен: ${DateFormatter.toDisplayDateTime(_cachedSnapshot!.fetchedAt)}).'
                          : 'В данный момент локальный кэш пуст.',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isClearing ? null : _clearCache,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(_isClearing ? 'Очистка...' : 'Очистить кэш'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.trendDecline,
                        side: const BorderSide(color: AppColors.trendDecline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lab info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'О проекте',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Лабораторная работа №4 — Кроссплатформенная мобильная разработка на Dart/Flutter.\n'
                      'Вариант Б: Мобильный конвертер валют с аналитикой за 7 и 30 дней.\n'
                      'Реализация с чистого листа без использования Python-кода.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Версия приложения: 1.0.0+1\nПлатформы: Android, Web (Chrome)',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
