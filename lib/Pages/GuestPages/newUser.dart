import 'package:flutter/material.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:http/http.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final String baseUrl = 'http://127.0.0.1:8000/api/post/';

  Future<void> createUser() async {
    //Create a Json response from the entered data
    //Try to submit the data to the correct endpoint.
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text
        }),
      );
      //If post request is accepted, give the user feedback and tell them a user has been successfully created.
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created successfully!')),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => loginPage()));
      } else {
        //In the case of a failed user creation, need to decompose the response
        Map<String, dynamic> responseData = jsonDecode(response.body);
        //Retrieve the field name for the error code.
        List<String> fieldNames = responseData.keys.toList();
        //Get the first entry of the first field which will be the serializer errors.
        //Gives a more informative error
        String outText = responseData[fieldNames[0]][0];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create user: $outText')),
        );
      }
    } catch (e) {
      //Possibility for a more complex error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create a User',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: createUser,
                child: Text('Create User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
