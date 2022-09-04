import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function callback;
  SearchBar(this.controller, this.callback);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width*0.85,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 12, 12, 12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.green),
            border: InputBorder.none
          ),
          controller: widget.controller,
          style: TextStyle(color: Colors.white),
          onChanged: (text) {
            setState(() {
              widget.callback(text);
            });
          },
        ),
      )
    );
  }
}