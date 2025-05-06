import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:hello_world/library/Utility.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hello_world/main.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hello_world/library/Utility.dart';
import 'package:weather/weather.dart';
import '../../services/apiService.dart';

class GeoPage extends StatefulWidget {
  @override
  GeoPageState createState() => GeoPageState();
}

class GeoPageState extends State<GeoPage> {
  ApiService apiService = ApiService();

  late Future<List<Garden>> ExistingGardens;
  //Centre on belfast
  LatLng Centering = LatLng(54.607868, -5.926437);

  //LatLong variable for clicked point
  LatLng? NewGardenLatLng;

  //Have to initialise these - choose invalid coords to ensure no matching
  double NewLat = 77;
  double NewLong = 77;

  //Dummy markers

  //Variable to check if a marker has been added (Avoids loads of markers being added)
  bool NewMarkerAdded = false;

  //Have to define a popup controller object
  PopupController popupController = PopupController();
  List<Marker> MarkerList = [];
  //Prepare weather object
  String cityName = "Belfast";
  WeatherFactory wf = new WeatherFactory("8c4431682b329e67209d84d549d16186");

  Future<List<dynamic>> fetchGardenInfoByLatLng(lat, long) async {
    const String apiUrl = 'http://127.0.0.1:8000/api/gardensearch/';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json
            .encode({'latitude': lat.toString(), 'longitude': long.toString()}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ([data['name'], data['bio'], data['ownerID']]);
      } else {
        throw Exception('Failed to load gardens');
      }
    } catch (e) {
      throw Exception('Failed to load gardens: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserID =
        Provider.of<UserProvider>(context, listen: false).getUser()?.getName();
    return Scaffold(
        appBar: buildAuthedAppBar(context),
        body: FutureBuilder<List<Marker>>(
            future: apiService.fetchGardenMarkers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print("loading");
                return Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                print("fail");
                //return Center(child: Text("No gardens available"));
              }
              //Fill MarkerList with all markers returned from database
              MarkerList.addAll(snapshot.data!);

              // }
              return Column(children: [
                SizedBox(height: 10),
                Expanded(
                    child: Stack(children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          onTap: (tapPosition, point) {
                            //ensure all previous popups are gone
                            popupController.hideAllPopups();
                            setState(() {
                              NewGardenLatLng = point;
                              NewLat = NewGardenLatLng!.latitude;
                              NewLong = NewGardenLatLng!.longitude;

                              //Check if a click has happened.
                              if (NewGardenLatLng?.longitude != null) {
                                //Check if a preexisting preview garden is in place
                                if (NewMarkerAdded) {
                                  //If so, remove the previous preview.
                                  MarkerList.removeWhere((marker) =>
                                      marker.key == ValueKey("TempFlag"));
                                }
                                //Add new garden marker
                                MarkerList.add(buildTempGardenMarker(
                                    NewGardenLatLng!.latitude,
                                    NewGardenLatLng!.longitude));
                                //Centre on new marker
                                Centering = LatLng(NewGardenLatLng!.latitude,
                                    NewGardenLatLng!.longitude);

                                NewMarkerAdded = true;
                              }
                            });
                          },
                          initialCenter: Centering,
                          initialZoom: 13.0,
                        ),
                        children: [
                          //Load in OSM tile
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          CurrentLocationLayer(),
                          PopupMarkerLayer(
                              options: PopupMarkerLayerOptions(
                            markers: MarkerList,
                            popupController: popupController,
                            popupDisplayOptions: PopupDisplayOptions(
                                builder: (BuildContext context, Marker marker) {
                              //Checks whether the pin chosen is a new pin or a pre existing garden.
                              if (marker.point.latitude.toDouble() == NewLat &&
                                  marker.point.longitude.toDouble() ==
                                      NewLong) {
                                //If pin is new, save the variables into the provider and link to creation page.

                                Garden? newGarden = Garden(
                                    Lat: marker.point.latitude.toDouble(),
                                    Long: marker.point.longitude.toDouble(),
                                    name: "NEWGARDEN",
                                    bio: "default",
                                    ownerID: 999);
                                Provider.of<gardenProvider>(context,
                                        listen: false)
                                    .setGarden(newGarden);

                                return buildElevatedButtonLink(
                                    context,
                                    CreateGardenScreen(),
                                    "Create a garden here!");
                              } else {
                                //return name of garden if preexisting
                                return FutureBuilder(
                                    future: fetchGardenInfoByLatLng(
                                        marker.point.latitude,
                                        marker.point.longitude),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text('Garden Fetch Error'));
                                      } else {
                                        //Positive response
                                        String gardenName = snapshot.data?[0];
                                        String bio = snapshot.data?[1];
                                        int ownerID = snapshot.data?[2];
                                        return Card(
                                          child: GestureDetector(
                                            onTap: () {
                                              //Set provider with garden info to pull into profile page
                                              setState(() {
                                                Provider.of<gardenProvider>(
                                                        context,
                                                        listen: false)
                                                    .setGarden(Garden(
                                                        name: gardenName,
                                                        Long: marker
                                                            .point.longitude,
                                                        Lat: marker
                                                            .point.latitude,
                                                        bio: bio,
                                                        ownerID: ownerID));
                                              });
                                              //Redirect to Profile Page on click

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GardenProfile()),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Garden, $gardenName at'
                                                ': \nLat: ${marker.point.latitude}, \nLon: ${marker.point.longitude}\n Description: $bio',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    });
                              }
                            }),
                          ))
                        ],
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Positioned(
                      bottom: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Consumer<gardenProvider>(
                              builder: (context, gardenProvider, child) {
                            Garden? clickedGarden = gardenProvider.getGarden();
                            String? clickedGardenName =
                                clickedGarden?.getName();
                            if (clickedGarden == null ||
                                clickedGardenName == "NEWGARDEN") {
                              return Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                      child: Text('Select a garden.',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30))));
                            } else {
                              return (Text('Garden: $clickedGardenName',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30)));
                            }
                          }),
                          SizedBox(
                            width: 10,
                          ),
                          //Weather widget
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FutureBuilder<String>(
                                future: getTemp(wf, cityName),
                                builder: (context, snapshot) {
                                  return Text(snapshot.data ?? "",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30));
                                }),
                          ),
                        ],
                      ))
                ]))
              ]);
            }));
  }
}
