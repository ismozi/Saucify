import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/DatabaseService.dart';

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class NotificationsPage extends StatefulWidget {
  final userId;
  NotificationsPage(this.userId);
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  DatabaseService dbService = DatabaseService();
  double opacityLevel = 0;
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');

  @override
  void initState() {
    super.initState();
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
          child: FutureBuilder<DocumentSnapshot>(
            future: dbService.getUserDocument(widget.userId),
            builder:(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                  return Container();
              } else { 
                Map<String, dynamic> user = snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  children: [
                    Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    Container( 
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 27, 27, 27).withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Image(image: user['imageUrl'] != null ? NetworkImage(user['imageUrl']): emptyImage, width: 200, height: 200)
                        )
                      )
                    ),
                    Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    Text(user['username'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w300, fontSize: 35)),
                    Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    Divider(
                      color: Color.fromARGB(255, 80, 80, 80)
                    )
                  ]
                );
              }
            },
          )
        ),
      )
    );
  }
}