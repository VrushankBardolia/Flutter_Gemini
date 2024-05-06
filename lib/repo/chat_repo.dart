import 'package:dio/dio.dart';

import '../global.dart';
import '../models/chat_message_model.dart';

class ChatRepo{
  static Future<String> chatTextGenerateRepo(List<ChatMessageModel> previousMessages) async {
    try{
      Dio dio = Dio();
      final response = await dio.post(
        API_URL,
        data: {
          "contents": previousMessages.map((e) => e.toMap()).toList(),
          "generationConfig": {
            "temperature": temperature,
            "topK": 1,
            "topP": 1,
            "maxOutputTokens": 2048,
            "stopSequences": []
          },
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            }
          ]
        },
      );
      print(response.toString());
      if(response.statusCode! >= 200 && response.statusCode! <= 300){
        return response.data['candidates'].first['content']['parts'].first['text'];
      }
      return '';
    }catch(e){
      print(e.toString());
    }
    return '';
  }
}