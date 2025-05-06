import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:hello_world/library/Utility.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather/weather.dart';
import '../../services/apiService.dart';

class GuestGeoPage extends StatefulWidget {
  @override
  GuestGeoPageState createState() => GuestGeoPageState();
}

class GuestGeoPageState extends State<GuestGeoPage> {
  ApiService apiService = ApiService();

  late Future<List<Garden>> ExistingGardens;

  //Centre on belfast
  LatLng Centering = LatLng(54.607868, -5.926437);

  //LatLong variable for clicked point
  LatLng? NewGardenLatLng;

  //Have to initialie these - choose invalid coords to ensure no matching
  double NewLat = 77;
  double NewLong = 77;

  //Dummy markers

  //Variable to check if a marker has been added (Avoids loads of markers being added)
  bool NewMarkerAdded = false;

  //Have to define a popup controller object
  PopupController popupController = PopupController();
  List<Marker> MarkerList = [];

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
        appBar: buildStandardAppBar(context),
        body: FutureBuilder<List<Marker>>(
            future: apiService.fetchGardenMarkers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {}
              MarkerList.addAll(snapshot.data!);

              // }
              return Column(children: [
                SizedBox(height: 5),
                Expanded(
                    child: Stack(
                  children: [
                    Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: Centering,
                            initialZoom: 13.0,
                          ),
                          children: [
                            //Build Map
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
                              popupDisplayOptions: PopupDisplayOptions(builder:
                                  (BuildContext context, Marker marker) {
                                //Checks if selected pin is a new garden or existing
                                if (marker.point.latitude.toDouble() ==
                                        NewLat &&
                                    marker.point.longitude.toDouble() ==
                                        NewLong) {
                                  Garden? newGarden = Garden(
                                      Lat: marker.point.latitude.toDouble(),
                                      Long: marker.point.longitude.toDouble(),
                                      name: "NEWGARDEN",
                                      bio: "default",
                                      ownerID: 999);
                                  Provider.of<gardenProvider>(context,
                                          listen: false)
                                      .setGarden(newGarden);
                                  //Return link to create garden if new area selected
                                  return buildElevatedButtonLink(
                                      context,
                                      CreateGardenScreen(),
                                      "Create a garden here!");
                                } else {
                                  return FutureBuilder(
                                      future: fetchGardenInfoByLatLng(
                                          marker.point.latitude,
                                          marker.point.longitude),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                              child:
                                                  Text('Garden Fetch Error'));
                                        } else {
                                          String gardenName = snapshot.data?[0];
                                          String bio = snapshot.data?[1];
                                          int ownerID = snapshot.data?[2];

                                          return Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '$gardenName'
                                                ': Bio: $bio',
                                                textAlign: TextAlign.center,
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
                    Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
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
                        ))
                  ],
                )),
                SizedBox(
                  height: 5,
                ),
              ]);
            }));
  }
}
