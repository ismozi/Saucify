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

class UserListPage extends StatefulWidget {
  String userId;
  bool isFollowers;
  UserListPage(this.userId, this.isFollowers);
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
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
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 20, 20, 20),
        title: widget.isFollowers ? Text("Followers", style: GoogleFonts.getFont('Montserrat', color: Colors.white))
                                  : Text("Following", style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: 
        Container(
          padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
          color: Color.fromARGB(255, 19, 19, 19),
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: !widget.isFollowers ? StreamBuilder(
              stream: dbService.getFollowingSnapshot(widget.userId),
              builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                    return Container();
                }
                List currentUserFollowing = [];
                snapshot.data!.docs.forEach((element) {
                  currentUserFollowing.add(element.id);
                });
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot user = snapshot.data!.docs[index];
                    bool isFollowed = currentUserFollowing.contains(user.id);
                    return SearchItem(user, isFollowed);
                  }
                );
              }
            ) : StreamBuilder(
              stream: dbService.getUserDocumentStream(widget.userId),
              builder:(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                    return Container();
                }
                DocumentSnapshot currentUser = snapshot.data!;
                List currentUserFollowing = currentUser['followers'];
                return ListView.builder(
                  itemCount: currentUserFollowing.length,
                  itemBuilder: (context, index) {
                    String userId = currentUserFollowing[index];
                    return FutureBuilder(
                      future: dbService.getUserDocument(userId),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot1) {
                        if (!snapshot1.hasData) {
                          return Container();
                        } else { 
                          DocumentSnapshot user = snapshot1.data!;
                          bool isFollowed = currentUserFollowing.contains(user.id);
                          return SearchItem(user, isFollowed);
                        }
                      }
                    );
                  }
                );
              }
            )
          )
        ),
      );
  }
}