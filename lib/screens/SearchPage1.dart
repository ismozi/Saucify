import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/MainPage.dart';
import 'package:saucify/screens/ProfilePage.dart';
import 'package:saucify/screens/TopTracksScreen.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class SearchPage1 extends StatefulWidget {
  @override
  State<SearchPage1> createState() => _SearchPage1State();
}

class _SearchPage1State extends State<SearchPage1> {
  TextEditingController controller = TextEditingController();
  DatabaseService dbService = DatabaseService();
  String searchQuery = "";
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');


  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 20, 20, 20),
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
          color: Color.fromARGB(255, 37, 37, 37),
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: new StreamBuilder(
              stream: dbService.getSearchStream(searchQuery),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else { 
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot user = snapshot.data!.docs[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 29, 29, 29),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        margin: const EdgeInsets.all(3.0),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image(image: user['imageUrl'] != null ? NetworkImage(user['imageUrl']): emptyImage, width: 40, height: 40)
                          ),
                          trailing: IconButton(
                            color: Colors.grey,
                            icon: Icon(Icons.person_add, color: Colors.grey), 
                            onPressed: (() => {

                            })
                          ),
                          title: Text(user['username'], 
                                      style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                          onTap: () => {
                            Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => ProfilePage(user['username']),
                              transitionsBuilder: (c, anim, a2, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset(0.0, 0.0);
                                final tween = Tween(begin: begin, end: end);
                                final offsetAnimation = anim.drive(tween);
                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                              transitionDuration: Duration(milliseconds: 100),
                            ))
                          },
                        )
                      );
                    }
                  );
                }
              }
            )
          )
        ),
      );
  }
}