import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class CategoryPicker extends StatefulWidget {
  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {  
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
                setState(() {
                });
              },
              child: Text("Track", style: GoogleFonts.getFont(
                'Montserrat',
                color: Colors.green, 
                fontWeight: FontWeight.w700)
              ),
            ), 
            GestureDetector(
              onTap:() {
                setState(() {
                });
              },
              child: Text("Artist", style: GoogleFonts.getFont(
                'Montserrat',
                color: Colors.white, 
                fontWeight: FontWeight.w400)
              ),
            ),
            GestureDetector(
              onTap:() {
                setState(() {
                });
              },
              child: Text("Playlist", style: GoogleFonts.getFont(
                'Montserrat',
                color: Colors.white, 
                fontWeight: FontWeight.w400)
              ),
            ) 
          ]
        ),
      )
    );
  }
}