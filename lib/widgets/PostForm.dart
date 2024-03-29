import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/widgets/CategoryPicker.dart';
import 'package:saucify/widgets/SearchBar.dart';

import '../app/app.locator.dart';
import '../services/DatabaseService.dart';
import '../services/spotifyService.dart';

class PostForm extends StatefulWidget {
  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {  
  spotifyService service = locator<spotifyService>();
  TextEditingController searchController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DatabaseService dbService = DatabaseService();
  List<Widget> list = [];
  dynamic selectedItem = {};
  NetworkImage emptyImage = NetworkImage('https://icones.pro/wp-content/uploads/2021/05/icone-point-d-interrogation-question-gris.png');

  List categoryState = [true, false, false];
  String itemType = 'track';

  List getCategoryState(){ 
    return categoryState;
  }

  void setItemType(int index) {
    if (index == 0) {
      setState(() {
        categoryState[0] = true;
        categoryState[1] = false;
        categoryState[2] = false;
        itemType = 'track';
      });
    } else if (index == 1) {
      setState(() {
        categoryState[0] = false;
        categoryState[1] = true;
        categoryState[2] = false;
        itemType = 'album';
      });
    } else if (index == 2) {
      setState(() {
        categoryState[0] = false;
        categoryState[1] = false;
        categoryState[2] = true;
        itemType = 'artist';
      });
    }
  }

  void getSearchedItems(String text) async {
    List myPlaylists = await service.searchItems(text, itemType);
    List<Widget> newList = [];

    myPlaylists.forEach((item) { 
      newList.add(
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 12, 12, 12),
            borderRadius: BorderRadius.all(Radius.circular(0))
          ),
          child: ListTile(
            visualDensity: VisualDensity(horizontal: -1, vertical: -4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image(
                image: categoryState[0] ? item['album']['images'].isNotEmpty ? NetworkImage(item['album']['images'][0]['url']) : emptyImage
                                        : item['images'].isNotEmpty ? NetworkImage(item['images'][0]['url']) : emptyImage, 
                width: 30, 
                height: 30
              )
            ),
            title: Text(item['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
            subtitle: categoryState[0] ? Text(item['artists'][0]['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white, fontSize: 10)) : null,
            onTap: () {
              searchController.text = item['name'];
              selectedItem = item;
              setState(() {
                list = [];
              });
            },
          ),
        )
      );
    });

    setState(() {
      list = newList;
    });
  }

  submitPost() async {
    Object post = {};
    DocumentSnapshot doc = await dbService.getUserDocument(service.userId);

    if (categoryState[0]) {
      post = {
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'postedBy': service.userId,
        'postType': 'track',
        'profileImgUrl': doc['imageUrl'],
        'profileName': service.userId,
        'description': descriptionController.text,
        'itemUrl': selectedItem['uri'],
        'itemImgUrl': selectedItem['album']['images'][0]['url'],
        'itemName': selectedItem['name'],
        'artistName': selectedItem['artists'][0]['name'],
        'previewUrl': selectedItem['preview_url'],
      };
    } else if (categoryState[1]) {
      post = {
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'postedBy': service.userId,
        'postType': 'album',
        'profileImgUrl': doc['imageUrl'],
        'profileName': service.userId,
        'description': descriptionController.text,
        'itemUrl': selectedItem['uri'],
        'itemImgUrl': selectedItem['images'][0]['url'],
        'itemName': selectedItem['name'],
        'artistName': selectedItem['artists'][0]['name'],
      };
    } else if (categoryState[2]) {
      post = {
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'postedBy': service.userId,
        'postType': 'artist',
        'profileImgUrl': doc['imageUrl'],
        'profileName': service.userId,
        'description': descriptionController.text,
        'itemUrl': selectedItem['uri'],
        'itemImgUrl': selectedItem['images'][0]['url'],
        'itemName': selectedItem['name'],
      };
    }

    await dbService.addDocToCollection('posts', post);
    Navigator.pop(context);
  } 

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: Color.fromARGB(255, 19, 19, 19),
      content: Form(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'New post',
                    style: GoogleFonts.getFont('Montserrat', 
                        fontWeight: FontWeight.w700,
                        color: Colors.white
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  CategoryPicker(setItemType, getCategoryState),
                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  SearchBar(searchController, getSearchedItems),
                  Stack(
                    children: [
                      Column(
                        children: [
                          Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                          Text(
                            'Description',
                            style: GoogleFonts.getFont('Montserrat', 
                                fontWeight: FontWeight.w400,
                                color: Colors.white
                            )
                          ),
                          Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.175,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 12, 12, 12),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: TextField(
                                  controller: descriptionController,
                                  style: TextStyle(color: Colors.white),
                                  expands: true,
                                  maxLines: null,
                                )
                              )
                            )
                          )
                        ]
                      ),
                      list.isNotEmpty ? Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width*0.6,
                          height: 220,
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: ListView(
                              children: list
                            ), 
                          ) // It will provide scroll functionality with your column
                        ),
                      ) : Container()
                    ],
                  )
                ]
              ),
              // ListView(
              //   children: list
              // ),
              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.post_add),
                  onPressed: (() => submitPost()),
                ),
              )
            ]
          ),
        )
      )
    );
  }
}