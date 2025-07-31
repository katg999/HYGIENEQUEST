import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'openai_service.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class LessonPlansScreen extends StatefulWidget {
  const LessonPlansScreen({super.key});

  @override
  State<LessonPlansScreen> createState() => _LessonPlansScreenState();
}

class _LessonPlansScreenState extends State<LessonPlansScreen> {
  final OpenAIService _openAIService = OpenAIService();
  File? _selectedFile;
  bool _isLoading = false;
  Map<String, dynamic>? _analysis;
  File? _generatedPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Plans')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Lesson Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickLessonPlan,
              icon: const Icon(Icons.upload),
              label: const Text('SELECT IMAGE'),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              Image.file(_selectedFile!, height: 200),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _analyzeLessonPlan,
                icon: const Icon(Icons.analytics),
                label: const Text('ANALYZE LESSON PLAN'),
              ),
            ],
            if (_isLoading) const LinearProgressIndicator(),
            if (_analysis != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Analysis Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Quality Score: ${_analysis?['score'] ?? 'N/A'}/100'),
              const SizedBox(height: 16),
              const Text(
                'Enhanced Lesson Plan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_analysis?['enhanced_plan'] ?? 'No analysis available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generatedPdf != null 
                    ? () => OpenFile.open(_generatedPdf!.path)
                    : null,
                child: const Text('OPEN PDF REPORT'),
              ),
            ],
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