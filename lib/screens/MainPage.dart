import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:saucify/screens/FeedPage.dart';
import 'package:saucify/screens/LibraryScreen.dart';
import 'package:saucify/screens/SearchPage.dart';
import 'package:saucify/screens/StatsPage.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/PostForm.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../widgets/CustomFloatingActionButtonLocation .dart';
import '../widgets/PlaylistForm.dart';

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
  bool isPostsActive = true;

  Container container = Container(color:Color.fromARGB(255, 41, 41, 41));
  LibraryScreen libScreen = LibraryScreen();
  StatsPage statsPage = StatsPage();
  SearchPage searchPage = SearchPage();
  late FeedPage feedPage;

  dynamic activeScreen;

  @override
  void initState() {
    super.initState();
    activeScreen = statsPage;
    feedPage = FeedPage(setFAB);
  }

  void setFAB(int index) {
    if (index == 0){
      isPostsActive = true;
    } else if (index == 1){
      isPostsActive = false;
    }
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  'Saucify', 
                  style: GoogleFonts.getFont('Montserrat', 
                  fontWeight: FontWeight.w700, 
                  fontStyle: FontStyle.italic,
                  fontSize: 25)
                ),
              ),
              Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                  Icon(Icons.person, color: Colors.grey),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                  Icon(Icons.message_rounded, color: Colors.grey)
                ]
              )
            ]
          ),
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
      floatingActionButton: Visibility(
        visible: isFeedActive,
        child: Container(
          height: 55.0,
          width: 55.0,
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 20, 20, 20), width: 8),
            shape: BoxShape.circle,
          ),
          child: FittedBox(
            child: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.black),
              onPressed: () {
                showGeneralDialog(
                  barrierDismissible: true,
                  barrierLabel:
                      MaterialLocalizations.of(context).modalBarrierDismissLabel,
                  transitionDuration: Duration(milliseconds: 200),
                  context: context,
                  pageBuilder: (ctx, anim1, anim2) => isPostsActive ? PostForm() : PlaylistForm(),
                  transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
                    child: FadeTransition(
                      child: child,
                      opacity: anim1,
                    ),
                  ),
                );
              }),
          ),
        )
      ),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
              (MediaQuery.of(context).size.width*0.5)-27.5,
              728
      )
    );
  }
}