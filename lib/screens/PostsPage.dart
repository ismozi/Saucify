 import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import '../app/app.locator.dart';
import 'package:saucify/widgets/SongPost.dart';

import '../services/DatabaseService.dart';

class PostsPage extends StatefulWidget {
  @override
  State<PostsPage> createState() => PostsPageState();
}

class PostsPageState extends State<PostsPage> {
  spotifyService service = locator<spotifyService>();
  double opacityLevel = 0;
  final player = AudioPlayer();
  List<Widget> widgets = [];
  DatabaseService dbService = DatabaseService();
 
  @override
  void initState() {
    super.initState();
    // TODO: Fix temporary fade in
    Timer(Duration(milliseconds: 200), () {
      setState(() => opacityLevel = 1);
    });
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
          new StreamBuilder(
            stream: dbService.getPostsStream(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else { 
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot post = snapshot.data!.docs[index];
                    return SongPost(
                      postId: post.id,
                      isLiked: post['likedBy'].contains(service.userId),
                      timestamp: post['timestamp'],
                      profileImgUrl: post['profileImgUrl'],
                      profileName: post['profileName'],
                      description: post['description'],
                      itemImgUrl: post['itemImgUrl'],
                      itemName: post['itemName'],
                      artistName: post['postType'] == 'artist' ? null : post['artistName'],
                      previewUrl: post['postType'] == 'track' ? post['previewUrl'] : null,
                      player: player
                    );
                  }
                );
              }
            }
          )
            // ListView(
            //   children: widgets
            // ) 
          )
      ),
    );
  }
}