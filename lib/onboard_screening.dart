import 'package:flutter/material.dart';

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
      'description': 'Upload your lesson plans and get instant AI feedback to enhance your teaching.',
    },
    {
      'mainImage': 'assets/images/Group7.png',
      'title': 'Easily upload your\nclass attendance',
      'description': 'Track student attendance and get insights on class participation trends.',
    },
    {
      'mainImage': 'assets/images/Group8.png',
      'title': 'Shop essential\nhygiene products',
      'description': 'Browse and purchase quality hygiene Dettol products for your classroom.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007A33),
      body: SafeArea(
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
                top: MediaQuery.of(context).padding.top + 20, // Responsive to status bar
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    // Changed from jumpToPage to animateToPage for smooth transition
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
    
    return Column(
      children: [
        // Dynamic spacing based on screen height to ensure proper positioning
        SizedBox(height: screenHeight * 0.15), // 15% of screen height for top spacing
        Center(
          child: Image.asset(
            imagePath,
            height: 250,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
          ),
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(40), // More oval shape at top
          ),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0), // Remove horizontal margin
            padding: const EdgeInsets.only(
              top: 50, // Increased padding for better spacing
              bottom: 30, // Increased bottom padding
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                // Position Keti image in the curved area
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -25), // Move Keti image further up into the curve
                    child: Image.asset(
                      'assets/images/Keti.png',
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 35), // Adjusted spacing after Keti image
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Bricolage Grotesque',
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.01,
                    color: Color(0xFF020617), // Changed to #020617
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: index == currentPage
                            ? const Color(0xFF007A33)
                            : const Color(0xFFB5B5B5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A33),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
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
                    // Handle Sign Up
                  },
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // Handle Login
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
      ],
    );
  }
}