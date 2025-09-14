part of 'chat_bloc.dart';

sealed class ChatEvent {}

// class ChatInitialize extends ChatEvent {}
class GenerateText extends ChatEvent {
  final String prompt;
  final bool isRetry;
  GenerateText({required this.prompt, this.isRetry = false}); 
}