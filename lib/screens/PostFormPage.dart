import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/widgets/CategoryPicker.dart';
import 'package:saucify/widgets/SearchBar.dart';

import '../app/app.locator.dart';
import '../services/DatabaseService.dart';
import '../services/spotifyService.dart';

class PostFormPage extends StatefulWidget {
  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {  
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
        'comments': []
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
        'comments': []
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
        'comments': []
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.green,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.black.withOpacity(1.0),
                              Colors.black.withOpacity(1.0), 
                              Colors.black.withOpacity(1.0),
                              Colors.black.withOpacity(0.0)]),
          ),
        ),
        title: Text("Share a discovery", style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 10, 10, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(0, 90, 0, 10)),
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
                        Container(
                          margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.175,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 19, 19, 19),
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
            GestureDetector(
              onTap: () {
                submitPost();
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 26, 26, 26),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 2, 2, 2).withOpacity(0.4),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              margin: const EdgeInsets.fromLTRB(28, 50, 28, 7),
              alignment: Alignment.center,
              child: Text('Share post', style: GoogleFonts.getFont('Montserrat', 
                    color: Colors.white, fontWeight: FontWeight.w300, fontSize: 17)),
              ),
            ),
          ]
        ),
      )
    );
  }
}