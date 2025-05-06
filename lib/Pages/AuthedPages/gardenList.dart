import 'package:flutter/material.dart';
import 'package:hello_world/services/apiService.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:provider/provider.dart';
import '../../library/Utility.dart';

class GardenListScreen extends StatefulWidget {
  @override
  _GardenListScreenState createState() => _GardenListScreenState();
}

class _GardenListScreenState extends State<GardenListScreen> {
  //Define all necessary variables.
  late int userID;
  late String currentName;
  late Future<List<dynamic>> gardens;
  late Future<List<dynamic>> followedGardens;
  late Future<List<dynamic>> users;

  @override
  void initState() {
    super.initState();
    final currentUser = Provider.of<UserProvider>(context, listen: false).getUser();
    if (currentUser != null) {
      currentName = currentUser.getName();
      userID = currentUser.getuserID();
    } else {
      currentName = "";
      userID = 1000000000;
    }
    ApiService apiService = ApiService();
    //Get required lists of gardens for display
    gardens = apiService.fetchUserGardens(currentName!);
    followedGardens = apiService.fetchUserFollowedGardens(userID!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAuthedAppBar(context),
        body:
          Row(children: [
          Flexible(
            child: buildStandardContainer(
                context,
                Colors.white,
                Column(children: [
                  buildStandardTitleText('Gardens you own:'),
                  //Output list of owned gardens, with failure text if none are returned
                  buildStandardFutureBuilder(gardens,'You have not created any gardens yet.', (snapshot) => buildStandardGardenList(snapshot, userID),),
                ]),
                ),
          ),
          Flexible(
              child:
                  buildStandardContainer(context, Colors.white,
                  Column(
                    children: [
                      buildStandardTitleText('Gardens you follow:'),
                      //Outputlist of followed gardens with failure text in none returned
                      buildStandardFutureBuilder(followedGardens,'You have not followed any gardens yet.',(snapshot) => buildStandardGardenList(snapshot, userID),),
                    ],
                  )))
        ]));
  }
}
