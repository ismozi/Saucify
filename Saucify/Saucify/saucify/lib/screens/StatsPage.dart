import 'dart:async';
import 'dart:math';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';

import '../app/app.locator.dart';
import '../widgets/StatsAppBar.dart';

class StatsPage extends StatefulWidget {

  @override
  State<StatsPage> createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  spotifyService service = locator<spotifyService>();
  double opacityLevel = 0.0;
  List<Widget> list = [];

  bool isTracksActive = true;
  bool isArtistsActive = false;

  bool isOneMonth = true;
  bool isFourMonths = false;
  bool isAllTime = false;
  String timeRange = 'short_term';

  Tuple2<bool, bool> getOptionsState() {
    return Tuple2<bool, bool>(isTracksActive, isArtistsActive);
  }

  void setTimeRange(int index) {
    opacityLevel = 0;

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

    getTopItems();
  }

  void setItemType(int index) {
    opacityLevel = 0;

    if (index == 0) {
      setState(() {
        isTracksActive = true;
        isArtistsActive = false;
      });
    } else if (index == 1) {
      setState(() {
        isTracksActive = false;
        isArtistsActive = true;
      });
    }

    getTopItems();
  }

  void getTopItems() async {
    List myItems = isTracksActive ? await service.getTopItems('tracks', timeRange) : 
                  await service.getTopItems('artists', timeRange);
    List<Widget> newList = [];
    int itemPosition = 1;

    myItems.forEach((item) { 
      print(item['name']);
      print(item['album']['images'][0]['url']);
      newList.add(
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 29, 29, 29),
            borderRadius: BorderRadius.circular(12)
          ),
          margin: const EdgeInsets.all(3.0),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isTracksActive ? Image(image: NetworkImage(item['album']['images'][0]['url']), width: 45, height: 45) :
                                      Image(image: NetworkImage(item['images'][0]['url']), width: 45, height: 45)
            ),
            trailing: Text('#$itemPosition', style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w700)),
            title: Text(item['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            subtitle: isTracksActive ? Text(item['artists'][0]['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)) : null,
            onTap: () => {

            },
        )
      ));
      itemPosition++;
    });

    setState(() {
      list = newList;
      opacityLevel = 1.0;
    });
  }
  
  @override
  void initState() {
    super.initState();
    getTopItems();
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
      extendBodyBehindAppBar: true,
      appBar: StatsAppBar(setItemType, getOptionsState),
      body: Container(
       color: Color.fromARGB(255, 41, 41, 41),
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: ListView(
            children: list
            ) 
          )
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 20, 20, 20),
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
                  child: Text("4 Months", style: GoogleFonts.getFont(
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
    );
  }
}