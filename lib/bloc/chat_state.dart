part of 'chat_bloc.dart';

sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class isLoading extends ChatState {
  final List<TextContentModel> messages;

  isLoading({required this.messages});
}
// final class ChatInitializeState extends ChatState {}
final class PromptEnteredState extends ChatState {
  final List<TextContentModel> messages;
  // final List<String> prompts;
  PromptEnteredState({required this.messages}); 
}

// final class TextGeneratedState extends ChatState{

// }