import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'auth_service.dart';
import 'onboard_screening.dart';
import 'openai_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _controller = TextEditingController();
  
  String _phoneNumber = '';
  String _fullName = '';
  String _school = '';
  String _district = '';
  String _language = 'English';
  String _otp = ''; 
  bool _otpSent = false;
  int _currentStep = 0;
  bool _isLoading = false;
  bool _registrationComplete = false;
  File? _selectedDocument;
  bool _documentProcessing = false;
  
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
                'Register',
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
                  
                  if (_currentStep == 0 && !_registrationComplete) 
                    _buildBotMessage("Let's get you registered! Please upload your school ID or any document that contains your name, school name, and district."),
                  
                  if (_documentProcessing)
                    _buildBotMessage("Processing your document..."),
                  
                  if (_currentStep == 3 && !_registrationComplete)
                    _buildBotMessage("Perfect! Now, what is your phone number? 📱"),
                  
                  if (_currentStep == 5 && !_registrationComplete)
                    _buildBotMessage("OTP sent successfully! Please enter the 6 digit OTP sent to $_phoneNumber"),
                ],
              ),
            ),
          ),
          if (_isLoading || _documentProcessing) const LinearProgressIndicator(),
          if (!_registrationComplete) _buildInputSection(),
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
            onPressed: _pickDocument,
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

  Future<void> _pickDocument() async {
    if (_currentStep != 0) return;
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedDocument = File(pickedFile.path);
        _documentProcessing = true;
      });
      
      try {
        final result = await _openAIService.extractRegistrationInfo(_selectedDocument!);
        
        setState(() {
          _fullName = result['name'] ?? '';
          _school = result['school'] ?? '';
          _district = result['district'] ?? '';
          _documentProcessing = false;
        });
        
        if (_fullName.isNotEmpty && _school.isNotEmpty && _district.isNotEmpty) {
          setState(() {
            _conversation.addAll([
              {
                'sender': 'bot',
                'message': "Thank you! I found the following information:",
              },
              {
                'sender': 'bot',
                'message': "👤 Name: $_fullName",
              },
              {
                'sender': 'bot',
                'message': "🏫 School: $_school",
              },
              {
                'sender': 'bot',
                'message': "📍 District: $_district",
              },
              {
                'sender': 'bot',
                'message': "Is this information correct?",
              },
            ]);
            _currentStep = 3; // Skip to phone number step
          });
        } else {
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': "I couldn't extract all the required information. Please type your details manually.",
            });
            _documentProcessing = false;
          });
        }
      } catch (e) {
        setState(() {
          _conversation.add({
            'sender': 'bot',
            'message': "Error processing document. Please try again or type your details manually.",
          });
          _documentProcessing = false;
        });
      }
    }
  }

  void _handleUserInput(String input) {
    if (input.trim().isEmpty) return;

    setState(() {
      _conversation.add({
        'sender': 'user',
        'message': input.trim(),
      });
    });

    switch (_currentStep) {
      case 0:
        // Manual entry fallback if document upload fails
        if (input.trim().length >= 2) {
          _fullName = input.trim();
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': "Nice to meet you, $_fullName! 😊",
            });
            _conversation.add({
              'sender': 'bot',
              'message': "Which school do you teach at? 🏫",
            });
            _currentStep = 1;
          });
        } else {
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': 'Please enter a valid name (at least 2 characters)',
            });
          });
        }
        break;
      case 1:
        if (input.trim().length >= 2) {
          _school = input.trim();
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': "Great! $_school sounds like a wonderful place to teach. 🌟",
            });
            _conversation.add({
              'sender': 'bot',
              'message': "In which district is your school located? 📍",
            });
            _currentStep = 2;
          });
        } else {
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': 'Please enter a valid school name',
            });
          });
        }
        break;
      case 2:
        if (input.trim().length >= 2) {
          _district = input.trim();
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': "Perfect! Now, what is your phone number? 📱",
            });
            _currentStep = 3;
          });
        } else {
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': 'Please enter a valid district name',
            });
          });
        }
        break;
      case 3:
        if (_validatePhone(input)) {
          _phoneNumber = input.trim();
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': "Sending OTP to $_phoneNumber...",
            });
            _currentStep = 4;
          });
          _sendOtp();
        } else {
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': 'Please enter a valid Ugandan phone number (e.g., +256701234567 or 0701234567)',
            });
          });
        }
        break;
      case 5:
        if (input.trim().length == 6 && input.contains(RegExp(r'^\d+$'))) {
          _otp = input.trim();
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': "Verifying OTP...",
            });
            _currentStep = 6;
          });
          _verifyOtp();
        } else {
          setState(() {
            _conversation.add({
              'sender': 'bot',
              'message': 'Please enter a valid 6-digit OTP',
            });
          });
        }
        break;
    }
  }

  bool _validatePhone(String input) {
    final ugandanPhoneRegex = RegExp(r'^(\+256|0)[0-9]{9}$');
    return ugandanPhoneRegex.hasMatch(input.replaceAll(' ', ''));
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      await _authService.sendOtp(_phoneNumber);
      setState(() {
        _conversation.add({
          'sender': 'bot',
          'message': "OTP sent to $_phoneNumber",
        });
        _currentStep = 5;
      });
    } catch (e) {
      setState(() {
        _conversation.add({
          'sender': 'bot',
          'message': 'Error sending OTP. Please try again.',
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final verified = await _authService.verifyOtp(_phoneNumber, _otp);
      if (verified) {
        await _registerUser();
      } else {
        setState(() {
          _conversation.add({
            'sender': 'bot',
            'message': 'Invalid OTP. Please try again.',
          });
          _currentStep = 5;
        });
      }
    } catch (e) {
      setState(() {
        _conversation.add({
          'sender': 'bot',
          'message': 'Error verifying OTP. Please try again.',
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerUser() async {
    try {
      await _authService.registerUser({
        'phone': _phoneNumber,
        'name': _fullName,
        'school': _school,
        'district': _district,
        'language': _language,
      });

      setState(() {
        _conversation.addAll([
          {
            'sender': 'bot',
            'message': "OTP verified successfully!",
          },
          {
            'sender': 'bot',
            'message': "Account created successfully!",
          },
          {
            'sender': 'bot',
            'message': "Registration complete! Please go back to the login screen to sign in.",
          },
        ]);
        _registrationComplete = true;
      });
    } catch (e) {
      setState(() {
        _conversation.add({
          'sender': 'bot',
          'message': 'Error creating account. Please try again.',
        });
      });
    }
  }
}