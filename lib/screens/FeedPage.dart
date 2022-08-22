import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/PlaylistsPage.dart';
import 'package:saucify/screens/PostsPage.dart';
import 'package:saucify/services/spotifyService.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:saucify/widgets/FeedAppBar.dart';
import 'package:saucify/widgets/SongPost.dart';
import 'package:saucify/widgets/StatsAppBar.dart';
import 'package:tuple/tuple.dart';
import '../app/app.locator.dart';

class FeedPage extends StatefulWidget {
  final Function setFAB;
  FeedPage(this.setFAB);
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  spotifyService service = locator<spotifyService>();
  TextEditingController controller = TextEditingController();
  List<Widget> list = [];
  double opacityLevel = 0;
  final player = AudioPlayer();

  bool isPostsActive = true;
  bool isPlaylistsActive = false;

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.setFAB(0);
    opacityLevel = 1;
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
        widget.setFAB(0);
      });
    } else if (index == 1) {
      setState(() {
        isPostsActive = false;
        isPlaylistsActive = true;
        widget.setFAB(1);
      });
    }

    return Tuple2<bool, bool>(isPostsActive, isPlaylistsActive);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FeedAppBar(setItemType),
      body: isPostsActive ? PostsPage() : PlaylistsPage()
    );
  }
}