part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class GenerateNewTextMessageEvent extends ChatEvent{
  final String inputMessage;

  GenerateNewTextMessageEvent({required this.inputMessage});
}