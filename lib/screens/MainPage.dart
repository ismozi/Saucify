import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:saucify/screens/FeedPage.dart';
import 'package:saucify/screens/LibraryScreen.dart';
import 'package:saucify/screens/MessagesPage.dart';
import 'package:saucify/screens/NotificationsPage.dart';
import 'package:saucify/screens/PlaylistsPage.dart';
import 'package:saucify/screens/ProfilePage.dart';
import 'package:saucify/screens/StatsPage.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/PostForm.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/app.locator.dart';
import '../widgets/CustomFloatingActionButtonLocation .dart';
import '../widgets/PlaylistForm.dart';
import 'SearchPage1.dart';

class MainPage extends StatefulWidget {

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  spotifyService service = locator<spotifyService>();
  bool isFeedActive = true;
  bool isPlaylistsActive = false;
  bool isStatsActive = false;
  bool isProfileActive = false;
  bool isPostsActive = true;

  Container container = Container(color:Color.fromARGB(255, 41, 41, 41));
  PlaylistsPage playlistsPage = PlaylistsPage();
  StatsPage statsPage = StatsPage();
  late ProfilePage profilePage;
  late FeedPage feedPage;

  dynamic activeScreen;

  @override
  void initState() {
    super.initState();
    feedPage = FeedPage(setFAB, displayProfile);
    profilePage = ProfilePage(service.userId, true, true);
    activeScreen = feedPage;
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
        isPlaylistsActive =  false;
        isStatsActive = false;
        isProfileActive = false;
      });
    }
    else if (index == 1) {
      setState(() {
        activeScreen = playlistsPage;
        isFeedActive = false;
        isPlaylistsActive =  true;
        isStatsActive = false;
        isProfileActive = false;
      });
    } else if (index == 2) {
      setState(() {
        activeScreen = statsPage;
        isFeedActive = false;
        isPlaylistsActive =  false;
        isStatsActive = true;
        isProfileActive = false;
      });
    } else if (index == 3) {
      setState(() {
        activeScreen = profilePage;
        isFeedActive = false;
        isPlaylistsActive =  false;
        isStatsActive = false;
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

  displayProfile() {
    setState(() {
      activeScreen = profilePage;
      isFeedActive = false;
      isPlaylistsActive =  false;
      isStatsActive = false;
      isProfileActive = true;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 19, 19, 19),
          foregroundColor: Colors.green,
          automaticallyImplyLeading: false,
          shape: Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 19, 19, 19),
              width: 4
            )
          ),
          elevation: 10,
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
                  IconButton(
                    color: Color.fromARGB(255, 212, 212, 212),
                    icon: Icon(Icons.search), 
                    onPressed: (() => {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => SearchPage1(),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 150),
                      )),
                    })
                  ), 
                  IconButton(
                    color: Color.fromARGB(255, 212, 212, 212),
                    icon: Icon(Icons.notifications), 
                    onPressed: (() => {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => NotificationsPage(),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 150),
                      )),
                    })
                  ), 
                  IconButton(
                    color: Color.fromARGB(255, 212, 212, 212),
                    icon: Icon(Icons.message_rounded), 
                    onPressed: (() => {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => MessagesPage(),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 150),
                      )),
                    })
                  ),
                ]
              )
            ]
          ),
      ),
      body: activeScreen,
      bottomNavigationBar: Container(
        decoration: !isStatsActive && !isPlaylistsActive ? BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ): null,
        child: BottomAppBar( 
          shape: isFeedActive ? CircularNotchedRectangle(): null,
          child: Row(
            children: [
              IconButton(
                color: isFeedActive ? Colors.green : Color.fromARGB(255, 212, 212, 212),
                icon: Icon(Icons.feed), 
                iconSize: isFeedActive ? 32 : 27,
                onPressed: (() => {setPage(0)})
              ), 
              IconButton(
                color: isPlaylistsActive ? Colors.green : Color.fromARGB(255, 212, 212, 212),
                icon: Icon(Icons.music_note), 
                iconSize: isPlaylistsActive ? 32 : 27,
                onPressed: (() => {setPage(1)})
              ), 
              IconButton(
                color: isStatsActive ? Colors.green : Color.fromARGB(255, 212, 212, 212),
                icon: Icon(Icons.query_stats_rounded), 
                iconSize: isStatsActive ? 32 : 27,
                onPressed: (() => {setPage(2)})
              ), 
              IconButton(
                color: isProfileActive ? Colors.green : Color.fromARGB(255, 212, 212, 212),
                icon: Icon(Icons.person), 
                iconSize: isProfileActive ? 32 : 27,
                onPressed: (() => {setPage(3)})
              ), 
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          color: Color.fromARGB(255, 19, 19, 19)
        ),
      ),
      floatingActionButton: Visibility(
        visible: isFeedActive,
        child: Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
    );
  }
}