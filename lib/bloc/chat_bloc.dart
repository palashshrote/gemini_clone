import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gemini_clone/models/text_content_model.dart';
import 'package:gemini_clone/repos/chat_repo.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  bool user = true;
  ChatBloc() : super(ChatInitial()) {
    on<GenerateText>(onGenerateText);
    // on<ChatInitialize>(onChatInitialize);
  }
  // FutureOr<void> onChatInitialize(
  //   ChatInitialize event,
  //   Emitter<ChatState> emit,
  // ) {
  //   emit(ChatInitializeState());
  // }

  List<TextContentModel> messages = [
    
  ];

  FutureOr<void> onGenerateText(
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
    user = !user;
    messages.add(TextContentModel(
      role: "system",
      parts: [TextPartModel(text: "With lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphin With lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphin With lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphinWith lifelong bonds, signature whistles and echolocation, dolphins are more than just smart swimmers. First observed in 2022, World Dolphin Day shines a light on these intelligent marine mammals and the oceans they rely on. Over 40 dolphin species swim our seas, from the Māui dolphin to the Irrawaddy dolphin")],
    ),);
    user = !user;
    emit(PromptEnteredState(messages: messages));
    /*
    emit(isLoading());
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
}
