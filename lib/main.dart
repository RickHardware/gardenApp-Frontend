import 'package:flutter/material.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:provider/provider.dart';
import 'package:hello_world/library/Necessary.dart';
import 'package:hello_world/services/apiService.dart';

void main() {
  runApp(
    MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (context) => UserProvider(),
  ),
   ChangeNotifierProvider(
        create: (context) => gardenProvider())
  ],
        child: GardenApp()
    ));

}

class GardenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'GardenGram',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Sets background to white globally
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(context),
      body: Center(


        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("../assets/logo.png", height: 200),
            const SizedBox(height: 4),
            const Text(
              'Welcome to GardenGram!',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 50,
                    fontWeight: FontWeight.bold
                )
            ),

            const SizedBox(height: 10),
            buildElevatedButtonLink(context,SecondPage(),'New Gardener'),
            const SizedBox(height: 10),
            buildElevatedButtonLink(context,loginPage(), 'Returning Gardener'),
            const SizedBox(height: 10),
            buildElevatedButtonLink(context,GeoPage(),'Explore Gardens'),
            //const SizedBox(height: 10),
            //buildElevatedButtonLink(context,ThirdPage(),'Returning Gardener'),
            //const SizedBox(height: 10),
            //buildElevatedButtonLink(context,weatherPage(),'Weather'),
            //const SizedBox(height: 10),
            //buildElevatedButtonLink(context,UserListScreen(),'User List'),
            //const SizedBox(height: 10),
            //buildElevatedButtonLink(context,Gardencreator(),'Add a garden'),
            //const SizedBox(height: 10),
            //buildElevatedButtonLink(context,GardenListScreen(), 'View all gardens'),
            //const SizedBox(height: 10),
            //buildElevatedButtonLink(context,plantInfoScreen(), 'View plant info'),
            //const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
