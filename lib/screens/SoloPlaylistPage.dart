import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/FeedAppBar.dart';
import 'package:tuple/tuple.dart';
import '../app/app.locator.dart';
import '../widgets/PlaylistItem.dart';

class SoloPlaylistPage extends StatefulWidget {

  @override
  State<SoloPlaylistPage> createState() => SoloPlaylistPageState();
}

class SoloPlaylistPageState extends State<SoloPlaylistPage> {
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  bool isPostsActive = true;
  bool isPlaylistsActive = false;

  bool isOneMonth = true;
  bool isFourMonths = false;
  bool isAllTime = false;
  String timeRange = 'short_term';
  double opacityLevel = 0;

  void setTimeRange(int index) {
    if (index == 0) {
      setState(() {
        isOneMonth = true;
        isFourMonths = false;
        isAllTime = false;
        timeRange = 'short_term';
      });
    } else if (index == 1) {
      setState(() {
        isOneMonth = false;
        isFourMonths = true;
        isAllTime = false;
        timeRange = 'medium_term';
      });
    } else if (index == 2) {
      setState(() {
        isOneMonth = false;
        isFourMonths = false;
        isAllTime = true;
        timeRange = 'long_term';
      });
    }
  }
 
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 0), () {
      setState(() => opacityLevel = 1);
    });
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Tuple2<bool, bool> setItemType(int index) {
    if (index == 0) {
      setState(() {
        isPostsActive = true;
        isPlaylistsActive = false;
      });
    } else if (index == 1) {
      setState(() {
        isPostsActive = false;
        isPlaylistsActive = true;
      });
    }

    return Tuple2<bool, bool>(isPostsActive, isPlaylistsActive);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        color: Color.fromARGB(255, 19, 19, 19),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: StreamBuilder(
            stream: dbService.getFollowingSnapshot(service.userId),
            builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                  return Container();
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot user = snapshot.data!.docs[index];
                  return PlaylistItem(timeRange: timeRange, user: user, key: ObjectKey(user));
                }
              );
            }
          )
        )
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: BottomAppBar(
          color: Color.fromARGB(255, 19, 19, 19),
          child: Container(
            padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: GestureDetector(
                    onTap:() => {setTimeRange(0)},
                    child: Text("1 Month", style: GoogleFonts.getFont(
                      'Montserrat',
                      color: isOneMonth ? Colors.green : Colors.white, 
                      fontWeight: isOneMonth ? FontWeight.w700 : FontWeight.w400)
                    ),
                  ),
                ),
                Container(
                  child: GestureDetector(
                    onTap:() => {setTimeRange(1)},
                    child: Text("6 Months", style: GoogleFonts.getFont(
                      'Montserrat',
                      color: isFourMonths ? Colors.green : Colors.white, 
                      fontWeight: isFourMonths ? FontWeight.w700 : FontWeight.w400)
                    ),
                  ),
                ),
                Container(
                  child: GestureDetector(
                    onTap:() => {setTimeRange(2)},
                    child: Text("All time", style: GoogleFonts.getFont(
                      'Montserrat',
                      color: isAllTime ? Colors.green : Colors.white, 
                      fontWeight: isAllTime ? FontWeight.w700 : FontWeight.w400)
                    ),
                  ),
                ),
              ]
            )
          ),
        ),
      ),
    );
  }
}