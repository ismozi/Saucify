import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:saucify/widgets/bottomPlayer.dart';
import 'package:tuple/tuple.dart';

import '../app/app.locator.dart';

class TopTracksScreen extends StatefulWidget {
  TopTracksScreen({super.key, required this.playlistId, required this.name});
  String playlistId;
  String name;

  @override
  State<TopTracksScreen> createState() => TopTracksScreenState();
}

class TopTracksScreenState extends State<TopTracksScreen> {
  List<Widget> list = [];
  List<Widget> deviceList = [];
  spotifyService service = locator<spotifyService>();
  bool isPlayerShown = false;
  dynamic bottomAppBar = BottomAppBar();
  List topTracks = [];
  double opacityLevel = 0.0;

  void shuffle(){
    int randomIndex = Random().nextInt(topTracks.length);
    dynamic randomTrack = topTracks[randomIndex];
    
    playMusic(randomTrack['track']['uri'], 
              randomTrack['track']['album']['images'][0]['url'], 
              randomTrack['track']['name'], 
              randomTrack['track']['artists'][0]['name']);
  }

  List<Widget> generateWidget() {
    List<Widget> newList = [];

    topTracks.forEach((item) => {
      newList.add(
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 29, 29, 29),
            borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          margin: const EdgeInsets.all(1.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15) 
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(item['track']['album']['images'][0]['url']), 
                width: 45, 
                height: 45
              )
            ),
            title: Text(item['track']['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            subtitle: Text(item['track']['artists'][0]['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            onTap: () => {
              playMusic(item['track']['uri'], 
                        item['track']['album']['images'][0]['url'], 
                        item['track']['name'], 
                        item['track']['artists'][0]['name'])
            },
          ),
        )
      )
    });

    return newList;
  }

  void getDevices() async {
    List devices = await service.getDevices();
    List<Widget> newList = [];
    
    devices.forEach((device) => {
      newList.add(
      SimpleDialogOption(
            child: Text(device['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.black)),
            onPressed: () => {
              service.deviceId = device['id']
            },
          ),
      )
    });

    newList.add(
      SimpleDialogOption(
        child: Text('Open Spotify'),
        onPressed: () async {
        },
      )
    );

    setState(() {
      deviceList = newList;
    });
  }

  void getTracks() async{
    Tuple2<dynamic, List> playlistTuple = await service.getPlaylistTracks(widget.playlistId);

    topTracks.addAll(playlistTuple.item2);
    dynamic nextUri = playlistTuple.item1;

    setState(() {
      list = generateWidget();
      opacityLevel = 1.0;
    });

    while (nextUri != null){
      playlistTuple = await service.getPlaylistTracks(widget.playlistId, nextUri);

      topTracks.addAll(playlistTuple.item2);
      nextUri = playlistTuple.item1;

      setState(() {
        list = generateWidget();
      });
    }
  }

  void playMusic(String uri, String imgUrl, String songName, String artistName) {
    service.playMusic(uri);
    setState(() {
      isPlayerShown = true;
      bottomAppBar = BottomPlayer(imgUrl: imgUrl, songName: songName, artistName: artistName);
    });
  }

  @override
  void initState() {
    super.initState();
    getTracks();
    getDevices();
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
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.devices), onPressed: (() {
            showDialog(context: context, 
                       builder: (ctx) => SimpleDialog(
                          title: Text("Choose a device"),
                          children: deviceList,
                        )
                      );
              getDevices();
          })),
          backgroundColor: Color.fromARGB(255, 20, 20, 20),
          foregroundColor: Colors.green,
          automaticallyImplyLeading: false,
          title: 
              Column(
                children: [
                  Text('Saucify', style: GoogleFonts.getFont('Montserrat', fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)),
                ]
              )
           
      ),
      body: Container(
        color: Color.fromARGB(255, 41, 41, 41),
        padding: const EdgeInsets.all(10.0),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: ListView(
            children: list
            ) 
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.shuffle, color: Colors.black), onPressed: () {shuffle();}
      ),
      bottomNavigationBar: !isPlayerShown ? null : bottomAppBar,
    );
  }
}
