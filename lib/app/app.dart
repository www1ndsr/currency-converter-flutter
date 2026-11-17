import 'package:material_ui/material_ui.dart';
import '../core/constants/app_constants.dart';
import 'app_theme.dart';

class CurrencyApp extends StatelessWidget {
  final Widget home;

  const CurrencyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
