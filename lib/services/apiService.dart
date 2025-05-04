import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hello_world/library/Utility.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:http/http.dart' as http;
import '../Widgets/All_Widgets.dart';






Future<String> getTemp(WeatherFactory wf, cityName) async {
  Weather weather = await wf.currentWeatherByCityName(cityName);
  String temp = weather.temperature?.celsius?.toString() ?? "";
  return(TempComment(temp));
}

String TempComment(String temp) {
  int dotIndex = temp.indexOf('.');
  print(temp);
  print(dotIndex);
  temp = temp.substring(0,dotIndex+1);
  print(temp);
  double  tempInt = double.parse(temp);
  String comment = '';

  if (tempInt<5) {
    comment =
    'It\'s only $temp °C outside, consider leaving the gardening for a warmer day!';
  } else if (tempInt < 25) {
    comment = 'It\'s $temp °C outside, a perfect day for some gardening!';
  } else if(tempInt >= 25) {
    comment =
    'It\'s $temp °C outside, consider leaving the gardening for a cooler day!';
  }
  return(comment);
}



Future<String> getWeather(WeatherFactory wf, cityName) async {
  Weather weather = await wf.currentWeatherByCityName(cityName);
  String temp = weather.toString() ?? "";

  return temp;
}


Future<String> recommendPlant(WeatherFactory wf, cityName) async {
  String Prompt = "";
  Weather weather = await wf.currentWeatherByCityName(cityName);
  String? PlaceName = weather.areaName;
  DateTime? Date = weather.date;
  String DateString = Date.toString();
  Prompt = Prompt + "Recommend a plant to grow in: " + PlaceName!;
  Prompt = Prompt + " at this time of year: " + DateString!;
  Prompt = Prompt + "Keep Responses to 100 characters or less.  Keep response in plain text with no unusual formatting. Give information about how to plant it.";
  Prompt = Prompt + "Keep response as a single paragraph..Include a comment on the time of year, the weather and the location.";
  String response = await askLLM(Prompt);
  return(response);
}

Future<String> askPlantQuestion(String plantName) async {
  return(askLLM("Give me general gardening information about how to plant $plantName.  Keep response less than 100 characters."));
  }



Future<String> askLLM(String message) async  {
  const String apiUrl = 'http://127.0.0.1:8000/api/chat/';
  //Sanitise message.
  String ResponseGuidance = "Respond to the next question in a single paragraph in less than 50 characters.";
  String newmessage = "$ResponseGuidance  $message";
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "query" : message
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Response data: $data");
      return data['response'];
    } else {
      return 'Error: ${response.statusCode}\n${response.body}';
    }
  } catch (e) {
    return 'Error: $e';
  }
}


class ApiService {
  Future<List<dynamic>> fetchPlantInfo() async {
    const String apiUrl = 'http://127.0.0.1:8000/api/plants/';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (e) {
      throw Exception('Failed to load plants: $e');
    }
  }





  Future<String> fetchLogOut() async {
    const String apiUrl = 'http://127.0.0.1:8000/api/logout/';
    try {
      final response = await http.post(Uri.parse(apiUrl));
      final data = jsonDecode(response.body);
      return (data['message']);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to logout');
      }
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<List<dynamic>> fetchLoginStatus() async {
    const String apiUrl = 'http://127.0.0.1:8000/api/loginStatus/';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to authenticate');
      }
    } catch (e) {
      throw Exception('Failed to authenticate: $e');
    }
  }

  Future<List<dynamic>> fetchUsers() async {
    const String apiUrl = 'http://127.0.0.1:8000/api/';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(int ID) async {
    const String apiUrl = 'http://127.0.0.1:8000/api/userprofile/';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "ID" : ID
        }),
      );
            if (response.statusCode == 200) {
              return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }




  Future<String> fetchUserName(int userID) async {
    String apiUrl = 'http://127.0.0.1:8000/api/user/$userID';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final username = data['username'];

        return username;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }





  Future<List<Map<String, String>>> fetchMessages(gardenID) async {
    String apiUrl = 'http://127.0.0.1:8000/api/msg/get/$gardenID/';
    print(apiUrl);
    try {
      print("in");
      final response = await http.get(Uri.parse(apiUrl));
      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        List<Map<String, String>> messageList = jsonData.map((msg) => {
          "date_sent": msg["date_sent"].toString(),
          "gardenID": msg["gardenID"].toString(),
          "senderID": msg["senderID"].toString(),
          "body": msg["body"].toString(),
        }).toList();

        for(var msg in messageList) {
          int senderID = int.parse(msg["senderID"]!);
          print("senderiD is $senderID");
          msg["senderUsername"] = await fetchUserName(senderID);
          };

        return messageList;
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }




  Future<List<dynamic>> fetchUserGardens(String username) async {
    String apiUrl = 'http://127.0.0.1:8000/api/gardenlist/$username';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data

        List<dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to load gardens');
      }
    } catch (e) {
      throw Exception('Failed to load gardens: $e');
    }
  }

  Future<List<dynamic>> fetchUserFollowedGardens(int userID) async {
    String apiUrl = 'http://127.0.0.1:8000/api/user/followed/$userID';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data

        List<dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to load gardens');
      }
    } catch (e) {
      throw Exception('Failed to load gardens: $e');
    }
  }






  Future<List<Garden>> fetchGarden() async {
    const String apiUrl = 'http://127.0.0.1:8000/api/garden/';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print("yoohoo");
        // If the server returns a 200 OK response, parse the data

        List<dynamic> responseData = json.decode(response.body);
        print("HE");
        return responseData.map((json) => Garden.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load gardens');
      }
    } catch (e) {
      throw Exception('Failed to load gardens: $e');
    }
  }



  Future<List<Marker>> fetchGardenMarkers() async {
    try {
      print("a");
      List<Garden> data = await fetchGarden();
      print("b");
      List<Marker> MarkerList = data.map((garden) {
        return (buildGardenMarker(garden.getLat(), garden.getLong()));
      }).toList();
      print("c");
      print(MarkerList);
      return (MarkerList);
    } catch (e) {
      print(e);
      return [];
    }
  }


Future<List<gardenMarkerHolder>> fetchGardenMarkerHolders() async {
  try {
    List<Garden> gardenList = await fetchGarden();
    List<Marker> markerList = await fetchGardenMarkers();
    int length = markerList.length;
    List<gardenMarkerHolder> gardenMarkerHolderlist = [];
    for (int i = 0 ; i < length ; i++) {
      gardenMarkerHolderlist.add(gardenMarkerHolder(marker: markerList[i], garden: gardenList[i]));
    }
    return(gardenMarkerHolderlist);
  }
  catch(e) {
    return [];
  }
}
}
