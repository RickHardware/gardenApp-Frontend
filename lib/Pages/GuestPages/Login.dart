import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:provider/provider.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:hello_world/library/Utility.dart';

class loginPage extends StatefulWidget {
  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  //Attempts user login
  Future<List<dynamic>> fetchLogin() async {
    String baseUrl = ("http://127.0.0.1:8000/api/login/");
    List responseList = [];
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text
        }),
      );
      //Early attempt at decoding JSON responses could be refactored
      final data = jsonDecode(response.body);
      String message = data['message'];
      String user = data['user'];
      int userID = data['userID'];
      responseList.add('message');
      responseList.add(user);
      responseList.add(userID);
      return (responseList);
    } catch (e) {
      responseList.add('Error');
      responseList.add(' : Failed to Authenticate!');
      return (responseList);
    }
  }

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
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
                'Please Log in.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    fixedSize: Size(350, 50),
                    side: BorderSide(
                      color: Colors.black, // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  child: Text('Login',
                      style: TextStyle(color: Colors.white, fontSize: 30)),
                  onPressed: () async {
                    final result = await fetchLogin();
                    final User currentUser = User(
                        username: result[1],
                        userID: result[2]); //, userID: result[2]);
                    Provider.of<UserProvider>(context, listen: false)
                        .setUser(currentUser);

                    if (result[0] == 'Error') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text((result[0] + result[1])),
                          duration: Duration(
                              seconds: 2), // Adjust the duration as needed
                        ),
                      );
                    }
                    ;
                    if (result[0] != 'Error') {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoggedInHomePage()));
                    }
                  }),
              const SizedBox(height: 10),
              buildElevatedButtonLink(
                  context, passReset(), 'Forgotten Password?'),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
