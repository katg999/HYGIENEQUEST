import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-3.5-turbo'; // or 'gpt-4'
  static const String _visionModel = 'gpt-4.1';

  // Get API key when needed, not at class initialization
  static String? get _apiKey => dotenv.env['API_KEY'];

  // Existing text analysis method
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
              'content': 'You are an expert in Ugandan primary education. '
                  'Respond with JSON containing: '
                  'score (0-100), feedback (list), and enhanced_plan (string).'
            },
            {
              'role': 'user',
              'content': _buildPrompt(lessonPlanText)
            }
          ],
          'response_format': { 'type': 'json_object' },
          'temperature': 0.3,
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return jsonDecode(responseData['choices'][0]['message']['content']);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Analysis failed: ${e.toString()}');
    }
  }

  // NEW: Add this method for image analysis
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
              'content': 'You are an expert in Ugandan primary education. '
                  'Analyze this lesson plan image and return JSON with: '
                  'score (0-100), feedback (list), and enhanced_plan (string).'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Analyze this Ugandan primary school lesson plan. '
                      'Focus on CBC curriculum alignment, practical local '
                      'resource usage, and inclusive participation techniques.'
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
          'response_format': { 'type': 'json_object' },
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return jsonDecode(responseData['choices'][0]['message']['content']);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Image analysis failed: ${e.toString()}');
    }
  }

  // Existing prompt builder
  String _buildPrompt(String lessonPlan) {
    return """
    Analyze this Ugandan primary school lesson plan and return JSON with:
    {
      "score": 0-100,
      "feedback": ["list", "of", "suggestions"],
      "enhanced_plan": "Markdown formatted text with:
        ### STEP 1: [Name]
        **Teacher:** [Activity]
        **Pupils:** [Activity]
        **Time:** [Duration]"
    }
    
    Focus on:
    - Uganda CBC curriculum alignment
    - Practical local resource usage
    - Inclusive participation techniques
    
    Lesson Plan:
    $lessonPlan
    """;
  }
}