import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/MainPage.dart';
import 'package:saucify/screens/TopTracksScreen.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/services/spotifyService.dart';

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 29, 29, 29),
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Container(
              height: 60,
            ),
            Center(
              child: Text(
                'Saucify', 
                style: GoogleFonts.getFont(
                  'Montserrat', 
                  fontWeight: FontWeight.w700, 
                  fontStyle: FontStyle.italic,
                  fontSize: 40,
                  color: Colors.green
                )
              )
            ),
            Container(
              height: 40,
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {
                spotifyService service = locator<spotifyService>();
                await service.logIn();
                if (service.isLoggedIn()){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainPage()));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 41, 41, 41),
                  borderRadius: BorderRadius.circular(12)
                ),
                padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                child: Text(
                  'Login',
                  style: GoogleFonts.getFont(
                  'Montserrat', 
                  fontWeight: FontWeight.w700, 
                  fontSize: 30,
                  color: Colors.white
                  )
                ),
              )
            )
          ]
        )
      )
    );
  }
}