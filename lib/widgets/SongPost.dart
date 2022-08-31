import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/widgets/ChooseOption.dart';

import '../app/app.locator.dart';
import '../screens/PersonnalProfilePage.dart';
import '../screens/ProfilePage.dart';
import '../services/spotifyService.dart';

class SongPost extends StatefulWidget {
  SongPost({super.key,
            required this.displayProfile,
            required this.userId, 
            required this.postId,
            required this.isLiked,
            required this.timestamp,
            required this.profileImgUrl,
            required this.profileName,
            required this.description,
            required this.itemImgUrl, 
            required this.itemName, 
            required this.artistName,
            required this.previewUrl,
            required this.player});

  Function displayProfile;
  String userId;
  String postId;
  bool isLiked;
  dynamic timestamp;
  dynamic profileImgUrl;
  String profileName;
  String description;
  String itemImgUrl;
  String itemName;
  dynamic artistName;
  dynamic previewUrl;
  final player;

  @override
  State<SongPost> createState() => _SongPostState();
}

class _SongPostState extends State<SongPost> {
  bool isPlaying = false;
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');

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

  String getTime() {
    // TODO : make it work for different timezones
    if (widget.timestamp == null) {
      return "";
    }
    int timeInSeconds = ((DateTime.now().millisecondsSinceEpoch - widget.timestamp.millisecondsSinceEpoch) / 1000).round();
    String time = "";
    if (timeInSeconds < 60) {
      time = "Just now.";
    } else if (timeInSeconds < 3600) {
      int timeInMinutes = (timeInSeconds / 60).round();
      time = timeInMinutes == 1 ? "1 minute ago." : "$timeInMinutes minutes ago.";
    } else if (timeInSeconds < 86400) {
      int timeInHours = (timeInSeconds / 3600).round();
      time = timeInHours == 1 ? "1 hour ago." : "$timeInHours hours ago.";
    } else {
      time = widget.timestamp.toDate().toString().split(' ')[0];
    }

    return time;
  }

  void toggleLike(){
    dbService.toggleLike(widget.postId, service.userId);
    setState(() {
      widget.isLiked = !widget.isLiked;
    });
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
                    image: widget.profileImgUrl != null ? NetworkImage(widget.profileImgUrl) : emptyImage, 
                    width: 45, 
                    height: 45
                  )
                ),
                onTap: () => {
                  service.userId == widget.userId ? widget.displayProfile() :   
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => ProfilePage(widget.userId),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 150),
                  )),
                },
              ),
              trailing: IconButton(
                icon: Icon(!widget.isLiked ? Icons.favorite_border : Icons.favorite, 
                      color: !widget.isLiked ? Colors.grey : Colors.green),
                onPressed: () {
                  toggleLike();
                },
              ),
              title: GestureDetector(
                child: Text(widget.profileName,
                       style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                onTap: () => {   
                  service.userId == widget.userId ? widget.displayProfile() :
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => ProfilePage(widget.userId),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 150),
                  )),
                },
              ),
              subtitle: Text(getTime(),
                        style: GoogleFonts.getFont('Montserrat', color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 10),
              child: Text(widget.description,
                  style: GoogleFonts.getFont('Montserrat', color: Colors.white))
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 37, 37, 37),
                borderRadius: BorderRadius.circular(12)
              ),
              margin: const EdgeInsets.all(10.0),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(image: NetworkImage(widget.itemImgUrl), width: 45, height: 45)
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
                title: Text(widget.itemName, 
                            style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                subtitle: widget.artistName != null ? Text(widget.artistName, 
                            style: GoogleFonts.getFont('Montserrat', color: Colors.white)) : null,
              )
            )
          ]
        ),
        color: Color.fromARGB(255, 29, 29, 29)
      )
    );
  }
}