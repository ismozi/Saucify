import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/widgets/CategoryPicker.dart';
import 'package:saucify/widgets/PlaylistTypePicker.dart';
import 'package:saucify/widgets/SearchBar.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class PlaylistForm extends StatefulWidget {
  @override
  State<PlaylistForm> createState() => _PlaylistFormState();
}

class _PlaylistFormState extends State<PlaylistForm> {  
  spotifyService service = locator<spotifyService>();
  TextEditingController controller = TextEditingController();
  List<Widget> list = [];

  List categoryState = [true, false, false];
  String itemType = 'track';

  List getCategoryState(){ 
    return categoryState;
  }

  List setItemType(int index) {
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

    return categoryState;
  }

  void getSearchedItems(String text) async {
    List myPlaylists = await service.searchItems(text, itemType);
    List<Widget> newList = [];

    print(myPlaylists);

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
            onTap: () => {
            },
          ),
        )
      );
    });

    setState(() {
      list = newList;
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
                    'Generate playlist',
                    style: GoogleFonts.getFont('Montserrat', 
                        fontWeight: FontWeight.w700,
                        color: Colors.white
                    )
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  PlaylistTypePicker(setItemType),
                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  SearchBar(controller, getSearchedItems),
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
                  onPressed: (() {
                    if (categoryState[0]) {
                      service.createPlaylist('short_term');
                    } else if (categoryState[1]) {
                      service.createPlaylist('medium_term');
                    } else if (categoryState[2]) {
                      service.createPlaylist('long_term');
                    }
                  }),
                ),
              )
            ]
          ),
        )
      )
    );
  }
}