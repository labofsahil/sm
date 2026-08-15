import 'package:flutter/material.dart';
import 'package:my_app/src/rust/frb_generated.dart';
import 'package:my_app/src/theme/app_theme.dart';
import 'package:my_app/src/views/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const SendmeApp());
}

class SendmeApp extends StatelessWidget {
  const SendmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sendme P2P Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardPage(),
    );
  }
}
