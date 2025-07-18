import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class AttendanceService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-3.5-turbo';
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  static String? get _apiKey => dotenv.env['API_KEY'];

  Future<Map<String, dynamic>> processAttendanceRegister(File imageFile) async {
    try {
      // Step 1: Extract text from image
      final extractedText = await _extractTextFromImage(imageFile);
      
      // Step 2: Analyze with OpenAI
      final analysis = await _analyzeAttendanceText(extractedText);
      
      // Step 3: Generate PDF
      final pdfFile = await _generateAttendancePDF(analysis);
      
      return {
        'success': true,
        'analysis': analysis,
        'pdfFile': pdfFile,
        'extractedText': extractedText,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<String> _extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text from image: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _analyzeAttendanceText(String attendanceText) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please check your .env file.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert in analyzing Ugandan school attendance registers. '
                  'Extract student names and absence reasons from the text. '
                  'Return JSON with: students (array of {name, status, reason}), '
                  'summary (object with present_count, absent_count, total_count), '
                  'date (extracted date or null).'
            },
            {
              'role': 'user',
              'content': _buildAttendancePrompt(attendanceText)
            }
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.1,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return jsonDecode(responseData['choices'][0]['message']['content']);
      } else {
        throw Exception('OpenAI API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Analysis failed: ${e.toString()}');
    }
  }

  String _buildAttendancePrompt(String attendanceText) {
    return """
Analyze this Ugandan school attendance register and extract information:

Return JSON format:
{
  "students": [
    {
      "name": "Student Name",
      "status": "present" or "absent",
      "reason": "reason for absence or null if present"
    }
  ],
  "summary": {
    "present_count": number,
    "absent_count": number,
    "total_count": number
  },
  "date": "extracted date or null",
  "class_info": "class/grade information if available"
}

Rules:
- Extract all student names clearly
- Identify present/absent status
- Extract absence reasons (sick, permission, etc.)
- Count totals accurately
- Handle common Ugandan names properly
- Look for date information

Attendance Register Text:
$attendanceText
""";
  }

  Future<File> _generateAttendancePDF(Map<String, dynamic> analysis) async {
    try {
      final pdf = pw.Document();
      final students = analysis['students'] as List<dynamic>? ?? [];
      final summary = analysis['summary'] as Map<String, dynamic>? ?? {};
      final date = analysis['date'] as String? ?? 'Date not specified';
      final classInfo = analysis['class_info'] as String? ?? 'Class not specified';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ATTENDANCE REGISTER ANALYSIS',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Date: $date'),
                    pw.Text('Class: $classInfo'),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ATTENDANCE SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Total Students: ${summary['total_count'] ?? 0}'),
                    pw.Text('Present: ${summary['present_count'] ?? 0}'),
                    pw.Text('Absent: ${summary['absent_count'] ?? 0}'),
                    pw.Text('Attendance Rate: ${_calculateAttendanceRate(summary)}%'),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Students Table
              pw.Text(
                'STUDENT DETAILS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Student Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Reason', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Student rows
                  ...students.asMap().entries.map((entry) {
                    final index = entry.key;
                    final student = entry.value as Map<String, dynamic>;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${index + 1}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(student['name'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            student['status'] ?? '',
                            style: pw.TextStyle(
                              color: student['status'] == 'present' 
                                  ? PdfColors.green 
                                  : PdfColors.red,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(student['reason'] ?? '-'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Text(
                'Generated on: ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ];
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/attendance_analysis_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('PDF generation failed: ${e.toString()}');
    }
  }

  Future<void> openGeneratedPDF(File pdfFile) async {
    try {
      final result = await OpenFile.open(pdfFile.path);
      
      if (result.type != ResultType.done) {
        throw Exception('Could not open file: ${result.message}');
      }
    } catch (e) {
      throw Exception('Failed to open PDF: ${e.toString()}');
    }
  }

  String _calculateAttendanceRate(Map<String, dynamic> summary) {
    final present = summary['present_count'] ?? 0;
    final total = summary['total_count'] ?? 0;
    
    if (total == 0) return '0';
    
    final rate = (present / total * 100).toStringAsFixed(1);
    return rate;
  }

  void dispose() {
    _textRecognizer.close();
  }
}