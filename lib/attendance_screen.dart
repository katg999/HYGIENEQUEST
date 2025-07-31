import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _analysis;
  String? _topicCovered;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_analysis == null) ...[
              const Text(
                'Upload Attendance Register',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text('SELECT IMAGE'),
              ),
            ],
            if (_selectedImage != null && _analysis == null) ...[
              const SizedBox(height: 16),
              Image.file(_selectedImage!, height: 200),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _analyzeImage,
                icon: const Icon(Icons.analytics),
                label: const Text('ANALYZE ATTENDANCE'),
              ),
            ],
            if (_isLoading) const LinearProgressIndicator(),
            if (_analysis != null && _topicCovered == null) ...[
              _buildAnalysisSummary(),
              const SizedBox(height: 24),
              const Text(
                'Enter the topic covered today:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'e.g. Hand Washing Techniques',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _topicCovered = value,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitAttendance,
                child: const Text('SUBMIT ATTENDANCE'),
              ),
            ],
            if (_topicCovered != null) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Attendance submitted successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() {
                  _selectedImage = null;
                  _analysis = null;
                  _topicCovered = null;
                }),
                child: const Text('NEW ATTENDANCE'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSummary() {
    final summary = _analysis?['summary'] ?? {};
    final students = _analysis?['students'] ?? [];
    final presentCount = summary['present_count'] ?? 0;
    final absentCount = summary['absent_count'] ?? 0;
    final total = summary['total_count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attendance Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('📅 Date: ${_analysis?['date'] ?? 'Not specified'}'),
        Text('🏫 Class: ${_analysis?['class_info'] ?? 'Not specified'}'),
        Text('👥 Total Students: $total'),
        Text('✅ Present: $presentCount'),
        Text('❌ Absent: $absentCount'),
        const SizedBox(height: 16),
        if (absentCount > 0) ...[
          const Text(
            'Absent Students:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...students.where((s) => s['status'] == 'absent').map((student) {
            return Text('• ${student['name']}: ${student['reason'] ?? 'No reason'}');
          }).toList(),
        ],
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    
    setState(() => _isLoading = true);
    try {
      final result = await _attendanceService.processAttendanceRegister(_selectedImage!);
      if (result['success'] == true) {
        setState(() => _analysis = result['analysis']);
        await _attendanceService.openGeneratedPDF(result['pdfFile']);
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
    if (_topicCovered == null || _topicCovered!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the topic covered')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Here you would typically send to your backend
      // await _apiService.submitAttendance(...);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}