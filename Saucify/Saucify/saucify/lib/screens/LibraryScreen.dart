import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  double opacityLevel = 0.0;

  void getPlaylists() async {
    List myPlaylists = await service.getPlaylists();
    List<Widget> newList = [];

    myPlaylists.forEach((playlist) { 
      newList.add(
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 29, 29, 29),
            borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          margin: const EdgeInsets.all(3.0),
          child: ListTile(
            leading: !playlist['images'].isEmpty ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(playlist['images'][0]['url']), 
                width: 40, 
                height: 40
              )
            ) : null,
            title: Text(playlist['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => TopTracksScreen(playlistId: playlist['id'], name: playlist['name'])))
            },
          ),
        )
      );
      print(playlist['images']);
    });

    setState(() {
      list = newList;
      opacityLevel = 1.0;
    });
  }

  @override
  void initState() {
    super.initState();
    getPlaylists();
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
      body: Container(
       color: Color.fromARGB(255, 41, 41, 41),
        padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: ListView(
            children: list
            ) 
          )
      )
    );
  }
}