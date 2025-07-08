import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _chat = [];
  final TextEditingController _controller = TextEditingController();
  int _step = 0;
  String _phoneNumber = '';
  String _fullName = '';
  String _school = '';
  String _district = '';
  String _language = '';
  
  // Attendance tracking variables
  String _presentStudents = '';
  String _absentStudents = '';
  String _absenceReasons = '';
  String _topicCovered = '';
  int _attendanceStep = 0;

  void _handleUserInput(String input) {
    setState(() {
      _chat.add({'sender': 'user', 'message': input});
    });

    switch (_step) {
      case 0:
        _phoneNumber = input;
        _addBotMessage("Let's begin the registration setup.");
        _addBotMessage("What's your full name?");
        _step++;
        break;
      case 1:
        _fullName = input;
        _addBotMessage("Which school do you teach at?");
        _step++;
        break;
      case 2:
        _school = input;
        _addBotMessage("In which district is your school?");
        _step++;
        break;
      case 3:
        _district = input;
        _addBotMessage("What is your preferred language of response?");
        _step++;
        break;
      case 4:
        // This step is handled with buttons below
        break;
      case 5:
        _addBotMessage("Sending OTP to this number: $_phoneNumber\nProcessing...");
        _addBotMessage("Please enter the 6-digit OTP sent to $_phoneNumber.");
        _step++;
        break;
      case 6:
        _addBotMessage("Thank you! Your account has been created.");
        _addBotMessage("Please Select An Option Below");
        _step++;
        break;
      case 8: // Attendance submission flow
        _handleAttendanceInput(input);
        break;
      default:
        _addBotMessage("Got it: $input");
    }

    _controller.clear();
  }

  void _handleAttendanceInput(String input) {
    switch (_attendanceStep) {
      case 0:
        _presentStudents = input;
        _addBotMessage("2. How many students were absent?");
        _attendanceStep++;
        break;
      case 1:
        _absentStudents = input;
        _addBotMessage("3. Please briefly explain the reasons for absence.\ni.e \"2 students sick with flu, 1 student...\"");
        _attendanceStep++;
        break;
      case 2:
        _absenceReasons = input;
        _addBotMessage("4. What topic did you cover today?\ne.g Algebraic Equations");
        _attendanceStep++;
        break;
      case 3:
        _topicCovered = input;
        _addBotMessage("Thank you! Your class report has been submitted successfully.");
        _addBotMessage("What would you like to do next?");
        _step = 7; // Return to main menu
        _attendanceStep = 0; // Reset attendance step
        break;
    }
  }

  void _addBotMessage(String message) {
    setState(() {
      _chat.add({'sender': 'bot', 'message': message});
    });
  }

  void _handleDropdownSelection(String selection) {
    setState(() {
      _chat.add({'sender': 'user', 'message': selection});
    });

    switch (selection) {
      case 'Submit Attendance':
        _addBotMessage("Hello! $_fullName Please provide today's class update");
        _addBotMessage("1. How many students were present today?");
        _step = 8; // Move to attendance flow
        _attendanceStep = 0;
        break;
      case 'Submit Lesson Plan':
        _addBotMessage("Lesson Plan submission is coming soon!");
        break;
      case 'Report An Issue':
        _addBotMessage("Issue reporting is coming soon!");
        break;
      case 'Check Performance':
        _addBotMessage("Performance checking is coming soon!");
        break;
      case 'Exit':
        _addBotMessage("Thank you for using Dettol Hygiene Quest Chatbot. Goodbye!");
        break;
      default:
        _addBotMessage("Please select a valid option.");
    }
  }

  @override
  void initState() {
    super.initState();
    _addBotMessage("Welcome to the Dettol Hygiene Quest Chatbot!");
    _addBotMessage("I'm here to support your hygiene education efforts in class.");
    _addBotMessage("Please enter your phone number.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettol Bot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                final message = _chat[index];
                final isUser = message['sender'] == 'user';
                return Container(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['message']!),
                  ),
                );
              },
            ),
          ),
          if (_step == 4)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _language = "English";
                      _addBotMessage("Language set to English.");
                      _step++;
                      _handleUserInput("English");
                    },
                    child: const Text("English"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _language = "Swahili";
                      _addBotMessage("Lugha imewekwa kwa Kiswahili.");
                      _step++;
                      _handleUserInput("Swahili");
                    },
                    child: const Text("Swahili"),
                  ),
                ],
              ),
            )
          else if (_step == 7) // Show dropdown after account creation
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  hint: const Text("Select Option"),
                  isExpanded: true,
                  underline: Container(),
                  items: [
                    'Submit Attendance',
                    'Submit Lesson Plan',
                    'Report An Issue',
                    'Check Performance',
                    'Exit'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _handleDropdownSelection(newValue);
                    }
                  },
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _handleUserInput,
                      decoration: const InputDecoration(
                        hintText: "Enter your response...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        _handleUserInput(_controller.text.trim());
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}