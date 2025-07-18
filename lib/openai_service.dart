import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-3.5-turbo'; // or 'gpt-4'

  // Get API key when needed, not at class initialization
  static String? get _apiKey => dotenv.env['API_KEY'];

  Future<Map<String, dynamic>> analyzeLessonPlan(String lessonPlanText) async {
    try {
      // Check if API key is available
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