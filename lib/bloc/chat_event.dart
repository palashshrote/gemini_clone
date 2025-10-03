part of 'chat_bloc.dart';

sealed class ChatEvent {}

// class ChatInitialize extends ChatEvent {}
class GenerateText extends ChatEvent {
  final String prompt;
  final bool isRetry;
  final String chatId;
  final bool isFirstChat;
  GenerateText({required this.prompt, required this.chatId, this.isRetry = false, this.isFirstChat = false});
}

class loadChatHistory extends ChatEvent {
  final String chatId;
  loadChatHistory({required this.chatId});
}

class StartNewChat extends ChatEvent {
  final String chatId;
  StartNewChat({required this.chatId});
}
class GotoNewChatScreen extends ChatEvent {
  GotoNewChatScreen();
}
class GotoHomePage extends ChatEvent {
  GotoHomePage();
}