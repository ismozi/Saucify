import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:saucify/widgets/SongPost.dart';
import '../app/app.locator.dart';

class FeedPage extends StatefulWidget {
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  spotifyService service = locator<spotifyService>();
  TextEditingController controller = TextEditingController();
  List<Widget> list = [];
  double opacityLevel = 0;

  @override
  void initState() {
    super.initState();
    opacityLevel = 1;
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
      body: 
        Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: Color.fromARGB(255, 41, 41, 41),
          child: AnimatedOpacity(
            opacity: opacityLevel,
            duration: const Duration(milliseconds: 300),
            child: 
              ListView(
                children: <Widget>[
                  Container(padding: EdgeInsets.fromLTRB(0, 6, 0, 0)),
                  SongPost(profileImgUrl: 'https://www.mtlblog.com/media-library/mike-ward-offered-mayor-plante-25-shelters-for-unhoused-montrealers-she-responded.jpg?id=28884878&width=600&coordinates=318%2C0%2C252%2C0&height=600',
                    profileName: 'Mike Ward',
                    description: "C'est insane écoutes ça mon chum!",
                    songImgUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUMrNo064B18CA3smtwWl8KD-SGs9KEk5fxQ&usqp=CAU',
                    songName: 'Saint Pablo',
                    artistName: 'Kanye West'
                  ),
                  SongPost(profileImgUrl: 'https://i.insider.com/5ffc93f9d184b30018aae194?width=1136&format=jpeg',
                    profileName: 'Georges St-Pierre',
                    description: "Wow!!!! Époustouflant!",
                    songImgUrl: 'https://i.scdn.co/image/ab67616d0000b2730fad23eafd8a89ee479cc611',
                    songName: 'I Hope to Be Around',
                    artistName: 'Men I Trust'
                  ),
                  SongPost(profileImgUrl: 'https://www.montrealcentreville.ca/wp-content/uploads/2021/03/MTL_CV-Adib-Alkhalidey-Inside-credit-Jocelyn-Michel.jpg',
                    profileName: 'Adib Alkhalidey',
                    description: "Fou beat! The Weekend da goat.",
                    songImgUrl: 'https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36',
                    songName: 'After Hours',
                    artistName: 'The Weekend'
                  ),
                  SongPost(profileImgUrl: 'https://ville.montreal.qc.ca/ordre/sites/ville.montreal.qc.ca.ordre/files/styles/ordre-screen-sm-square/public/yvon_deschamps.jpg?itok=9c2uczVm&c=23584e489367c7b54c6c3cdb9c0683da',
                    profileName: 'Yvon Deschamps',
                    description: "Asti m'attendais pas à aimer d'la musique de yo!",
                    songImgUrl: 'https://i.scdn.co/image/ab67616d0000b273aacc3ddf3bfa01f4bd44cacc',
                    songName: 'Survivors Guilt',
                    artistName: 'Joey Badass'
                  ),
                ]
              ) 
          )
        ),
      );
  }
}