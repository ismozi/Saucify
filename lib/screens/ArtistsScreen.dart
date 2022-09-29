import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app.locator.dart';

class ArtistsScreen extends StatefulWidget {
  ArtistsScreen({super.key, required this.userId, required this.pageName, required this.timeRange});
  String userId;
  String pageName;
  String timeRange;

  @override
  State<ArtistsScreen> createState() => ArtistsScreenState();
}

class ArtistsScreenState extends State<ArtistsScreen> {
  List<Widget> list = [];
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  List topTracks = [];
  double opacityLevel = 0.0;
  List artistsItemsList = [];

  bool isOneMonth = true;
  bool isFourMonths = false;
  bool isAllTime = false;
  String timeRange = 'short';

  @override
  void initState() {
    super.initState();
    getArtistsItems();
    timeRange = widget.timeRange;
    isOneMonth = timeRange == 'short' ? true : false;
    isFourMonths = timeRange == 'medium' ? true : false;
    isAllTime = timeRange == 'long' ? true : false;
    Timer(Duration(milliseconds: 300), () {
      setState(() => opacityLevel = 1);
    });
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  void setTimeRange(int index) {
    setState(() {
      opacityLevel = 0;
    });

    if (index == 0) {
      setState(() {
        isOneMonth = true;
        isFourMonths = false;
        isAllTime = false;
        timeRange = 'short';
      });
    } else if (index == 1) {
      setState(() {
        isOneMonth = false;
        isFourMonths = true;
        isAllTime = false;
        timeRange = 'medium';
      });
    } else if (index == 2) {
      setState(() {
        isOneMonth = false;
        isFourMonths = false;
        isAllTime = true;
        timeRange = 'long';
      });
    }

    artistsItemsList = [];
    getArtistsItems();
  }

  getArtistsItems() async {
    DocumentSnapshot userSnap = await dbService.getUserDocument(widget.userId);
    List artistItems = [];

    dynamic userData = userSnap.data();
    List artistIds = userData['topArtists'][timeRange];
    List artists = await service.getArtists(artistIds);

    for(int i = 0; i < artistIds.length; i++){
      artistItems.add({
        'artist': artists[i],
        'artistRank': i+1
      });
    }

    setState(() { 
      artistsItemsList = artistItems;
      opacityLevel = 1;
    });
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
        title: Text('Top Artists', style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            color: Color.fromARGB(255, 10, 10, 10),
            child: AnimatedOpacity(
              opacity: opacityLevel,
              duration: const Duration(milliseconds: 250),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 80, 0, 75),
                itemCount: artistsItemsList.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 19, 19, 19),
                      borderRadius: BorderRadius.all(Radius.circular(12))
                    ),
                    margin: const EdgeInsets.all(4.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15) 
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: NetworkImage(artistsItemsList[index]['artist']['images'][0]['url']), 
                          width: 47, 
                          height: 47
                        )
                      ),
                      trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.06,
                          width: MediaQuery.of(context).size.width * 0.06,
                          color: Color.fromARGB(255, 46, 46, 46),
                          padding: EdgeInsets.all(2),
                          child: Center(
                            child: Text('${artistsItemsList[index]['artistRank']}', style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w300))
                          )
                        )
                      ),
                      title: Text(artistsItemsList[index]['artist']['name'], 
                                  style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 15)),
                      onTap: () async {
                        final Uri _url = Uri.parse(artistsItemsList[index]['artist']['uri']);
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ),
                  );
                }
              )
            )
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.92,
            right: MediaQuery.of(context).size.width * 0.14,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.5),
                    spreadRadius: 13,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(40, 15, 40, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: GestureDetector(
                      onTap:() => {setTimeRange(0)},
                      child: Text("1 Month", style: GoogleFonts.getFont(
                        'Montserrat',
                        color: isOneMonth ? Colors.green : Colors.white, 
                        fontWeight: isOneMonth ? FontWeight.w700 : FontWeight.w400)
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(7, 0, 5, 0)),
                  Container(
                    child: GestureDetector(
                      onTap:() => {setTimeRange(1)},
                      child: Text("6 Months", style: GoogleFonts.getFont(
                        'Montserrat',
                        color: isFourMonths ? Colors.green : Colors.white, 
                        fontWeight: isFourMonths ? FontWeight.w700 : FontWeight.w400)
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(5, 0, 7, 0)),
                  Container(
                    child: GestureDetector(
                      onTap:() => {setTimeRange(2)},
                      child: Text("All time", style: GoogleFonts.getFont(
                        'Montserrat',
                        color: isAllTime ? Colors.green : Colors.white, 
                        fontWeight: isAllTime ? FontWeight.w700 : FontWeight.w400)
                      ),
                    ),
                  ),
                ]
              )
            )
          )
        ]
      )
    );
  }
}
