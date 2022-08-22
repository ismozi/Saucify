import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import '../app/app.locator.dart';
import 'package:saucify/widgets/SongPost.dart';

class PostsPage extends StatefulWidget {

  @override
  State<PostsPage> createState() => PostsPageState();
}

class PostsPageState extends State<PostsPage> {
  spotifyService service = locator<spotifyService>();
  double opacityLevel = 1;
  final player = AudioPlayer();
 
  
  @override
  void initState() {
    super.initState();
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
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        color: Color.fromARGB(255, 37, 37, 37),
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 300),
          child: 
            ListView(
              children: <Widget>[
                Container(padding: EdgeInsets.fromLTRB(0, 7, 0, 0)),
                SongPost(profileImgUrl: 'https://www.mtlblog.com/media-library/mike-ward-offered-mayor-plante-25-shelters-for-unhoused-montrealers-she-responded.jpg?id=28884878&width=600&coordinates=318%2C0%2C252%2C0&height=600',
                  profileName: 'Mike Ward',
                  description: "C'est insane écoutes ça mon chum!",
                  songImgUrl: 'https://i.scdn.co/image/ab67616d0000b2732a7db835b912dc5014bd37f4',
                  songName: 'Saint Pablo',
                  artistName: 'Kanye West',
                  previewUrl: 'https://p.scdn.co/mp3-preview/05254ff5f4014a7481bb184fe4b11db953f8aca3?cid=ab34da279af84ac5a6573a70f14a1b0a',
                  player: player
                ),
                SongPost(profileImgUrl: 'https://i.insider.com/5ffc93f9d184b30018aae194?width=1136&format=jpeg',
                  profileName: 'Georges St-Pierre',
                  description: "Wow!!!! Époustouflant!",
                  songImgUrl: 'https://i.scdn.co/image/ab67616d0000b2730fad23eafd8a89ee479cc611',
                  songName: 'I Hope to Be Around',
                  artistName: 'Men I Trust',
                  previewUrl: 'https://p.scdn.co/mp3-preview/3a10442d3a4ae6aa933d6a47559498e2bb526844?cid=ab34da279af84ac5a6573a70f14a1b0a',
                  player: player
                ),
                SongPost(profileImgUrl: 'https://www.montrealcentreville.ca/wp-content/uploads/2021/03/MTL_CV-Adib-Alkhalidey-Inside-credit-Jocelyn-Michel.jpg',
                  profileName: 'Adib Alkhalidey',
                  description: "Fou beat! The Weekend da goat.",
                  songImgUrl: 'https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36',
                  songName: 'After Hours',
                  artistName: 'The Weekend',
                  previewUrl: 'https://p.scdn.co/mp3-preview/9c0ca877bd80e459e2117543f45fc7ae2680913c?cid=ab34da279af84ac5a6573a70f14a1b0a',
                  player: player
                ),
                SongPost(profileImgUrl: 'https://ville.montreal.qc.ca/ordre/sites/ville.montreal.qc.ca.ordre/files/styles/ordre-screen-sm-square/public/yvon_deschamps.jpg?itok=9c2uczVm&c=23584e489367c7b54c6c3cdb9c0683da',
                  profileName: 'Yvon Deschamps',
                  description: "Malade",
                  songImgUrl: 'https://i.scdn.co/image/ab67616d0000b273aacc3ddf3bfa01f4bd44cacc',
                  songName: 'Survivors Guilt',
                  artistName: 'Joey Badass',
                  previewUrl: 'https://p.scdn.co/mp3-preview/52f447701f6551a8378b066770ca315cd4e966b1?cid=ab34da279af84ac5a6573a70f14a1b0a',
                  player: player
                ),
              ]
            ) 
          )
      ),
    );
  }
}