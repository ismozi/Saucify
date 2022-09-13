import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/widgets/ChooseOption.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app.locator.dart';
import '../screens/ProfilePage.dart';
import '../screens/TracksScreen.dart';
import '../services/spotifyService.dart';

class PlaylistItem extends StatefulWidget {
  PlaylistItem({super.key,
            required this.timeRange,
            required this.user});

  String timeRange;
  DocumentSnapshot user;

  @override
  State<PlaylistItem> createState() => _PlaylistItemState();
}

class _PlaylistItemState extends State<PlaylistItem> {
  bool isPlaying = false;
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  String playlistName = '';
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playlistName = widget.user['username']+"'s ";
    playlistName += widget.timeRange == 'short_term' ? 'Monthly Playlist' : widget.timeRange == 'medium_term' ? '6 Months Playlist' : 'All Time Playlist';
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: GestureDetector(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image(
                    image: widget.user['imageUrl'] != null ? NetworkImage(widget.user['imageUrl']) : emptyImage, 
                    width: 45, 
                    height: 45
                  )
                ),
                onTap: () => {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => ProfilePage(widget.user.id, false, true),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 150),
                  )),
                },
              ),
              title: GestureDetector(
                child: Text(widget.user['username'],
                       style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                onTap: () => {   
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => ProfilePage(widget.user.id, false, true),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 150),
                  )),
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.push_pin_outlined , 
                      color: Colors.grey),
                onPressed: () {
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 35, 35, 35),
                borderRadius: BorderRadius.circular(12)
              ),
              child: ListTile(
                onTap: () async {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => TracksScreen(tracksIds: widget.user['topTracks'][widget.timeRange.split('_')[0]], playlistName: playlistName),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 150),
                  ));
                },
                leading: Icon(Icons.music_note, color: Colors.grey),
                title: Text(playlistName, 
                            style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
              )
            )
          ]
        ),
        color: Color.fromARGB(255, 27, 27, 27)
      )
    );
  }
}