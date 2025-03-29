import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:http/http.dart' as http;

import '../../services/apiService.dart';

class weatherPage extends StatefulWidget {
  @override
  weatherPageState createState() => weatherPageState();
}

class weatherPageState extends State<weatherPage> {
  ApiService apiService = ApiService();
  late Future<List<dynamic>> users;

  @override
  void initState() {
    super.initState();
  }

  String cityName = "Belfast";
  WeatherFactory wf = new WeatherFactory("8c4431682b329e67209d84d549d16186");

  late Future<List<dynamic>> plants;

  String CGPTapiKey =
      "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";
  String apiKey = "AIzaSyCdiF2KXjAlKXOGX7XUrGBEAiTn3CdRE78";
  final String cgptapiUrl = 'https://api.openai.com/v1/chat/completions';
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyCdiF2KXjAlKXOGX7XUrGBEAiTn3CdRE78";

  //Define empty message list - this will mean messages are not persistent
  List<Map<String, String>> messageList = [];
  final TextEditingController chatController = TextEditingController();

  void send_chat_message() {
    setState(() {
      messageList.insert(0, {'text': chatController.text, 'sender': 'user'});
    });
  }

  void clearChatbox() {
    setState(() {
      chatController.clear();
    });
  }

  void send_chat_message_auto(String message) {
    setState(() {
      messageList.insert(0, {'text': message, 'sender': 'user'});
    });
  }

  void chat_reply(String response) {
    setState(() {
      messageList.insert(0, {'text': response, 'sender': 'LLM'});
    });
  }

  @override
  Widget build(BuildContext context) {
    String PlantRecommendation = "";
    return Scaffold(
      appBar: buildAuthedAppBar(context),
      //bottomNavigationBar: buildStandardBottomAppBar(context),
      body: // Center(
          //child:
          Column(
        children: [
          FutureBuilder<String>(
              future: getTemp(wf, cityName),
              builder: (context, snapshot) {
                return Text(snapshot.data ?? "",
                    style: TextStyle(color: Colors.green, fontSize: 30));
              }),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
                reverse: true, // New messages at the bottom
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  bool userFlag = messageList[index]['sender'] == "user";

                  //ListTile(
                  title:
                  return Align(
                    alignment:
                        userFlag ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:  userFlag ?  Colors.blue[300] : Colors.green[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(messageList[index]['text']!,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ); //);
                }),
          ),

          const SizedBox(height: 10),
          TextField(
            controller: chatController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Ask me a question about plants',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          ElevatedButton(
            onPressed: () async {
              send_chat_message();
              final result = await askLLM(chatController.text);
              chat_reply(result);
              String PlantRecommendation = result;
              clearChatbox();
            },
            child: Text('Send'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              send_chat_message_auto("What should I plant?");

              final result = await recommendPlant(wf, cityName);
              chat_reply(result);
              print(result);

              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text(result),
              //     duration: Duration(seconds: 5),  // Duration of the Snackbar
              //     behavior: SnackBarBehavior.floating, // Floating style
              //   ),
              // );
            },
            child: Text('What should I plant?'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),]),
          const SizedBox(height: 10),
        ],
      ),
      //),
    );
  }
}
