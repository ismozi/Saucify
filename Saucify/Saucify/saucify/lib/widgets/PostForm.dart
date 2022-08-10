import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saucify/widgets/CategoryPicker.dart';
import 'package:saucify/widgets/SearchBar.dart';

import '../app/app.locator.dart';
import '../services/spotifyService.dart';

class PostForm extends StatefulWidget {
  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {  
  spotifyService service = locator<spotifyService>();
  TextEditingController controller = TextEditingController();
  List<Widget> list = [];

  void getSearchedItems(String text) async {
    List myPlaylists = await service.searchItems(text);
    List<Widget> newList = [];

    myPlaylists.forEach((item) { 
      newList.add(
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 29, 29, 29),
            borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          margin: const EdgeInsets.all(3.0),
          child: ListTile(
            leading: !item['album']['images'].isEmpty ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(item['album']['images'][0]['url']), 
                width: 40, 
                height: 40
              )
            ) : null,
            title: Text(item['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
            subtitle: Text(item['artists'][0]['name'], 
                        style: GoogleFonts.getFont('Montserrat', color: Colors.white)),
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
      elevation: 1000,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: Color.fromARGB(255, 31, 31, 31),
      content: Form(
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
                CategoryPicker(),
                Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                SearchBar(controller),
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
                  height: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 20, 20, 20),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        expands: true,
                        maxLines: null,
                      )
                    )
                  )
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
                onPressed: (() => {}),
              ),
            )
          ]
        ),
      )
    );
  }
}