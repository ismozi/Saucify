import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/DatabaseService.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';
import '../widgets/ProfileContainer.dart';
import 'LibraryScreen.dart';

class PersonnalProfilePage extends StatefulWidget {
  final userId;
  PersonnalProfilePage(this.userId);
  @override
  State<PersonnalProfilePage> createState() => _PersonnalProfilePageState();
}

class _PersonnalProfilePageState extends State<PersonnalProfilePage> {
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
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
                        return ProfileContainer(user, targetUserFollowing, isFollowed, false, key: ObjectKey(user));
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