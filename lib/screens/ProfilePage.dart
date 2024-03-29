import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/DatabaseService.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';
import '../widgets/ProfileContainer.dart';
import 'LibraryScreen.dart';

class ProfilePage extends StatefulWidget {
  final userId;
  final bool isCurrentUser;
  final bool fromDashboard;
  ProfilePage(this.userId, this.isCurrentUser, this.fromDashboard);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DatabaseService dbService = DatabaseService();
  double opacityLevel = 1;
  spotifyService service = locator<spotifyService>();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  List targetUserFollowing = [];
  bool isFollowed = false;
  late Future<DocumentSnapshot> userDoc;

  @override
  void initState() {
    super.initState();
    userDoc = dbService.getUserDocument(widget.userId);
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: !widget.isCurrentUser || !widget.fromDashboard ? AppBar(
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
        title: Text("Profile", style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ) : null,
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
        color: Color.fromARGB(255, 10, 10, 10),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: StreamBuilder(
            stream: dbService.getFollowingSnapshot(widget.userId),
            builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                  return Container();
              }
              List targetUserFollowing = [];
              snapshot.data!.docs.forEach((element) {
                targetUserFollowing.add(element.id);
              });
              return StreamBuilder(
                stream: dbService.getFollowingSnapshot(service.userId),
                builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
                  if (!snapshot1.hasData) {
                      return Container();
                  }
                  List currentUserFollowing = [];
                  snapshot1.data!.docs.forEach((element) {
                    currentUserFollowing.add(element.id);
                  });
                  bool isFollowed = currentUserFollowing.contains(widget.userId);
                  return StreamBuilder<DocumentSnapshot>(
                    stream: dbService.getUserDocumentStream(widget.userId),
                    builder:(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot2) {
                      if (!snapshot2.hasData) {
                          return Container();
                      } else { 
                        DocumentSnapshot user = snapshot2.data!;
                        return FutureBuilder(
                          future: service.getProfileTracks(user['topTracks']),
                          builder: (BuildContext context, AsyncSnapshot snapshot1) {
                            if (!snapshot1.hasData) {
                              return Container();
                            } else { 
                              Map<String, List> topTracks = snapshot1.data!;
                              return FutureBuilder(
                                future: service.getProfileArtists(user['topArtists']),
                                builder: (BuildContext context, AsyncSnapshot snapshot1) {
                                  if (!snapshot1.hasData) {
                                    return Container();
                                  } else { 
                                    Map<String, List> topArtists = snapshot1.data!;
                                    return ProfileContainer(user['topTracks'], user['topArtists'], topTracks, topArtists, user, targetUserFollowing, isFollowed, widget.isCurrentUser, key: ObjectKey(user));
                                  }
                                }
                              );
                            }
                          }
                        );
                      }
                    },
                  );
                },
              );
            },
          )
        ),
      )
    );
  }
}