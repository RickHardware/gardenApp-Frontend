import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import '../../services/apiService.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';

class plantInfoScreen extends StatefulWidget {
  @override
  _plantInfoScreenState createState() => _plantInfoScreenState();
}

class _plantInfoScreenState extends State<plantInfoScreen> {
  //Define variables and instantiate controller object
  final TextEditingController nameController = TextEditingController();
  Future<String>? PlantQuery;
  Future<String>? PlantAnswer;
  String cityName = "Belfast";
  //Weather factory is needed to supply to LLM
  WeatherFactory wf = new WeatherFactory("8c4431682b329e67209d84d549d16186");

  ApiService apiService = ApiService();
  late Future<List<dynamic>> plants;
  //Empy message list defined
  List<Map<String, String>> messageList = [];
  final TextEditingController chatController = TextEditingController();

  //Standard user message
  void send_chat_message() {
    setState(() {
      messageList.insert(0, {'text': chatController.text, 'sender': 'user'});
    });
  }
  //Need to clear chatbox when message sends
  void clearChatbox() {
    setState(() {
      chatController.clear();
    });
  }
  //Auto message is a user message but sent automatically
  void send_chat_message_auto(String message) {
    setState(() {
      messageList.insert(0, {'text': message, 'sender': 'user'});
    });
  }
  //Distinct chat entry from LLM
  void chat_reply(String response) {
    setState(() {
      messageList.insert(0, {'text': response, 'sender': 'LLM'});
    });
  }

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
                buildStandardSubtitleText('Choose a plant for more information:'),
            //Text("Popular Plants: Click for information:"),
            buildStandardFutureBuilder(
              plants,
              'Failed to load plants',
              (snapshot) => Expanded(
                  child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  //Get name of each plant for use with LLM
                  final plant = snapshot.data![index];
                  final name = plant['common_name'] ?? 'No Name.';
                  return ListTile(
                    title: Text(name),
                    onTap: () async {
                      //Fill send chat message
                      send_chat_message_auto("Tell me about $name");
                      setState(() {
                        //Send API request for LLM info
                        PlantAnswer = askPlantQuestion(name);
                      });
                      //Receive answer
                      String? PlantString = await PlantAnswer;
                      //Record answer
                      chat_reply(PlantString!);
                      //Text to show input received
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Plant selected:  $name"),
                          duration: Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
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
                  reverse: true, // New messages at the bottom - more appropriate for a chat feature
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    bool userFlag = messageList[index]['sender'] == "user";
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
                    //Clear when done
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
                    //Record question
                    send_chat_message_auto("What should I plant?");
                    //Receive response
                    final result = await recommendPlant(wf, cityName);
                    //Record response
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
