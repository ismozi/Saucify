import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class CategoryPicker extends StatefulWidget {
  final Function callback1;
  final Function callback2;
  CategoryPicker(this.callback1, this.callback2);

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {  
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
                widget.callback1(0);
                setState(() {
                  category = widget.callback2();
                });
              },
              child: Text("Track", style: GoogleFonts.getFont(
                'Montserrat',
                color: category[0] ? Colors.green : Colors.white, 
                fontWeight: category[0] ? FontWeight.w700 : FontWeight.w400)
              ),
            ), 
            GestureDetector(
              onTap:() {
                widget.callback1(1);
                setState(() {
                  category = widget.callback2();
                });
              },
              child: Text("Album", style: GoogleFonts.getFont(
                'Montserrat',
                color: category[1] ? Colors.green : Colors.white, 
                fontWeight: category[1] ? FontWeight.w700 : FontWeight.w400)
              ),
            ),
            GestureDetector(
              onTap:() {
                widget.callback1(2);
                setState(() {
                  category = widget.callback2();
                });
              },
              child: Text("Artist", style: GoogleFonts.getFont(
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