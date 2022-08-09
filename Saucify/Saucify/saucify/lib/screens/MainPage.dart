import 'dart:async';
import 'dart:math';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:saucify/screens/FeedPage.dart';
import 'package:saucify/screens/LibraryScreen.dart';
import 'package:saucify/screens/SearchPage.dart';
import 'package:saucify/screens/StatsPage.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../widgets/CustomFloatingActionButtonLocation .dart';

class MainPage extends StatefulWidget {

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  spotifyService service = locator<spotifyService>();
  bool isStatsActive = true;
  bool isLibraryActive = false;
  bool isProfileActive = false;
  bool isFeedActive = false;

  Container container = Container(color:Color.fromARGB(255, 41, 41, 41));
  LibraryScreen libScreen = LibraryScreen();
  StatsPage statsPage = StatsPage();
  SearchPage searchPage = SearchPage();
  FeedPage feedPage = FeedPage();

  dynamic activeScreen;

  @override
  void initState() {
    super.initState();
    activeScreen = statsPage;
  }

  void setPage(int index) {
    if (index == 0) {
      setState(() {
        activeScreen = feedPage;
        isFeedActive = true;
        isStatsActive =  false;
        isLibraryActive = false;
        isProfileActive = false;
      });
    }
    else if (index == 1) {
      setState(() {
        activeScreen = statsPage;
        isFeedActive = false;
        isStatsActive =  true;
        isLibraryActive = false;
        isProfileActive = false;
      });
    } else if (index == 2) {
      setState(() {
        activeScreen = libScreen;
        isFeedActive = false;
        isStatsActive =  false;
        isLibraryActive = true;
        isProfileActive = false;
      });
    } else if (index == 3) {
      setState(() {
        activeScreen = searchPage;
        isFeedActive = false;
        isStatsActive =  false;
        isLibraryActive = false;
        isProfileActive = true;
      });
    }
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
          backgroundColor: Color.fromARGB(255, 20, 20, 20),
          foregroundColor: Colors.green,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Saucify', 
                    style: GoogleFonts.getFont('Montserrat', fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)
                  ),
                ]
              )
            ]
          )
      ),
      body: activeScreen,
      bottomNavigationBar: BottomAppBar(child: 
        Row(
          children: [
            IconButton(
              color: isFeedActive ? Colors.green : Colors.grey,
              icon: Icon(Icons.feed), 
              iconSize: isFeedActive ? 32 : 27,
              onPressed: (() => {setPage(0)})
            ), 
            IconButton(
              color: isStatsActive ? Colors.green : Colors.grey,
              icon: Icon(Icons.query_stats_rounded), 
              iconSize: isStatsActive ? 32 : 27,
              onPressed: (() => {setPage(1)})
            ), 
            IconButton(
              color: isLibraryActive ? Colors.green : Colors.grey,
              icon: Icon(Icons.music_note), 
              iconSize: isLibraryActive ? 32 : 27,
              onPressed: (() => {setPage(2)})
            ), 
            IconButton(
              color: isProfileActive ? Colors.green : Colors.grey,
              icon: Icon(Icons.search_rounded), 
              iconSize: isProfileActive ? 32 : 27,
              onPressed: (() => {setPage(3)})
            ), 
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        color: Color.fromARGB(255, 20, 20, 20)
      ),
      floatingActionButton: isFeedActive ? Container(
        height: 50.0,
        width: 50.0,
        child: FittedBox(
          child: FloatingActionButton(
            child: Icon(Icons.add, color: Colors.black),
            onPressed: () {}),
        ),
      ) : null,
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
              168,
              725
      )
    );
  }
}