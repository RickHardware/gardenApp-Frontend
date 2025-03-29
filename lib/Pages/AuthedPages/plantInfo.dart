import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import '../../services/apiService.dart';
import 'package:hello_world/main.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:http/http.dart' as http;

class plantInfoScreen extends StatefulWidget {
  @override
  _plantInfoScreenState createState() => _plantInfoScreenState();
}

class _plantInfoScreenState extends State<plantInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  Future<String>? PlantQuery;
  Future<String>? PlantAnswer;
  String cityName = "Belfast";
  WeatherFactory wf = new WeatherFactory("8c4431682b329e67209d84d549d16186");

  ApiService apiService = ApiService();
  late Future<List<dynamic>> plants;
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

  //String apiKey = "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";
  //final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  @override
  void initState() {
    super.initState();
    plants = apiService.fetchPlantInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAuthedAppBar(context),
        //bottomNavigationBar: buildStandardBottomAppBar(context),
        body:
            //Column(children: [
            Row(children: [
          Expanded(
              child: Column(children: [
            Text("Popular Plants: Click for information:"),
            buildStandardFutureBuilder(
              plants,
              'Failed to load plants',
              (snapshot) => Expanded(
                  child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final plant = snapshot.data![index];
                  final name = plant['common_name'] ?? 'No Name.';
                  return ListTile(
                    title: Text(name), // Show username
                    onTap: () async {
                      send_chat_message_auto("Tell me about $name");
                      setState(() {
                        PlantAnswer = askPlantQuestion(name);
                      });
                      String? PlantString = await PlantAnswer;
                      chat_reply(PlantString!);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Plant selected:  $name"),
                          duration: Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating, // Floating style
                        ),
                      );
                    },
                  );
                },
              )),
            ),
          ])),
          Expanded(
              child: Column(children: [
            Expanded(
              child: ListView.builder(
                  reverse: true, // New messages at the bottom
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    bool userFlag = messageList[index]['sender'] == "user";

                    //ListTile(
                    title:
                    return Align(
                      alignment: userFlag
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              userFlag ? Colors.blue[300] : Colors.green[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(messageList[index]['text']!,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ); //);
                  }),
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                  child: TextField(
                controller: chatController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ask me a question about plants',
                ),
              )),
              Column(children: [
                ElevatedButton(
                  onPressed: () async {
                    //Record the ask
                    send_chat_message();
                    final result = await askLLM(chatController.text);
                    //Record the answer
                    chat_reply(result);
                    clearChatbox();
                  },
                  child: Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () async {
                    send_chat_message_auto("What should I plant?");

                    final result = await recommendPlant(wf, cityName);
                    chat_reply(result);
                  },
                  child: Text('What should I plant?'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                )
              ]),
            ]),
          ])),
        ]));
  }
}
