import 'package:flutter/material.dart';
import 'chart_screen.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'mainImage': 'assets/images/Group6.png',
      'title': 'Get instant feedback\non your lesson plan',
      'description': 'Upload your lesson plans and get instant\nAI feedback to enhance your teaching.',
    },
    {
      'mainImage': 'assets/images/Group7.png',
      'title': 'Easily upload your\nclass attendance',
      'description': 'Track student attendance and get insights\non class participation trends.',
    },
    {
      'mainImage': 'assets/images/Group8.png',
      'title': 'Shop essential\nhygiene products',
      'description': 'Browse and purchase quality hygiene\nDettol products for your classroom.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007A33),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  imagePath: onboardingData[index]['mainImage']!,
                  title: onboardingData[index]['title']!,
                  description: onboardingData[index]['description']!,
                  showSkip: index < onboardingData.length - 1,
                  currentPage: _currentPage,
                  totalPages: onboardingData.length,
                );
              },
            ),
            if (_currentPage < onboardingData.length - 1)
              Positioned(
                top: 16,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    _controller.animateToPage(
                      _currentPage + 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Geist',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool showSkip;
  final int currentPage;
  final int totalPages;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.showSkip,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = screenHeight * 0.45; // Slightly reduced from 0.5 to 0.45
    
    return Stack(
      children: [
        // Green background for top portion
        Container(
          height: topHeight,
          color: const Color(0xFF007A33),
        ),
        // White background for bottom portion - extends to very bottom
        Positioned(
          top: topHeight - 10, // Start 10px higher to create overlap for border radius
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(150),
                topRight: Radius.circular(150),
              ),
            ),
          ),
        ),
        // Keti image positioned at the center of the circular border
        Positioned(
          top: topHeight - 40, // Position to center on the circular border
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.0),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                child: Image.asset(
                  'assets/images/Keti.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Content
        Column(
          children: [
            SizedBox(height: screenHeight * 0.12), // Reduced from fixed 130 to dynamic
            Center(
              child: Image.asset(
                imagePath,
                height: screenHeight * 0.25, // Reduced from fixed 280 to dynamic
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
            Expanded(
              child: SingleChildScrollView( // Added SingleChildScrollView to handle overflow
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 40),
                  padding: const EdgeInsets.only(
                    top: 80, // Increased top padding to account for Keti image
                    left: 24,
                    right: 24,
                    bottom: 20, // Reduced bottom padding
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Bricolage Grotesque',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: Color(0xFF020617),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24), // Reduced from 32
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          totalPages,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == currentPage
                                  ? const Color(0xFF007A33)
                                  : const Color(0xFFB5B5B5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24), // Reduced from 32
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007A33),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                  settings: RouteSettings(arguments: {'flow': 'signup'}),                                     
                            ),
                          );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 12), // Reduced from 16
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                  settings: RouteSettings(arguments: {'flow': 'login'}),                                     
                            )
                         );
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF007A33),
                              fontFamily: 'Geist',
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF007A33),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}