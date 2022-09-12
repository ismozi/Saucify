import 'dart:async';

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
  List topTracks;
  List topArtists;
  List targetUserFollowing;
  bool isFollowed;
  bool isCurrentUser;
  ProfileContainer(this.topTracks, this.topArtists, this.user, this.targetUserFollowing, this.isFollowed, this.isCurrentUser, {required Key key}): super(key: key);
  @override
  _ProfileContainerState createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  DatabaseService dbService = DatabaseService();
  spotifyService service = locator<spotifyService>();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  Map<String, dynamic> user = {};
  double opacityLevel = 0;

  @override
  void initState() {
    super.initState();
    user = widget.user.data() as Map<String, dynamic>;
    Timer(Duration(milliseconds: 0), () {
      setState(() => opacityLevel = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacityLevel,
      duration: const Duration(milliseconds: 300),
        child: Column(
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
                  child: Image(image: user['imageUrl'] != null ? NetworkImage(user['imageUrl']): emptyImage, width: 150, height: 150)
                )
              )
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Text(user['username'], 
                style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontWeight: FontWeight.w300, fontSize: 25)),
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
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 12, 12, 12),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 14, 14, 14).withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
                  width: 100,
                  child: GestureDetector(
                    child: Text("Followers:  ${user['followers'].length}", 
                            style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontWeight: FontWeight.w300, fontSize: 14)),
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => UserListPage(widget.user.id, true),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 150),
                      ));
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 0)),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 12, 12, 12),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 14, 14, 14).withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
                  width: 100,
                  child: GestureDetector(
                    child: Text("Following:  ${widget.targetUserFollowing.length}", 
                            style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontWeight: FontWeight.w300, fontSize: 14)),
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => UserListPage(widget.user.id, false),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 150),
                      ));
                    },
                  )
                )
              ]
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            Divider(
              color: Color.fromARGB(255, 77, 77, 77)
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Text("Top Songs All Time", 
                style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontWeight: FontWeight.w500, fontSize: 17)),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 12, 0, 0)),
            GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: 4,
              primary: false,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => Card(
                color: Color.fromARGB(255, 29, 29, 29),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image(image: NetworkImage(widget.topTracks[index]['album']['images'][0]['url']), width: 45, height: 45)
                  ),
                  title: Text(widget.topTracks[index]['name'].length > 15 ? widget.topTracks[index]['name'].substring(0, 15)+'...' : widget.topTracks[index]['name'], 
                            style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 12)),
                )
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Text("Top Artists All Time", 
                style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontWeight: FontWeight.w500, fontSize: 17)),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 12, 0, 0)),
            GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: 4,
              primary: false,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => Card(
                color: Color.fromARGB(255, 29, 29, 29),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image(image: NetworkImage(widget.topArtists[index]['images'][0]['url']), width: 45, height: 45)
                  ),
                  title: Text(widget.topArtists[0]['name'].length > 15 ? widget.topArtists[index]['name'].substring(0, 15)+'...' : widget.topArtists[index]['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontSize: 12)),
                )
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
            ),
          ]
        )
    );
  }
}