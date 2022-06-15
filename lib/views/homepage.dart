import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:newsdemoapp/helper/NewsDao.dart';
import 'package:newsdemoapp/helper/TopHeadlines.dart';
import 'package:newsdemoapp/helper/data.dart';
import 'package:newsdemoapp/helper/widgets.dart';
import 'package:newsdemoapp/models/TodaysNews.dart';
import 'package:newsdemoapp/models/categorie_model.dart';
import 'package:newsdemoapp/views/categorie_news.dart';
import 'package:path_provider/path_provider.dart';
import '../helper/NewsDB.dart';
import '../helper/NewsDao.dart';
import '../helper/NewsDao.dart';
import '../helper/news.dart';
import 'package:get_time_ago/get_time_ago.dart';

import '../models/Bookmark.dart';
import '../models/article.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'CardView.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _loading;
  late bool isHomeVisible;
  var newslist;
  List<CategorieModel> categories = <CategorieModel>[];
  List<Article> news1 = [];
  List<TodaysNews> news2 = [];
  List<Bookmark> bookmarkData = [];
  List<TodaysNews> bookmark = [];
  List<TodaysNews> finalBookmarkList = [];
  List<String> urls = [];
  News news = News();
  TopHeadlines topHeadlines = TopHeadlines();
  int selectedIndex = 0; //New
  String formattedDate = "";
  late final newsDao;
  late final database;
  File imageFile = File("");
  var locationMessage = '';
  String latitude = "";
  String longitude = "";

  void getNews() async {
    WidgetsFlutterBinding.ensureInitialized();

    await news.getNews("2022-06-12", "2022-06-12");
    newslist = news.news;
    news1 = news.news;
    news.news.toSet().toList();
    setState(() {
      _loading = false;
    });

    // for(TodaysNews e in removeDuplicates(news2))
    //   {
    //
    // debugPrint("list data:== ${e.title}");
    //   }
  }

  List<TodaysNews> removeDuplicates(List<TodaysNews> list) {
    // Create a new ArrayList
    List<TodaysNews> newList = <TodaysNews>[];

    // Traverse through the first list
    for (TodaysNews element in list) {
      // If this element is not present in newList
      // then add it
      if (!newList.contains(element)) {
        newList.add(element);
      }
    }

    // return the new list
    return newList;
  }

  // Driver
  void getTopHeadlineNews() async {
    await topHeadlines.getNews();
    topHeadlines.news.toSet().toList();

    setState(() {
      _loading = false;
    });
    // var convertedTimestamp = DateTime.parse(
    //     news.news[0].publshedAt); // Converting into [DateTime] object
    // var result = GetTimeAgo.parse(convertedTimestamp);
    debugPrint("topHeadlines:- ${topHeadlines.news.toString()}");
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      debugPrint("SelectedList:- $selectedIndex");
      if (selectedIndex == 0) {
      } else if (selectedIndex == 1) {
        isHomeVisible = true;
      } else {}
    });
  }

  void callBookmark() async {
    final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();
    final personDao = database.newsDao;

    final bookmarkDao = database.bookmarkDao;

    bookmarkData = await bookmarkDao.getAllBookmark();
    urls.clear();
    for (Bookmark e in bookmarkData) {
      urls.add(e.url);
    }
    debugPrint("callBookmarkDB:- ${bookmarkData.length}");
    finalBookmarkList = (await personDao.getBookmark(urls))!;
    debugPrint("completeBookData1 :- ${urls.toString()}");
    removeDuplicates(finalBookmarkList);
    for (TodaysNews e in finalBookmarkList!) {
      debugPrint("finalBookMark :- ${e.title}");
    }
  }

  void callDB() async {
    final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();

    final personDao = database.newsDao;

    news2 = await personDao.findAllPersons();
    debugPrint("bookmark222:- ${news2.length}");

    // for (TodaysNews e in news2) {
    //   urls.add(e.urlToImage);
    // }
    bookmark = (await personDao.getBookmark(urls))!;
    // for (TodaysNews e in bookmark) {
    //   debugPrint("completeBookData :- ${e.urlToImage}");
    // }

    // for(TodaysNews e in news2)
    //   {
    // final ischeck=await personDao.isTitle(e.title);
    //     if(ischeck==true) {
    //       await personDao.update(e.title,e.author,e.description, e.urlToImage, e.publshedAt, e.content, e.articleUrl);
    //
    //     }
    //   }
  }

  @override
  void initState() {
    _loading = true;
    // TODO: implement initState
    super.initState();
    var now = new DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    formattedDate = formatter.format(now);
    categories = getCategories();
    getNews();
    getTopHeadlineNews();
    callDB();
    callBookmark();
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    getNews();
    getTopHeadlineNews();
    callDB();
    callBookmark();
    _refreshController.refreshCompleted();
  }

  // Future<List<TodaysNews>> retrieveUsers() async {
  //   final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();
  //
  //   final personDao = database.newsDao;
  //   return personDao.findAllPersons();
  // }

  void _onLoading() async {
    // monitor network fetch
    callDB();
    callBookmark();
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) {
      setState(() {});
    }
    _refreshController.loadComplete();
  }

  // void callBookmarDB() async {
  //   final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();
  //
  //   final bookmarkDao = database.bookmarkDao;
  //
  //
  //   Bookmark bookmark=Bookmark(url:"Avinash");
  //   bookmarkDao.addToBookmark(bookmark);
  //   debugPrint("callBookmarkDB:- $bookmark");
  //   //
  //   // for (TodaysNews e in news2) {
  //   //   urls.add(e.urlToImage);
  //   //
  //   // }
  //   // bookmark=(await personDao.getBookmark(urls))!;
  //   // for (TodaysNews e in bookmark) {
  //   //   debugPrint("completeBookData :- ${e.urlToImage}");
  //   // }
  //   // for(TodaysNews e in news2)
  //   //   {
  //   // final ischeck=await personDao.isTitle(e.title);
  //   //     if(ischeck==true) {
  //   //       await personDao.update(e.title,e.author,e.description, e.urlToImage, e.publshedAt, e.content, e.articleUrl);
  //   //
  //   //     }
  //   //   }
  // }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var long = position.longitude;

    // passing this to latitude and longitude strings
    latitude = "$lat";
    longitude = "$long";
    // getNamebyCordinates();
    // if (lat == null || long == null) return double.parse("");

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    debugPrint("location :- $placemarks $latitude  $longitude");
    setState(() {
      locationMessage = "${placemarks[0].locality}";
    });
    return await Geolocator.getCurrentPosition();
  }

  getFromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      debugPrint("Camera Image:-  $image");

      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  getFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint("Gallery Image:-  $image");
      // imageFile = File(image.path);
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  showAlertDialog(BuildContext context) {
    // Navigator.of(context, rootNavigator: true).pop('dialog');
    // set up the button
    Widget remindButton, launchButton;
    Widget ui = Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: 10),
        remindButton = TextButton(
          child: Text("Camera"),
          onPressed: () {
            getFromCamera();
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
        SizedBox(width: 110),
        launchButton = TextButton(
          child: Text("Gallery"),
          onPressed: () {
            getFromGallery();
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        )
      ],
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(child: Text("Image Picker")),
      actions: [ui],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? child = null;
    var currentDate = DateFormat('EEEE,MMMM d').format(DateTime.now());
    switch (selectedIndex) {
      case 0:
        child = Container(
            child: Column(children: <Widget>[
          Container(
              margin: const EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currentDate,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal),
                    ),
                    const Text(
                      "Welcome  \nAvinash",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontFamily: 'AirbnbCerealBook',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold),
                    )
                  ])),
          const SizedBox(
            height: 10,
          ),

          ///Categories
          Container(
            padding: EdgeInsets.only(left: 20),
            height: 70,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    imageAssetUrl: categories[index].imageAssetUrl,
                    categoryName: categories[index].categorieName,
                  );
                }),
          ),

          ///Top Headlines
          ///
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            height: 200.0,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topHeadlines.news.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  var convertedTimestamp = DateTime.parse(topHeadlines
                      .news[index]
                      .publshedAt); // Converting into [DateTime] object
                  var result = GetTimeAgo.parse(convertedTimestamp);

                  return NewsTile2(
                      imgUrl1: topHeadlines.news[index].urlToImage ?? "",
                      title1: topHeadlines.news[index].title ?? "",
                      desc1: topHeadlines.news[index].description ?? "",
                      content1: topHeadlines.news[index].content ?? "",
                      posturl1: topHeadlines.news[index].articleUrl ?? "",
                      publishAt1: result ?? "",
                      author1: topHeadlines.news[index].author ?? "");
                }),
          ),

          ///News For you
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: const Text(
                    "Just For You",
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: ListView.builder(
                      itemCount: news2.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var convertedTimestamp = DateTime.parse(news2[index]
                            .publshedAt); // Converting into [DateTime] object
                        var result = GetTimeAgo.parse(convertedTimestamp);
                        if (result == ("a day ago")) {
                          result = "1 day ago";
                        } else {
                          result = GetTimeAgo.parse(convertedTimestamp);
                        }

                        final contact = removeDuplicates(news2)[index];
// debugPrint("NewsDatabse:- ${retrieveUsers()}");
                        return NewsTile(
                            imgUrl: contact.urlToImage ?? "",
                            title: contact.title ?? "",
                            desc: contact.description ?? "",
                            content: contact.content ?? "",
                            posturl: contact.articleUrl ?? "",
                            publishAt: result ?? "",
                            author: contact.author ?? "");
                      }),
                ),
              ])
        ]));

        break;
      case 1:
        callBookmark();

        child = ListView.builder(
            itemCount: finalBookmarkList.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              var convertedTimestamp = DateTime.parse(finalBookmarkList[index]
                  .publshedAt); // Converting into [DateTime] object
              var result = GetTimeAgo.parse(convertedTimestamp);
              if (result == ("a day ago")) {
                result = "1 day ago";
              } else {
                result = GetTimeAgo.parse(convertedTimestamp);
              }

              final contact = removeDuplicates(finalBookmarkList)[index];
              debugPrint("NewsDatabseB:- ${finalBookmarkList.length}");
              return NewsTile(
                  imgUrl: contact.urlToImage ?? "",
                  title: contact.title ?? "",
                  desc: contact.description ?? "",
                  content: contact.content ?? "",
                  posturl: contact.articleUrl ?? "",
                  publishAt: result ?? "",
                  author: contact.author ?? "");
            });

        break;
      case 2:
        child = Container(
            height: 500,
            child:
            Column(children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black,
                        image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.6), BlendMode.dstATop),
                            image: NetworkImage(
                                "https://www.pixel4k.com/wp-content/uploads/2018/10/material-design-4k_1539370636-2048x1152.jpg"),
                            fit: BoxFit.fill)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: 250,

                          margin: const EdgeInsets.only(left: 50, top: 130),
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  //Do something
                                  // getFromCamera();
                                  showAlertDialog(context);
                                },
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: Image.file(
                                    imageFile,
                                  ).image,
                                ),
                              ),
                              Text(
                                "Avinash",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),

                            ],
                          )),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _determinePosition();
                },
                child: const Text("Get User Location"),
              ),
              const SizedBox(
                height: 18,
              ),

              Text(
                "locationMessage",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ],)

           );

        break;
    }
    return Scaffold(
      appBar: MyAppBar(),
      body: SafeArea(
          child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: _onRefresh,
              physics: const AlwaysScrollableScrollPhysics(),
              onLoading: _onLoading,
              child: SingleChildScrollView(child: child))),
      // drawer: Drawer(
      //   // Add a ListView to the drawer. This ensures the user can scroll
      //   // through the options in the drawer if there isn't enough vertical
      //   // space to fit everything.
      //
      //   child: ListView(
      //     // Important: Remove any padding from the ListView.
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const SizedBox(
      //         height: 50,
      //       ),
      //       Container(
      //           child: GestureDetector(
      //         onTap: () {
      //           Navigator.of(context)
      //               .push(MaterialPageRoute(builder: (context) => Profile()));
      //         },
      //         child: const CircleAvatar(
      //           radius: 50,
      //         ),
      //       )),
      //       const SizedBox(
      //         height: 20,
      //       ),
      //       const Text(
      //         "Avinash",
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      //       ),
      //       Divider(color: Colors.black),
      //       ListTile(
      //         title: const Text('Bookmark'),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.of(context)
      //               .push(MaterialPageRoute(builder: (context) => bookmark()));
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('Newsstand'),
      //         onTap: () {
      //           // Update the state of the app
      //           // ...
      //           // Then close the drawer
      //           Navigator.pop(context);
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex, //New
        onTap: _onItemTapped,
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imageAssetUrl, categoryName;

  CategoryCard({required this.imageAssetUrl, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryNews(
                      newsCategory: categoryName.toUpperCase(),
                    )));
      },
      child: Container(
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(right: 14),
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: imageAssetUrl,
                height: 60,
                width: 120,
                fit: BoxFit.fitWidth,
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 60,
              width: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black26),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }
}
