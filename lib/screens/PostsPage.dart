 import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/services/spotifyService.dart';
import '../app/app.locator.dart';
import 'package:saucify/widgets/SongPost.dart';

import '../services/DatabaseService.dart';
import '../widgets/PostForm.dart';

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
        color: Color.fromARGB(255, 10, 10, 10),
        child: Stack(children: [
        AnimatedOpacity(
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
                        padding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot post = snapshot.data!.docs[index];
                          if (index == 0){
                            return Container(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: Card(
                                  color: Color.fromARGB(255, 19, 19, 19),
                                  elevation: 8.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image(
                                        image: NetworkImage(post['profileImgUrl']), 
                                        width: 45, 
                                        height: 45
                                      )
                                    ),
                                    title: Card(
                                      color: Color.fromARGB(255, 26, 26, 26),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.search, color: Colors.green),
                                            Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                                            Text('Search and share something!', style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 185, 185, 185), fontWeight: FontWeight.w300, fontSize: 13))
                                          ]
                                        )
                                      )
                                    ),
                                  )
                                )
                              )
                            );
                          }
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
          ),
          // Positioned(
          //   top: MediaQuery.of(context).size.height * 0.888,
          //   left: MediaQuery.of(context).size.width * 0.5 - 60,
          //   child: Container(
          //     width: 100.0,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(20),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Color.fromARGB(255, 2, 2, 2).withOpacity(1),
          //           spreadRadius: 5,
          //           blurRadius: 7,
          //           offset: Offset(0, 3), // changes position of shadow
          //         ),
          //       ],
          //     ),
          //     child: FittedBox(
          //       child: Container(
          //         child: FloatingActionButton.extended(
          //           label: Text('Add post', style: GoogleFonts.getFont('Montserrat', 
          //             color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20)),
          //           backgroundColor: Colors.green,
          //           onPressed: () {
          //             showGeneralDialog(
          //               barrierDismissible: true,
          //               barrierLabel:
          //                   MaterialLocalizations.of(context).modalBarrierDismissLabel,
          //               transitionDuration: Duration(milliseconds: 200),
          //               context: context,
          //               pageBuilder: (ctx, anim1, anim2) => PostForm(),
          //               transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
          //                 filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
          //                 child: FadeTransition(
          //                   child: child,
          //                   opacity: anim1,
          //                 ),
          //               ),
          //             );
          //           }
          //         ),
          //       )
          //     ),
          //   ),
          // )
        ])
      ),
    );
  }
}