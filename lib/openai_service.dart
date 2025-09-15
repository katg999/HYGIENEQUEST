import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4o';
  static const String _visionModel = 'gpt-4o';

  static String? get _apiKey => dotenv.env['API_KEY'];

  /// Fix encoding issues (like â€™ etc.)
  String _normalizeText(String input) {
    return utf8.decode(input.runes.toList(), allowMalformed: true)
        .replaceAll("â€™", "'")
        .replaceAll("â€œ", '"')
        .replaceAll("â€", '"')
        .replaceAll("â€“", "-")
        .replaceAll("â€”", "-")
        .replaceAll("Â", "");
  }

  /// Make text more human and local
  String _humanizeText(String text) {
    return text
        .replaceAll("Pupils brainstorm", "Children think together")
        .replaceAll("Teacher moderates", "Teacher guides")
        .replaceAll("inclusive participation techniques", "making sure all children take part")
        .replaceAll("enhanced lesson plan", "improved lesson plan")
        .replaceAll("score", "evaluation");
  }

  /// Clean up strange characters and markdown
  String _cleanText(String input) {
    String output = input;

    output = output
        .replaceAll("â€™", "'")
        .replaceAll("â€œ", '"')
        .replaceAll("â€", '"')
        .replaceAll("â€“", "-")
        .replaceAll("â€”", "-")
        .replaceAll("Â", "")
        .replaceAll(RegExp(r'[\*\_`~>#\[\]\{\}]'), '') // remove markdown
        .replaceAll(RegExp(r'\.{2,}'), '.') // multiple periods → one
        .replaceAll(' .', '.')
        .replaceAll(' ,', ',')
        .replaceAll(' :', ':')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return output;
  }

  /// Format lesson plan text nicely for teachers
  String _formatLessonPlanText(String input) {
    String formatted = input;

    formatted = formatted.replaceAllMapped(
      RegExp(r'(\d+\.)'),
      (match) => '\n${match.group(1)}',
    );

    formatted = formatted.replaceAllMapped(
      RegExp(r'(Teacher|Children):'),
      (match) => '\n${match.group(1)}:',
    );

    formatted = formatted.replaceAllMapped(
      RegExp(r'(Assessment|Materials|Emphasis):'),
      (match) => '\n\n${match.group(1)}:',
    );

    formatted = formatted.replaceAll('. ', '.\n');

    formatted = formatted.replaceAll(RegExp(r'\s+'), ' ').trim();

    return formatted;
  }

  /// Analyze plain text lesson plan
  Future<Map<String, dynamic>> analyzeLessonPlan(String lessonPlanText) async {
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
              'content': 'You are an expert Ugandan primary teacher. '
                  'Reply in JSON with: score (0-100), feedback (short list), enhanced_plan (natural text). '
                  'The enhanced plan should be written like a real teacher in Uganda would write, not formal or AI-like.'
            },
            {
              'role': 'user',
              'content': _buildPrompt(lessonPlanText)
            }
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.5,
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var content = responseData['choices'][0]['message']['content'];

        content = _normalizeText(content);
        var parsed = jsonDecode(content);

        if (parsed['score'] != null) {
          int score = int.tryParse(parsed['score'].toString()) ?? 0;
          parsed['score'] = score.clamp(0, 100);
        }

        if (parsed['enhanced_plan'] != null) {
          parsed['enhanced_plan'] = _cleanText(parsed['enhanced_plan']);
          parsed['enhanced_plan'] = _formatLessonPlanText(parsed['enhanced_plan']);
          parsed['enhanced_plan'] = _humanizeText(parsed['enhanced_plan']);
        }

        if (parsed['feedback'] != null && parsed['feedback'] is List) {
          parsed['feedback'] = (parsed['feedback'] as List)
              .map((f) => _cleanText(f.toString()))
              .toList();
        }

        return parsed;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Analysis failed: ${e.toString()}');
    }
  }

  /// Analyze lesson plan from image
  Future<Map<String, dynamic>> analyzeLessonPlanImage(File imageFile) async {
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
          'model': _visionModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert Ugandan primary teacher. '
                  'Analyze this lesson plan image and return JSON with: '
                  'score (0-100), feedback (short list), enhanced_plan (natural text). '
                  'The enhanced plan should be plain, teacher-friendly, and realistic.'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Analyze this Ugandan primary school lesson plan. '
                      'Focus on CBC curriculum, local resources, and ensuring all children participate.'
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
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var content = responseData['choices'][0]['message']['content'];

        content = _normalizeText(content);
        var parsed = jsonDecode(content);

        if (parsed['score'] != null) {
          int score = int.tryParse(parsed['score'].toString()) ?? 0;
          parsed['score'] = score.clamp(0, 100);
        }

        if (parsed['enhanced_plan'] != null) {
          parsed['enhanced_plan'] = _cleanText(parsed['enhanced_plan']);
          parsed['enhanced_plan'] = _formatLessonPlanText(parsed['enhanced_plan']);
          parsed['enhanced_plan'] = _humanizeText(parsed['enhanced_plan']);
        }

        if (parsed['feedback'] != null && parsed['feedback'] is List) {
          parsed['feedback'] = (parsed['feedback'] as List)
              .map((f) => _cleanText(f.toString()))
              .toList();
        }

        return parsed;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Image analysis failed: ${e.toString()}');
    }
  }

  /// Extract teacher/school info from registration doc
  Future<Map<String, dynamic>> extractRegistrationInfo(File documentImage) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please check your .env file.');
      }

      final bytes = await documentImage.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _visionModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert in Ugandan school records. '
                  'Return JSON with: name (teacher), school, and district.'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Extract the teacher name, school, and district from this document.'
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
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var content = responseData['choices'][0]['message']['content'];

        content = _normalizeText(content);
        var parsed = jsonDecode(content);

        parsed.updateAll((key, value) => _cleanText(value.toString()));

        return parsed;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Document analysis failed: ${e.toString()}');
    }
  }

  /// Prompt template
  String _buildPrompt(String lessonPlan) {
    return """
    Analyze this Ugandan primary school lesson plan and return JSON with:
    {
      "score": 0-100,
      "feedback": ["short teacher-friendly suggestions"],
      "enhanced_plan": "A plain lesson plan written in natural teacher language, 
                        simple, clear, and practical, not in Markdown or AI style."
    }
    Lesson Plan:
    $lessonPlan
    """;
  }
}
