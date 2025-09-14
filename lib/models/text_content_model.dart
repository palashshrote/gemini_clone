import 'dart:convert';

class TextContentModel {
  final String role;
  final List<TextPartModel> parts;
  final bool isRetry;

  TextContentModel({required this.role, required this.parts, this.isRetry = false});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role,
      'parts': parts.map((x) => x.toMap()).toList(),
    };
  }

  factory TextContentModel.fromMap(Map<String, dynamic> map) {
    return TextContentModel(
      role: map['role'] ?? '',
      parts: List<TextPartModel>.from(
        (map['parts'] as List).map(
          (x) => TextPartModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TextContentModel.fromJson(String source) =>
      TextContentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class TextPartModel {
  final String text;

  TextPartModel({required this.text});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
    };
  }

  factory TextPartModel.fromMap(Map<String, dynamic> map) {
    return TextPartModel(
      text: map['text'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TextPartModel.fromJson(String source) =>
      TextPartModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
