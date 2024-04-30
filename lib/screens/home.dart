import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../bloc/chat_bloc.dart';
import '../models/chat_message_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final ChatBloc chatBloc = ChatBloc();
  final msgController = TextEditingController();
  final scrollController = ScrollController();
  late AnimationController rotationController;

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// Appbar
      appBar: AppBar(
        title: Image.asset('assets/gemini_logo.png', width: 100),
        scrolledUnderElevation: 0,
      ),

      /// Body
      body: BlocConsumer<ChatBloc,ChatState>(
        bloc: chatBloc,
        listener: (context,state){},
        builder: (context,state) {
          switch(state.runtimeType) {

            /// Success State
            case const (ChatSuccessState):
              List<ChatMessageModel> messages = (state as ChatSuccessState).messages;
              return Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        shrinkWrap: true,
                        // primary: false,
                        physics: const ClampingScrollPhysics(),
                        itemCount: messages.length,
                        separatorBuilder: (context,index) => const SizedBox(height: 8),
                        itemBuilder: (context,index){
                          final msg = messages[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                            decoration: BoxDecoration(
                              color: msg.role == 'user'
                                  ? Theme.of(context).colorScheme.surfaceVariant
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: msg.role == 'user'
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('ME',style: TextStyle(fontWeight: FontWeight.w600)),
                                      Text(msg.parts.first.text, style: const TextStyle(fontSize: 16)),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset('assets/gemini_icon.png',width: 40,),
                                      MarkdownBody(data: msg.parts.first.text)
                                    ],
                                  ),

                          );
                        },
                      ),
                    ),
                    if(chatBloc.generating)
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: AnimatedRotation(
                          turns: 1000,
                          duration: const Duration(milliseconds: 300),
                          child: Image.asset('assets/gemini_icon.png',width: 40,),
                        ),
                      ),
                  ],
                ),
              );
            default:
              return const SizedBox();
          }
        }
      ),

      /// Bottom TextField and button
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 0),
          elevation: 0,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: msgController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Ask Gemini',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                onPressed: (){
                  if(msgController.text.isNotEmpty){
                    chatBloc.add(GenerateNewTextMessageEvent(inputMessage: msgController.text));
                    msgController.clear();
                    FocusScope.of(context).unfocus();
                  }
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   scrollController.jumpTo(scrollController.position.maxScrollExtent);
                  // });
                  scrollToBottom();
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                child: Icon(
                  CupertinoIcons.arrow_turn_up_right,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
