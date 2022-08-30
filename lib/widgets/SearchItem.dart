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
  List userFollowing;
  SearchItem(this.user, this.userFollowing);
  @override
  _SearchItemState createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  Tuple2<bool, bool> options = Tuple2<bool, bool>(true, false);
  DatabaseService dbService = DatabaseService();
  spotifyService service = locator<spotifyService>();
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');
  bool isFollowed = false;

  @override
  void initState() {
    super.initState();
    isFollowed = widget.userFollowing.contains(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.circular(12)
      ),
      margin: const EdgeInsets.all(3.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image(image: widget.user['imageUrl'] != null ? NetworkImage(widget.user['imageUrl']): emptyImage, width: 40, height: 40)
        ),
        trailing: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: isFollowed ? Colors.green :Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.all(5),
            child: Text(isFollowed ? 'Following' : 'Follow',
            style: GoogleFonts.getFont('Montserrat', color: isFollowed ? Colors.green :Colors.grey))
          ), 
          onTap: () {
            dbService.toggleFollow(service.userId, widget.user.id);
            setState(() {
              isFollowed = !isFollowed;
            });
          },
        ),
        
        // IconButton(
        //   color: isFollowed ? Colors.green :Colors.grey,
        //   icon: Icon(Icons.person_add), 
        //   onPressed: (() {
        //     dbService.toggleFollow(service.userId, widget.user.id);
        //     setState(() {
        //       isFollowed = !isFollowed;
        //       print(isFollowed);
        //     });
        //   })
        // ),
        title: Text(widget.user['username'], 
                    style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        onTap: () => {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (c, a1, a2) => ProfilePage(widget.user['username']),
            transitionsBuilder: (c, anim, a2, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset(0.0, 0.0);
              final tween = Tween(begin: begin, end: end);
              final offsetAnimation = anim.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: Duration(milliseconds: 100),
          ))
        },
      )
    );
  }
}