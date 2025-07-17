import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import './openai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _chat = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late final OpenAIService _openAIService;
 final TextRecognizer _textRecognizer = TextRecognizer();
  
  int _step = 0;
  String _phoneNumber = '';
  String _fullName = '';
  String _school = '';
  String _district = '';
  String _language = '';
  String _otp = '';
  bool _isLoading = false;
  
  // Attendance tracking variables
  String _presentStudents = '';
  String _absentStudents = '';
  String _absenceReasons = '';
  String _topicCovered = '';
  int _attendanceStep = 0;

  // API base URL
  final String _baseUrl = 'https://hygienequestemdpoints.onrender.com';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _openAIService = OpenAIService();
    _addBotMessage("Welcome to the Dettol Hygiene Quest Chatbot! 🤖", showAvatar: true);
    _addBotMessage("I'm here to support your hygiene education efforts in class. 📚");
    _addBotMessage("Please enter your phone number to get started. 📱");
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _handleUserInput(String input) {
    if (input.trim().isEmpty) return;
    
    setState(() {
      _chat.add({
        'sender': 'user', 
        'message': input, 
        'timestamp': DateTime.now(),
        'isAnimated': true
      });
    });

    _scrollToBottom();

    switch (_step) {
      case 0:
        if (_isValidPhoneNumber(input)) {
          _phoneNumber = input;
          _checkRegistrationStatus();
        } else {
          _addBotMessage("Please enter a valid phone number (e.g., +256701234567 or 0701234567). ❌");
        }
        break;
      case 1:
        if (input.trim().length >= 2) {
          _fullName = input;
          _addBotMessage("Nice to meet you, $_fullName! 😊");
          _addBotMessage("Which school do you teach at? 🏫");
          _step++;
        } else {
          _addBotMessage("Please enter your full name (at least 2 characters). ❌");
        }
        break;
      case 2:
        if (input.trim().length >= 2) {
          _school = input;
          _addBotMessage("Great! $_school sounds like a wonderful place to teach. 🌟");
          _addBotMessage("In which district is your school located? 📍");
          _step++;
        } else {
          _addBotMessage("Please enter your school name (at least 2 characters). ❌");
        }
        break;
      case 3:
        if (input.trim().length >= 2) {
          _district = input;
          _addBotMessage("Perfect! Now, what is your preferred language of response? 🗣️");
          _step++;
        } else {
          _addBotMessage("Please enter your district name (at least 2 characters). ❌");
        }
        break;
      case 4:
        // This step is handled with buttons below
        break;
      case 5:
        _sendOtp();
        break;
      case 6:
        if (input.length == 6 && input.contains(RegExp(r'^\d+$'))) {
          _otp = input;
          _verifyOtp();
        } else {
          _addBotMessage("Please enter a valid 6-digit OTP. ❌");
        }
        break;
      case 7:
        _addBotMessage("Please select an option from the menu below. 👇");
        break;
      case 8: // Attendance submission flow
        _handleAttendanceInput(input);
        break;
      default:
        _addBotMessage("I received: $input ✅");
    }

    _controller.clear();
  }

  bool _isValidPhoneNumber(String phone) {
    // Simple validation for Ugandan phone numbers
    final ugandanPhoneRegex = RegExp(r'^(\+256|0)[0-9]{9}$');
    return ugandanPhoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }

  Future<void> _checkRegistrationStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    // Add loading message and keep track of its index
    int loadingMessageIndex = _chat.length;
    _addBotMessage("Checking registration status... 🔍", showLoading: true);
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/check-registration/$_phoneNumber'),
        headers: {'Content-Type': 'application/json'},
      );

      // Remove the loading message
      setState(() {
        if (loadingMessageIndex < _chat.length) {
          _chat.removeAt(loadingMessageIndex);
        }
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['registered'] == true) {
          // User is already registered
          _fullName = data['name'] ?? 'User';
          _school = data['school'] ?? '';
          _district = data['district'] ?? '';
          _language = data['language'] ?? 'English';
          
          _addBotMessage("Registration status checked successfully! ✅");
          _addBotMessage("Welcome back, $_fullName! 🎉");
          _addBotMessage("Great to see you again! What would you like to do today? 😊");
          _step = 7; // Go directly to main menu
        } else {
          // User is not registered, proceed with registration
          _addBotMessage("Registration check complete! ✅");
          _addBotMessage("Perfect! Let's begin the registration setup. ✅");
          _addBotMessage("What's your full name? 👤");
          _step = 1; // Continue with registration flow
        }
      } else if (response.statusCode == 404) {
        // User not found, proceed with registration
        _addBotMessage("Registration check complete! ✅");
        _addBotMessage("Perfect! Let's begin the registration setup. ✅");
        _addBotMessage("What's your full name? 👤");
        _step = 1; // Continue with registration flow
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Failed to check registration status';
        _addBotMessage("❌ Error: $error");
        _addBotMessage("Let's proceed with registration. What's your full name? 👤");
        _step = 1; // Continue with registration flow as fallback
      }
    } catch (e) {
      // Remove the loading message in case of error too
      setState(() {
        if (loadingMessageIndex < _chat.length) {
          _chat.removeAt(loadingMessageIndex);
        }
      });
      
      _addBotMessage("❌ Error: Failed to connect to the server. Let's proceed with registration.");
      _addBotMessage("What's your full name? 👤");
      _step = 1; // Continue with registration flow as fallback
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleAttendanceInput(String input) {
    switch (_attendanceStep) {
      case 0:
        if (_isValidNumber(input)) {
          _presentStudents = input;
          _addBotMessage("Got it! $_presentStudents students were present. 👥");
          _addBotMessage("How many students were absent? 🤔");
          _attendanceStep++;
        } else {
          _addBotMessage("Please enter a valid number of students. ❌");
        }
        break;
      case 1:
        if (_isValidNumber(input)) {
          _absentStudents = input;
          _addBotMessage("I see, $_absentStudents students were absent. 📝");
          _addBotMessage("Please briefly explain the reasons for absence.\n\nFor example: \"2 students sick with flu, 1 student had family emergency\" 🏥");
          _attendanceStep++;
        } else {
          _addBotMessage("Please enter a valid number of absent students. ❌");
        }
        break;
      case 2:
        if (input.trim().length >= 5) {
          _absenceReasons = input;
          _addBotMessage("Thank you for the explanation. 📋");
          _addBotMessage("What topic did you cover today?\n\nFor example: \"Algebraic Equations\" or \"Hand Washing Techniques\" 📚");
          _attendanceStep++;
        } else {
          _addBotMessage("Please provide a more detailed explanation (at least 5 characters). ❌");
        }
        break;
      case 3:
        if (input.trim().length >= 3) {
          _topicCovered = input;
          _submitAttendance();
        } else {
          _addBotMessage("Please enter the topic you covered (at least 3 characters). ❌");
        }
        break;
    }
  }

  bool _isValidNumber(String input) {
    final number = int.tryParse(input);
    return number != null && number >= 0;
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });
    
    _addBotMessage("Sending OTP to $_phoneNumber... 📨", showLoading: true);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': _phoneNumber}),
      );

      if (response.statusCode == 200) {
        _addBotMessage("OTP sent successfully! 🎉");
        _addBotMessage("Please enter the 6-digit OTP sent to $_phoneNumber. 🔐");
        _step++;
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Failed to send OTP';
        _addBotMessage("❌ Error: $error");
      }
    } catch (e) {
      _addBotMessage("❌ Error: Failed to connect to the server. Please check your internet connection and try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });
    
    _addBotMessage("Verifying OTP... 🔍", showLoading: true);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': _phoneNumber, 'otp': _otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['verified'] == true) {
          _addBotMessage("OTP verified successfully! 🎉");
          _registerUser();
        } else {
          _addBotMessage("❌ Invalid OTP. Please try again.");
          _step = 5; // Go back to OTP sending step
        }
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'OTP verification failed';
        _addBotMessage("❌ Error: $error");
        _step = 5; // Go back to OTP sending step
      }
    } catch (e) {
      _addBotMessage("❌ Error: Failed to connect to the server. Please try again.");
      _step = 5; // Go back to OTP sending step
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    
    _addBotMessage("Creating your account... 👤", showLoading: true);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _phoneNumber,
          'name': _fullName,
          'school': _school,
          'district': _district,
          'language': _language,
        }),
      );

      if (response.statusCode == 201) {
        _addBotMessage("🎉 Registration successful! Welcome aboard, $_fullName!");
        _addBotMessage("You can now access all features. Please select an option below: 👇");
        _step = 7; // Move to main menu
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Registration failed';
        _addBotMessage("❌ Error: $error");
      }
    } catch (e) {
      _addBotMessage("❌ Error: Failed to connect to the server. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAttendance() async {
    setState(() {
      _isLoading = true;
    });
    
    _addBotMessage("Submitting your attendance report... 📊", showLoading: true);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _phoneNumber,
          'students_present': int.tryParse(_presentStudents) ?? 0,
          'students_absent': int.tryParse(_absentStudents) ?? 0,
          'absence_reason': _absenceReasons,
          'topic_covered': _topicCovered,
        }),
      );

      if (response.statusCode == 201) {
        _addBotMessage("🎉 Perfect! Your class report has been submitted successfully.");
        _addBotMessage("📋 Summary:\n• Present: $_presentStudents students\n• Absent: $_absentStudents students\n• Topic: $_topicCovered");
        _addBotMessage("What would you like to do next? 🤔");
        _step = 7; // Return to main menu
        _attendanceStep = 0; // Reset attendance step
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Attendance submission failed';
        _addBotMessage("❌ Error: $error");
      }
    } catch (e) {
      _addBotMessage("❌ Error: Failed to connect to the server. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndSubmitLessonPlan() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      _addBotMessage("❌ No image selected. Please try again.");
      return;
    }

    _addBotMessage("🕒 Uploading and analyzing your lesson plan... please wait.", showLoading: true);

    try {
      // First try to extract text locally
      final extractedText = await _extractTextFromImage(File(pickedFile.path));
      
      // Then send to OpenAI for analysis
      final analysis = await _openAIService.analyzeLessonPlan(extractedText);
      
      // Display the results
      _displayAnalysisResults(analysis);
      
      // Also submit to the backend if needed
      await _submitLessonPlanToBackend(pickedFile);
      
    } catch (e) {
      _addBotMessage("❌ Error processing lesson plan: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      _addBotMessage("⚠️ Couldn't read text from image. Sending image directly for analysis.");
      rethrow;
    }
  }

  void _displayAnalysisResults(Map<String, dynamic> analysis) {
    // Clear loading message
    setState(() {
      _chat.removeWhere((msg) => msg['showLoading'] == true);
    });

    // Display score
    _addBotMessage("📝 Lesson Plan Score: ${analysis['score']}/100");
    
    // Display feedback
    if (analysis['feedback'] is List) {
      _addBotMessage("🔍 Suggestions for Improvement:");
      for (var suggestion in analysis['feedback']) {
        _addBotMessage("• $suggestion");
      }
    }
    
    // Display enhanced plan
    _addBotMessage("✨ IMPROVED LESSON PLAN ✨");
    _addBotMessage(analysis['enhanced_plan'] ?? "");
  }

  Future<void> _submitLessonPlanToBackend(XFile pickedFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/submit-lessonplan/'),
      );

      request.fields['teacher_name'] = _fullName;
      request.fields['school'] = _school;

      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        pickedFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final result = jsonDecode(respStr);
        final downloadUrl = result['download_url'];
        _addBotMessage("📥 [Download enhanced lesson plan]($downloadUrl)");
      }
    } catch (e) {
      // Don't show error if backend submission fails since we already have the analysis
      debugPrint("Error submitting to backend: $e");
    }
  }

  void _addBotMessage(String message, {bool showAvatar = false, bool showLoading = false}) {
    setState(() {
      _chat.add({
        'sender': 'bot', 
        'message': message,
        'timestamp': DateTime.now(),
        'showAvatar': showAvatar,
        'showLoading': showLoading,
        'isAnimated': true
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleDropdownSelection(String selection) {
    setState(() {
      _chat.add({
        'sender': 'user', 
        'message': selection,
        'timestamp': DateTime.now(),
        'isAnimated': true
      });
    });

    switch (selection) {
      case 'Submit Attendance':
        _addBotMessage("Hello $_fullName! 👋 Let's record today's class attendance.");
        _addBotMessage("How many students were present in your class today? 👥");
        _step = 8; // Move to attendance flow
        _attendanceStep = 0;
        break;
      case 'Submit Lesson Plan':
        _addBotMessage("📚 Let's analyze your lesson plan!");
        _addBotMessage("📸 Please share your lesson plan (image of your handwritten plan).");
        _pickAndSubmitLessonPlan();
        break;
      case 'Report An Issue':
        _addBotMessage("🚨 Issue reporting feature is coming soon! In the meantime, you can contact our support team.");
        break;
      case 'Check Performance':
        _addBotMessage("📊 Performance analytics feature is coming soon! You'll be able to track your teaching progress here.");
        break;
      case 'Exit':
        _addBotMessage("Thank you for using Dettol Hygiene Quest Chatbot! 👋");
        _addBotMessage("Have a great day teaching! 🌟");
        break;
      default:
        _addBotMessage("Please select a valid option from the menu. 🔄");
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isUser = message['sender'] == 'user';
    final showAvatar = message['showAvatar'] ?? false;
    final showLoading = message['showLoading'] ?? false;
    
    return AnimatedSlide(
      offset: message['isAnimated'] == true ? Offset.zero : const Offset(0, 0.3),
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && showAvatar)
              Container(
                margin: const EdgeInsets.only(right: 8, top: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.teal.shade100,
                  child: const Icon(Icons.smart_toy, size: 16, color: Colors.teal),
                ),
              ),
            if (!isUser && !showAvatar)
              const SizedBox(width: 40),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser 
                    ? Colors.teal.shade600 
                    : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['message']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                    if (showLoading)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isUser ? Colors.white : Colors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: isUser ? Colors.white70 : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettol Hygiene Quest'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _chat.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_chat[index], index);
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildInputArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    if (_step == 4) {
      return _buildLanguageButtons();
    } else if (_step == 7) {
      return _buildDropdownMenu();
    } else {
      return _buildTextInput();
    }
  }

  Widget _buildLanguageButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Select your preferred language:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _language = "English";
                    _addBotMessage("✅ Language set to English.");
                    _step++;
                    _sendOtp();
                  },
                  icon: const Icon(Icons.language),
                  label: const Text("English"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _language = "Swahili";
                    _addBotMessage("✅ Lugha imewekwa kwa Kiswahili.");
                    _step++;
                    _sendOtp();
                  },
                  icon: const Icon(Icons.language),
                  label: const Text("Swahili"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'What would you like to do?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Select an option..."),
                ),
                isExpanded: true,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.arrow_drop_down, color: Colors.teal),
                ),
                items: [
                  {'value': 'Submit Attendance', 'icon': Icons.people, 'desc': 'Record daily attendance'},
                  {'value': 'Submit Lesson Plan', 'icon': Icons.book, 'desc': 'Upload lesson plans'},
                  {'value': 'Report An Issue', 'icon': Icons.report_problem, 'desc': 'Report problems'},
                  {'value': 'Check Performance', 'icon': Icons.analytics, 'desc': 'View your stats'},
                  {'value': 'Exit', 'icon': Icons.exit_to_app, 'desc': 'Close the app'},
                ].map((item) {
                  return DropdownMenuItem<String>(
                    value: item['value'] as String,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(item['icon'] as IconData, color: Colors.teal, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['value'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                item['desc'] as String,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _handleDropdownSelection(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _handleUserInput,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.teal.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.teal.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: _isLoading ? null : _pickAndSubmitLessonPlan,
                        tooltip: 'Upload Lesson Plan',
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : () {
                if (_controller.text.trim().isNotEmpty) {
                  _handleUserInput(_controller.text.trim());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}