import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/historical_rate_point.dart';
import '../../../data/repositories/exchange_rate_repository.dart';
import '../../../domain/services/statistics_service.dart';
import '../widgets/historical_chart_card.dart';
import '../widgets/statistics_metrics_grid.dart';
import '../../converter/widgets/currency_picker_sheet.dart';

class AnalyticsView extends StatefulWidget {
  final int days;
  final String title;
  final ExchangeRateRepository repository;
  final StatisticsService statisticsService;

  const AnalyticsView({
    super.key,
    required this.days,
    required this.title,
    required this.repository,
    required this.statisticsService,
  });

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  String _selectedCurrency = 'EUR';
  List<HistoricalRatePoint>? _points;
  RateStatistics? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final points = await widget.repository.getHistoricalRates(
        charCode: _selectedCurrency,
        days: widget.days,
        forceRefresh: forceRefresh,
      );

      final stats = widget.statisticsService.calculate(points);

      if (!mounted) return;
      setState(() {
        _points = points;
        _statistics = stats;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.userMessage;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Не удалось загрузить историю курсов: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openCurrencyPicker() async {
    try {
      final snapshot = await widget.repository.getLatestRates();
      if (!mounted) return;
      final sortedRates = snapshot.rates.values.where((r) => r.charCode != 'MDL').toList()
        ..sort((a, b) => a.charCode.compareTo(b.charCode));

      final selected = await CurrencyPickerSheet.show(
        context,
        rates: sortedRates,
        selectedCode: _selectedCurrency,
      );

      if (selected != null && selected != _selectedCurrency && mounted) {
        setState(() {
          _selectedCurrency = selected;
        });
        _loadData(forceRefresh: false);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Обновить историю',
            onPressed: _isLoading ? null : () => _loadData(forceRefresh: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _points == null) {
      return LoadingView(
        message: 'Загрузка официальной истории курсов BNM (${widget.days} дн.)...',
      );
    }

    if (_errorMessage != null && _points == null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: () => _loadData(forceRefresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Currency selector header
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Валюта для анализа',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openCurrencyPicker,
                          icon: const Icon(Icons.tune, size: 16),
                          label: const Text('Все валюты'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppConstants.primaryCurrencies
                            .where((c) => c != 'MDL')
                            .map((c) {
                          final isSelected = c == _selectedCurrency;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val && c != _selectedCurrency) {
                                  setState(() {
                                    _selectedCurrency = c;
                                  });
                                  _loadData(forceRefresh: false);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_points != null && _statistics != null) ...[
              HistoricalChartCard(
                points: _points!,
                statistics: _statistics!,
                charCode: _selectedCurrency,
              ),
              const SizedBox(height: 16),
              StatisticsMetricsGrid(
                statistics: _statistics!,
                charCode: _selectedCurrency,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
