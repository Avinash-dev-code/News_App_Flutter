import 'dart:ffi';
import 'dart:io';
import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:newsdemoapp/helper/NewsDao.dart';
import 'package:newsdemoapp/models/categorie_model.dart';
import 'package:newsdemoapp/views/ReorderedListView.dart';
import 'package:newsdemoapp/views/homepage.dart';
import 'package:newsdemoapp/views/notificationDemo.dart';
import 'package:newsdemoapp/views/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper/NewsDB.dart';
import 'helper/ThemeClas.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
        primaryColor: Colors.white,
          brightness: Brightness.light
    ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          /* dark theme settings */
        ),
        themeMode: ThemeMode.light,
        home:SplashScreen()
    );
    }
}

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool islogged=false;
  @override
  void initState() {
    super.initState();
    getLogged();
    List<CategorieModel> category=[];
    final array1=[{"categorieName": "General","isDisable":"false","imageAssetUrl":"https://images.unsplash.com/photo-1495020689067-958852a7765e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60"},
      {"categorieName": "Business","isDisable":"false","imageAssetUrl":"https://images.unsplash.com/photo-1507679799987-c73779587ccf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1502&q=80"},
      {"categorieName": "Science","isDisable":"false","imageAssetUrl":"https://images.unsplash.com/photo-1507679799987-c73779587ccf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1502&q=80"},
      {"categorieName": "Health","isDisable":"false","imageAssetUrl":"https://images.unsplash.com/photo-1507679799987-c73779587ccf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1502&q=80"},
      {"categorieName": "Entertainment","isDisable":"false","imageAssetUrl":"https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1500&q=80"},
      {"categorieName": "Sports","isDisable":"false","imageAssetUrl":"https://images.unsplash.com/photo-1495563923587-bdc4282494d0?ixlib=rb-1.2.1&auto=format&fit=crop&w=1500&q=80"},
      {"categorieName": "Technology","isDisable":"false","imageAssetUrl":"https://images.unsplash.com/photo-1519389950473-47ba0277781c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1500&q=80"},
    ];

    Timer(const Duration(seconds: 2),
            () =>
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder:
                    (context) => islogged?ReorderedListView(list: array1):LoginPage()
                )
            )
    );
  }

  Future<bool?> getLogged() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    islogged=prefs.getBool("isLogged")!;
    debugPrint("isLogged:= $islogged");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.yellow,
        child: FlutterLogo(size: MediaQuery
            .of(context).size
            .height)

    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('My Page!'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}