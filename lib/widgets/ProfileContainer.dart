import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/app/app.locator.dart';
import 'package:saucify/screens/UserListPage.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:tuple/tuple.dart';

import '../services/spotifyService.dart';

class ProfileContainer extends StatefulWidget{
  final DocumentSnapshot user;
  List targetUserFollowing;
  bool isFollowed;
  bool isCurrentUser;
  ProfileContainer(this.user, this.targetUserFollowing, this.isFollowed, this.isCurrentUser, {required Key key}): super(key: key);
  @override
  _ProfileContainerState createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  DatabaseService dbService = DatabaseService();
  spotifyService service = locator<spotifyService>();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    user = widget.user.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
        Container( 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 27, 27, 27).withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Image(image: user['imageUrl'] != null ? NetworkImage(user['imageUrl']): emptyImage, width: 180, height: 180)
            )
          )
        ),
        Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Text(user['username'], 
            style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w300, fontSize: 30)),
        Padding(padding: !widget.isCurrentUser ? const EdgeInsets.fromLTRB(0, 10, 0, 0) : const EdgeInsets.fromLTRB(0, 0, 0, 0)),
        Container(
          child: !widget.isCurrentUser ? GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: widget.isFollowed ? Colors.green :Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: EdgeInsets.all(5),
              child: Text(widget.isFollowed ? 'Following' : 'Follow',
              style: GoogleFonts.getFont('Montserrat', color: widget.isFollowed ? Colors.green :Colors.grey))
            ), 
            onTap: () async {
              await dbService.toggleFollow(service.userId, widget.user.id);
              setState(() {
                widget.isFollowed = !widget.isFollowed;
              });
            },
          ) : null,
        ),
        Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: Text("Followers: ${user['followers'].length}", 
                      style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 17)),
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => UserListPage(widget.user.id, true),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: Duration(milliseconds: 150),
                ));
              },
            ),
            Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
            GestureDetector(
              child: Text("Following: ${widget.targetUserFollowing.length}", 
                      style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 17)),
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => UserListPage(widget.user.id, false),
                  transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: Duration(milliseconds: 150),
                ));
              },
            )
          ]
        ),
        Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
        Divider(
          color: Color.fromARGB(255, 80, 80, 80)
        )
      ]
    );
  }
}