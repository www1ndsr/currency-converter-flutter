import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/date_formatter.dart';
import '../models/exchange_rate.dart';
import '../models/historical_rate_point.dart';
import '../models/rate_snapshot.dart';

class BnmApiService {
  final http.Client _client;

  BnmApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches exchange rates from BNM for a given [date].
  /// If [date] is omitted, today's date is used.
  Future<RateSnapshot> fetchRates({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = DateFormatter.toBnmApi(targetDate);
    final uri = Uri.parse('${AppConstants.bnmBaseUrl}?get_xml=1&date=$dateStr');

    http.Response response;
    try {
      response = await _client.get(uri).timeout(AppConstants.networkTimeout);
    } on TimeoutException {
      throw const TimeoutException('Превышено время ожидания ответа от BNM');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(e.toString());
    }

    if (response.statusCode != 200) {
      throw NetworkException(
        'Сервер BNM вернул ошибку HTTP ${response.statusCode}',
      );
    }

    return parseXmlRates(
      xmlBody: response.body,
      requestedDate: targetDate,
    );
  }

  /// Parses BNM XML string into [RateSnapshot].
  /// Can be tested directly with raw XML string fixture.
  RateSnapshot parseXmlRates({
    required String xmlBody,
    required DateTime requestedDate,
  }) {
    if (xmlBody.trim().isEmpty) {
      throw const EmptyDataException('Ответ от сервера BNM пуст');
    }

    final XmlDocument document;
    try {
      document = XmlDocument.parse(xmlBody);
    } catch (e) {
      throw XmlParseException('Не удалось распарсить XML: $e');
    }

    final valCursElement = document.findAllElements('ValCurs').firstOrNull;
    if (valCursElement == null) {
      throw const XmlParseException('Корневой тег <ValCurs> не найден в XML BNM');
    }

    final dateAttr = valCursElement.getAttribute('Date');
    if (dateAttr == null || dateAttr.trim().isEmpty) {
      throw const XmlParseException('Атрибут Date отсутствует в теге <ValCurs>');
    }

    final effectiveDate = DateFormatter.tryParseBnmApi(dateAttr);
    if (effectiveDate == null) {
      throw XmlParseException('Неверный формат даты в XML BNM: $dateAttr');
    }

    final valuteElements = valCursElement.findElements('Valute');
    if (valuteElements.isEmpty) {
      throw const EmptyDataException('В ответе BNM нет элементов <Valute>');
    }

    final rates = <String, ExchangeRate>{};

    for (final valute in valuteElements) {
      final charCodeEl = valute.findElements('CharCode').firstOrNull;
      final nominalEl = valute.findElements('Nominal').firstOrNull;
      final nameEl = valute.findElements('Name').firstOrNull;
      final valueEl = valute.findElements('Value').firstOrNull;
      final numCodeEl = valute.findElements('NumCode').firstOrNull;

      if (charCodeEl == null || nominalEl == null || valueEl == null) {
        // Skip incomplete items or report error if none valid
        continue;
      }

      final charCode = charCodeEl.innerText.trim().toUpperCase();
      if (charCode.isEmpty) continue;

      final nominalInt = int.tryParse(nominalEl.innerText.trim());
      if (nominalInt == null || nominalInt <= 0) {
        continue;
      }

      // BNM uses '.' as decimal separator in XML (e.g. 19.0274)
      final rawValueText = valueEl.innerText.trim().replaceAll(',', '.');
      final valueDecimal = Decimal.tryParse(rawValueText);
      if (valueDecimal == null || valueDecimal <= Decimal.zero) {
        continue;
      }

      final numCodeInt = int.tryParse(numCodeEl?.innerText.trim() ?? '') ?? 0;
      final nameText = nameEl?.innerText.trim() ?? charCode;

      try {
        final rate = ExchangeRate.create(
          charCode: charCode,
          numCode: numCodeInt,
          nominal: nominalInt,
          name: nameText,
          value: valueDecimal,
        );
        rates[charCode] = rate;
      } catch (_) {
        // Skip invalid single items
      }
    }

    if (rates.isEmpty) {
      throw const EmptyDataException(
        'В ответе BNM не найдено ни одного корректного курса валюты',
      );
    }

    // Always inject MDL base currency with rate 1.0
    rates[AppConstants.baseCurrencyCode] = ExchangeRate.mdl();

    return RateSnapshot(
      requestedDate: requestedDate,
      effectiveDate: effectiveDate,
      fetchedAt: DateTime.now(),
      rates: rates,
      isFromCache: false,
      source: 'Banca Națională a Moldovei',
    );
  }

  /// Fetches historical points for a specific [charCode] over [days] calendar days.
  /// Iterates sequentially to prevent overloading BNM server.
  Future<List<HistoricalRatePoint>> fetchHistoricalRatesForCurrency({
    required String charCode,
    required int days,
    DateTime? endDate,
  }) async {
    final code = charCode.trim().toUpperCase();
    final end = endDate ?? DateTime.now();
    final points = <HistoricalRatePoint>[];

    // Build list of calendar dates from earliest to latest
    final dates = List.generate(days, (i) {
      final d = end.subtract(Duration(days: days - 1 - i));
      return DateTime(d.year, d.month, d.day);
    });

    for (final d in dates) {
      try {
        final snapshot = await fetchRates(date: d);
        final rate = snapshot.getRate(code);
        if (rate != null) {
          points.add(
            HistoricalRatePoint(
              date: d,
              effectiveDate: snapshot.effectiveDate,
              charCode: code,
              ratePerUnit: rate.ratePerUnit,
            ),
          );
        }
      } catch (_) {
        // If a weekend or holiday fetch fails, we can reuse previous valid point
        if (points.isNotEmpty) {
          final last = points.last;
          points.add(
            HistoricalRatePoint(
              date: d,
              effectiveDate: last.effectiveDate,
              charCode: code,
              ratePerUnit: last.ratePerUnit,
            ),
          );
        }
      }
    }

    if (points.isEmpty) {
      throw EmptyDataException(
        'Не удалось получить исторические данные для валюты $code за указанный период',
      );
    }

    return points;
  }
}
