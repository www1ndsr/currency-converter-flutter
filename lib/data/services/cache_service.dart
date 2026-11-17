import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/historical_rate_point.dart';
import '../models/rate_snapshot.dart';

class CacheService {
  static const String _keyLatestSnapshot = 'bnm_latest_rate_snapshot';
  static const String _prefixHistory = 'bnm_history_';

  final SharedPreferences? _prefInstance;

  CacheService({SharedPreferences? preferences}) : _prefInstance = preferences;

  Future<SharedPreferences> _getPrefs() async {
    return _prefInstance ?? await SharedPreferences.getInstance();
  }

  /// Saves the latest rate snapshot to persistent storage.
  Future<bool> saveLatestSnapshot(RateSnapshot snapshot) async {
    try {
      final prefs = await _getPrefs();
      final jsonMap = snapshot.toJson();
      final jsonString = jsonEncode(jsonMap);
      return await prefs.setString(_keyLatestSnapshot, jsonString);
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the latest rate snapshot from persistent storage.
  /// Returns null if no cache exists or if cache is corrupted.
  Future<RateSnapshot?> getLatestSnapshot() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keyLatestSnapshot);
      if (jsonString == null || jsonString.trim().isEmpty) {
        return null;
      }
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final snapshot = RateSnapshot.fromJson(decoded);
      // Mark explicitly as cached
      return snapshot.copyWith(isFromCache: true);
    } catch (_) {
      // Gracefully handle corrupted cache
      return null;
    }
  }

  /// Saves historical rate points for a specific currency [charCode].
  Future<bool> saveHistoricalPoints({
    required String charCode,
    required List<HistoricalRatePoint> points,
  }) async {
    try {
      final prefs = await _getPrefs();
      final key = '$_prefixHistory${charCode.trim().toUpperCase()}';
      final listJson = points.map((p) => p.toJson()).toList();
      return await prefs.setString(key, jsonEncode(listJson));
    } catch (_) {
      return false;
    }
  }

  /// Retrieves historical rate points for a specific currency [charCode].
  Future<List<HistoricalRatePoint>?> getHistoricalPoints(String charCode) async {
    try {
      final prefs = await _getPrefs();
      final key = '$_prefixHistory${charCode.trim().toUpperCase()}';
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.trim().isEmpty) {
        return null;
      }
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return null;
      }
      final points = decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => HistoricalRatePoint.fromJson(item))
          .toList();
      return points.isEmpty ? null : points;
    } catch (_) {
      return null;
    }
  }

  /// Clears all stored rate data from cache.
  Future<bool> clearAll() async {
    try {
      final prefs = await _getPrefs();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key == _keyLatestSnapshot || key.startsWith(_prefixHistory)) {
          await prefs.remove(key);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
