import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('chats')
                    .orderBy('lastUpdated', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chats = snapshot.data!.docs;

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.tealAccent.shade700,
                        ),
                        child: const Text(
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
                              if (_currentChatId != doc.id) {
                                setState(() {
                                  _currentChatId = doc.id;
                                });
                                chatBloc.add(loadChatHistory(chatId: doc.id));
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No internet connection!"),
                                ),
                              );
                            }
                          },
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.tealAccent.shade700,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Chat"),
                                  content: const Text(
                                    "Are you sure you want to delete this chat?",
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          50,
                                          86,
                                          81,
                                        ),
                                      ),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                chatBloc.add(
                                  DeleteChat(chatId: _currentChatId!),
                                );
                                if (_currentChatId == doc.id) {
                                  setState(() {
                                    _currentChatId = null;
                                  });
                                }
                              }
                            },
                          ),
                        );
                      }).toList(),
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Home'),
                        onTap: () {
                          setState(() {
                            _currentChatId = null;
                          });
                          Navigator.pop(context);
                          chatBloc.add(GotoHomePage());
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text("New Chat"),
                        onTap: () async {
                          setState(() {
                            _currentChatId = null;
                          });
                          Navigator.pop(context);
                          chatBloc.add(GotoNewChatScreen());
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // 👇 User email fixed at bottom
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 30,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.email ?? "No Email",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text('GemChat'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
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
          print("State: $state.runtimeType");
          switch (state.runtimeType) {
            case isLoading:
              final successState = state as isLoading;
              return _chatLayout(successState.messages, true);

            case PromptEnteredState:
              final successState = state as PromptEnteredState;
              return _chatLayout(successState.messages, false);

            case firstChatScreen:
              return _firstChatScreen();
            default:
              return _emptyChatScreen();
          }
        },
      ),
    );
  }

  Widget _firstChatScreen() {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "What can I help with?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SafeArea(child: _inputBar(loading: false, isFirstChat: true)),
        ),
      ],
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
                Icon(Icons.diamond, size: 64, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  "Welcome to GemChat",
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

  Widget _inputBar({required bool loading, bool isFirstChat = false}) {
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
                        if (promptController.text.length <= 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Your query is too short"),
                            ),
                          );
                        }

                        if (_currentChatId == null) {
                          final newChatId = DateTime.now()
                              .millisecondsSinceEpoch
                              .toString();
                          _currentChatId = newChatId;
                          print(newChatId);
                        }
                        // else {
                        print("isFirstChat: $isFirstChat");
                        chatBloc.add(
                          GenerateText(
                            prompt: promptController.text,
                            chatId: _currentChatId!,
                            isFirstChat: isFirstChat,
                          ),
                        );
                        promptController.clear();
                        // }
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
