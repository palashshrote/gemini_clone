part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class isLoading extends ChatState {}
// final class ChatInitializeState extends ChatState {}
final class PromptEnteredState extends ChatState {
  final List<TextContentModel> messages;

  PromptEnteredState({required this.messages}); 
}

// final class TextGeneratedState extends ChatState{

// }