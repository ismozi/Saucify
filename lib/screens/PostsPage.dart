 import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/PostFormPage.dart';
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
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 250),
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
                      // if (snapshot.data!.docs.isEmpty){
                      //   return Center(
                      //     child: Text('Follow your friends to see their posts!', 
                      //           style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 185, 185, 185), fontWeight: FontWeight.w300, fontSize: 17)),
                      //   );
                      // }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
                        itemCount: snapshot.data!.docs.length+1,
                        itemBuilder: (context, index) {
                          if (index == 0){
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (c, a1, a2) => PostFormPage(),
                                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                                  transitionDuration: Duration(milliseconds: 150),
                                ));
                              },
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Card(
                                    color: Color.fromARGB(255, 19, 19, 19),
                                    elevation: 8.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image(
                                          image: NetworkImage('https://scontent-lga3-2.xx.fbcdn.net/v/t1.6435-9/49509493_2220570931333084_9073185916800991232_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=hw2IsM4iAWgAX-1zwIx&_nc_oc=AQl2TFp6DGxQ9CQz_RMB5RV5qKZ1qtk5M89GCNHiwibgWYHj8izY-5hrdEvNABBAgCA&_nc_ht=scontent-lga3-2.xx&oh=00_AT8_paZq2Xa1JgiuwicBcohOTGf_8hfFtnVqzlxk1yw9og&oe=6353B780'), 
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
                                          padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                                          child: Row(
                                            children: [
                                              Icon(Icons.search, color: Colors.green, size: 20),
                                              Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0)),
                                              Text('Search and share your new discovery!', style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 185, 185, 185), fontWeight: FontWeight.w300, fontSize: 11.5))
                                            ]
                                          )
                                        )
                                      ),
                                    )
                                  )
                                )
                              )
                            );
                          }
                          DocumentSnapshot post = snapshot.data!.docs[index-1];
                          return SongPost(
                            displayProfile: widget.displayProfile,
                            userId: post['postedBy'],
                            postId: post.id,
                            isLiked: post['likedBy'].contains(service.userId),
                            likedBy: post['likedBy'],
                            timestamp: post['timestamp'],
                            profileImgUrl: post['profileImgUrl'],
                            profileName: post['profileName'],
                            description: post['description'],
                            itemUrl: post['itemUrl'],
                            itemImgUrl: post['itemImgUrl'],
                            itemName: post['itemName'],
                            artistName: post['postType'] == 'artist' ? null : post['artistName'],
                            previewUrl: post['postType'] == 'track' ? post['previewUrl'] : null,
                            comments: post['comments'],
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
      ),
    );
  }
}