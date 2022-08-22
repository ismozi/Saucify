import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class PlaylistTypePicker extends StatefulWidget {
  final Function callback;
  PlaylistTypePicker(this.callback);

  @override
  State<PlaylistTypePicker> createState() => _PlaylistTypePickerState();
}

class _PlaylistTypePickerState extends State<PlaylistTypePicker> {  
  List category = [true, false, false];

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 20, 20, 20),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap:() {
                widget.callback(0);
                setState(() {
                  category = widget.callback(0);
                });
              },
              child: Text("1 Month", style: GoogleFonts.getFont(
                'Montserrat',
                color: category[0] ? Colors.green : Colors.white, 
                fontWeight: category[0] ? FontWeight.w700 : FontWeight.w400)
              ),
            ), 
            GestureDetector(
              onTap:() {
                setState(() {
                  category = widget.callback(1);
                });
              },
              child: Text("6 Months", style: GoogleFonts.getFont(
                'Montserrat',
                color: category[1] ? Colors.green : Colors.white, 
                fontWeight: category[1] ? FontWeight.w700 : FontWeight.w400)
              ),
            ),
            GestureDetector(
              onTap:() {
                setState(() {
                  category = widget.callback(2);
                });
              },
              child: Text("All time", style: GoogleFonts.getFont(
                'Montserrat',
                color: category[2] ? Colors.green : Colors.white, 
                fontWeight: category[2] ? FontWeight.w700 : FontWeight.w400)
              ),
            ) 
          ]
        ),
      )
    );
  }
}