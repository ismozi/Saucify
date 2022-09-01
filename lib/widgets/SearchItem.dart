import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/app/app.locator.dart';
import 'package:saucify/services/DatabaseService.dart';
import 'package:tuple/tuple.dart';

import '../screens/ProfilePage.dart';
import '../services/spotifyService.dart';

class SearchItem extends StatefulWidget{
  final DocumentSnapshot user;
  bool isFollowed;
  SearchItem(this.user, this.isFollowed);
  @override
  _SearchItemState createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  Tuple2<bool, bool> options = Tuple2<bool, bool>(true, false);
  DatabaseService dbService = DatabaseService();
  spotifyService service = locator<spotifyService>();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.circular(12)
      ),
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.08,
      margin: const EdgeInsets.fromLTRB(3, 13, 3, 3),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image(image: widget.user['imageUrl'] != null ? NetworkImage(widget.user['imageUrl']): emptyImage, width: 50, height: 50)
        ),
        trailing: widget.user.id != service.userId ? GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: widget.isFollowed ? Colors.green :Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.all(5),
            child: Text(widget.isFollowed ? 'Following' : 'Follow',
            style: GoogleFonts.getFont('Montserrat', color: widget.isFollowed ? Colors.green :Colors.grey))
          ), 
          onTap: () {
            dbService.toggleFollow(service.userId, widget.user.id);
            setState(() {
              widget.isFollowed = !widget.isFollowed;
            });
          },
        ) : null,
        title: Text(widget.user['username'], 
                    style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 18)),
        onTap: () => {   
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (c, a1, a2) => widget.user.id == service.userId ? ProfilePage(widget.user.id, true, false) : ProfilePage(widget.user.id, false, false),
            transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: Duration(milliseconds: 150),
          )),
        },
      )
    );
  }
}