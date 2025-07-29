import 'package:flutter/material.dart';
import 'package:appbot/home_screen.dart';
import 'onboard_screening.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Extend delay so you can view the splash better (e.g. 5 seconds)
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007A33),
      body: SafeArea(
        child: Column(
          children: [
            // Main logo centered in the middle of the screen
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Dettol branding at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/Dettol.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Brought to you by Dettol',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}