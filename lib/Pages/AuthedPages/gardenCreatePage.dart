import 'package:flutter/material.dart';
import '../../library/Utility.dart';
import '../../services/apiService.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:provider/provider.dart';


class CreateGardenScreen extends StatefulWidget {
  @override
  _CreateGardenScreenState createState() => _CreateGardenScreenState();
}

class _CreateGardenScreenState extends State<CreateGardenScreen> {
  //Instantiate Tetxt controllers for capturing user input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  //Set API target URL
  final String baseUrl = 'http://127.0.0.1:8000/api/postGarden/';
  //Instantiate API service for use
  ApiService apiService = ApiService();


  //Function to call API given information in text boxes
  Future<void> createGarden(Garden chosenGarden, String username) async {
    try {
      //Get current user from state of page
      final currentUser = Provider.of<UserProvider>(context,listen: false).getUser();
      String? username = currentUser?.getName();
      //Attempt post
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text,
          'latitude': chosenGarden.getLat(),
          'longitude': chosenGarden.getLong(),
          'bio' : bioController.text,
          'ownerID' : username

        }),
      );
      //Good response
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Garden created successfully!')),
        );
        //Redirect to map
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => GeoPage()));
      } else {
        //Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create garden: ${response.statusCode}')),
        );
      }
    }
    catch (e) {
      //Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    //Controllers should be disposed when not in use
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAuthedAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create a Garden!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Garden Name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Add a bio:',
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed :  () async {
                  //Set garden to the garden held in the provider
                  Garden? chosenGarden = Provider.of<gardenProvider>(context,listen: false).getGarden();
                  final currentUser = Provider.of<UserProvider>(context,listen: false).getUser();
                  final currentName = currentUser?.getName();
                  //Call create garden function with the garden object and the user
                  createGarden(chosenGarden!, currentName!);
                  },
                child: Text('Create Garden'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green,),
              ),

            ],
          ),
        ),
      ),
    );
  }
}