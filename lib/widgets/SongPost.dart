import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/screens/CommentsPage.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:saucify/widgets/ChooseOption.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app.locator.dart';
import '../screens/ProfilePage.dart';
import '../services/spotifyService.dart';

class SongPost extends StatefulWidget {
  SongPost({super.key,
            required this.displayProfile,
            required this.userId, 
            required this.postId,
            required this.isLiked,
            required this.likedBy,
            required this.timestamp,
            required this.profileImgUrl,
            required this.profileName,
            required this.description,
            required this.itemUrl,
            required this.itemImgUrl, 
            required this.itemName, 
            required this.artistName,
            required this.previewUrl,
            required this.comments,
            required this.player});

  Function displayProfile;
  String userId;
  String postId;
  bool isLiked;
  List likedBy;
  dynamic timestamp;
  dynamic profileImgUrl;
  String profileName;
  String description;
  String itemUrl;
  String itemImgUrl;
  String itemName;
  dynamic artistName;
  dynamic previewUrl;
  List comments;
  final player;

  @override
  State<SongPost> createState() => _SongPostState();
}

class _SongPostState extends State<SongPost> {
  bool isPlaying = false;
  spotifyService service = locator<spotifyService>();
  DatabaseService dbService = DatabaseService();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // TODO : manage listeners to remove
  void play() async {
    widget.player.pause();
    await widget.player.setSourceUrl(widget.previewUrl);
    widget.player.resume();
    
    setState(() {
      isPlaying = true;
    });

    widget.player.onPlayerStateChanged.listen((PlayerState s) {
      if (s == PlayerState.paused || s == PlayerState.stopped){
        setState(() {
          isPlaying = false;
        });
      }
    });
    widget.player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
      });
    });
  }

  void pause(){
    widget.player.pause();
  }

  String getTime() {
    // TODO : make it work for different timezones
    if (widget.timestamp == null) {
      return "";
    }
    int timeInSeconds = ((DateTime.now().millisecondsSinceEpoch - widget.timestamp.millisecondsSinceEpoch) / 1000).round();
    String time = "";
    if (timeInSeconds < 60) {
      time = "Just now.";
    } else if (timeInSeconds < 3600) {
      int timeInMinutes = (timeInSeconds / 60).round();
      time = timeInMinutes == 1 ? "1 minute ago." : "$timeInMinutes minutes ago.";
    } else if (timeInSeconds < 86400) {
      int timeInHours = (timeInSeconds / 3600).round();
      time = timeInHours == 1 ? "1 hour ago." : "$timeInHours hours ago.";
    } else {
      time = widget.timestamp.toDate().toString().split(' ')[0];
    }

    return time;
  }

  void toggleLike(){
    !widget.isLiked ? widget.likedBy.add(service.userId) : widget.likedBy.remove(service.userId);
    dbService.toggleLike(widget.postId, service.userId);
    setState(() {
      widget.isLiked = !widget.isLiked;
    });
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: GestureDetector(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image(
                    image: widget.profileImgUrl != null ? NetworkImage(widget.profileImgUrl) : emptyImage, 
                    width: 45, 
                    height: 45
                  )
                ),
                onTap: () => {
                  service.userId == widget.userId ? widget.displayProfile() :   
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => ProfilePage(widget.userId, false, true),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 150),
                  )),
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.more_horiz, 
                          color: Colors.grey),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        backgroundColor: Color.fromARGB(255, 12, 12, 12),
                        builder: (BuildContext context) {
                          return Container(
                            height: 250,
                            color: Color.fromARGB(255, 17, 17, 17),    
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 0.5, color:Color.fromARGB(255, 112, 112, 112)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.fromLTRB(60, 0, 60, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.share, color: Color.fromARGB(255, 112, 112, 112)),
                                        Padding(padding: EdgeInsets.fromLTRB(2.5, 0, 2.5, 0)),
                                        Text(
                                          'Share',
                                          style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 112, 112, 112), fontWeight: FontWeight.w600)
                                        ),
                                      ]
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  }
                                ),
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 0.5, color:Color.fromARGB(255, 100, 100, 100)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.fromLTRB(60, 20, 60, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_remove, color: Color.fromARGB(255, 100, 100, 100)),
                                        Padding(padding: EdgeInsets.fromLTRB(2.5, 0, 2.5, 0)),
                                        Text(
                                          'Unfollow',
                                          style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 100, 100, 100), fontWeight: FontWeight.w600)
                                        ),
                                      ]
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  }
                                ),
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 0.5, color:Color.fromARGB(255, 100, 100, 100)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.fromLTRB(60, 20, 60, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete, color: Color.fromARGB(255, 100, 100, 100)),
                                        Text(
                                          'Delete post',
                                          style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 100, 100, 100), fontWeight: FontWeight.w600)
                                        ),
                                      ]
                                    ),
                                  ),
                                  onTap: () {
                                    dbService.deletePost(widget.postId);
                                    Navigator.pop(context);
                                  }
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
                ]
              ),
              title: GestureDetector(
                child: Text(widget.profileName,
                       style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
                onTap: () => {   
                  service.userId == widget.userId ? widget.displayProfile() :
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (c, a1, a2) => ProfilePage(widget.userId, false, true),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 150),
                  )),
                },
              ),
              subtitle: Text(getTime(),
                        style: GoogleFonts.getFont('Montserrat', color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 10),
              child: Text(widget.description,
                  style: GoogleFonts.getFont('Montserrat', color: Colors.white))
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 26, 26, 26),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.03),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              margin: widget.likedBy.isEmpty && widget.comments.isEmpty ? const EdgeInsets.fromLTRB(12, 5, 12, 20) :
                      const EdgeInsets.fromLTRB(12, 5, 12, 15),
              child: GestureDetector(
                onTap: () async {
                  final Uri _url = Uri.parse(widget.itemUrl);
                  if (!await launchUrl(_url)) {
                    throw 'Could not launch $_url';
                  }
                },
                child : Container(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(image: NetworkImage(widget.itemImgUrl), width: 55, height: 55)
                      ),
                      widget.artistName != null ? 
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.itemName.length > 21 ? widget.itemName.substring(0, 21)+'...' : widget.itemName, 
                              style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 15)),
                            Padding(padding: EdgeInsets.fromLTRB(0, 3, 0, 0)),
                            Text(widget.artistName, 
                              style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 187, 187, 187), fontSize: 13)),
                          ]
                        )
                      ) : 
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(widget.itemName.length > 21 ? widget.itemName.substring(0, 21)+'...' : widget.itemName, 
                            style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 15))
                      )
                    ],
                  )
                )
                // trailing: IconButton(
                //   icon:Icon(!isPlaying ? Icons.more_horiz : Icons.pause_circle), 
                //   color: Colors.white,
                //   onPressed: (() {
                //     isPlaying ? pause() : 
                //     showGeneralDialog(
                //       barrierDismissible: true,
                //       barrierLabel:
                //         MaterialLocalizations.of(context).modalBarrierDismissLabel,
                //       transitionDuration: Duration(milliseconds: 100),
                //       context: context,
                //       pageBuilder: (ctx, anim1, anim2) => ChooseOption(play),
                //       transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
                //         filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
                //         child: FadeTransition(
                //           child: child,
                //           opacity: anim1,
                //         ),
                //       ),
                //     );
                //   })
                // ),
              )
            ),
            Row(
              children: [
                !widget.likedBy.isEmpty ? GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 10),
                    child: Text(widget.likedBy.length == 1 ? '1 like' : '${widget.likedBy.length} like', 
                      style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w200, fontSize: 13))
                  )
                ) : Container(),
                !widget.comments.isEmpty ? GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (c, a1, a2) => CommentsPage(isCommenting: false, postId: widget.postId),
                      transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                      transitionDuration: Duration(milliseconds: 150),
                    ));
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 10),
                    child: Text(widget.comments.length == 1 ? '1 comment' : '${widget.comments.length} comments', 
                      style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w200, fontSize: 13))
                  )
                ) : Container(),
              ]
            ),
            Divider(
              color: Color.fromARGB(255, 39, 39, 39),
              height: 1
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      toggleLike();
                    },
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(width: 0.000001, color: const Color(0xFFFFFFFF))),
                      padding: EdgeInsets.fromLTRB(25, 13, 22, 13),
                      child: Row(
                        children: [
                          Icon(widget.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, color: widget.isLiked ? Colors.green : Colors.grey, size: 15),
                          Padding(padding: const EdgeInsets.fromLTRB(5, 0, 0, 0)),
                          Text(widget.isLiked ? 'Unlike' : 'Like', style: GoogleFonts.getFont('Montserrat', color: widget.isLiked ? Colors.green : Colors.grey, fontSize: 12))
                        ]
                      )
                    )
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => CommentsPage(isCommenting: true, postId: widget.postId),
                          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                          transitionDuration: Duration(milliseconds: 150),
                        ));
                      },
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(width: 0.000001, color: const Color(0xFFFFFFFF))),
                      padding: EdgeInsets.fromLTRB(16, 13, 16, 13),
                      child: Row(
                        children: [
                          Icon(Icons.comment_outlined, color: Colors.grey, size: 15),
                          Padding(padding: const EdgeInsets.fromLTRB(5, 0, 0, 0)),
                          Text('Comment', style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontSize: 12))
                        ]
                      )
                    )
                  ),
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(width: 0.000001, color: const Color(0xFFFFFFFF))),
                      padding: EdgeInsets.fromLTRB(22, 13, 25, 13),
                      child: Row(
                        children: [
                          Icon(Icons.send_outlined, color: Colors.grey, size: 15),
                          Padding(padding: const EdgeInsets.fromLTRB(5, 0, 0, 0)),
                          Text('Share', style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontSize: 12))
                        ]
                      )
                    )
                  )
                ]
              )
            )
          ]
        ),
        color: Color.fromARGB(255, 18, 18, 18)
      )
    );
  }
}