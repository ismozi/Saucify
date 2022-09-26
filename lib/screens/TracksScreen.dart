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

class TracksScreen extends StatefulWidget {
  TracksScreen({super.key, required this.userId, required this.playlistName, required this.timeRange});
  String userId;
  String playlistName;
  String timeRange;

  @override
  State<TracksScreen> createState() => TracksScreenState();
}

class TracksScreenState extends State<TracksScreen> {
  List<Widget> list = [];
  List<Widget> deviceList = [];
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  bool isPlayerShown = false;
  dynamic bottomAppBar = BottomAppBar();
  List topTracks = [];
  double opacityLevel = 0.0;
  List tracksIdsPlaylist = [];
  List trackItemsList = [];

  bool isOneMonth = true;
  bool isFourMonths = false;
  bool isAllTime = false;
  String timeRange = 'short';


  @override
  void initState() {
    super.initState();
    getTrackItems();
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

    trackItemsList = [];
    getTrackItems();
  }

  getTrackItems() async {
    DocumentSnapshot userSnap = await dbService.getUserDocument(widget.userId);
    List trackItems = [];

    dynamic userData = userSnap.data();
    List trackIds = userData['topTracks'][timeRange];
    tracksIdsPlaylist = trackIds;
    List tracks = await service.getTracks(trackIds);

    for(int i = 0; i < trackIds.length; i++){
      trackItems.add({
        'track': tracks[i],
        'trackRank': i+1
      });
    }

    setState(() { 
      trackItemsList = trackItems;
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
        title: Text('Top songs', style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
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
                itemCount: trackItemsList.length+1,
                itemBuilder: (context, index) {
                  if (index == 0){
                    return GestureDetector(
                      onTap: () {
                        service.createPlaylist1(tracksIdsPlaylist, 'Mixed playlist');
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(42, 8, 42, 8),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 26, 26, 26),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.6),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.fromLTRB(15, 7, 15, 7),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Generate playlist', style: GoogleFonts.getFont('Montserrat', 
                              color: Colors.white, fontWeight: FontWeight.w300, fontSize: 17)),
                            Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                            ImageIcon(
                                AssetImage("assets/images/Spotify_Icon_RGB_White.png"),
                                color: Colors.green,
                            ),
                          ]
                        ),
                      )
                    );
                  }
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
                          image: NetworkImage(trackItemsList[index-1]['track']['album']['images'][0]['url']), 
                          width: 45, 
                          height: 45
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
                            child: Text('${trackItemsList[index-1]['trackRank']}', style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w300))
                          )
                        )
                      ),
                      title: Text(trackItemsList[index-1]['track']['name'].length > 24 ? trackItemsList[index-1]['track']['name'].substring(0, 24)+'...' : trackItemsList[index-1]['track']['name'],
                                  style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 15)),
                      subtitle: Text(trackItemsList[index-1]['track']['artists'][0]['name'], 
                                  style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 187, 187, 187), fontSize: 13)),
                      onTap: () async {
                        final Uri _url = Uri.parse(trackItemsList[index-1]['track']['uri']);
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
