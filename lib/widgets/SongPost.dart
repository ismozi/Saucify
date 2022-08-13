import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/widgets/ChooseOption.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class SongPost extends StatefulWidget {
  SongPost({super.key, 
            required this.profileImgUrl,
            required this.profileName,
            required this.description,
            required this.songImgUrl, 
            required this.songName, 
            required this.artistName,
            required this.previewUrl,
            required this.player});

  String profileImgUrl;
  String profileName;
  String description;
  String songImgUrl;
  String songName;
  String artistName;
  String previewUrl;
  final player;

  @override
  State<SongPost> createState() => _SongPostState();
}

class _SongPostState extends State<SongPost> {
  bool isPlaying = false;

  // TODO : manage listeners to remove
  void play() async {
    widget.player.pause();
    await widget.player.setSourceUrl(widget.previewUrl);
    widget.player.resume();
    
    setState(() {
      isPlaying = true;
    });

    widget.player.onPlayerStateChanged.listen((PlayerState s) {
      if (s == PlayerState.paused || s == PlayerState.stopped){
        setState(() {
          isPlaying = false;
        });
      }
    });
    widget.player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
      });
    });
  }

  void pause(){
    widget.player.pause();
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image(
                  image: NetworkImage(widget.profileImgUrl), 
                  width: 45, 
                  height: 45
                )
              ),
              title: Text(widget.profileName,
                      style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
              subtitle: Text('2h ago',
                        style: GoogleFonts.getFont('Montserrat', color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 10),
              child: Text(widget.description,
                  style: GoogleFonts.getFont('Montserrat', color: Colors.white))
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 46, 46, 46),
                borderRadius: BorderRadius.circular(12)
              ),
              margin: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(image: NetworkImage(widget.songImgUrl), width: 45, height: 45)
                ),
                trailing: IconButton(
                  icon:Icon(!isPlaying ? Icons.more_horiz : Icons.pause_circle), 
                  color: Colors.white,
                  onPressed: (() {
                    isPlaying ? pause() : 
                    showGeneralDialog(
                      barrierDismissible: true,
                      barrierLabel:
                        MaterialLocalizations.of(context).modalBarrierDismissLabel,
                      transitionDuration: Duration(milliseconds: 100),
                      context: context,
                      pageBuilder: (ctx, anim1, anim2) => ChooseOption(play),
                      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
                        child: FadeTransition(
                          child: child,
                          opacity: anim1,
                        ),
                      ),
                    );
                  })
                ),
                title: Text(widget.songName, 
                            style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                subtitle: Text(widget.artistName, 
                            style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
              )
            )
          ]
        ),
        color: Color.fromARGB(255, 29, 29, 29)
      )
    );
  }
}