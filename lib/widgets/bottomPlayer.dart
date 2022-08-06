import 'package:flutter/material.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class BottomPlayer extends StatefulWidget {
  BottomPlayer({super.key, required this.imgUrl, required this.songName, required this.artistName});
  String imgUrl;
  String songName;
  String artistName;
  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  spotifyService service = locator<spotifyService>();
  bool isPlaying = true;

  void togglePlayer() async {
    service.togglePlayer();
    setState(() {
      isPlaying = !isPlaying;
    });
  }
  
  @override
  Widget build(BuildContext context){
    return BottomAppBar(
      color: Color.fromARGB(255, 20, 20, 20),
      shape: CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 65.0,
            child: Image(image: NetworkImage(widget.imgUrl), width: 45, height: 45),
            margin: EdgeInsets.fromLTRB(15, 0, 0, 0)
          ),
          Text('${widget.songName} - ${widget.artistName}', style: TextStyle(color: Colors.grey),),
          IconButton(color: Colors.grey, icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow), onPressed: () {togglePlayer();}),
        ],
      ),
    );
  }
}