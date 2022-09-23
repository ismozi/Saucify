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

class SearchPage1 extends StatefulWidget {
  @override
  State<SearchPage1> createState() => _SearchPage1State();
}

class _SearchPage1State extends State<SearchPage1> {
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
      resizeToAvoidBottomInset: false,
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          autofocus: true,
          onChanged: (text) {
            setState(() {
              searchQuery = text;
            });
          },
        )
      ),
      body: 
        Container(
          padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
          color: Color.fromARGB(255, 10, 10, 10),
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: StreamBuilder(
              stream: dbService.getFollowingSnapshot(service.userId),
              builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
                if (!snapshot1.hasData) {
                    return Container();
                }
                List currentUserFollowing = [];
                snapshot1.data!.docs.forEach((element) {
                  currentUserFollowing.add(element.id);
                });
                return StreamBuilder(
                  stream: dbService.getSearchStream(searchQuery),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    } else { 
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 100, color: Colors.grey),
                              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                              Text('Search for users',
                                style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontSize: 22)),
                            ]
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot user = snapshot.data!.docs[index];
                          bool isFollowed = currentUserFollowing.contains(user.id);
                          return SearchItem(user, isFollowed);
                        }
                      );
                    }
                  }
                );
              }
            )
          )
        ),
      );
  }
}