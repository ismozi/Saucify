import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  SearchBar(this.controller);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {  
  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 20, 20, 20),
        borderRadius: BorderRadius.circular(30)
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: TextField(
          decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.green)),
          controller: widget.controller,
          style: TextStyle(color: Colors.white),
          onChanged: (text) {
            setState(() {
              //getSearchedItems(text);
            });
          },
        ),
      )
    );
  }
}