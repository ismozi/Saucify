import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app.locator.dart';

class ArtistsScreen extends StatefulWidget {
  ArtistsScreen({super.key, required this.artistsIds, required this.pageName});
  List artistsIds;
  String pageName;

  @override
  State<ArtistsScreen> createState() => ArtistsScreenState();
}

class ArtistsScreenState extends State<ArtistsScreen> {
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
        title: Text(widget.pageName, style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        color: Color.fromARGB(255, 10, 10, 10),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: FutureBuilder(
            future: service.getArtists(widget.artistsIds),
            builder: (BuildContext context, AsyncSnapshot snapshot1) {
              if (!snapshot1.hasData) {
                return Container();
              }
              List items = snapshot1.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                itemCount: widget.artistsIds.length,
                itemBuilder: (context, index) {
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
                          image: NetworkImage(items[index]['images'][0]['url']), 
                          width: 45, 
                          height: 45
                        )
                      ),
                      title: Text(items[index]['name'], 
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
    );
  }
}
