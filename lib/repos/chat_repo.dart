import 'package:dio/dio.dart';
import 'package:gemini_clone/models/text_content_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatRepo {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://generativelanguage.googleapis.com/v1beta/",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": dotenv.env['gemini_api_key'] ?? "",
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
    ),
  );

  static Future<TextContentModel?> chatTextGeneration(
    List<TextContentModel> previousMessages,
  ) async {
    final url = "models/gemini-2.5-flash:generateContent";

    final payload = {
      "contents": previousMessages.map((e) => e.toMap()).toList(),
      "generationConfig": {
        "temperature": 0.25,
        "thinkingConfig": {"thinkingBudget": 0},
      },
      "tools": [
        {"googleSearch": {}},
      ],
    };

    try {
      // 🔹 Debugging log
      print("➡️ Sending payload: $payload");

      final response = await _dio.post(url, data: payload);

      if (response.statusCode == 200) {
        final decoded = response.data;

        if (decoded["candidates"] != null &&
            decoded["candidates"].isNotEmpty) {
          final contentData = decoded["candidates"][0]["content"];
          final textContentModel = TextContentModel.fromMap(contentData);

          print("✅ Response: ${textContentModel.parts.first.text}");
          return textContentModel;
        } else {
          print("⚠️ No candidates returned by API");
          return TextContentModel(
            role: "error",
            parts: [TextPartModel(text: "No candidates in response")],
          );
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
        return TextContentModel(
          role: "error",
          parts: [TextPartModel(text: "Server error ${response.statusCode}")],
        );
      }
    } on DioException catch (e) {
      print("❌ DioException: ${e.message}");
      if (e.response != null) {
        print("❌ Status: ${e.response?.statusCode}");
        print("❌ Body: ${e.response?.data}");
      }
      return TextContentModel(
        role: "error",
        parts: [
          TextPartModel(
            text: "Request failed: ${e.response?.statusCode ?? e.message}",
          ),
        ],
      );
    } catch (e, stack) {
      print("❌ Unexpected error: $e");
      print(stack);
      return TextContentModel(
        role: "error",
        parts: [TextPartModel(text: "Unexpected error: $e")],
      );
    }
  }
}
