import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/MainPage.dart';
import 'package:saucify/screens/TopTracksScreen.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:saucify/widgets/searchItem.dart';

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class CommentsPage extends StatefulWidget {
  CommentsPage();
  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  TextEditingController controller = TextEditingController();
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  String searchQuery = "";
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  List userFollowing = [];

  @override
  void initState() {
    super.initState();
    getUserFollowing();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  getUserFollowing() async {
    userFollowing = await dbService.getFollowing(service.userId);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.green,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.black.withOpacity(1.0),
                              Colors.black.withOpacity(1.0), 
                              Colors.black.withOpacity(1.0),
                              Colors.black.withOpacity(0.0)]),
          ),
        ),
        title: Text("Comments", style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
        color: Color.fromARGB(255, 10, 10, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 19, 19, 19),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Share your tought!',
                  hintStyle: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 185, 185, 185), fontWeight: FontWeight.w300, fontSize: 14.5),
                  border: InputBorder.none
                ),
                style: TextStyle(color: Colors.white),
              )
            ),
          ]
        )
      ),
    );
  }
}