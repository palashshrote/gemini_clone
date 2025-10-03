import 'package:flutter/material.dart';
import 'package:gemini_clone/bloc/chat_bloc.dart';
import 'package:gemini_clone/models/text_content_model.dart';
import 'package:gemini_clone/utils/general_functions.dart';

Widget customListTile(
  String data,
  String role,
  String chatId,
  List<TextContentModel> messages,
  ChatBloc chatBloc,
  BuildContext context,

) {
  final isError = role == "error";
  final isUser = role == "user";

  return Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: role == 'user' ? Colors.teal.shade900 : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: role == 'user'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(data, style: const TextStyle(color: Colors.white, fontSize: 16)),
          if (isError) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                // 🔥 Retry without duplicating user message
                if (await isConnected()) {
                  final latestPrompt = messages
                      .lastWhere((msg) => msg.role == "user")
                      .parts[0]
                      .text;

                  chatBloc.add(
                    GenerateText(
                      prompt: latestPrompt,
                      isRetry: true, // ✅ flag prevents duplicate
                      chatId: chatId,
                      isFirstChat: false,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Check your internet connection"),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ],
      ),
    ),
  );
}
