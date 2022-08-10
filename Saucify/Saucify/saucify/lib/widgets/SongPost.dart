import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class SongPost extends StatefulWidget {
  SongPost({super.key, 
            required this.profileImgUrl,
            required this.profileName,
            required this.description,
            required this.songImgUrl, 
            required this.songName, 
            required this.artistName});

  String profileImgUrl;
  String profileName;
  String description;
  String songImgUrl;
  String songName;
  String artistName;

  @override
  State<SongPost> createState() => _SongPostState();
}

class _SongPostState extends State<SongPost> {
  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Card(
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
                trailing: Icon(Icons.play_circle, color: Colors.white),
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