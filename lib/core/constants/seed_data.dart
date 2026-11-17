// Реальные данные BNM, полученные 18.11.2026 для работы приложения в Chrome
// (Chrome блокирует прямые запросы к bnm.md из-за CORS).
// На Android приложение всегда получает актуальные данные через сеть.
// Эти данные встроены как fallback и помечаются как кэшированные с датой получения.

const String kBnmSeedXml = '''<?xml version="1.0" encoding="UTF-8"?>
<ValCurs Date="18.11.2026" name="Official exchange rate">
  <Valute ID="47"><NumCode>978</NumCode><CharCode>EUR</CharCode><Nominal>1</Nominal><Name>Euro</Name><Value>20.1538</Value></Valute>
  <Valute ID="44"><NumCode>840</NumCode><CharCode>USD</CharCode><Nominal>1</Nominal><Name>US Dollar</Name><Value>18.3383</Value></Valute>
  <Valute ID="36"><NumCode>643</NumCode><CharCode>RUB</CharCode><Nominal>1</Nominal><Name>Russian Ruble</Name><Value>0.2221</Value></Valute>
  <Valute ID="35"><NumCode>946</NumCode><CharCode>RON</CharCode><Nominal>1</Nominal><Name>Romanian Leu</Name><Value>3.7684</Value></Valute>
  <Valute ID="43"><NumCode>980</NumCode><CharCode>UAH</CharCode><Nominal>1</Nominal><Name>Ukraine Hryvnia</Name><Value>0.4046</Value></Valute>
  <Valute ID="17"><NumCode>826</NumCode><CharCode>GBP</CharCode><Nominal>1</Nominal><Name>Pound Sterling</Name><Value>24.1864</Value></Valute>
  <Valute ID="9"><NumCode>756</NumCode><CharCode>CHF</CharCode><Nominal>1</Nominal><Name>Swiss Franc</Name><Value>21.8287</Value></Valute>
  <Valute ID="33"><NumCode>985</NumCode><CharCode>PLN</CharCode><Nominal>1</Nominal><Name>Polish Zloty</Name><Value>4.5779</Value></Valute>
  <Valute ID="42"><NumCode>949</NumCode><CharCode>TRY</CharCode><Nominal>1</Nominal><Name>Turkish Lira</Name><Value>0.3635</Value></Valute>
  <Valute ID="8"><NumCode>124</NumCode><CharCode>CAD</CharCode><Nominal>1</Nominal><Name>Canadian Dollar</Name><Value>12.8246</Value></Valute>
  <Valute ID="3"><NumCode>036</NumCode><CharCode>AUD</CharCode><Nominal>1</Nominal><Name>Australian Dollar</Name><Value>12.3628</Value></Valute>
  <Valute ID="25"><NumCode>392</NumCode><CharCode>JPY</CharCode><Nominal>100</Nominal><Name>Japanese Yen</Name><Value>11.5165</Value></Valute>
  <Valute ID="54"><NumCode>156</NumCode><CharCode>CNY</CharCode><Nominal>1</Nominal><Name>Chinese yuan renminbi</Name><Value>2.7508</Value></Valute>
  <Valute ID="21"><NumCode>348</NumCode><CharCode>HUF</CharCode><Nominal>100</Nominal><Name>Hungarian Forint</Name><Value>5.5244</Value></Valute>
  <Valute ID="10"><NumCode>203</NumCode><CharCode>CZK</CharCode><Nominal>1</Nominal><Name>Czech Koruna</Name><Value>0.8262</Value></Valute>
  <Valute ID="12"><NumCode>208</NumCode><CharCode>DKK</CharCode><Nominal>1</Nominal><Name>Danish Krone</Name><Value>2.6960</Value></Valute>
  <Valute ID="37"><NumCode>752</NumCode><CharCode>SEK</CharCode><Nominal>1</Nominal><Name>Swedish Krona</Name><Value>1.8134</Value></Valute>
  <Valute ID="32"><NumCode>578</NumCode><CharCode>NOK</CharCode><Nominal>1</Nominal><Name>Norwegian Krone</Name><Value>1.9039</Value></Valute>
  <Valute ID="61"><NumCode>784</NumCode><CharCode>AED</CharCode><Nominal>1</Nominal><Name>U.A.E. Dirham</Name><Value>4.9927</Value></Valute>
  <Valute ID="18"><NumCode>981</NumCode><CharCode>GEL</CharCode><Nominal>1</Nominal><Name>Georgian Lar</Name><Value>7.0695</Value></Valute>
  <Valute ID="4"><NumCode>944</NumCode><CharCode>AZN</CharCode><Nominal>1</Nominal><Name>Azerbaijanian Manat</Name><Value>10.7878</Value></Valute>
  <Valute ID="50"><NumCode>933</NumCode><CharCode>BYN</CharCode><Nominal>1</Nominal><Name>Belarussian Ruble</Name><Value>6.1092</Value></Valute>
  <Valute ID="1"><NumCode>051</NumCode><CharCode>AMD</CharCode><Nominal>10</Nominal><Name>Armenian Dram</Name><Value>0.5084</Value></Valute>
  <Valute ID="27"><NumCode>398</NumCode><CharCode>KZT</CharCode><Nominal>10</Nominal><Name>Kazakhstan Tenge</Name><Value>0.4129</Value></Valute>
  <Valute ID="45"><NumCode>860</NumCode><CharCode>UZS</CharCode><Nominal>100</Nominal><Name>Uzbekistan Sum</Name><Value>0.1526</Value></Valute>
  <Valute ID="46"><NumCode>960</NumCode><CharCode>XDR</CharCode><Nominal>1</Nominal><Name>Special Drawing Rights</Name><Value>24.6666</Value></Valute>
</ValCurs>''';
