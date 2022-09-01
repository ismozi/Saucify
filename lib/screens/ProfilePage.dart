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
  double opacityLevel = 0;
  spotifyService service = locator<spotifyService>();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  List targetUserFollowing = [];
  bool isFollowed = false;
  late Future<DocumentSnapshot> userDoc;

  @override
  void initState() {
    super.initState();
    userDoc = dbService.getUserDocument(widget.userId);
    Timer(Duration(milliseconds: 200), () {
      setState(() => opacityLevel = 1);
    });
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
        foregroundColor: Colors.green,
        backgroundColor: Color(0x44000000),
        elevation: 0,
      ) : null,
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: !widget.isCurrentUser || !widget.fromDashboard ? const EdgeInsets.fromLTRB(10, 80, 10, 0)
                                                                : const EdgeInsets.fromLTRB(10, 3, 10, 0),
        color: Color.fromARGB(255, 37, 37, 37),
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
                        return ProfileContainer(user, targetUserFollowing, isFollowed, widget.isCurrentUser, key: ObjectKey(user));
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