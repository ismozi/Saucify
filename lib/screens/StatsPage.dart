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

    if (isTracksActive) {
      newList.add(
        GestureDetector(
          onTap: () {
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 26, 26, 26),
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.6),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            margin: const EdgeInsets.fromLTRB(28, 2, 28, 7),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Generate playlist', style: GoogleFonts.getFont('Montserrat', 
                  color: Colors.white, fontWeight: FontWeight.w300, fontSize: 17)),
                Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                ImageIcon(
                    AssetImage("assets/images/Spotify_Icon_RGB_White.png"),
                    color: Colors.green,
                ),
              ]
            ),
          )
        )
      );
    }

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
            trailing: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.06,
                width: MediaQuery.of(context).size.width * 0.06,
                color: Color.fromARGB(255, 46, 46, 46),
                padding: EdgeInsets.all(2),
                child: Center(
                  child: Text('$itemPosition', style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w300))
                )
              )
            ),
            title: Text(item['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            subtitle: isTracksActive ? Text(item['artists'][0]['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 187, 187, 187))) : null,
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
      body: Stack(
        children: [
          Container(
          color: Color.fromARGB(255, 10, 10, 10),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
            child: AnimatedOpacity(
              opacity: opacityLevel,
              duration: const Duration(milliseconds: 250),
              child: ListView(
                children: list
                ) 
              )
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.88,
            right: MediaQuery.of(context).size.width * 0.14,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
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
                  Padding(padding: EdgeInsets.fromLTRB(7, 0, 5, 0)),
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
                  Padding(padding: EdgeInsets.fromLTRB(5, 0, 7, 0)),
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
            )
          )
        ]
      )
    );
  }
}