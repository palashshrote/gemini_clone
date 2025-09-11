import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_clone/bloc/chat_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final chatBloc = ChatBloc();
  TextEditingController promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gemini Clone')),
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: chatBloc,
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case isLoading:
              return const Center(child: CircularProgressIndicator());
            case (PromptEnteredState):
              final successState = state as PromptEnteredState;

              return Column(
                children: [
                  /*
                  Container(
                    padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                    child: Text(
                      'Gemini Clone',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 8, 33, 54),
                      ),
                    ),
                  ),
                  */
                  Expanded(
                    child: ListView.builder(
                      itemCount: successState.messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            successState.messages[index].parts[0].text,
                          ),
                          tileColor: Colors.blueGrey,
                        );
                      },
                    ),
                  ),
                  Container(
                    // color: Colors.blueAccent,
                    // height: 20,
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promptController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.w),
                              ),
                              fillColor: Colors.blue.shade200,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(100.w),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        CircleAvatar(
                          radius: 8.w,
                          backgroundColor: Colors.blue.shade900,
                          child: IconButton(
                            focusColor: Theme.of(context).primaryColor,
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 7.w,
                            ),
                            onPressed: () {
                              // Handle send action
                              chatBloc.add(
                                GenerateText(prompt: promptController.text),
                              );
                              promptController.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            default:
              // final successState = state as PromptEnteredState;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /*
                  Container(
                    padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                    child: Text(
                      'Gemini Clone',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 8, 33, 54),
                      ),
                    ),
                  ),
                  
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: successState.messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            successState.messages[index].parts[0].text,
                          ),
                          tileColor: Colors.blueGrey,
                        );
                      },
                    ),
                  ),
                  */
                  
                  Container(
                    // color: Colors.blueAccent,
                    // height: 20,
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promptController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.w),
                              ),
                              fillColor: Colors.blue.shade900,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(100.w),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        CircleAvatar(
                          radius: 8.w,
                          backgroundColor: Colors.blue.shade900,
                          child: IconButton(
                            focusColor: Theme.of(context).primaryColor,
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 7.w,
                            ),
                            onPressed: () {
                              // Handle send action
                              chatBloc.add(
                                GenerateText(prompt: promptController.text),
                              );
                              promptController.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
