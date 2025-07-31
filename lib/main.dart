import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'onboard_screening.dart'; // Renamed from onboarding_screen.dart
import 'lesson_plans_screen.dart';
import 'attendance_screen.dart';
import 'hygiene_products_screen.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env file loaded successfully");
  } catch (e) {
    debugPrint("❌ Error loading .env file: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dettol Hygiene Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007A33)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/lesson_plans': (context) => const LessonPlansScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        
      },
    );
  }
}