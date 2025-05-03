import 'package:flutter/material.dart';
import 'package:hello_world/Pages/AllPages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hello_world/Widgets/All_Widgets.dart';
import 'package:http/http.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

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
                'About GardenGram',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'GardenGram is a community focused project which aims to empower gardeners to come together and drive real ecological improvements in their local area.',
                style: TextStyle(
                  //color: Colors.black,
                  fontSize: 20,
                  //fontWeight: FontWeight.bold,
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
