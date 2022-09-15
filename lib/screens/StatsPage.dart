import 'dart:async';
import 'dart:math';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

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

  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');

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
    
    list = [];
    getTopItems(isTracksActive, timeRange);
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

    list = [];
    getTopItems(isTracksActive, timeRange);
  }


  void getTopItems(bool itemTypeAtStart, String timeRangeAtStart) async{
    List topItems = [];
    Tuple2<dynamic, List> myItemsTuple = isTracksActive ? await service.getTopItems1('tracks', timeRange) : 
                                         await service.getTopItems1('artists', timeRange);

    topItems.addAll(myItemsTuple.item2);
    dynamic nextUri = myItemsTuple.item1;

    setState(() {
      if (itemTypeAtStart == isTracksActive && timeRangeAtStart == timeRange) {
        list = generateWidget(topItems);
        opacityLevel = 1.0;
      } else {
        return;
      }
    });

    while (nextUri != null){
      myItemsTuple = isTracksActive ? await service.getTopItems1('tracks', timeRange, nextUri) : 
                     await service.getTopItems1('artists', timeRange, nextUri);

      topItems.addAll(myItemsTuple.item2);
      nextUri = myItemsTuple.item1;

      setState(() {
        if (itemTypeAtStart == isTracksActive && timeRangeAtStart == timeRange) {
          list = generateWidget(topItems);
        } else {
          return;
        }
      });
    }
  }

  List<Widget> generateWidget(List topItems) {
    List<Widget> newList = [];
    int itemPosition = 1;

    topItems.forEach((item) { 
      newList.add(
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 19, 19, 19),
            borderRadius: BorderRadius.circular(12)
          ),
          margin: const EdgeInsets.all(3.0),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isTracksActive ? Image(image: item['album']['images'] != null ? NetworkImage(item['album']['images'][0]['url']) : emptyImage, width: 45, height: 45) :
                                      Image(image: item['images'] != null ? NetworkImage(item['images'][0]['url']) : emptyImage, width: 45, height: 45)
            ),
            trailing: Text('#$itemPosition', style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w700)),
            title: Text(item['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            subtitle: isTracksActive ? Text(item['artists'][0]['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)) : null,
            onTap: () async {
              final Uri _url = Uri.parse(item['uri']);
              if (!await launchUrl(_url)) {
                throw 'Could not launch $_url';
              }
            },
        )
      ));
      itemPosition++;
    });
    return newList;
  }
  
  @override
  void initState() {
    super.initState();
    getTopItems(isTracksActive, timeRange);
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
       color: Color.fromARGB(255, 10, 10, 10),
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: ListView(
            children: list
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
          color: Color.fromARGB(255, 0, 0, 0),
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
      )
    );
  }
}