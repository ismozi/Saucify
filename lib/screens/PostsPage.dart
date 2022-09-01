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
  final Function displayProfile;
  PostsPage(this.displayProfile);
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
          child: StreamBuilder(
            stream: dbService.getFollowingSnapshot(service.userId),
            builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
              if (!snapshot1.hasData) {
                  return Container();
              }
              List userFollowing = [];
              snapshot1.data!.docs.forEach((element) {
                userFollowing.add(element.id);
              });
              userFollowing.add(service.userId);
              return StreamBuilder(
                  stream: dbService.getPostsStream(userFollowing),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                      );
                    } else { 
                      if (snapshot.data!.docs.isEmpty){
                        return Center(
                          child: Text('Follow your friends to see their posts!', 
                                style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 185, 185, 185), fontWeight: FontWeight.w300, fontSize: 17)),
                        );
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot post = snapshot.data!.docs[index];
                          return SongPost(
                            displayProfile: widget.displayProfile,
                            userId: post['postedBy'],
                            postId: post.id,
                            isLiked: post['likedBy'].contains(service.userId),
                            timestamp: post['timestamp'],
                            profileImgUrl: post['profileImgUrl'],
                            profileName: post['profileName'],
                            description: post['description'],
                            itemUrl: post['itemUrl'],
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
                );
              }
            )
          )
      ),
    );
  }
}