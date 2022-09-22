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
  int val = 3;

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
      'size': val * 10,
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
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text("Playlist size", style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w200)),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Radio(
                        value: 1, 
                        groupValue: val, 
                        onChanged: (value) {
                          setState(() {
                            val = value as int;
                          });
                        },
                        visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity,
                        ),
                      ),
                      Text('10', style: GoogleFonts.getFont('Montserrat', 
                        color: Colors.white, fontWeight: FontWeight.w300, fontSize: 12)),
                    ]
                  ),
                  Column(
                    children: [
                      Radio(
                        value: 2, 
                        groupValue: val, 
                        onChanged: (value) {
                          setState(() {
                            val = value as int;
                          });
                        },
                        visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity,
                        ),
                      ),
                      Text('20', style: GoogleFonts.getFont('Montserrat', 
                        color: Colors.white, fontWeight: FontWeight.w300, fontSize: 12)),
                    ]
                  ),
                  Column(
                    children: [
                      Radio(
                        value: 3, 
                        groupValue: val, 
                        onChanged: (value) {
                          setState(() {
                            val = value as int;
                          });
                        },
                        visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity,
                        ),
                      ),
                      Text('30', style: GoogleFonts.getFont('Montserrat', 
                        color: Colors.white, fontWeight: FontWeight.w300, fontSize: 12)),
                    ]
                  ),
                  Column(
                    children: [
                      Radio(
                        value: 4, 
                        groupValue: val, 
                        onChanged: (value) {
                          setState(() {
                            val = value as int;
                          });
                        },
                        visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity,
                        ),
                      ),
                      Text('40', style: GoogleFonts.getFont('Montserrat', 
                        color: Colors.white, fontWeight: FontWeight.w300, fontSize: 12)),
                    ]
                  ),
                  Column(
                    children: [
                      Radio(
                        value: 5, 
                        groupValue: val, 
                        onChanged: (value) {
                          setState(() {
                            val = value as int;
                          });
                        },
                        visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity,
                        ),
                      ),
                      Text('50', style: GoogleFonts.getFont('Montserrat', 
                        color: Colors.white, fontWeight: FontWeight.w300, fontSize: 12)),
                    ]
                  ),
                  Column(
                    children: [
                      Radio(
                        value: 6, 
                        groupValue: val, 
                        onChanged: (value) {
                          setState(() {
                            val = value as int;
                          });
                        },
                        visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity,
                        ),
                      ),
                      Text('60', style: GoogleFonts.getFont('Montserrat', 
                        color: Colors.white, fontWeight: FontWeight.w300, fontSize: 12)),
                    ]
                  ),
                ]
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