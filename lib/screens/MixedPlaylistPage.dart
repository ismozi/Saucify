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

  @override
  void initState() {
    super.initState();
    generateMixedPlaylist();
    Timer(Duration(milliseconds: 800), () {
      setState(() => opacityLevel = 1);
    });
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  generateMixedPlaylist() async {
    List following = await dbService.getFollowing(service.userId);
    int playlistSize = 30;
    int numOfTracks = (playlistSize / following.length).floor();
    int remaining = playlistSize % numOfTracks;
    int index = 0;
    List newTracksIds = [];

    await Future.forEach(following, (userId) async { 
      DocumentSnapshot userSnap = await dbService.getUserDocument(userId as String);
      List topTracks = userSnap['topTracks']['short'];

      if (index == 0) {
        topTracks = topTracks.sublist(0, numOfTracks+remaining);
      } else {
        topTracks = topTracks.sublist(0, numOfTracks);
      }

      topTracks.forEach((element) {
        newTracksIds.add(element);
      });
    });
    tracksIds = newTracksIds;
    return service.getTracks(newTracksIds);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        color: Color.fromARGB(255, 19, 19, 19),
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
              print(items.length);
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 110),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 29, 29, 29),
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
                          image: NetworkImage(items[index]['album']['images'][0]['url']), 
                          width: 45, 
                          height: 45
                        )
                      ),
                      title: Text(items[index]['name'], 
                                  style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                      subtitle: Text(items[index]['artists'][0]['name'], 
                                  style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                      onTap: () async {
                        final Uri _url = Uri.parse(items[index]['uri']);
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
      floatingActionButton: !tracksIds.isEmpty ? Container(
        child: FloatingActionButton.extended(
          label: Text('Generate playlist', style: GoogleFonts.getFont('Montserrat', 
            color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17)),
          backgroundColor: Colors.green,
          onPressed: () {
            service.createPlaylist1(tracksIds, 'Mixed playlist');
          }
        ),
      ) : null,
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
              (MediaQuery.of(context).size.width*0.5)-105,
              620
      )
    );
  }
}
