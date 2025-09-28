import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemini_clone/models/text_content_model.dart';
import 'package:gemini_clone/repos/chat_repo.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final List<TextContentModel> messages = [];

  ChatBloc() : super(ChatInitial()) {
    on<GenerateText>(onGenerateText);
    on<loadChatHistory>(_onLoadChatHistory);
  }
  Future<void> saveChatToFirestore(String prompt, String response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc('history'); // single doc for all chats

    await docRef.set({
      'conversations': {
        prompt: response, // key = prompt, value = response
      },
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  FutureOr<void> onGenerateText(
    GenerateText event,
    Emitter<ChatState> emit,
  ) async {
    if (!event.isRetry) {
      messages.add(
        TextContentModel(
          role: "user",
          parts: [TextPartModel(text: event.prompt)],
        ),
      );
    }

    emit(isLoading(messages: messages));

    try {
      final filteredMessages = messages
          .where((msg) => msg.role != "error")
          .toList();
      final content = await ChatRepo.chatTextGeneration(filteredMessages);
      // .timeout(
      //   const Duration(seconds: 7),
      //   onTimeout: () {
      //     throw TimeoutException("Request timed out. Please try again.");
      //   },
      // );

      if (content != null) {
        messages.add(content);
        print('Question : ${messages[messages.length - 2].parts[0].text}');
        print('Answer : ${messages[messages.length - 1].parts[0].text}');
        await saveChatToFirestore(
          messages[messages.length - 2].parts[0].text,
          messages[messages.length - 1].parts[0].text,
        );
        emit(PromptEnteredState(messages: messages));
      } else {
        messages.add(
          TextContentModel(
            role: "error",
            parts: [TextPartModel(text: "Unable to generate response")],
            isRetry: true,
          ),
        );
        emit(PromptEnteredState(messages: messages));
      }
    } on TimeoutException {
      messages.add(
        TextContentModel(
          role: "error",
          parts: [
            TextPartModel(text: "⏳ Request took too long. Please try again."),
          ],
          isRetry: true,
        ),
      );
      emit(PromptEnteredState(messages: messages));
    } catch (e) {
      messages.add(
        TextContentModel(
          role: "error",
          parts: [TextPartModel(text: e.toString())],
          isRetry: true,
        ),
      );
      emit(PromptEnteredState(messages: messages));
    }
  }

  FutureOr<void> _onLoadChatHistory(
    loadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc('history'); // single doc for all chats

    final doc = await docRef.get();
    final data = doc.data();
    final rawConversations = data?['conversations'];

    // List<TextContentModel> messages = [];

    if (rawConversations is List) {
      for (var convo in rawConversations) {
        final prompt = convo['prompt'] ?? '';
        final response = convo['response'] ?? '';

        messages.add(
          TextContentModel(
            role: "user",
            parts: [TextPartModel(text: prompt)],
          ),
        );
        messages.add(
          TextContentModel(
            role: "model",
            parts: [TextPartModel(text: response)],
          ),
        );
      }
    } else if (rawConversations is Map) {
      rawConversations.forEach((prompt, response) {
        messages.add(
          TextContentModel(
            role: "user",
            parts: [TextPartModel(text: prompt)],
          ),
        );
        messages.add(
          TextContentModel(
            role: "model",
            parts: [TextPartModel(text: response)],
          ),
        );
      });
    }
    emit(PromptEnteredState(messages: messages));
  }
}
