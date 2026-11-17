import 'package:material_ui/material_ui.dart';
import 'app/app.dart';
import 'features/shell/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const CurrencyApp(
      home: MainShellScreen(
        screens: [
          Scaffold(body: Center(child: Text('Конвертер'))),
          Scaffold(body: Center(child: Text('Аналитика за 7 дней'))),
          Scaffold(body: Center(child: Text('Аналитика за 30 дней'))),
          Scaffold(body: Center(child: Text('О программе'))),
        ],
      ),
    ),
  );
}
