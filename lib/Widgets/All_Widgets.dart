import 'package:flutter/material.dart';
import 'package:hello_world/Pages/AuthedPages/userProfile.dart';
import 'package:hello_world/main.dart';
import 'package:hello_world/services/apiService.dart';
import 'package:hello_world/library/Utility.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:hello_world/Pages/AuthedPages/allAuthedPages.dart';
import 'package:flutter_map/flutter_map.dart';

Widget buildStandardFutureBuilder(futureEntity, failText, childWidget) {
  return FutureBuilder<List<dynamic>>(
    future: futureEntity,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text(failText));
      } else {
        return Expanded(child: childWidget(snapshot));
      }
    },
  );
}

Widget buildStandardTitleText(String titleText) {
  return Text(titleText,
      style: TextStyle(
          color: Colors.green, fontSize: 50, fontWeight: FontWeight.bold));
}

Widget buildStandardSubtitleText(String titleText) {
  return Text(titleText,
      style: TextStyle(
          color: Colors.green, fontSize: 30, fontWeight: FontWeight.bold));
}

Widget buildStandardGardenList(snapshot, userID) {
  return ListView.builder(
    itemCount: snapshot.data!.length,
    itemBuilder: (context, index) {
      final garden = snapshot.data![index];
      final name = garden['name'] ?? 'No Name.';
      final bio = garden['bio'] ?? 'No Bio.';
      final lat = garden['latitude'] ?? 'No Bio.';
      final long = garden['longitude'] ?? 'No Bio.';
      return ListTile(
        onTap: () {
          Provider.of<gardenProvider>(context, listen: false).setGarden(Garden(
              name: name, Long: long, Lat: lat, bio: bio, ownerID: userID));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GardenProfile()),
          );
        },
        title: Text(name), // Show username
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Description: $bio')],
        ),
      );
    },
  );
}

Widget buildStandardContainer(
    BuildContext context, Color backgroundColor, Widget Internal) {
  return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Internal);
}

Flexible buildElevatedButtonLink(
    BuildContext context, Widget DestinationPage, String ButtonLabel) {
  Size screenSize = MediaQuery.of(context).size;
  return Flexible(
      child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      fixedSize: Size(350, 50),
      side: BorderSide(
        color: Colors.green,
        width: 0,
      ),
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DestinationPage),
      );
    },
    child: Text(
      ButtonLabel,
      style: TextStyle(color: Colors.white, fontSize: 30),
    ),
  ));
}

Flexible buildIconButtonLink(BuildContext context, Widget DestinationPage,
    String ButtonLabel, IconData icon, String TooltipMessage) {
  Size screenSize = MediaQuery.of(context).size;

  return Flexible(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            maximumSize: screenSize / 4,
            side: BorderSide(
              color: Colors.black, // Border color
              width: 1.0, // Border width
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DestinationPage),
            );
          },
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Tooltip(
              message: TooltipMessage,
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            Text(
              ButtonLabel,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ])));
}

Marker buildGardenMarker(double Latitude, double Longitude) {
  return Marker(
    point: LatLng(Latitude, Longitude),
    width: 64,
    height: 64,
    alignment: Alignment.topCenter,
    child: Icon(Icons.location_pin, size: 40, color: Colors.green),
  );
}

Marker buildTempGardenMarker(double Latitude, double Longitude) {
  return Marker(
    key: const ValueKey("TempFlag"),
    point: LatLng(Latitude, Longitude),
    width: 64,
    height: 64,
    alignment: Alignment.topCenter,
    child: Icon(Icons.location_pin, size: 40, color: Colors.green),
  );
}

gardenMarkerHolder buildGardenMarkerHolder(
    double Latitude, double Longitude, String name, String bio, int ownerID) {
  Garden garden = Garden(
      Lat: Latitude, Long: Longitude, name: name, bio: bio, ownerID: ownerID);

  Marker marker = Marker(
    point: LatLng(Latitude, Longitude),
    width: 64,
    height: 64,
    alignment: Alignment.topCenter,
    child: Icon(Icons.location_pin, size: 40, color: Colors.green),
  );

  return (gardenMarkerHolder(garden: garden, marker: marker));
}

