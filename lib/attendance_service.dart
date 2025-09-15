import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class AttendanceService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-3.5-turbo';
  
  static String? get _apiKey => dotenv.env['API_KEY'];

 Future<Map<String, dynamic>> processAttendanceRegister(File imageFile) async {
  try {
    // Step 1: Send image directly to OpenAI for analysis
    final analysis = await _analyzeAttendanceImage(imageFile);
    
    // Step 2: Generate PDF
    final pdfFile = await _generateAttendancePDF(analysis);
    
    return {
      'success': true,
      'analysis': analysis,
      'pdfFile': pdfFile,
    };
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> submitAttendanceData({
  required String phone,
  required int studentsPresent,
  required int studentsAbsent,
  required String absenceReason,
  required String subject,
  required String district,
}) async {
  try {
    // CORRECTED: Use the actual backend URL for attendance
    final response = await http.post(
      Uri.parse('https://hygienequestemdpoints.onrender.com/attendance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'students_present': studentsPresent,
        'students_absent': studentsAbsent,
        'absence_reason': absenceReason,
        'subject': subject,
        'district': district,
      }),
    );

    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': 'Attendance submitted successfully',
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': 'Failed to submit attendance: ${response.statusCode} - ${response.body}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error submitting attendance: ${e.toString()}',
    };
  }
}

  

  Future<Map<String, dynamic>> _analyzeAttendanceImage(File imageFile) async {
  try {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not found. Please check your .env file.');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o', // Use vision model for image analysis
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert in analyzing Ugandan school attendance registers. '
                'Extract the following information from the image: '
                '1. Student names, attendance status (present/absent), and absence reasons '
                '2. Date of attendance '
                '3. Class/subject information '
                '4. School district/location '
                '5. Main reason for absences (if multiple students are absent for similar reasons) '
                'Return JSON with this structure: '
                '{'
                '  "students": [{"name": "string", "status": "present/absent", "reason": "string"}],'
                '  "summary": {"present_count": number, "absent_count": number, "total_count": number},'
                '  "date": "string",'
                '  "class_info": "string",'
                '  "district": "string",'
                '  "subject": "string",'
                '  "absence_reason": "string" (main reason if multiple absences, otherwise "Various reasons")'
                '}'
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': 'Analyze this Ugandan school attendance register image thoroughly. '
                    'Extract all student names, their present/absent status, and specific absence reasons. '
                    'Identify the date, class/subject, school district, and determine the main reason for absences if multiple students are absent for similar reasons.'
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 0.1,
        'max_tokens': 3000,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final analysisResult = jsonDecode(responseData['choices'][0]['message']['content']);
      
      // Ensure all required fields are present with fallback values
      return {
        'students': analysisResult['students'] ?? [],
        'summary': analysisResult['summary'] ?? {'present_count': 0, 'absent_count': 0, 'total_count': 0},
        'date': analysisResult['date'] ?? 'Not specified',
        'class_info': analysisResult['class_info'] ?? 'Not specified',
        'district': analysisResult['district'] ?? 'Not specified',
        'subject': analysisResult['subject'] ?? 'General',
        'absence_reason': analysisResult['absence_reason'] ?? _determineMainAbsenceReason(analysisResult['students'] ?? []),
        'participation_insights': analysisResult['participation_insights'] ?? 'No specific insights available',
      };
    } else {
      throw Exception('OpenAI API Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Image analysis failed: ${e.toString()}');
  }
}

// Helper method to determine the main absence reason from student data
String _determineMainAbsenceReason(List<dynamic> students) {
  final absentStudents = students.where((student) => 
      student is Map && student['status']?.toString().toLowerCase() == 'absent');
  
  if (absentStudents.isEmpty) return 'No absences';
  
  // Count frequency of each reason
  final reasonCounts = <String, int>{};
  for (final student in absentStudents) {
    final reason = student['reason']?.toString().trim();
    if (reason != null && reason.isNotEmpty && reason != 'No reason provided') {
      reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
    }
  }
  
  if (reasonCounts.isEmpty) return 'Various reasons';
  
  // Find the most common reason
  final mostCommonReason = reasonCounts.entries.reduce((a, b) => 
      a.value > b.value ? a : b);
  
  // If one reason dominates, return it, otherwise return "Various reasons"
  return mostCommonReason.value > 1 ? mostCommonReason.key : 'Various reasons';
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
                    // Inside _generateAttendancePDF method, add these to the PDF content:
                    pw.Text('District: ${analysis['district'] ?? 'Not specified'}'),
                    pw.Text('Subject: ${analysis['subject'] ?? 'General'}'),
                    pw.Text('Main Absence Reason: ${analysis['absence_reason'] ?? 'Not specified'}'),
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
  
  }
}
