import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saucify/app/app.locator.dart';
import 'package:saucify/screens/loginScreen.dart';


void main() {
  setupLocator();
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color.fromARGB(255, 20, 20, 20),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        body: 
          Center(
            child: LoginScreen(),
          )
      )
    );
  }
}
