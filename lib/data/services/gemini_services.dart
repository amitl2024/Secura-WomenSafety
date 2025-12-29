import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ai_women_safety/data/services/emotional_support_service.dart';
import 'package:ai_women_safety/utils/logger_util.dart';

class GeminiService {
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];
  final EmotionalSupportService _emotionalService = EmotionalSupportService();

  Future<String> sendMessage({
    required String message,
    String model = "gemini-2.5-flash",
  }) async {
    if (apiKey == null) {
      return "Error: API Key not found.";
    }

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey",
    );
    // Analyze emotional context
    final emotionalContext = _emotionalService.analyzeEmotionalContext(message);

    // Check for emergency situations
    if (_emotionalService.needsImmediateSupport(message)) {
      return _emotionalService.getEmergencySupportMessage();
    }

    // Use the refined prompt with emotional context
    final prompt = _refinedCalmPrompt(message, emotionalContext);
    AppLogger.debug("📝 Prompt length: ${prompt.length} characters");

    try {
      AppLogger.debug("🚀 Sending request to Gemini API...");
      AppLogger.verbose("📝 Message: $message");

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "contents": [
                {
                  "role": "user",
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
              "generationConfig": {
                "temperature":
                    0.9, // Higher for more creative and empathetic responses
                "topP": 0.95,
                "topK": 40,
                "maxOutputTokens": 200,
                "candidateCount": 1,
                "stopSequences": [],
              },
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              AppLogger.error("Gemini API request timeout");
              throw TimeoutException('Request timeout');
            },
          );

      AppLogger.debug("📡 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.verbose("API Response received successfully");

        // Try multiple ways to extract the response
        String? botReply;

        // Method 1: Standard Gemini response structure
        if (data["candidates"] != null && data["candidates"].isNotEmpty) {
          final candidate = data["candidates"][0];

          // Check for various finish reasons
          final finishReason = candidate["finishReason"];
          if (finishReason != null) {
            AppLogger.warning(
              "⚠️ Response finished with reason: $finishReason",
            );
            switch (finishReason) {
              case "MAX_TOKENS":
                return "I'm here to help, sweetheart! Could you please ask a shorter question so I can give you a complete response? 💜";
              case "SAFETY":
                return "I can't provide a response to that question due to safety guidelines. Could you please rephrase your question? 💜";
              case "RECITATION":
                return "I can't provide that specific information. Could you please ask something else? 💜";
              case "OTHER":
                return "I'm having trouble processing that request. Could you please try rephrasing your question? 💜";
              default:
                AppLogger.warning("⚠️ Unknown finish reason: $finishReason");
            }
          }

          if (candidate["content"] != null) {
            // Check for parts array
            if (candidate["content"]["parts"] != null &&
                candidate["content"]["parts"].isNotEmpty) {
              botReply = candidate["content"]["parts"][0]["text"];
            }
            // Check for direct text in content
            else if (candidate["content"]["text"] != null) {
              botReply = candidate["content"]["text"];
            }
            // Check if content is a string
            else if (candidate["content"] is String) {
              botReply = candidate["content"];
            }
          }
        }

        // Method 2: Check for direct text field
        if (botReply == null && data["text"] != null) {
          botReply = data["text"];
        }

        // Method 3: Check for alternative response field
        if (botReply == null && data["response"] != null) {
          botReply = data["response"];
        }

        // Method 4: Check for content field directly
        if (botReply == null && data["content"] != null) {
          if (data["content"] is String) {
            botReply = data["content"];
          } else if (data["content"]["text"] != null) {
            botReply = data["content"]["text"];
          }
        }

        if (botReply != null && botReply.isNotEmpty) {
          AppLogger.debug("✅ Successfully extracted response");
          return botReply;
        } else {
          AppLogger.error(
            "❌ No valid response found",
            "Candidate content structure: ${data["candidates"]?[0]?["content"]}",
          );
          return "I'm having trouble processing that right now. Could you please try rephrasing your question? 💜";
        }
      } else {
        AppLogger.error(
          "Gemini API Error - Status: ${response.statusCode}",
          response.body,
        );
        return "I'm experiencing some technical difficulties. Please try again in a moment. 💜";
      }
    } catch (e, stackTrace) {
      AppLogger.error("💥 Exception calling Gemini API", e, stackTrace);
      return "I'm having some technical difficulties right now. Please try again in a moment, sweetheart. 💜";
    }
  }

  /// Enhanced prompt for a loving, supportive AI companion
  String _refinedCalmPrompt(String userMessage, String emotionalContext) {
    return """You are Luna, a caring AI companion for women's safety and emotional support. Be warm, empathetic, and helpful. Use gentle language with occasional terms like "sweetheart" or "dear". Keep responses 2-3 sentences. Use emojis sparingly (💜, 🌸, 🤗). 

Emotional context: $emotionalContext
User: "$userMessage"

Respond as Luna:""";
  }
}

final GeminiService _geminiService = GeminiService();

Future<String> fetchGeminiReply(String message) async {
  return await _geminiService.sendMessage(
    message: message,
    model: "gemini-2.5-flash",
  );
}
