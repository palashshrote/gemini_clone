import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_clone/auth/auth_service.dart';
import 'package:gemini_clone/bloc/chat_bloc.dart';
import 'package:gemini_clone/design/text_prompt.dart';
import 'package:gemini_clone/models/text_content_model.dart';
import 'package:gemini_clone/utils/general_functions.dart';

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
  final user = FirebaseAuth.instance.currentUser;
  String? _currentChatId; // keeps track of selected chat session
  @override
  void initState() {
    super.initState();
    // Generate a new chat session by default
    // _startNewChat();
  }

  void _startNewChat() {
    _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
    chatBloc.add(loadChatHistory(chatId: _currentChatId!));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: Drawer(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('chats')
              .orderBy('lastUpdated', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final chats = snapshot.data!.docs;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.tealAccent.shade700),
                  child: Text(
                    'Chat Histories',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                ...chats.map((doc) {
                  final title = doc['title'] ?? 'Untitled Chat';
                  return ListTile(
                    title: Text(title),
                    subtitle: Text(
                      doc['lastUpdated'] != null
                          ? (doc['lastUpdated'] as Timestamp)
                                .toDate()
                                .toString()
                          : '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: _currentChatId == doc.id,
                    onTap: () async {
                      Navigator.pop(context);
                      if (await isConnected()) {
                        setState(() {
                          _currentChatId = doc.id;
                        });
                        chatBloc.add(loadChatHistory(chatId: doc.id));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No internet connection!"),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    chatBloc.add(GotoHomePage());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("New Chat"),
                  onTap: () async {
                    Navigator.pop(context);
                    if (await isConnected()) {
                      final newChatId = DateTime.now().millisecondsSinceEpoch
                          .toString();
                      setState(() {
                        _currentChatId = newChatId;
                      });
                      chatBloc.add(StartNewChat(chatId: newChatId));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No internet connection!"),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('AquaVerse'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.logout_outlined),
          //   onPressed: () => authService.logout(),
          // ),
          IconButton(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 50, 86, 81),
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                authService.logout();
              }
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: chatBloc,
        listener: (context, state) {
          if (state is PromptEnteredState || state is isLoading) {
            /*
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                );
              }
            });
            */
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                  );
                }
              });
            });
          }
        },
        builder: (context, state) {
          // List<TextContentModel> messages = [];
          // bool loading = false;
          print("State: $state.runtimeType");
          switch (state.runtimeType) {
            case isLoading:
              final successState = state as isLoading;
              return _chatLayout(successState.messages, true);

            case PromptEnteredState:
              final successState = state as PromptEnteredState;
              return _chatLayout(successState.messages, false);

            default:
              return _emptyChatScreen();
          }
          // if (state is isLoading) {
          //   messages = state.messages;
          //   loading = true;
          // } else if (state is PromptEnteredState) {
          //   messages = state.messages;
          //   loading = false;
          // }
          // Show placeholder if empty
          // if (messages.isEmpty && !loading) {
          //   return _emptyChatScreen();
          // }
          // return _chatLayout(messages, loading);
        },
      ),
    );
  }

  Widget _emptyChatScreen() {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop, size: 64, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  "Welcome to AquaVerse 🌊",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ask me anything to get started!",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        // Expanded(flex: 2, child: SafeArea(child: _inputBar(loading: false))),
      ],
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
                  _currentChatId ?? "",
                  messages,
                  chatBloc,
                  context,
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

  Widget _inputBar({required bool loading}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          loading
              ? const CircularProgressIndicator()
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: () async {
                      if (await isConnected()) {
                        if (_currentChatId == null) {
                          final newChatId = DateTime.now()
                              .millisecondsSinceEpoch
                              .toString();
                          _currentChatId = newChatId;
                          chatBloc.add(StartNewChat(chatId: newChatId));
                        }
                        chatBloc.add(
                          GenerateText(
                            prompt: promptController.text,
                            chatId: _currentChatId!,
                          ),
                        );
                        promptController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No internet connection!"),
                          ),
                        );
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
