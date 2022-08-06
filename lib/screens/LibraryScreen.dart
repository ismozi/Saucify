import 'package:flutter/material.dart';
import 'package:saucify/screens/TopTracksScreen.dart';
import 'package:saucify/services/spotifyService.dart';

import '../app/app.locator.dart';

class LibraryScreen extends StatefulWidget {
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Widget> list = [];
  spotifyService service = locator<spotifyService>();

  void getPlaylists() async {
    List myPlaylists = await service.getPlaylists();
    List<Widget> newList = [];

    myPlaylists.forEach((playlist) { 
      newList.add(
        Container(
          color: Color.fromARGB(255, 29, 29, 29),
          margin: const EdgeInsets.all(3.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15) 
            ),
            title: Text(playlist['name'], 
                        style: TextStyle(color: Colors.white)),
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => TopTracksScreen(playlistId: playlist['id'], name: playlist['name'])))
            },
          ),
        )
      );
    });

    setState(() {
      list = newList;
    });
  }

  @override
  void initState() {
    super.initState();
    getPlaylists();
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
                  Text('Saucify'),
                  Opacity(
                    opacity: 0.5,
                    child: Text('My playlists')
                  )
                ]
              )
            ]
          )
      ),
      body: Container(
       color: Color.fromARGB(255, 41, 41, 41),
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: list
        ) 
      )
    );
  }
}