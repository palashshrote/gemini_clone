import 'package:dio/dio.dart';
import 'package:gemini_clone/models/text_content_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ChatRepo {
  // static String key = ;
  static Future<TextContentModel?> chatTextGeneration(
    List<TextContentModel> previousMessages,
  ) async {
    try {
      String url =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

      Map<String, dynamic> headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": dotenv.env['gemini_api_key'],
      };

      Map<String, dynamic> payload = {
        "contents": previousMessages.map((e) => e.toMap()).toList(),
        "generationConfig": {
          "temperature": 0.25,
          "thinkingConfig": {"thinkingBudget": 0},
        },
        "tools": [
          {"googleSearch": {}},
        ],
      };
      Dio dio = Dio();

      dio.options = BaseOptions(headers: headers);
      final response = await dio.post(url, data: payload);
      // print(response.toString());
      if (response.statusCode == 200) {
        final decodedResponse = response.data;
        final contentData = decodedResponse['candidates'][0]['content'];
        TextContentModel textContentModel = TextContentModel.fromMap(
          contentData,
        );
        print(textContentModel.parts.first.text);
        return textContentModel;
      } else {
        print("Error loading data from server");
        return null;
        // throw Exception("Failed to load data from server");
      }
    } catch (e) {
      print(e.toString());
      // throw Exception("Caught exception: $e");
      return null;
    }
  }
}
