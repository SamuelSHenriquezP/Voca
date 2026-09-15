import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/voca_theme.dart';
import 'features/navigation/main_nav_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const VocaApp());
}

class VocaApp extends StatelessWidget {
  const VocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOCA - Speak English',
      debugShowCheckedModeBanner: false,
      theme: VocaTheme.lightTheme,
      home: const MainNavScreen(),
    );
  }
}
