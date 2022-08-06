import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saucify/screens/TopTracksScreen.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 41, 41, 41),
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {
                spotifyService service = locator<spotifyService>();
                await service.logIn();
                if (service.isLoggedIn()){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => LibraryScreen()));
                }
              },
              child: Text('Login'),
            ),
           TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 93, 243, 33)),
              ),
              onPressed: () async {
                LaunchApp.openApp(
                  androidPackageName: 'com.spotify.music'
                );
                LaunchApp.openApp(
                  androidPackageName: 'com.example.saucify'
                );
              },
              child: Text('Open spotify'),
            ),
          ]
        )
      )
    );
  }
}