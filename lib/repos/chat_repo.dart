import 'package:dio/dio.dart';
import 'package:gemini_clone/models/text_content_model.dart';

class ChatRepo {
  static chatTextGeneration(List<TextContentModel> previousMessages) async {
    try {
      String url =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

      Map<String, dynamic> headers = {"Content-Type": "application/json"};

      Map<String, dynamic> payload = {
        "contents": previousMessages,
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
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception("Caught exception: $e");
    }
  }
}
