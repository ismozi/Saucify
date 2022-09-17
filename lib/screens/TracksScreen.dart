import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app.locator.dart';

class TracksScreen extends StatefulWidget {
  TracksScreen({super.key, required this.tracksIds, required this.playlistName});
  List tracksIds;
  String playlistName;

  @override
  State<TracksScreen> createState() => TracksScreenState();
}

class TracksScreenState extends State<TracksScreen> {
  List<Widget> list = [];
  List<Widget> deviceList = [];
  spotifyService service = locator<spotifyService>();
  bool isPlayerShown = false;
  dynamic bottomAppBar = BottomAppBar();
  List topTracks = [];
  double opacityLevel = 0.0;

  @override
  void initState() {
    super.initState();
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
        title: Text(widget.playlistName, style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 70, 10, 0),
        color: Color.fromARGB(255, 10, 10, 10),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: FutureBuilder(
            future: service.getTracks(widget.tracksIds),
            builder: (BuildContext context, AsyncSnapshot snapshot1) {
              if (!snapshot1.hasData) {
                return Container();
              }
              List items = snapshot1.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 80),
                itemCount: widget.tracksIds.length,
                itemBuilder: (context, index) {
                  if (index == 0){
                    return GestureDetector(
                      onTap: () {
                        service.createPlaylist1(widget.tracksIds, widget.playlistName);;
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
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
                        margin: const EdgeInsets.fromLTRB(28, 7, 28, 7),
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
    );
  }
}