Marker buildDynamicGardenMarker(double Latitude, double Longitude) {
  return Marker(
    point: LatLng(Latitude, Longitude),
    width: 64,
    height: 64,
    alignment: Alignment.topCenter,
    child: Icon(Icons.location_pin, size: 40, color: Colors.green),
  );
}

Image BuildStandardLogo(BuildContext context) {
  return Image.asset("../assets/logo.png", height: 200);
}

AppBar buildStandardAppBar(BuildContext context) {
  return AppBar(
    title: Row(children: [
      GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.green, BlendMode.multiply),
            child: Image.asset("../assets/logo.jpg", height: 60),
          )),
      //Image.asset("../assets/logo.png", height: 40),
      GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: const Text(
            'GardenGram',
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          )),
    ]),
    backgroundColor: Colors.green,
    automaticallyImplyLeading: false,
  );
}

BottomAppBar buildStandardBottomAppBar(BuildContext context) {
  return BottomAppBar(
    color: Colors.green,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildIconButtonLink(
            context, LoggedInHomePage(), "Home", Icons.home, "Homepage"),
        buildIconButtonLink(context, GeoPage(), "Map", Icons.map_outlined,
            "Map of all Gardens"),
        buildIconButtonLink(context, weatherPage(), "Weather",
            Icons.thunderstorm, "View current weather"),
        buildIconButtonLink(context, GardenListScreen(), 'My Gardens',
            Icons.energy_savings_leaf, "See my gardens"),
        buildIconButtonLink(context, plantInfoScreen(), "Almanac", Icons.book,
            "View the almanac."),
        //buildElevatedButtonLink(context, CreateGardenScreen(), "Gardens"),
      ],
    ),
  );
}

buildAuthedAppBar(BuildContext context) {
  ApiService apiService = ApiService();
  final currentUser = Provider.of<UserProvider>(context).getUser();
  final currentName = currentUser?.getName();

  String getLogoutText(currentName) {
    if (currentName == null) {
      return ('Main Menu');
    }
    return ('Logged in as $currentName... Log out?');
  }

  return AppBar(
    title: Flexible(
        child: Row(children: [
      GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoggedInHomePage()),
            );
          },
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.green, BlendMode.multiply),
            child: Image.asset("../assets/logo.jpg", height: 60),
          )),
      GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoggedInHomePage()),
            );
          },
          child: const Text(
            'GardenGram',
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          )),
      const SizedBox(width: 20),
      buildIconButtonLink(
          context, LoggedInHomePage(), "Home", Icons.home, "Homepage"),
      buildIconButtonLink(
          context, GeoPage(), "Map", Icons.map_outlined, "Map of all Gardens"),
      buildIconButtonLink(context, GardenListScreen(), 'My Gardens',
          Icons.energy_savings_leaf, "See my gardens"),
      buildIconButtonLink(context, plantInfoScreen(), "Almanac", Icons.book,
          "View the almanac."),
      buildIconButtonLink(context, UserProfileScreen(), "My Profile", Icons.face,
          "View and edit your profile.")
    ])),
    backgroundColor: Colors.green,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(15), // Rounded bottom
    )),
    automaticallyImplyLeading: false,
    actions: <Widget>[
      TextButton(
          onPressed: () async {
            try {
              final response = await apiService.fetchLogOut();
              Provider.of<UserProvider>(context, listen: false)
                  .clearUserStatus();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Failed to Log Out, Please wait a few seconds and retry : $e'),
                  duration:
                      Duration(seconds: 2), // Adjust the duration as needed
                ),
              );
            }
          },
          child: Text(
            getLogoutText(currentName),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )),
    ],
  );
}
