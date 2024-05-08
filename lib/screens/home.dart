import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late ConnectivityResult connectionStatus;
  bool bottomBarVisible = true;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    print(connectivityResult);
    setState(() {
      connectionStatus = connectivityResult.first;
      if(connectionStatus == ConnectivityResult.mobile || connectionStatus == ConnectivityResult.wifi){
        bottomBarVisible = true;
      } else {
        bottomBarVisible = false;
      }
    });
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void clearChat() {
    chatBloc.add(ClearChatEvent());
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget fieldAndButton(){
    return Padding(
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
              onPressed: () {
                if(msgController.text.isNotEmpty){
                  chatBloc.add(GenerateNewTextMessageEvent(inputMessage: msgController.text));
                  msgController.clear();
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
    );
  }

  Widget noConnection(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('No Internet Connection'),
          IconButton(onPressed: checkInternetConnection, icon: const Icon(Icons.replay))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        /// Appbar
        appBar: AppBar(
          title: Image.asset('assets/gemini_logo.png', width: 100),
          scrolledUnderElevation: 0,
          actions: [
            PopupMenuButton(
              position: PopupMenuPosition.under,
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: clearChat,
                  child: const ListTile(
                    leading: Icon(Icons.delete_forever_rounded),
                    title: Text('Clear Conversation'),
                  ),
                ),
                PopupMenuItem(
                  onTap:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>const Setting())),
                  child: const ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ),
              ]
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
                          itemCount: messages.length + (chatBloc.generating ? 1 : 0),
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
                                          const Text('ME',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
                                          Text(msg.parts.first.text, style: const TextStyle(fontSize: 16)),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Image.asset('assets/gemini_icon.png',width: 40,),
                                          const SizedBox(height: 8),
                                          MarkdownBody(data: msg.parts.first.text,
                                            selectable: true,
                                            styleSheet: MarkdownStyleSheet(
                                              h1: const TextStyle(fontWeight: FontWeight.w700,fontSize: 28),
                                              h2: const TextStyle(fontWeight: FontWeight.w700,fontSize: 24),
                                              h3: const TextStyle(fontWeight: FontWeight.w700,fontSize: 20),
                                              p: const TextStyle(fontSize: 16),
                                              listIndent: 12,
                                              code: GoogleFonts.ptMono(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                              ),
                                              codeblockDecoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: Theme.of(context).colorScheme.secondaryContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              );
                            } else {
                              return SizedBox(
                                height: 100,
                                child: Shimmer.fromColors(
                                  baseColor: const Color(0xff6FB2FE),
                                  highlightColor: const Color(0xff2780FE),
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
                          style: TextStyle(fontSize: 22, height: 1),
                        ),
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
      bottomNavigationBar: bottomBarVisible
          ? fieldAndButton()
          : noConnection()
    );
  }
}
