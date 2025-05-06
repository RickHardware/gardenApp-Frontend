import 'package:flutter/material.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:hello_world/Pages/AuthedPages/userProfile.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:hello_world/services/apiService.dart';


class LoggedInHomePage extends StatefulWidget {
  @override
  _LoggedInHomepageState createState() => _LoggedInHomepageState();
  }

  class _LoggedInHomepageState extends State<LoggedInHomePage> {
    ApiService apiService = ApiService();
    @override
    void initState() {
      super.initState();
    }
     @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAuthedAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BuildStandardLogo(context),
            const SizedBox(height: 4),
            buildStandardTitleText('Welcome Gardener'),
            const SizedBox(height: 10),
            buildElevatedButtonLink(context,GeoPage(),'Explore Gardens'),
            const SizedBox(height: 10),
           buildElevatedButtonLink(context,GardenListScreen(),'My Gardens'),
           const SizedBox(height: 10),
            buildElevatedButtonLink(context,plantInfoScreen(), 'Almanac'),
            const SizedBox(height: 10),
            buildElevatedButtonLink(context,UserProfileScreen(), 'My Profile'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
