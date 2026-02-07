import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart'; // Contains your API key

class AICoachProvider with ChangeNotifier {
  bool _isLoading = false;
  String _lastResponse = '';
  final List<Map<String, dynamic>> _conversationHistory = [];

  bool get isLoading => _isLoading;
  String get lastResponse => _lastResponse;
  List<Map<String, dynamic>> get conversationHistory => _conversationHistory;

  Future<void> getDietRecommendation({
    required double currentWeight,
    required double targetWeight,
    required String dietaryPreference,
    required String fitnessLevel,
    required String healthConditions,
    required List<Map<String, dynamic>> recentMeals,
  }) async {
    _isLoading = true;
    notifyListeners();

    final prompt = '''
    Act as a personalized diet coach. Provide specific recommendations based on:
    - Current weight: $currentWeight kg
    - Target weight: $targetWeight kg
    - Dietary preference: $dietaryPreference
    - Fitness level: $fitnessLevel
    - Health conditions: $healthConditions
    - Recent meals: ${recentMeals.map((m) => '${m['name']} (${m['calories']} kcal)').join(', ')}
    
    Provide response in valid JSON format EXACTLY as follows (no extra text before or after):
    {
      "analysis": "Brief analysis of current diet",
      "recommendations": ["List", "of", "specific", "recommendations"],
      "meal_plan": {
        "breakfast": "Suggestion with calories",
        "lunch": "Suggestion with calories",
        "dinner": "Suggestion with calories",
        "snacks": "Suggestion with calories"
      },
      "motivation": "Personalized motivational message"
    }
    
    IMPORTANT: Only return the JSON object, without any markdown formatting or additional text.
    ''';

    try {
      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final textResponse =
            responseData['candidates'][0]['content']['parts'][0]['text'];

        // Try to extract JSON from the response
        String jsonString = _extractJsonFromResponse(textResponse);
        _lastResponse = jsonString;

        _conversationHistory.add({
          'timestamp': DateTime.now(),
          'prompt': prompt,
          'response': _lastResponse,
        });
      } else {
        _lastResponse = 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      _lastResponse = 'Error: $e';
    } finally {
      print(_lastResponse);
      _isLoading = false;
      notifyListeners();
    }
  }

  String _extractJsonFromResponse(String response) {
    try {
      // First try to parse directly
      jsonDecode(response);
      return response;
    } catch (e) {
      // If that fails, try to extract JSON from markdown or other formatting
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        try {
          final jsonString = response.substring(jsonStart, jsonEnd + 1);
          jsonDecode(jsonString);
          return jsonString;
        } catch (e) {
          return response; // Return original if extraction fails
        }
      }
      return response; // Return original if no JSON found
    }
  }

  Future<void> askFollowUpQuestion(String question) async {
    _isLoading = true;
    notifyListeners();

    try {
      // final response = await http.post(
      //   Uri.parse(
      //     "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey",
      //   ),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     "contents": [
      //       ..._conversationHistory.map((e) => {
      //         "role": "user",
      //         "parts": [{"text": e['prompt']}]
      //       }),
      //       ..._conversationHistory.map((e) => {
      //         "role": "model",
      //         "parts": [{"text": e['response']}]
      //       }),
      //       {
      //         "parts": [
      //           {"text": question}
      //         ]
      //       }
      //     ]
      //   }),
      // );
      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiApiKey",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            ..._conversationHistory.expand(
              (e) => [
                {
                  "role": "user",
                  "parts": [
                    {"text": e['prompt']},
                  ],
                },
                {
                  "role": "model",
                  "parts": [
                    {"text": e['response']},
                  ],
                },
              ],
            ),
            {
              "role": "user",
              "parts": [
                {"text": question},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final textResponse =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        _lastResponse = _extractJsonFromResponse(textResponse);

        _conversationHistory.add({
          'timestamp': DateTime.now(),
          'prompt': question,
          'response': _lastResponse,
        });
      } else {
        _lastResponse = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      _lastResponse = 'Error: $e';
    } finally {
      _isLoading = false;
      print(_lastResponse);
      notifyListeners();
    }
  }

  void clearConversation() {
    _conversationHistory.clear();
    _lastResponse = '';
    notifyListeners();
  }
}
