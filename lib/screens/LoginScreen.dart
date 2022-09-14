import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/MainPage.dart';
import 'package:saucify/screens/TopTracksScreen.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  dynamic refreshToken = null;
  spotifyService service = locator<spotifyService>();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    getPreferences();
  }

  getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      refreshToken = prefs.getString('refreshToken');
    });
    if (refreshToken != null) {
      await service.signIn();
      Navigator.of(context).pushAndRemoveUntil(PageRouteBuilder(
        pageBuilder: (c, a1, a2) => MainPage(),
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 150),
      ), (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 19, 19, 19),
        padding: const EdgeInsets.all(10.0),
        child: 
          refreshToken == null ? ListView(
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
                  await service.logIn();
                  if (service.isLoggedIn()){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainPage()));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 29, 29, 29),
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
          ) : 
          Container(
            color: Color.fromARGB(255, 19, 19, 19),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Saucify', 
                    style: GoogleFonts.getFont(
                      'Montserrat', 
                      fontWeight: FontWeight.w700, 
                      fontStyle: FontStyle.italic,
                      fontSize: 40,
                      color: Colors.green
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                  SpinKitWave(
                    color: Colors.green,
                    size: 30.0,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                  Text(
                    'Syncing statistics...',
                    style: GoogleFonts.getFont(
                    'Montserrat', 
                    fontWeight: FontWeight.w500, 
                    fontSize: 20,
                    color: Colors.grey
                    )
                  ),
                ] 
              )
            )
          ),
      )
    );
  }
}