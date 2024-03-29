import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saucify/app/app.locator.dart';
import 'package:saucify/screens/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator();
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
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
        unselectedWidgetColor: Color.fromARGB(255, 92, 92, 92)
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
