import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leggo/model/gpt_place.dart';

class ChatGPTRepository {
  final OpenAI _openAI =
      OpenAI.instance.build(token: dotenv.env['OPENAI_API_KEY']);

  /// Change the access token
  void changeAccessToken(String token) {
    _openAI.setToken(token);
  }

  /// Chat complete GPT-4
  Future<GptPlace?> chatComplete(List<String> messages, String name) async {
    try {
      final request =
          ChatCompleteText(model: GptTurbo0301ChatModel(), messages: [
        for (String message in messages)
          Messages(role: Role.user, content: message, name: name)
      ]);

      final response =
          await _openAI.onChatCompletion(request: request).catchError((error) {
        print('Chat error: $error');
      });

      final responseChoiceMessages = [];
      print('Char choices: ${response!.choices}');
      for (var element in response.choices) {
        responseChoiceMessages.add(element.message?.content);
        print('Chat response: ${element.message?.content}');
        if (element.finishReason != null) {
          print('Finish reason ${element.finishReason}');

          /// Continue the conversation if the finish reason is length
          /// Providing the previous message
          if (element.finishReason == 'length') {
            final request =
                ChatCompleteText(model: GptTurbo0301ChatModel(), messages: [
              Messages(
                  role: Role.user,
                  content: 'Finish this: ${element.message?.content}',
                  name: name)
            ], stop: [
              '\n'
            ]);
            final response = await _openAI
                .onChatCompletion(request: request)
                .catchError((error) {
              print('Chat error: $error');
            });
            // Try to decode the JSON and handle errors
          }

          try {
            var decodedJson = jsonDecode(element.message!.content);
            print('Decoded json: $decodedJson');
            return GptPlace.fromJson(decodedJson);
          } catch (e) {
            print('Error decoding JSON: $e');
            print('JSON string: ${element.message!.content}');
          }
        }
      }
      return null;
    } catch (e) {
      print('Chat error: $e');
      return null;
    }

    // return responseChoiceMessages;
  }
}
