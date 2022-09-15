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
import '../widgets/CustomFloatingActionButtonLocation .dart';

class MixedPlaylistPage extends StatefulWidget {
  @override
  State<MixedPlaylistPage> createState() => MixedPlaylistPageState();
}

class MixedPlaylistPageState extends State<MixedPlaylistPage> {
  List<Widget> list = [];
  List<Widget> deviceList = [];
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  bool isPlayerShown = false;
  dynamic bottomAppBar = BottomAppBar();
  List topTracks = [];
  double opacityLevel = 0.0;
  List tracksIds = [];
  List userImgs = [];

  bool isOneMonth = true;
  bool isFourMonths = false;
  bool isAllTime = false;
  String timeRange = 'short';

  @override
  void initState() {
    super.initState();
    generateMixedPlaylist();
    Timer(Duration(milliseconds: 400), () {
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
    opacityLevel = 0;
    Timer(Duration(milliseconds: 800), () {
      setState(() => opacityLevel = 1);
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
  }

  generateMixedPlaylist() async {
    List following = await dbService.getFollowing(service.userId);
    int playlistSize = 30;
    int numOfTracks = (playlistSize / following.length).floor();
    int remaining = playlistSize % numOfTracks;
    int index = 0;
    List newTracksIds = [];
    List newUserImgs = [];

    await Future.forEach(following, (userId) async { 
      DocumentSnapshot userSnap = await dbService.getUserDocument(userId as String);
      List topTracks = userSnap['topTracks'][timeRange];

      if (index == 0) {
        topTracks = topTracks.sublist(0, numOfTracks+remaining);
      } else {
        topTracks = topTracks.sublist(0, numOfTracks);
      }

      topTracks.forEach((element) {
        newTracksIds.add(element);
        newUserImgs.add(userSnap['imageUrl']);
      });
    });

    userImgs = newUserImgs;
    tracksIds = newTracksIds;
    return service.getTracks(newTracksIds);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        color: Color.fromARGB(255, 10, 10, 10),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: FutureBuilder(
            future: generateMixedPlaylist(),
            builder: (BuildContext context, AsyncSnapshot snapshot1) {
              if (!snapshot1.hasData) {
                return Container();
              }
              List items = snapshot1.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 110, 0, 65),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  if (index == 0){
                    return GestureDetector(
                      onTap: () {
                        service.createPlaylist1(tracksIds, 'Mixed playlist');
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 26, 26, 26),
                          borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        margin: const EdgeInsets.all(5.0),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.music_note, color: Colors.white),
                            Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                            Text('Generate playlist', style: GoogleFonts.getFont('Montserrat', 
                              color: Colors.white, fontWeight: FontWeight.w300, fontSize: 17)),
                            Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                            Icon(Icons.music_note, color: Colors.white)
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
                    margin: const EdgeInsets.all(5.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15) 
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: NetworkImage(items[index-1]['album']['images'][0]['url']), 
                          width: 45, 
                          height: 45
                        )
                      ),
                      trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image(
                          image: NetworkImage(userImgs[index-1]), 
                          width: 30, 
                          height: 30
                        )
                      ),
                      title: Text(items[index-1]['name'], 
                                  style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                      subtitle: Text(items[index-1]['artists'][0]['name'], 
                                  style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                      onTap: () async {
                        final Uri _url = Uri.parse(items[index-1]['uri']);
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ),
                  );
                }
              );
            }
          )
        )
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: BottomAppBar(
          color: Color.fromARGB(255, 0, 0, 0),
          child: Container(
            padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
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
          ),
        ),
      ),
    );
  }
}
