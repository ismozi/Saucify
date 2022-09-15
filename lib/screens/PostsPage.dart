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
                        padding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          if (index == 0){
                            return GestureDetector(
                              onTap: () {
                                showGeneralDialog(
                                  barrierDismissible: true,
                                  barrierLabel:
                                      MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                  transitionDuration: Duration(milliseconds: 200),
                                  context: context,
                                  pageBuilder: (ctx, anim1, anim2) => PostForm(),
                                  transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
                                    child: FadeTransition(
                                      child: child,
                                      opacity: anim1,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
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
                                          image: NetworkImage('https://scontent.fymq2-1.fna.fbcdn.net/v/t1.6435-9/49509493_2220570931333084_9073185916800991232_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=YFjTkrpSIjEAX-jPn8z&_nc_oc=AQlOprkDFtF0mkGFe_9mLW8YLx3Ll9g3ri5LJirC_qCXG3FOfhnA6SccOkbYvVEPNc4&_nc_ht=scontent.fymq2-1.fna&oh=00_AT-QsZe9PqKI15-hXXmqCyCsJC1Of6e-OZNRritSd81S0A&oe=632C2A80'), 
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
                                              Text('Share your new discovery!', style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 185, 185, 185), fontWeight: FontWeight.w300, fontSize: 13))
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
      ),
    );
  }
}