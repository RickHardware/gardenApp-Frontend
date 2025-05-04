//Basic User Class to allow persistent login.
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

class User {
  final String username;
  final  userID;
  User({required this.username, required this.userID});

  String getName() {
    return username;
  }

  int getuserID() {
    return userID;
  }
}



class Garden {
  final String name;
  final double Long;
  final double Lat;
  final String bio;
  final int ownerID;

  Garden({required this.name, required this.Long, required this.Lat, required this.bio, required this.ownerID});
  String getName() {
    return name;
  }
  double getLat() {
    return Lat;
  }
  double getLong() {
    return Long;
  }

  String getBio() {
    return bio;
  }
  int getOwner() {
    return ownerID;
  }



  factory Garden.fromJson(Map<String, dynamic> json)  {
    return Garden(Long: json['longitude'], Lat : json['latitude'], name: json['name'], bio : json['bio'], ownerID : json['ownerID']);
  }
}

class gardenMarkerHolder {
  final Marker marker;
  final Garden garden;
  gardenMarkerHolder({required this.marker, required this.garden});

  Marker getMarker() {
    return marker;
  }
  Garden getGarden() {
    return garden;
  }
}




class UserProvider with ChangeNotifier{
  User? currentUser;

  User? getUser() {
    return(currentUser);
  }

  void setUser(User newUser) {
    currentUser = newUser;
  }

  void clearUserStatus() {
    currentUser = null;
  }

}


class gardenProvider with ChangeNotifier{
  Garden? selectedGarden;
  double? lat;
  double? long;
  Garden? getGarden() {
    return(selectedGarden);
  }


  void setGarden(Garden newGarden) {
    selectedGarden = newGarden;
    notifyListeners();
  }

  void clearUserStatus() {
    selectedGarden = null;
  }

}