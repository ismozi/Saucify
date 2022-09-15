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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
          foregroundColor: Colors.green,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.black.withOpacity(1.0),
                                Colors.black.withOpacity(1.0), 
                                Colors.black.withOpacity(1.0),
                                Colors.black.withOpacity(0.0)]),
            ),
          ),
          elevation: 0,
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
        decoration: BoxDecoration(
            gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[Colors.black.withOpacity(1.0),
                                  Colors.black.withOpacity(1.0), 
                                  Colors.black.withOpacity(1.0),
                                  Colors.black.withOpacity(0.0)]),
          ),
        child: BottomAppBar( 
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: isFeedActive ? const EdgeInsets.fromLTRB(0, 0, 0, 12) : const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: IconButton(
                      color: isFeedActive ? Colors.green : Color.fromARGB(255, 212, 212, 212),
                      icon: Icon(Icons.feed), 
                      iconSize: isFeedActive ? 32 : 27,
                      onPressed: (() => {setPage(0)})
                    ),
                  ),
                  isFeedActive ? Positioned(
                    top: 38,
                    right: 8,
                    child: Text('Feed', style: GoogleFonts.getFont('Montserrat', color: Colors.green, fontSize: 12))
                  ) : Positioned(
                    top: 38,
                    right: 6,
                    child: Container()
                  )
                ]
              ),
              Stack(
                children: [
                  Container(
                    padding: isPlaylistsActive ? const EdgeInsets.fromLTRB(0, 0, 0, 12) : const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: IconButton(
                      color: isPlaylistsActive ? Colors.green : Color.fromARGB(255, 212, 212, 212),
                      icon: Icon(Icons.music_note), 
                      iconSize: isPlaylistsActive ? 32 : 27,
                      onPressed: (() => {setPage(1)})
                    ), 
                  ),
                  isPlaylistsActive ? Positioned(
                    top: 38,
                    right: 0,
                    child: Text('Playlists', style: GoogleFonts.getFont('Montserrat', color: Colors.green, fontSize: 12))
                  ) : Positioned(
                    top: 38,
                    right: 6,
                    child: Container()
                  )
                ]
              ),
              Stack(
                children: [
                  Container(
                    padding: isStatsActive ? const EdgeInsets.fromLTRB(0, 0, 0, 12) : const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: IconButton(
                      color: isStatsActive ? Colors.green : Color.fromARGB(255, 212, 212, 212),
                      icon: Icon(Icons.query_stats_rounded), 
                      iconSize: isStatsActive ? 32 : 27,
                      onPressed: (() => {setPage(2)})
                    ), 
                  ),
                  isStatsActive ? Positioned(
                    top: 38,
                    right: 8,
                    child: Text('Stats', style: GoogleFonts.getFont('Montserrat', color: Colors.green, fontSize: 12))
                  ) : Positioned(
                    top: 38,
                    right: 6,
                    child: Container()
                  )
                ]
              ),
              Stack(
                children: [
                  Container(
                    padding: isProfileActive ? const EdgeInsets.fromLTRB(0, 0, 0, 12) : const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: IconButton(
                      color: isProfileActive ? Colors.green : Color.fromARGB(255, 212, 212, 212),
                      icon: Icon(Icons.person), 
                      iconSize: isProfileActive ? 32 : 27,
                      onPressed: (() => {setPage(3)})
                    ), 
                  ),
                  isProfileActive ? Positioned(
                    top: 38,
                    right: 4,
                    child: Text('Profile', style: GoogleFonts.getFont('Montserrat', color: Colors.green, fontSize: 12))
                  ) : Positioned(
                    top: 38,
                    right: 4,
                    child: Container()
                  )
                ]
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          color: Colors.transparent
        ),
      ),
      floatingActionButton: Visibility(
        visible: false,
        child: Container(
          width: 100.0,
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
            child: Container(
              child: FloatingActionButton.extended(
                label: Text('Add post', style: GoogleFonts.getFont('Montserrat', 
                  color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20)),
                backgroundColor: Colors.green,
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
                }
              ),
            )
          ),
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
    );
  }
}