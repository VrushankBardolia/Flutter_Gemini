import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gemini_ai/models/chat_message_model.dart';

import '../bloc/chat_bloc.dart';
import '../global.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final ChatBloc chatBloc = ChatBloc();
  final msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// Appbar
      appBar: AppBar(
        title: Image.asset('assets/gemini_logo.png', width: 100),
      ),

      /// Body
      body: BlocConsumer<ChatBloc,ChatState>(
        bloc: chatBloc,
        listener: (context,state){},
        builder: (context,state) {
          switch(state.runtimeType) {
            case ChatSuccessState:
              List<ChatMessageModel> messages = (state as ChatSuccessState).messages;
              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context,index){
                  return Text(messages[index].parts.first.text);
                },
              );
            default:
              return SizedBox();
          }

        }
      ),

      /// Bottom TextField and button
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: BottomAppBar(
          padding: const EdgeInsets.all(12),
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
