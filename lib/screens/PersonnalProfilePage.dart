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
    getUserFollowing();
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

  getUserFollowing() async {
    List currentUserFollowing = await dbService.getFollowing(service.userId);
    isFollowed = currentUserFollowing.contains(widget.userId);
    targetUserFollowing = await dbService.getFollowing(widget.userId);
  }

  refresh() async {
    await getUserFollowing();
    setState(() {
      userDoc = dbService.getUserDocument(widget.userId);
    });
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
          child: FutureBuilder<DocumentSnapshot>(
            future: userDoc,
            builder:(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                  return Container();
              } else { 
                DocumentSnapshot user = snapshot.data!;
                return ProfileContainer(user, targetUserFollowing, isFollowed, refresh, key: ObjectKey(user));
              }
            },
          )
        ),
      )
    );
  }
}