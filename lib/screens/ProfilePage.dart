import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/DatabaseService.dart';

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class ProfilePage extends StatefulWidget {
  final userId;
  ProfilePage(this.userId);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DatabaseService dbService = DatabaseService();
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
      body: 
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
          color: Color.fromARGB(255, 37, 37, 37),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(image: user['imageUrl'] != null ? NetworkImage(user['imageUrl']): emptyImage, width: 200, height: 200)
                    ),
                    Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    Text(user['username'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 35))
                  ]
                );
              }
            },
          )
        ),
      );
  }
}