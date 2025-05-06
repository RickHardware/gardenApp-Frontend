import 'package:flutter/material.dart';
import 'package:hello_world/services/apiService.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:provider/provider.dart';

import '../../library/Utility.dart';


class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> user_;
  late int userID;
  late String currentName;

  @override
  void initState() {
    super.initState();
    final currentUser =
    Provider.of<UserProvider>(context, listen: false).getUser();
    if (currentUser != null) {
      currentName = currentUser.getName();
      userID = currentUser.getuserID();
    } else {
      currentName = "";
      userID = 1000000000;
    }
    user_ = apiService.fetchUserProfile(userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAuthedAppBar(context),
      bottomNavigationBar: buildStandardBottomAppBar(context),
      body: FutureBuilder<Map<String, dynamic>>(
        future: user_,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user found.'));
          } else {
            final user = snapshot.data!;
            final name = user['username'] ?? 'No Name';
            final email = user['email'] ?? 'No Email';
            final datejoined = user['date_joined'] ?? 'No Email';
//Simple user info tile
            return ListTile(
              title: Text("Username: $name"),
              subtitle: Text("Email : $email   \n Member since: $datejoined "
                  ),
            );
          }
        },
      )
    );
  }
}
