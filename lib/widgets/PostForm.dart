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
                image: NetworkImage(categoryState[0] ? item['album']['images'][0]['url'] : item['images'][0]['url']), 
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
    Object post = {
      'timestamp': FieldValue.serverTimestamp(),
      'profileImgUrl': 'https://scontent.fymq2-1.fna.fbcdn.net/v/t1.6435-9/49509493_2220570931333084_9073185916800991232_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=YFjTkrpSIjEAX-jPn8z&_nc_oc=AQlOprkDFtF0mkGFe_9mLW8YLx3Ll9g3ri5LJirC_qCXG3FOfhnA6SccOkbYvVEPNc4&_nc_ht=scontent.fymq2-1.fna&oh=00_AT-QsZe9PqKI15-hXXmqCyCsJC1Of6e-OZNRritSd81S0A&oe=632C2A80',
      'profileName': 'Ismaël Zirek',
      'description': descriptionController.text,
      'songImgUrl': selectedItem['album']['images'][0]['url'],
      'songName': selectedItem['name'],
      'artistName': selectedItem['artists'][0]['name'],
      'previewUrl': selectedItem['preview_url'],
    };

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
      backgroundColor: Color.fromARGB(255, 31, 31, 31),
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
                                color: Color.fromARGB(255, 20, 20, 20),
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