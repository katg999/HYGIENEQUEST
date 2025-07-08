import 'package:flutter/material.dart';
import 'home_screen.dart'; // ✅ Corrected path
import 'chart_screen.dart'; 
void main() {
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
      home: const HomeScreen(),
      routes: {
        '/voice_screen': (context) => const Placeholder(),
        '/text_screen': (context) => const ChatScreen(),
      },
    );
  }
}
