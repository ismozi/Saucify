import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

class StatsAppBar extends StatefulWidget implements PreferredSizeWidget{
  final Function callback;
  final Function callback2;
  StatsAppBar(this.callback, this.callback2);
  @override
  _StatsAppBarState createState() => _StatsAppBarState();

  ///width doesnt matter
  @override
  Size get preferredSize => Size(250, 30);
}

class _StatsAppBarState extends State<StatsAppBar> {
  Tuple2<bool, bool> options = Tuple2<bool, bool>(true, false);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: 250,
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          GestureDetector(
            onTap:() {
              widget.callback(0);
              setState(() {
                options = widget.callback2();
              });
            },
            child: Text("Tracks", style: GoogleFonts.getFont(
              'Montserrat',
              color: options.item1 ? Colors.green : Colors.white, 
              fontWeight: options.item1 ? FontWeight.w700 : FontWeight.w400)
            ),
          ), 
          GestureDetector(
            onTap:() {
              widget.callback(1);
              setState(() {
                options = widget.callback2();
              });
            },
            child: Text("Artists", style: GoogleFonts.getFont(
              'Montserrat',
              color: options.item2 ? Colors.green : Colors.white, 
              fontWeight: options.item2 ? FontWeight.w700 : FontWeight.w400)
            ),
          ), 
        ]),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 20, 20, 20),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(40.0),
            topLeft: Radius.circular(0),
            bottomLeft: Radius.circular(40.0)
          ),
        ),
      ),
    );
  }
}