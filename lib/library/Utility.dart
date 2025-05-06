import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

//Basic User Class to allow persistent login.
class User {
//Define Variables
  final String username;
  final userID;

//Assert variables are required in constructor
  User({required this.username, required this.userID});

//Getters
  String getName() {
    return username;
  }

  int getuserID() {
    return userID;
  }
}

//Defined Garden Class
class Garden {
  //Define variables
  final String name;
  final double Long;
  final double Lat;
  final String bio;
  final int ownerID;

//Assert required variables in constructor
  Garden(
      {required this.name,
      required this.Long,
      required this.Lat,
      required this.bio,
      required this.ownerID});

//Getters
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

//Complex constructor - creates a Garden object directly from JSON - not used in the end
  factory Garden.fromJson(Map<String, dynamic> json) {
    return Garden(
        Long: json['longitude'],
        Lat: json['latitude'],
        name: json['name'],
        bio: json['bio'],
        ownerID: json['ownerID']);
  }
}

//Defunct class - prototype for handling garden markers in map component
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

//Allows state management to pass user info between pages
class UserProvider with ChangeNotifier {
  User? currentUser;

  User? getUser() {
    return (currentUser);
  }

  void setUser(User newUser) {
    currentUser = newUser;
  }

  void clearUserStatus() {
    currentUser = null;
  }
}

//Allows state management to pass garden info between pages
class gardenProvider with ChangeNotifier {
  Garden? selectedGarden;
  double? lat;
  double? long;

  Garden? getGarden() {
    return (selectedGarden);
  }

  void setGarden(Garden newGarden) {
    selectedGarden = newGarden;
    notifyListeners();
  }

  void clearUserStatus() {
    selectedGarden = null;
  }
}
