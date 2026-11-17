import 'package:flutter_test/flutter_test.dart';
import 'package:currency_converter_flutter/app/app.dart';
import 'package:currency_converter_flutter/features/shell/main_shell_screen.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('Main shell renders navigation destinations smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CurrencyApp(
        home: MainShellScreen(
          screens: [
            Scaffold(body: Center(child: Text('Конвертер'))),
            Scaffold(body: Center(child: Text('7 дней'))),
            Scaffold(body: Center(child: Text('30 дней'))),
            Scaffold(body: Center(child: Text('Инфо'))),
          ],
        ),
      ),
    );

    expect(find.text('Конвертер'), findsWidgets);
    expect(find.text('7 дней'), findsOneWidget);
    expect(find.text('30 дней'), findsOneWidget);
    expect(find.text('Инфо'), findsOneWidget);
  });
}
