import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/voca_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure premium web typography is actively fetched via internet connection
  GoogleFonts.config.allowRuntimeFetching = true;
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
