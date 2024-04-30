import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/chat_message_model.dart';
import '../repo/chat_repo.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatSuccessState(messages: const [])) {
    on<GenerateNewTextMessageEvent>(_generateNewTextMessageEvent);
  }

  List<ChatMessageModel> messages = [];
  bool generating = false;

  Future<void> _generateNewTextMessageEvent(GenerateNewTextMessageEvent event, Emitter<ChatState> emit) async {
    messages.add(ChatMessageModel(
      role: 'user',
      parts: [ChatPartModel(text: event.inputMessage)],
    ));
    emit(ChatSuccessState(messages: messages));
    generating = true;
    String generatedText = await ChatRepo.chatTextGenerateRepo(messages);
    if(generatedText.isNotEmpty){
      messages.add(ChatMessageModel(
        role: 'model',
        parts: [ChatPartModel(text: generatedText)],
      ));
    }
    emit(ChatSuccessState(messages: messages));
    generating = false;
  }
}
