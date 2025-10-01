part of 'chat_bloc.dart';

sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class isLoading extends ChatState {
  final List<TextContentModel> messages;
  
  isLoading({required this.messages});
}

final class PromptEnteredState extends ChatState {
  final List<TextContentModel> messages;

  PromptEnteredState({required this.messages});
}
