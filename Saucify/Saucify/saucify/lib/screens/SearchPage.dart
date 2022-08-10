import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/MainPage.dart';
import 'package:saucify/screens/TopTracksScreen.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

import '../app/app.locator.dart';
import 'LibraryScreen.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  spotifyService service = locator<spotifyService>();
  TextEditingController controller = TextEditingController();
  List<Widget> list = [];
  double opacityLevel = 0.0;

  void getSearchedItems(String text) async {
    List myPlaylists = await service.searchItems(text);
    List<Widget> newList = [];

    myPlaylists.forEach((item) { 
      newList.add(
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 29, 29, 29),
            borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          margin: const EdgeInsets.all(3.0),
          child: ListTile(
            leading: !item['album']['images'].isEmpty ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(item['album']['images'][0]['url']), 
                width: 40, 
                height: 40
              )
            ) : null,
            title: Text(item['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            subtitle: Text(item['artists'][0]['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            onTap: () => {
            },
          ),
        )
      );
    });

    setState(() {
      list = newList;
      opacityLevel = 1.0;
    });
  } 

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
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 37, 37, 37),
        automaticallyImplyLeading: false,
        title: TextField(
          decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.green)),
          controller: controller,
          style: TextStyle(color: Colors.white),
          onChanged: (text) {
            setState(() {
              getSearchedItems(text);
            });
          },
        )
      ),
      body: 
        Container(
          padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
          color: Color.fromARGB(255, 41, 41, 41),
          child: AnimatedOpacity(
            opacity: opacityLevel,
            duration: const Duration(milliseconds: 300),
            child: ListView(
              children: list
              ) 
          )
        ),
      );
  }
}