import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'onboard_screening.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _controller = TextEditingController();
  
  String _phoneNumber = '';
  bool _isLoading = false;
  bool _loginComplete = false;
  String _userName = '';
  
  List<Map<String, dynamic>> _conversation = [
    {
      'sender': 'bot',
      'message': 'Welcome to the Dettol Hygiene Quest chatbot! 👋',
    },
    {
      'sender': 'bot',
      'message': 'I\'m here to support your hygiene education efforts in class.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  );
                },
                child: Image.asset('assets/images/StatusIcon.png', height: 24),
              ),
            ),
            Center(
              child: const Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'Bricolage Grotesque',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Image.asset('assets/images/Group9.png', height: 100),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF007A33),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFFBF0),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ..._conversation.map((message) => 
                    message['sender'] == 'bot' 
                      ? _buildBotMessage(message['message'])
                      : _buildUserMessage(message['message'])
                  ),
                  
                  if (!_loginComplete) 
                    _buildBotMessage("Enter your registered phone number to login"),
                ],
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          if (!_loginComplete) _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildBotMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/Keti.png', width: 32, height: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF007A33),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF007A33),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Image.asset('assets/images/paperclip.png', width: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset('assets/images/mic_line.png', width: 24),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type here",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                hintStyle: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.3,
                  color: Color(0xFF64748B),
                ),
              ),
              onSubmitted: (value) => _handleUserInput(value),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF007A33),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Image.asset('assets/images/SendIcon.png', width: 24),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _handleUserInput(_controller.text);
                  _controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleUserInput(String input) {
    if (input.trim().isEmpty) return;

    setState(() {
      _conversation.add({
        'sender': 'user',
        'message': input.trim(),
      });
    });

    if (_validatePhone(input)) {
      _phoneNumber = input.trim();
      setState(() {
        _conversation.add({
          'sender': 'bot',
          'message': "⏳ Checking registration status...",
        });
      });
      _checkRegistrationStatus();
    } else {
      setState(() {
        _conversation.add({
          'sender': 'bot',
          'message': 'Please enter a valid Ugandan phone number (e.g., +256701234567 or 0701234567)',
        });
      });
    }
  }

  bool _validatePhone(String input) {
    final ugandanPhoneRegex = RegExp(r'^(\+256|0)[0-9]{9}$');
    return ugandanPhoneRegex.hasMatch(input.replaceAll(' ', ''));
  }

  Future<void> _checkRegistrationStatus() async {
    setState(() => _isLoading = true);
    try {
      final response = await _authService.checkRegistrationStatus(_phoneNumber);
      
      if (response['registered'] == true) {
        _userName = response['name'] ?? 'User';
        
        setState(() {
          _conversation.addAll([
            {
              'sender': 'bot',
              'message': "Welcome back, $_userName! 😊",
            },
            {
              'sender': 'bot',
              'message': "⏳ Redirecting to your account...",
            },
          ]);
          _loginComplete = true;
        });
        
        // Navigate to home screen after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        setState(() {
          _conversation.add({
            'sender': 'bot',
            'message': "This phone number is not registered. Please register first.",
          });
        });
      }
    } catch (e) {
      setState(() {
        _conversation.add({
          'sender': 'bot',
          'message': 'Error checking registration status. Please try again.',
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}