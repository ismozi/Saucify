import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:saucify/app/app.locator.dart';
import 'package:saucify/screens/UserListPage.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/ArtistsScreen.dart';
import '../screens/TracksScreen.dart';
import '../services/spotifyService.dart';

class ProfileContainer extends StatefulWidget{
  final DocumentSnapshot user;
  Map<String, dynamic> topTracksIds;
  Map<String, dynamic> topArtistsIds;
  Map<String, dynamic> topTracks;
  Map<String, dynamic> topArtists;
  List targetUserFollowing;
  bool isFollowed;
  bool isCurrentUser;
  ProfileContainer(this.topTracksIds, this.topArtistsIds, this.topTracks, this.topArtists, this.user, this.targetUserFollowing, this.isFollowed, this.isCurrentUser, {required Key key}): super(key: key);
  @override
  _ProfileContainerState createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  DatabaseService dbService = DatabaseService();
  spotifyService service = locator<spotifyService>();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  Map<String, dynamic> user = {};
  double opacityLevel = 0;

  List topTracksIds = [];
  List topArtistsIds = [];

  final tracksController = PageController(viewportFraction: 0.99);
  final artistsController = PageController(viewportFraction: 0.99);
  final tracksCurrentPageNotifier = ValueNotifier<int>(0);
  final artistsCurrentPageNotifier = ValueNotifier<int>(0);
  
