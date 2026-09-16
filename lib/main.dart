import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/voca_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
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
      home: const OnboardingScreen(),
    );
  }
}
