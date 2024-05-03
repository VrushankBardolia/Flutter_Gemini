import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:remove_markdown/remove_markdown.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc/chat_bloc.dart';
import '../models/chat_message_model.dart';
import 'setting.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final ChatBloc chatBloc = ChatBloc();
  final msgController = TextEditingController();
  final scrollController = ScrollController();

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void copyResponse(String response){
    Clipboard.setData(ClipboardData(text: response.removeMarkdown())).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to your clipboard!')),
      );
    });
  }

  void clearConversation(List<ChatMessageModel> messages){
    setState(() {
      messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// Appbar
      appBar: AppBar(
        title: Image.asset('assets/gemini_logo.png', width: 100),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>const Setting())),
            icon: const Icon(Icons.settings),
          ),
        ],
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
              if(messages.isNotEmpty){
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8,0,8,0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          // itemCount: messages.length,
                          itemCount: messages.length + (chatBloc.generating ? 1 : 0), // Add 1 for Shimmer if generating
                          separatorBuilder: (context,index) => const SizedBox(height: 8),
                          itemBuilder: (context,index){
                            if (index < messages.length) {
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
                                        MarkdownBody(data: msg.parts.first.text),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () => copyResponse(msg.parts.first.text),
                                              iconSize: 20,
                                              icon: const Icon(Icons.copy),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                              );
                            } else {
                              return SizedBox(
                                height: 100,
                                child: Shimmer.fromColors(
                                  baseColor: const Color(0xff836DC3),
                                  highlightColor: const Color(0xff1AA0E2),
                                  child: const Center(
                                    child: Text('Generating...',
                                      style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w600, fontSize: 20),
                                    ),
                                  ),
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

              /// If there is no chat
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.75),
                      Theme.of(context).colorScheme.background,
                    ],
                  )
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Start Conversation with ',
                        style: TextStyle(fontSize: 22, height:1),),
                      Image.asset('assets/gemini_logo.png', height: 28,),
                    ],
                  ),
                ),
              );
            default:
              return Container();
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
                    msgController.clear;
                    FocusScope.of(context).unfocus();
                  }
                  scrollToBottom();
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                focusElevation: 0,
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
