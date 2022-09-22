import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/MainPage.dart';
import 'package:saucify/screens/TopTracksScreen.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:saucify/widgets/searchItem.dart';
import 'package:http/http.dart' as http;

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class MixFilterPage extends StatefulWidget {
  final Function refresh;
  MixFilterPage(this.refresh);
  @override
  State<MixFilterPage> createState() => _MixFilterPageState();
}

class _MixFilterPageState extends State<MixFilterPage> {
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  TextEditingController sizeController = TextEditingController();
  bool isLoading = false;

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

  updateMix() async {
    List userFollowing = await dbService.getFollowing(service.userId);
    final queryParameters = {
      'targetUserId': service.userId,
      'size': int.parse((sizeController.text)),
      'following': userFollowing,
    };
    setState(() {
      isLoading = true;
    });
    final ga = await http.post(Uri.parse('https://us-central1-saucify-71787.cloudfunctions.net/generateFirstMixes'), body: jsonEncode(queryParameters));
    if (ga.body == 'done'){
      widget.refresh();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
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
        title: Text("Filter Mix", style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: 
        Container(
          padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
          color: Color.fromARGB(255, 10, 10, 10),
          width: MediaQuery.of(context).size.width,
          child: !isLoading ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Playlist size", style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w200)),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 200, 0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height*0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 19, 19, 19),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextField(
                        controller: sizeController,
                        style: TextStyle(color: Colors.white),
                        expands: true,
                        maxLines: null,
                      )
                    )
                  )
                )
              ),
              GestureDetector(
                onTap: () {
                  updateMix();
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 26, 26, 26),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.4),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                margin: const EdgeInsets.fromLTRB(28, 40, 28, 7),
                alignment: Alignment.center,
                child: Text('Update Mix', style: GoogleFonts.getFont('Montserrat', 
                      color: Colors.white, fontWeight: FontWeight.w300, fontSize: 17)),
                ),
              ),
            ]
          ) : Center(
            child: SpinKitWave(
              color: Colors.green,
              size: 30.0,
            ),
          )
        ),
      );
  }
}