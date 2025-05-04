import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:provider/provider.dart';
import '../../services/apiService.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:hello_world/library/Utility.dart';


class passReset extends StatefulWidget {
  @override
  _passResetState createState() => _passResetState();
}

class _passResetState extends State<passReset> {

  Future<void> passwordReset() async {
    String baseUrl = ("http://127.0.0.1:8000/api/password-reset/");
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': emailController.text
        }),
      );
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    }
  }
  final TextEditingController emailController = TextEditingController();


  @override
  void dispose() {
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
                'Reset Password below:',
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

              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green,),
                child: Text('Send Reset Link'),
                onPressed: () async {
                  final result  = await passwordReset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email link sent to reset password if correct email was supplied.'),
                      duration: Duration(seconds: 2), // Adjust the duration as needed
                    ),
                  );


                  }

              )

            ],
          ),
        ),
      ),
    );
  }
}
