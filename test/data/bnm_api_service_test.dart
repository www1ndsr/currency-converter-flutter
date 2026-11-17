import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:decimal/decimal.dart';
import 'package:currency_converter_flutter/core/errors/app_exceptions.dart';
import 'package:currency_converter_flutter/data/services/bnm_api_service.dart';

void main() {
  const validXmlFixture = '''<?xml version="1.0" encoding="UTF-8"?>
<ValCurs Date="15.11.2024" name="Official exchange rate">
  <Valute ID="47">
    <NumCode>978</NumCode>
    <CharCode>EUR</CharCode>
    <Nominal>1</Nominal>
    <Name>Euro</Name>
    <Value>19.0274</Value>
  </Valute>
  <Valute ID="44">
    <NumCode>840</NumCode>
    <CharCode>USD</CharCode>
    <Nominal>1</Nominal>
    <Name>US Dollar</Name>
    <Value>18.0732</Value>
  </Valute>
  <Valute ID="30">
    <NumCode>348</NumCode>
    <CharCode>HUF</CharCode>
    <Nominal>100</Nominal>
    <Name>Forint</Name>
    <Value>4.8500</Value>
  </Valute>
</ValCurs>''';

  group('BnmApiService - XML Parser', () {
    late BnmApiService apiService;

    setUp(() {
      apiService = BnmApiService();
    });

    test('parses valid BNM XML and extracts rates correctly', () {
      final snapshot = apiService.parseXmlRates(
        xmlBody: validXmlFixture,
        requestedDate: DateTime(2024, 11, 15),
      );

      expect(snapshot.effectiveDate, DateTime(2024, 11, 15));
      expect(snapshot.rates.containsKey('EUR'), isTrue);
      expect(snapshot.rates.containsKey('USD'), isTrue);
      expect(snapshot.rates.containsKey('HUF'), isTrue);
      expect(snapshot.rates.containsKey('MDL'), isTrue);

      final eur = snapshot.getRate('EUR')!;
      expect(eur.charCode, 'EUR');
      expect(eur.nominal, 1);
      expect(eur.value, Decimal.parse('19.0274'));
      expect(eur.ratePerUnit, Decimal.parse('19.0274'));

      // Check normalization with nominal = 100
      final huf = snapshot.getRate('HUF')!;
      expect(huf.nominal, 100);
      expect(huf.value, Decimal.parse('4.8500'));
      expect(huf.ratePerUnit, Decimal.parse('0.0485'));

      // Check injected base MDL
      final mdl = snapshot.getRate('MDL')!;
      expect(mdl.charCode, 'MDL');
      expect(mdl.ratePerUnit, Decimal.one);
    });

    test('throws EmptyDataException on empty response body', () {
      expect(
        () => apiService.parseXmlRates(
          xmlBody: '',
          requestedDate: DateTime(2024, 11, 15),
        ),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('throws XmlParseException on malformed XML syntax', () {
      expect(
        () => apiService.parseXmlRates(
          xmlBody: '<ValCurs Date="15.11.2024"><Valute><unclosed></ValCurs>',
          requestedDate: DateTime(2024, 11, 15),
        ),
        throwsA(isA<XmlParseException>()),
      );
    });

    test('throws XmlParseException when Date attribute is missing', () {
      const xmlWithoutDate = '''<?xml version="1.0"?>
<ValCurs name="Official exchange rate">
  <Valute ID="47">
    <CharCode>EUR</CharCode>
    <Nominal>1</Nominal>
    <Value>19.0</Value>
  </Valute>
</ValCurs>''';

      expect(
        () => apiService.parseXmlRates(
          xmlBody: xmlWithoutDate,
          requestedDate: DateTime(2024, 11, 15),
        ),
        throwsA(isA<XmlParseException>()),
      );
    });

    test('throws EmptyDataException when no Valute tags are present', () {
      const emptyValCursXml = '''<?xml version="1.0"?>
<ValCurs Date="15.11.2024" name="Empty">
</ValCurs>''';

      expect(
        () => apiService.parseXmlRates(
          xmlBody: emptyValCursXml,
          requestedDate: DateTime(2024, 11, 15),
        ),
        throwsA(isA<EmptyDataException>()),
      );
    });
  });

  group('BnmApiService - HTTP Client & Networking', () {
    test('successfully fetches rates with MockClient', () async {
      final mockClient = MockClient((request) async {
        return http.Response(validXmlFixture, 200, headers: {'content-type': 'application/xml'});
      });

      final service = BnmApiService(client: mockClient);
      final snapshot = await service.fetchRates(date: DateTime(2024, 11, 15));

      expect(snapshot.rates.length, 4); // EUR, USD, HUF + MDL
      expect(snapshot.getRate('EUR')!.ratePerUnit, Decimal.parse('19.0274'));
    });

    test('throws NetworkException when server responds with 500 Internal Error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final service = BnmApiService(client: mockClient);
      expect(
        () => service.fetchRates(date: DateTime(2024, 11, 15)),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
