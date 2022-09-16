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
import 'MixedPlaylistPage.dart';
import 'SoloPlaylistPage.dart';

class PlaylistsPage extends StatefulWidget {
  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  spotifyService service = locator<spotifyService>();
  TextEditingController controller = TextEditingController();
  List<Widget> list = [];
  double opacityLevel = 0;
  final player = AudioPlayer();

  bool isPostsActive = false;
  bool isPlaylistsActive = true;

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

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
  
  Tuple2<bool, bool> setItemType(int index) {
    if (index == 0) {
      setState(() {
        isPostsActive = true;
        isPlaylistsActive = false;
      });
    } else if (index == 1) {
      setState(() {
        isPostsActive = false;
        isPlaylistsActive = true;
      });
    }

    return Tuple2<bool, bool>(isPostsActive, isPlaylistsActive);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: isPostsActive ? SoloPlaylistPage() : MixedPlaylistPage()
    );
  }
}