import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../library/Utility.dart';
import '../../services/apiService.dart';
import 'package:hello_world/main.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';

import 'gardenList.dart';

class GardenProfile extends StatefulWidget {
  @override
  _GardenProfileState createState() => _GardenProfileState();
}

class _GardenProfileState extends State<GardenProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  List<Map<String, String>> messageList = [];

  final String baseUrl = 'http://127.0.0.1:8000/api/garden/';
  ApiService apiService = ApiService();

  Future<void> followGarden(String gardenName) async {
    String apiUrl = 'http://127.0.0.1:8000/api/garden/join/$gardenName/';
    try {
      final currentUser = Provider.of<UserProvider>(context,listen: false).getUser();
      int? currentID = currentUser?.getuserID();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userID': currentID
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Garden Followed successfully!')),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => GardenListScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to follow garden: ${response.statusCode}')),
        );
      }
    }
    catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> unfollowGarden(String gardenName) async {
    String apiUrl = 'http://127.0.0.1:8000/api/garden/leave/$gardenName/';
    print(apiUrl);
    try {
      final currentUser = Provider.of<UserProvider>(context,listen: false).getUser();
      int? currentID = currentUser?.getuserID();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userID': currentID
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Garden unfollowed successfully!')),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => GardenListScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to unfollow garden: ${response.statusCode}')),
        );
      }
    }
    catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }









  void send_chat_message(username) {
    setState(() {
      messageList.insert(messageList.length,
          {'body': messageController.text, 'senderUsername': username});
    });
  }

  void clearChatbox() {
    setState(() {
      messageController.clear();
    });
  }

  void send_chat_message_auto(String message) {
    setState(() {
      messageList.insert(0, {'body': message, 'sender': 'user'});
    });
  }

  void chat_reply(String response) {
    setState(() {
      messageList.insert(0, {'body': response, 'sender': 'LLM'});
    });
  }

  Future<void> createMessage(userID, gardenID) async {
    String apiUrl = 'http://127.0.0.1:8000/api/msg/';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'senderID': userID,
          'gardenID': gardenID,
          'body': messageController.text
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to create message: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> fetchData() async {
    final Garden? currentGarden =
        Provider.of<gardenProvider>(context, listen: false).getGarden();
    List<dynamic> fetchedMessages =
        await apiService.fetchMessages(currentGarden?.name);
    setState(() {
      messageList = fetchedMessages
          .map((msg) => {
                "date_sent": msg["date_sent"].toString(),
                "gardenID": msg["gardenID"].toString(),
                "senderID": msg["senderID"].toString(),
                "body": msg["body"].toString(),
                "senderUsername": msg["senderUsername"].toString()
              })
          .toList();
    });

    print("Messages loaded: $messageList"); // Debugging output
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<String> getOwnerUsername(int ownerID) async {
    return await apiService.fetchUserName(ownerID);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, fetchData);
  }

  @override
  Widget build(BuildContext context) {
    final Garden? currentGarden =
        Provider.of<gardenProvider>(context).getGarden();
    final currentUser = Provider.of<UserProvider>(context).getUser();
    final currentName = currentUser?.getName();

    String ownText = "";
    Map<String, dynamic> profile = {
      "name": currentGarden?.getName(),
      "bio": currentGarden?.getBio(),
      "lat": currentGarden?.getLat().toString(),
      "long": currentGarden?.getLong().toString()
    };
    if (currentName == profile['ownerUsername']) {
      ownText = "This is your garden";
    } else {
      ownText = "This garden belongs to ${profile['ownerUsername']}";
    }

    return Scaffold(
      appBar: buildAuthedAppBar(context),
      body: FutureBuilder(
          future: getOwnerUsername(currentGarden!.getOwner()),
          builder: (context, snapshot) {
            return (Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildStandardSubtitleText('Welcome to ${profile['name']}'),
                  const SizedBox(height: 20),
                  buildStandardSubtitleText('Bio: ${profile['bio']}'),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      followGarden(profile['name']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text("Follow this garden"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      unfollowGarden(profile['name']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text("Unfollow this garden"),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text("Owned by ${snapshot.data}"),
                  ),
                  Expanded(
                      child: ListView.builder(
                          reverse: false,
                          itemCount: messageList.length,
                          itemBuilder: (context, index) {
                            bool userFlag = messageList[index]
                                    ['senderUsername'] ==
                                currentName;
                            return Align(
                              alignment: userFlag
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: userFlag
                                      ? Colors.blue[300]
                                      : Colors.green[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                    '${messageList[index]['senderUsername']} said: ${messageList[index]['body']}',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ); //);
                          })),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(
                        child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What would you like to say?',
                      ),
                    )),
                    Column(children: [
                      ElevatedButton(
                        onPressed: () async {
                          print("name sending is $currentName");
                          send_chat_message(currentName);
                          createMessage(currentUser?.getuserID(),
                              currentGarden.getName());
                          clearChatbox();
                        },
                        child: Text('Send'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ]),
                  ]),
                ],
              ),
            )));
          }),
    );
  }
}
