import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

class FeedAppBar extends StatefulWidget implements PreferredSizeWidget{
  final Function callback;
  FeedAppBar(this.callback);
  @override
  _FeedAppBarState createState() => _FeedAppBarState();

  ///width doesnt matter
  @override
  Size get preferredSize => Size(275, 30);
}

class _FeedAppBarState extends State<FeedAppBar> {
  Tuple2<bool, bool> options = Tuple2<bool, bool>(false, true);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 65, 0, 0),
        child: Container(
          alignment: Alignment.center,
          width: 275,
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            GestureDetector(
              onTap:() {
                setState(() {
                  options = widget.callback(0);
                });
              },
              child: Text("Solo", style: GoogleFonts.getFont(
                'Montserrat',
                color: options.item1 ? Colors.green : Colors.white, 
                fontWeight: options.item1 ? FontWeight.w700 : FontWeight.w400)
              ),
            ), 
            GestureDetector(
              onTap:() {
                setState(() {
                  options = widget.callback(1);
                });
              },
              child: Text("Mix", style: GoogleFonts.getFont(
                'Montserrat',
                color: options.item2 ? Colors.green : Colors.white, 
                fontWeight: options.item2 ? FontWeight.w700 : FontWeight.w400)
              ),
            ), 
          ]),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 0),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40.0),
              bottomRight: Radius.circular(40.0),
              topLeft: Radius.circular(40.0),
              bottomLeft: Radius.circular(40.0)
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.6),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
        ),
      )
    );
  }
}