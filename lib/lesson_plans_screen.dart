import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'openai_service.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'attendance_screen.dart';

class LessonPlansScreen extends StatefulWidget {
  
   const LessonPlansScreen({super.key, required this.userName});
   final String userName; 

  @override
  State<LessonPlansScreen> createState() => _LessonPlansScreenState();
}

class _LessonPlansScreenState extends State<LessonPlansScreen> {
  final OpenAIService _openAIService = OpenAIService();
  File? _selectedFile;
  bool _isLoading = false;
  Map<String, dynamic>? _analysis;
  File? _generatedPdf;
  int _currentIndex = 0; // To track the current selected tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lesson Plans',
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
                    _buildBotMessage("Hello ${widget.userName}, I'm here to help you improve your lesson plans"),
                    _buildBotMessage("Please share your lesson plan (image of your handwritten plan)"),
                    
                    const SizedBox(height: 20),
                    _buildUploadSection(),
                    
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 20),
                      Image.file(_selectedFile!, height: 200),
                      const SizedBox(height: 20),
                      if (!_isLoading)
                        ElevatedButton(
                          onPressed: _analyzeLessonPlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007A33),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'ANALYZE LESSON PLAN',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                    
                    if (_isLoading) ...[
                      const SizedBox(height: 20),
                      _buildBotMessage("⏳ Perfect! Let's analyse your lesson plan"),
                      const LinearProgressIndicator(),
                    ],
                    
                    if (_analysis != null) ...[
                      const SizedBox(height: 20),
                      _buildBotMessage("Analysis complete! Here's your detailed feedback:"),
                      const SizedBox(height: 20),
                      _buildScoreCard(),
                      const SizedBox(height: 20),
                      _buildAnalysisText(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
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
    onTap: _pickLessonPlan,
    child: Container(
      width: double.infinity, // Changed from fixed 370 to responsive
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/Upload.png', width: 24),
          const SizedBox(height: 8),
          const Text(
            'Upload lesson plan',
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
                '${_analysis?['score'] ?? '0'}',
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
            'Lesson Plan Score',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _analysis?['enhanced_plan'] ?? 'No analysis available',
        style: const TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.5,
          color: Color(0xDD000000),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            if (_generatedPdf != null) {
              OpenFile.open(_generatedPdf!.path);
            }
          },
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
                'Download Enhanced Lesson Plan',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedFile = null;
              _analysis = null;
              _generatedPdf = null;
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
                'Analyse Another Plan',
                style: TextStyle(color: Color(0xFF007A33)),
              ),
            ],
          ),
        ),
      ],
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceScreen(userName: widget.userName),
              ),
            );
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
              // Navigate to hygiene products screen
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

  Future<void> _pickLessonPlan() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
        _analysis = null;
        _generatedPdf = null;
      });
    }
  }

  Future<void> _analyzeLessonPlan() async {
    if (_selectedFile == null) return;
    
    setState(() => _isLoading = true);
    try {
      final analysis = await _openAIService.analyzeLessonPlanImage(_selectedFile!);
      final pdfFile = await _generatePdf(analysis);
      
      setState(() {
        _analysis = analysis;
        _generatedPdf = pdfFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<File> _generatePdf(Map<String, dynamic> analysis) async {
    final pdf = pw.Document();
    final enhancedPlan = analysis['enhanced_plan'] ?? "No enhanced plan available";
    final score = analysis['score'] ?? "N/A";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'IMPROVED LESSON PLAN',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Quality Score: $score/100'),
                  pw.SizedBox(height: 20),
                ],
              ),
            ),
            pw.Text(enhancedPlan),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${DateTime.now().toString().split('.')[0]}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lesson_plan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}