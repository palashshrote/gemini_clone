import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_clone/auth/auth_service.dart';
import 'package:gemini_clone/bloc/chat_bloc.dart';
import 'package:gemini_clone/design/text_prompt.dart';
import 'package:gemini_clone/models/text_content_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final chatBloc = ChatBloc();
  TextEditingController promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('AquaVerse'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              authService.logout();
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: chatBloc,
        listener: (context, state) {
          // TODO: implement listener
          if (state is PromptEnteredState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOut,
                );
              }
            });
          } else if (state is isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },

        builder: (context, state) {
          switch (state.runtimeType) {
            case isLoading:
              final successState = state as isLoading;
              return _chatLayout(successState.messages, true);

            case PromptEnteredState:
              final successState = state as PromptEnteredState;
              return _chatLayout(successState.messages, false);

            default:
              return _inputBar(); // initial empty state
          }
        },
      ),
    );
  }

  Widget _chatLayout(List<TextContentModel> messages, bool loading) {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: customListTile(
                  messages[index].parts[0].text,
                  messages[index].role,
                  messages,
                  chatBloc,
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: SafeArea(child: _inputBar(loading: loading)),
        ),
      ],
    );
  }

  // Input bar widget
  Widget _inputBar({bool loading = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(10.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: promptController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.tealAccent.shade700,
              shape: BoxShape.circle,
            ),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: () {
                      if (promptController.text.trim().isNotEmpty) {
                        chatBloc.add(
                          GenerateText(prompt: promptController.text.trim()),
                        );
                        promptController.clear();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
