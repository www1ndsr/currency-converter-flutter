import '../models/historical_rate_point.dart';
import '../models/rate_snapshot.dart';
import '../services/bnm_api_service.dart';
import '../services/cache_service.dart';
import '../../core/constants/seed_data.dart';
import '../../core/constants/seed_history.dart';
import '../../core/errors/app_exceptions.dart';

class ExchangeRateRepository {
  final BnmApiService _apiService;
  final CacheService _cacheService;

  ExchangeRateRepository({
    BnmApiService? apiService,
    CacheService? cacheService,
  })  : _apiService = apiService ?? BnmApiService(),
        _cacheService = cacheService ?? CacheService();

  /// Gets current exchange rates. Tries network first; falls back to cache on failure.
  Future<RateSnapshot> getLatestRates({bool forceRefresh = false}) async {
    try {
      final freshSnapshot = await _apiService.fetchRates();
      // Persist successful snapshot in cache
      await _cacheService.saveLatestSnapshot(freshSnapshot);
      return freshSnapshot;
    } catch (e) {
      // Network or parsing failed: attempt offline fallback
      final cachedSnapshot = await _cacheService.getLatestSnapshot();
      if (cachedSnapshot != null) {
        return cachedSnapshot;
      }

      // No cache available to fallback to
      // Last resort: use built-in seed data (real BNM rates, pre-fetched)
      try {
        final seedSnapshot = _apiService.parseXmlRates(
          xmlBody: kBnmSeedXml,
          requestedDate: DateTime(2026, 11, 18),
        );
        final seedCached = seedSnapshot.copyWith(isFromCache: true);
        // Save seed to cache so subsequent loads are faster
        await _cacheService.saveLatestSnapshot(seedCached);
        return seedCached;
      } catch (_) {}

      if (e is AppException) {
        throw CacheNotFoundException(
          'Сеть недоступна, а локальный кэш отсутствует: ${e.userMessage}',
        );
      }
      throw CacheNotFoundException(
        'Сеть недоступна, а локальный кэш отсутствует ($e)',
      );
    }
  }

  /// Gets historical rate points for [charCode] for the last [days] days (e.g. 7 or 30).
  /// Falls back to cached history if network is unavailable.
  Future<List<HistoricalRatePoint>> getHistoricalRates({
    required String charCode,
    required int days,
    bool forceRefresh = false,
  }) async {
    final code = charCode.trim().toUpperCase();

    if (!forceRefresh) {
      final cachedPoints = await _cacheService.getHistoricalPoints(code);
      if (cachedPoints != null && cachedPoints.length >= days) {
        // Return latest [days] points
        return cachedPoints.sublist(cachedPoints.length - days);
      }
    }

    try {
      final freshPoints = await _apiService.fetchHistoricalRatesForCurrency(
        charCode: code,
        days: days,
      );
      await _cacheService.saveHistoricalPoints(
        charCode: code,
        points: freshPoints,
      );
      return freshPoints;
    } catch (e) {
      final cachedPoints = await _cacheService.getHistoricalPoints(code);
      if (cachedPoints != null && cachedPoints.isNotEmpty) {
        final count = cachedPoints.length >= days ? days : cachedPoints.length;
        return cachedPoints.sublist(cachedPoints.length - count);
      }

      // Last resort: use built-in seed history (real BNM data)
      final seedPoints = SeedHistory.getPoints(code);
      if (seedPoints.isNotEmpty) {
        final count = seedPoints.length >= days ? days : seedPoints.length;
        return seedPoints.sublist(seedPoints.length - count);
      }

      if (e is AppException) rethrow;
      throw EmptyDataException(
        'Не удалось получить историю курсов для $code ($e)',
      );
    }
  }

  /// Clears stored cache.
  Future<bool> clearCache() => _cacheService.clearAll();

  /// Returns cached snapshot without making network calls.
  Future<RateSnapshot?> getCachedSnapshot() => _cacheService.getLatestSnapshot();
}
