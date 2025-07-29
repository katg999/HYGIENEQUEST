import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chart_screen.dart';
import 'splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env file loaded successfully");
    print("API_KEY loaded: ${dotenv.env['API_KEY']?.substring(0, 10)}..."); 
  } catch (e) {
    print("❌ Error loading .env file: $e");
    print("Error type: ${e.runtimeType}");
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/voice_screen': (context) => const Placeholder(),
        '/text_screen': (context) => const ChatScreen(),
      },
    );
  }
}