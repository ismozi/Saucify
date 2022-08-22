import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import '../app/app.locator.dart';

class PlaylistsPage extends StatefulWidget {

  @override
  State<PlaylistsPage> createState() => PlaylistsPageState();
}

class PlaylistsPageState extends State<PlaylistsPage> {
  spotifyService service = locator<spotifyService>();
 
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: Color.fromARGB(255, 37, 37, 37),
      )
    );
  }
}