import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

class ChooseOption extends StatefulWidget {
  final Function callback;
  ChooseOption(this.callback);

  @override
  _ChooseOptionState createState() => _ChooseOptionState();
}

class _ChooseOptionState extends State<ChooseOption> {
  Tuple2<bool, bool> options = Tuple2<bool, bool>(true, false);

@override
  Widget build(BuildContext context){
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: Color.fromARGB(255, 31, 31, 31),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 20, 20, 20),
                borderRadius: BorderRadius.circular(30)
              ),
              child: GestureDetector(
                child: Text(
                  'Play preview',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    color: Colors.green,
                    fontWeight: FontWeight.w700
                  )
                ),
                onTap:() {
                  widget.callback();
                  Navigator.pop(context);
                },
              )
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 20, 20, 20),
                borderRadius: BorderRadius.circular(30)
              ),
              child: GestureDetector(
                child: Text(
                  'Open in Spotify',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    color: Colors.green,
                    fontWeight: FontWeight.w700
                  )
                ),
                onTap:() {
                  
                },
              )
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 20, 20, 20),
                borderRadius: BorderRadius.circular(30)
              ),
              child: GestureDetector(
                child: Text(
                  'Add to playlist',
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    color: Colors.green,
                    fontWeight: FontWeight.w700
                  )
                ),
                onTap:() {
                  
                },
              )
            )
          ]
        ),
      )
    );
  }
}
