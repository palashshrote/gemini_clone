import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gemini_clone/models/text_content_model.dart';
import 'package:gemini_clone/repos/chat_repo.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
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

  List<TextContentModel> messages = [];

  FutureOr<void> onGenerateText(
    GenerateText event,
    Emitter<ChatState> emit,
  ) async {
    messages.add(
      TextContentModel(
        role: "user",
        parts: [TextPartModel(text: event.prompt)],
      ),
    );
    emit(PromptEnteredState(messages: messages));
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
  }
}
