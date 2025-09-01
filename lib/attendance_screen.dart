import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'attendance_service.dart';
import 'package:open_file/open_file.dart';
import 'lesson_plans_screen.dart';
import 'hygiene_products_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required this.userName});
  final String userName;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  File? _selectedFile;
  bool _isLoading = false;
  Map<String, dynamic>? _analysis;
  String? _topicCovered;
  int _currentIndex = 1; // Set to 1 since this is the Attendance tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Class Attendance',
              style: TextStyle(
                fontFamily: 'Bricolage Grotesque',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: Color(0xFFFFFFFF),
              ),
            ),
            Image.asset('assets/images/Group9.png', height: 30),
          ],
        ),
        backgroundColor: const Color(0xFF007A33),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFFFBF0),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 200,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBotMessage("Hello ${widget.userName}👋, Let's record today's class attendance"),
                    _buildBotMessage("Please share your attendance sheet (image of your register)"),
                    
                    const SizedBox(height: 20),
                    _buildUploadSection(),
                    
                    if (_selectedFile != null && _analysis == null) ...[
                      const SizedBox(height: 20),
                      Image.file(_selectedFile!, height: 200),
                      const SizedBox(height: 20),
                      if (!_isLoading)
                        ElevatedButton(
                          onPressed: _analyzeAttendance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007A33),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'ANALYZE ATTENDANCE',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                    
                    if (_isLoading) ...[
                      const SizedBox(height: 20),
                      _buildBotMessage("⏳ Perfect! Let's analyse your attendance sheet"),
                      const LinearProgressIndicator(),
                    ],
                    
                    if (_analysis != null && _topicCovered == null) ...[
                      const SizedBox(height: 20),
                      _buildBotMessage("Analysis complete! Here's your detailed feedback:"),
                      const SizedBox(height: 20),
                      _buildScoreCard(),
                      const SizedBox(height: 20),
                      _buildAnalysisText(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                    
                    if (_topicCovered != null) ...[
                      const SizedBox(height: 40),
                      _buildSuccessMessage(),
                      const SizedBox(height: 20),
                      _buildNewAttendanceButton(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNavBar(),
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

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: _pickAttendanceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Upload.png', width: 24),
            const SizedBox(height: 8),
            const Text(
              'Upload Attendance Sheet',
              style: TextStyle(
                color: Color(0xFF007A33),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'JPG or PNG files',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final summary = _analysis?['summary'] ?? {};
    final presentCount = summary['present_count'] ?? 0;
    final total = summary['total_count'] ?? 0;
    final score = ((presentCount / total) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF007A33),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Class Attendance Score',
            style: TextStyle(
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisText() {
    final summary = _analysis?['summary'] ?? {};
    final students = _analysis?['students'] ?? [];
    final presentCount = summary['present_count'] ?? 0;
    final absentCount = summary['absent_count'] ?? 0;
    final total = summary['total_count'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 Date: ${_analysis?['date'] ?? 'Not specified'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('🏫 Class: ${_analysis?['class_info'] ?? 'Not specified'}'),
          const SizedBox(height: 12),
          Text('👥 Total Students: $total'),
          Text('✅ Present: $presentCount'),
          Text('❌ Absent: $absentCount'),
          const SizedBox(height: 12),
          if (absentCount > 0) ...[
            const Text(
              'Absent Students:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...students.where((s) => s['status'] == 'absent').map((student) {
              return Text('• ${student['name']}: ${student['reason'] ?? 'No reason provided'}');
            }).toList(),
          ],
          const SizedBox(height: 12),
          const Text(
            'Participation Insights:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(_analysis?['participation_insights'] ?? 'No participation insights available'),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _submitAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007A33),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Download.png', width: 20),
              const SizedBox(width: 8),
              const Text(
                'Submit Analyzed Report',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),l,klkk
        OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedFile = null;
              _analysis = null;
              _topicCovered = null;
            });
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF007A33)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Analyse.png', width: 20),
              const SizedBox(width: 8),
              const Text(
                'Analyse Another Attendance',
                style: TextStyle(color: Color(0xFF007A33)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF007A33), size: 60),
        const SizedBox(height: 16),
        const Text(
          'Attendance Submitted Successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007A33),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Topic: $_topicCovered',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildNewAttendanceButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedFile = null;
            _analysis = null;
            _topicCovered = null;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007A33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 48),
        ),
        child: const Text(
          'NEW ATTENDANCE',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: 'assets/images/Lessonplan.png',
            label: 'Lesson Plans',
            isSelected: _currentIndex == 0,
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonPlansScreen(userName: widget.userName),
                ),
              );
            },
          ),
          _buildNavItem(
            icon: 'assets/images/Attendance.png',
            label: 'Attendance',
            isSelected: _currentIndex == 1,
            onTap: () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          _buildNavItem(
            icon: 'assets/images/HygieneProducts.png',
            label: 'Hygiene',
            isSelected: _currentIndex == 2,
            onTap: () {
              setState(() {
                _currentIndex = 2;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HygieneProductsScreen(userName: widget.userName),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007A33) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 24,
              color: isSelected ? Colors.white : const Color(0xFF007A33),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF007A33),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAttendanceSheet() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
        _analysis = null;
        _topicCovered = null;
      });
    }
  }

  Future<void> _analyzeAttendance() async {
    if (_selectedFile == null) return;
    
    setState(() => _isLoading = true);
    try {
      final result = await _attendanceService.processAttendanceRegister(_selectedFile!);
      if (result['success'] == true) {
        setState(() => _analysis = result['analysis']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAttendance() async {
    setState(() => _isLoading = true);
    try {
      // Here you would typically send to your backend
      // await _apiService.submitAttendance(...);
      setState(() {
        _topicCovered = "Submitted"; // Mark as submitted
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}