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

class MessagesPage extends StatefulWidget {
  MessagesPage();
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  TextEditingController controller = TextEditingController();
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  String searchQuery = "";
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  List userFollowing = [];
  double opacityLevel = 0;

  @override
  void initState() {
    super.initState();
    getUserFollowing();
    Timer(Duration(milliseconds: 150), () {
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
    userFollowing = await dbService.getFollowing(service.userId);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: 
        Container(
          padding: const EdgeInsets.fromLTRB(10, 80, 10, 0),
          color: Color.fromARGB(255, 10, 10, 10),
          width: MediaQuery.of(context).size.width,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: opacityLevel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                    width: MediaQuery.of(context).size.width*0.85,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 21, 21, 21),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: Colors.green),
                          border: InputBorder.none
                        ),
                        controller: controller,
                        style: TextStyle(color: Colors.white),
                        onChanged: (text) {
                          setState(() {
                          });
                        },
                      ),
                    )
                  )
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text('Chat with friends', style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 199, 199, 199), fontSize: 22, fontWeight: FontWeight.w500))
                ),
                StreamBuilder(
                  stream: dbService.getFollowingSnapshot(service.userId),
                  builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                        return Container();
                    }
                    List currentUserFollowing = [];
                    snapshot.data!.docs.forEach((element) {
                      currentUserFollowing.add(element.id);
                    });
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot user = snapshot.data!.docs[index];
                        return Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image(image: user['imageUrl'] != null ? NetworkImage(user['imageUrl']): emptyImage, width: 50, height: 50)
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(user['username'], style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 167, 167, 167), fontSize: 15, fontWeight: FontWeight.w500))
                                  ]
                                )
                              )
                            ]
                          )
                        );
                      }
                    );
                  }
                )
              ]
            )
          )
        ),
      );
  }
}