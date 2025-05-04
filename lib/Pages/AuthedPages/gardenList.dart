import 'package:flutter/material.dart';
import 'package:hello_world/services/apiService.dart';
import 'package:hello_world/main.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:provider/provider.dart';
import 'allAuthedPages.dart';
import '../../library/Utility.dart';

class GardenListScreen extends StatefulWidget {
  @override
  _GardenListScreenState createState() => _GardenListScreenState();
}

class _GardenListScreenState extends State<GardenListScreen> {
  late int userID;
  late String currentName;
  late Future<List<dynamic>> gardens;
  late Future<List<dynamic>> followedGardens;
  late Future<List<dynamic>> users;

  @override
  void initState() {
    super.initState();
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).getUser();
    if (currentUser != null) {
      currentName = currentUser.getName();
      userID = currentUser.getuserID();
    } else {
      print("CRITICAL ERROR");
      currentName = "";
      userID = 1000000000;
    }
    ApiService apiService = ApiService();
    gardens = apiService.fetchUserGardens(currentName!);
    followedGardens = apiService.fetchUserFollowedGardens(userID!);
//    users = apiService.fetchUserProfile(userID);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAuthedAppBar(context),
        body: //Column(children : [
        // Row(children: [

        //   FutureBuilder<List<dynamic>>(
        //     future: users,
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return Center(child: CircularProgressIndicator());
        //       } else if (snapshot.hasError) {
        //         return Center(child: Text('Error: ${snapshot.error}'));
        //       } else {
        //         print("LOOK HERE");
        //         print(snapshot.data);

        //         return ListView.builder(
        //           itemCount: snapshot.data!.length,
        //           itemBuilder: (context, index) {
        //             final user = snapshot.data![index];
        //             final name = user['username'] ?? 'No Name.';
        //             final password = user['password'] ?? 'No Password.';
        //             final emailAddress = user['email'] ?? 'No Password.';

        //             return ListTile(
        //               title: Text(name),  // Show username
        //               subtitle: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text('Password: $password'),
        //                   Text('Password: $emailAddress')
        //                 ],
        //               ),
        //             );
        //           },
        //         );
        //       }
        //     },
        //   ),


        // ],),

          Row(children: [
          Flexible(
            child: buildStandardContainer(
                context,
                Colors.white,
                Column(children: [
                  buildStandardTitleText('Gardens you own:'),
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

                      buildStandardFutureBuilder(followedGardens,'You have not followed any gardens yet.',(snapshot) => buildStandardGardenList(snapshot, userID),),
                    ],
                  )))
        ]));
  }
}
