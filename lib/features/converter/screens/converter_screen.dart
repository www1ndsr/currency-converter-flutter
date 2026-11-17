import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/rate_snapshot.dart';
import '../../../data/repositories/exchange_rate_repository.dart';
import '../../../domain/services/conversion_service.dart';
import '../../../domain/validators/amount_validator.dart';
import '../widgets/conversion_result_card.dart';
import '../widgets/currency_picker_sheet.dart';

class ConverterScreen extends StatefulWidget {
  final ExchangeRateRepository repository;
  final ConversionService conversionService;

  const ConverterScreen({
    super.key,
    required this.repository,
    required this.conversionService,
  });

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _amountController = TextEditingController(text: '100');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RateSnapshot? _snapshot;
  bool _isLoading = false;
  String? _errorMessage;

  String _fromCurrency = 'EUR';
  String _toCurrency = AppConstants.baseCurrencyCode; // MDL

  ConversionResult? _conversionResult;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadRates({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await widget.repository.getLatestRates(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _isLoading = false;
      });
      _performConversion();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.userMessage;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Не удалось загрузить данные: $e';
        _isLoading = false;
      });
    }
  }

  void _performConversion() {
    if (_snapshot == null) return;

    final validationError = AmountValidator.validate(_amountController.text);
    if (validationError != null) {
      setState(() {
        _conversionResult = null;
      });
      return;
    }

    final parsedAmount = AmountValidator.tryParse(_amountController.text);
    if (parsedAmount == null) return;

    try {
      final result = widget.conversionService.convert(
        amount: parsedAmount,
        sourceCurrency: _fromCurrency,
        targetCurrency: _toCurrency,
        snapshot: _snapshot!,
      );
      setState(() {
        _conversionResult = result;
      });
    } catch (e) {
      // Handle conversion error
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _performConversion();
  }

  Future<void> _selectCurrency({required bool isFrom}) async {
    if (_snapshot == null) return;

    final sortedRates = _snapshot!.rates.values.toList()
      ..sort((a, b) => a.charCode.compareTo(b.charCode));

    final currentCode = isFrom ? _fromCurrency : _toCurrency;

    final selected = await CurrencyPickerSheet.show(
      context,
      rates: sortedRates,
      selectedCode: currentCode,
    );

    if (selected != null && mounted) {
      setState(() {
        if (isFrom) {
          _fromCurrency = selected;
        } else {
          _toCurrency = selected;
        }
      });
      _performConversion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Обновить курсы',
            onPressed: _isLoading ? null : () => _loadRates(forceRefresh: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _snapshot == null) {
      return const LoadingView(message: 'Загрузка официальных курсов BNM...');
    }

    if (_errorMessage != null && _snapshot == null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: () => _loadRates(forceRefresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadRates(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_snapshot != null) ...[
              Center(
                child: StatusBadge(
                  isFromCache: _snapshot!.isFromCache,
                  effectiveDate: _snapshot!.effectiveDate,
                  fetchedAt: _snapshot!.fetchedAt,
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Card for input amount and currency selectors
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Сумма для конвертации',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calculate_outlined, color: AppColors.primary),
                          suffixIcon: _amountController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _amountController.clear();
                                    _performConversion();
                                  },
                                )
                              : null,
                          hintText: '0.00',
                        ),
                        validator: AmountValidator.validate,
                        onChanged: (_) => _performConversion(),
                      ),
                      const SizedBox(height: 20),
                      // Currency Selector Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencySelectorTile(
                              label: 'Отдаете',
                              code: _fromCurrency,
                              onTap: () => _selectCurrency(isFrom: true),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: IconButton.filledTonal(
                              onPressed: _swapCurrencies,
                              icon: const Icon(Icons.swap_horiz, size: 22),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary.withAlpha(20),
                                foregroundColor: AppColors.primary,
                              ),
                              tooltip: 'Поменять валюты местами',
                            ),
                          ),
                          Expanded(
                            child: _buildCurrencySelectorTile(
                              label: 'Получаете',
                              code: _toCurrency,
                              onTap: () => _selectCurrency(isFrom: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Quick currency chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text(
                              'Быстрый выбор: ',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            ...AppConstants.primaryCurrencies.take(6).map((c) {
                              final isSelected = c == _fromCurrency;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: ChoiceChip(
                                  label: Text(c, style: const TextStyle(fontSize: 12)),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() {
                                        _fromCurrency = c;
                                      });
                                      _performConversion();
                                    }
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_conversionResult != null)
              ConversionResultCard(result: _conversionResult!)
            else if (_amountController.text.isNotEmpty &&
                AmountValidator.validate(_amountController.text) != null)
              Card(
                color: AppColors.trendDecline.withAlpha(15),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.trendDecline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AmountValidator.validate(_amountController.text)!,
                          style: const TextStyle(
                            color: AppColors.trendDecline,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _performConversion,
              icon: const Icon(Icons.sync_alt, size: 20),
              label: const Text('Рассчитать по официальному курсу'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelectorTile({
    required String label,
    required String code,
    required VoidCallback onTap,
  }) {
    final currencyObj = _snapshot?.getRate(code);
    final name = currencyObj?.name ?? code;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