  @override
  void initState() {
    super.initState();
    print(widget.topTracks);
    user = widget.user.data() as Map<String, dynamic>;
    topTracksIds = widget.topTracksIds['long'];
    topArtistsIds = widget.topArtistsIds['long'];
    Timer(Duration(milliseconds: 0), () {
      setState(() => opacityLevel = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacityLevel,
      duration: const Duration(milliseconds: 250),
        child: Column(
          children: [
            widget.isCurrentUser ? Padding(padding: const EdgeInsets.fromLTRB(0, 85, 0, 0)) :
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
            Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 0)),
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
            Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 26, 26, 26),
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
                    color: Color.fromARGB(255, 26, 26, 26),
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
            Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 0)),
            Divider(
              color: Color.fromARGB(255, 49, 49, 49)
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 5, 0, 0)),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tracksCurrentPageNotifier.value == 0 ? 'Top Songs All Time' : 
                       tracksCurrentPageNotifier.value == 1 ? 'Top Songs Last 6 Months' :
                       'Top Songs This Month',
                    style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontWeight: FontWeight.w500, fontSize: 17)),
                  IconButton(
                    color: Colors.green,
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.expand_circle_down), onPressed: () async {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => TracksScreen(tracksIds: topTracksIds, 
                        playlistName: tracksCurrentPageNotifier.value == 0 ? 'Top Songs All Time' : 
                                      tracksCurrentPageNotifier.value == 1 ? 'Top Songs Last 6 Months' :
                                      'Top Songs This Month'),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 150),
                      ));
                    }
                  )
                ],
              )
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 12, 0, 0)),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.16,
              child: PageView(
                onPageChanged: (int index) {
                  setState(() {
                    tracksCurrentPageNotifier.value = index;
                    if (index == 0){
                      topTracksIds = widget.topTracksIds['long'];
                    } else if (index == 1) {
                      topTracksIds = widget.topTracksIds['medium'];
                    } else {
                      topTracksIds = widget.topTracksIds['short'];
                    }
                  });
                },
                children: [
                  GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: 4,
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => GestureDetector(
                      child: Card(
                        color: Color.fromARGB(255, 19, 19, 19),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 0)),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image(image: NetworkImage(widget.topTracks['long'][index]['album']['images'][0]['url']), width: 42, height: 42)
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 2, 0)),
                                  Text(widget.topTracks['long'][index]['name'].length > 11 ? widget.topTracks['long'][index]['name'].substring(0, 11)+'...' : widget.topTracks['long'][index]['name'], 
                                      style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontSize: 11)),
                                ]
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    child: Text('${index+1}', 
                                            style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 11)),
                                  )
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      onTap: () async {
                        final Uri _url = Uri.parse(widget.topTracks['long'][index]['uri']);
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                  ),
                  GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: 4,
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => GestureDetector(
                      child: Card(
                        color: Color.fromARGB(255, 19, 19, 19),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 0)),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image(image: NetworkImage(widget.topTracks['medium'][index]['album']['images'][0]['url']), width: 42, height: 42)
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 2, 0)),
                                  Text(widget.topTracks['medium'][index]['name'].length > 11 ? widget.topTracks['medium'][index]['name'].substring(0, 11)+'...' : widget.topTracks['medium'][index]['name'], 
                                      style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontSize: 11)),
                                ]
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    child: Text('${index+1}', 
                                            style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 11)),
                                  )
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      onTap: () async {
                        final Uri _url = Uri.parse(widget.topTracks['medium'][index]['uri']);
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                  ),
                  GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: 4,
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => GestureDetector(
                      child: Card(
                        color: Color.fromARGB(255, 19, 19, 19),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 0)),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image(image: NetworkImage(widget.topTracks['short'][index]['album']['images'][0]['url']), width: 42, height: 42)
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 2, 0)),
                                  Text(widget.topTracks['short'][index]['name'].length > 11 ? widget.topTracks['short'][index]['name'].substring(0, 11)+'...' : widget.topTracks['short'][index]['name'], 
                                      style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontSize: 11)),
                                ]
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    child: Text('${index+1}', 
                                            style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 11)),
                                  )
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      onTap: () async {
                        final Uri _url = Uri.parse(widget.topTracks['short'][index]['uri']);
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                  ),
                ], // Can be null
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            CirclePageIndicator(
              size: 3,
              itemCount: 3,
              currentPageNotifier: tracksCurrentPageNotifier,
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(artistsCurrentPageNotifier.value == 0 ? 'Top Artists All Time' : 
                       artistsCurrentPageNotifier.value == 1 ? 'Top Artists Last 6 Months' :
                       'Top Artists This Month', 
                    style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontWeight: FontWeight.w500, fontSize: 17)),
                  IconButton(
                    color: Colors.green,
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.expand_circle_down), onPressed: () async {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => ArtistsScreen(artistsIds: topArtistsIds, 
                        pageName: artistsCurrentPageNotifier.value == 0 ? 'Top Artists All Time' : 
                                  artistsCurrentPageNotifier.value == 1 ? 'Top Artists Last 6 Months' :
                                  'Top Artists This Month'),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 150),
                      ));
                    }
                  )
                ],
              )
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 12, 0, 0)),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.16,
              child: PageView(
                physics: AlwaysScrollableScrollPhysics(),
                onPageChanged: (int index) {
                  setState(() {
                    artistsCurrentPageNotifier.value = index;
                    if (index == 0){
                      topArtistsIds = widget.topArtistsIds['long'];
                    } else if (index == 1) {
                      topArtistsIds = widget.topArtistsIds['medium'];
                    } else {
                      topArtistsIds = widget.topArtistsIds['short'];
                    }
                  });
                },
                controller: artistsController,
                children: [
                  GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: 4,
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => GestureDetector(
                      child: Card(
                        color: Color.fromARGB(255, 19, 19, 19),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 0)),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image(image: NetworkImage(widget.topArtists['long'][index]['images'][0]['url']), width: 42, height: 42)
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 2, 0)),
                                  Text(widget.topArtists['long'][index]['name'].length > 11 ? widget.topArtists['long'][index]['name'].substring(0, 11)+'...' : widget.topArtists['long'][index]['name'], 
                                    style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontSize: 11)),
                                ]
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    child: Text('${index+1}', 
                                            style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 11)),
                                  )
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      onTap: () async {
                        final Uri _url = Uri.parse(widget.topArtists['long'][index]['uri']);
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                  ),
                  GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: 4,
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => GestureDetector(
                      child: Card(
                        color: Color.fromARGB(255, 19, 19, 19),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 0)),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image(image: NetworkImage(widget.topArtists['medium'][index]['images'][0]['url']), width: 42, height: 42)
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 2, 0)),
                                  Text(widget.topArtists['medium'][index]['name'].length > 11 ? widget.topArtists['medium'][index]['name'].substring(0, 11)+'...' : widget.topArtists['medium'][index]['name'], 
                                    style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontSize: 11)),
                                ]
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    child: Text('${index+1}', 
                                            style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 11)),
                                  )
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      onTap: () async {
                        final Uri _url = Uri.parse(widget.topArtists['medium'][index]['uri']);
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                  ),
                  GridView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: 4,
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => GestureDetector(
                      child: Card(
                        color: Color.fromARGB(255, 19, 19, 19),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 0)),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image(image: NetworkImage(widget.topArtists['short'][index]['images'][0]['url']), width: 42, height: 42)
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(4, 0, 2, 0)),
                                  Text(widget.topArtists['short'][index]['name'].length > 11 ? widget.topArtists['short'][index]['name'].substring(0, 11)+'...' : widget.topArtists['short'][index]['name'], 
                                    style: GoogleFonts.getFont('Montserrat', color: Color.fromARGB(255, 212, 212, 212), fontSize: 11)),
                                ]
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    child: Text('${index+1}', 
                                            style: GoogleFonts.getFont('Montserrat', color: Colors.grey, fontWeight: FontWeight.w300, fontSize: 11)),
                                  )
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      onTap: () async {
                        final Uri _url = Uri.parse(widget.topArtists['short'][index]['uri']);
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                  )                                                         
                ],
              )
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0)),
            CirclePageIndicator(
              size: 3,
              itemCount: 3,
              currentPageNotifier: artistsCurrentPageNotifier,
            ),
          ]
        )
    );
  }
}