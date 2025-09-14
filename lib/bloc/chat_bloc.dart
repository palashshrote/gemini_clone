
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:gemini_clone/models/text_content_model.dart';
import 'package:gemini_clone/repos/chat_repo.dart';

part 'chat_event.dart';
part 'chat_state.dart';
/*
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  bool user = true;
  List<TextContentModel> messages = [];
  // List<String> prompts = [];
  ChatBloc() : super(ChatInitial()) {
    on<GenerateText>(onGenerateText);
  }

  //original format
  FutureOr<void> onGenerateText(
    GenerateText event,
    Emitter<ChatState> emit,
  ) async {
    // prompts.add(event.prompt);
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
      // Set timeout of 10 seconds
      TextContentModel? content = await ChatRepo.chatTextGeneration(messages)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              print("Length: " + messages.length.toString());
              throw TimeoutException("Request timed out. Please try again.");
            },
          );
      if (content != null) {
        messages.add(content);
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
    } on TimeoutException catch (_) {
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

  /*
  FutureOr<void> onGenerateTex2t(
    GenerateText event,
    Emitter<ChatState> emit,
  ) async {
    String customRole = user ? "user" : "model";
    messages.add(
      TextContentModel(
        role: customRole,
        parts: [TextPartModel(text: event.prompt)],
      ),
    );
    // emit(PromptEnteredState(messages: messages));
    emit(isLoading(messages: messages));
    await Future.delayed(const Duration(seconds: 2), () {
      user = !user;
      messages.add(
        TextContentModel(
          role: "system",
          parts: [
            TextPartModel(
              text:
                  "With lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphin With lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphin With lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphin",
            ),
          ],
        ),
      );
      user = !user;
      emit(PromptEnteredState(messages: messages));
    });

    /*
    try {
      TextContentModel? content = await ChatRepo.chatTextGeneration(messages);
      if (content != null) {
        messages.add(content);
        emit(PromptEnteredState(messages: messages));
      } else {
        messages.add(
          TextContentModel(
            role: "error",
            parts: [TextPartModel(text: "Unable to generate response")],
          ),
        );
        emit(PromptEnteredState(messages: messages));
      }
    } catch (e) {
      messages.add(
        TextContentModel(
          role: "error",
          parts: [TextPartModel(text: e.toString())],
        ),
      );
      emit(PromptEnteredState(messages: messages));
    }
    */
  }
*/
}
*/

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final List<TextContentModel> messages = [];

  ChatBloc() : super(ChatInitial()) {
    on<GenerateText>(onGenerateText);
  }

  FutureOr<void> onGenerateText(
    GenerateText event,
    Emitter<ChatState> emit,
  ) async {
    // ✅ Add user message only if not retry
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
      final filteredMessages = messages.where((msg) => msg.role != "error").toList();
      final content = await ChatRepo.chatTextGeneration(filteredMessages);
      // .timeout(
      //   const Duration(seconds: 7),
      //   onTimeout: () {
      //     throw TimeoutException("Request timed out. Please try again.");
      //   },
      // );

      if (content != null) {
        messages.add(content);
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
}
