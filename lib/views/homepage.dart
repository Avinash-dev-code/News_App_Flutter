import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:newsdemoapp/views/login_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsdemoapp/helper/TopHeadlines.dart';
import 'package:newsdemoapp/helper/data.dart';
import 'package:newsdemoapp/helper/widgets.dart';
import 'package:newsdemoapp/models/TodaysNews.dart';
import 'package:newsdemoapp/models/categorie_model.dart';
import 'package:newsdemoapp/views/categorie_news.dart';
import 'package:path_provider/path_provider.dart';
import '../helper/NewsDB.dart';

import '../helper/news.dart';
import 'package:get_time_ago/get_time_ago.dart';

import '../models/Bookmark.dart';
import '../models/article.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class HomePage extends StatefulWidget {
  final list;

  const HomePage({Key? key,  this.list}) : super(key: key);
  // const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _loading;
  late bool isHomeVisible;
  var newslist;
  List<CategorieModel> categories = <CategorieModel>[];
  List<TodaysNews> apiList = [];
  List<TodaysNews> dbList = [];
  List<Bookmark> bookmarkData = [];
  List<TodaysNews> bookmark = [];
  List<TodaysNews> finalBookmarkList = [];
  List<TodaysNews> topHeadlineList = [];
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
  String userName = "";
  String usersPhoto = "";
  String photo = "";
  bool bookmarkLoading = true;

  var catList=[];

  Future getNews() async {
    WidgetsFlutterBinding.ensureInitialized();
    var now = DateTime.now();
    String tempDate1 = DateFormat("yyyy-MM-dd").format(now);
    debugPrint("getDate:- $tempDate1");
    // News.newsList;

    bool result = await InternetConnectionChecker().hasConnection;
    debugPrint("Result Internet:- ${result}");
    if (result == true) {
      await news.getNews(tempDate1, tempDate1);
      debugPrint('YAY! Free cute dog pics!');
      dbList = News.newsList;
      debugPrint("apiList:- ${dbList.length}  ${News.newsList.length}");
    } else {

      final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();

      final personDao = database.newsDao;
      Fluttertoast.showToast(msg: "please connect to the internet");
      dbList = await personDao.findAllPersons();

      debugPrint('No internet :( Reason:');

      // Fluttertoast.showToast(msg: "please connect to the internet");
      // dbList = await personDao.findAllPersons();
      //
      // debugPrint('No internet :( Reason:');
      // debugPrint("databaseList:- ${dbList.length}");
    }
    // news.news.toSet().toList();
    setState(() {
      _loading = false;
    });

    return apiList;

    // for(TodaysNews e in removeDuplicates(news2))
    //   {
    //
    // debugPrint("list data:== ${e.title}");
    //   }
  }

  List removeDuplicates(List<TodaysNews> list) {
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
    topHeadlineList = await topHeadlines.getNews();

    setState(() {
      _loading = false;
    });
    // var convertedTimestamp = DateTime.parse(
    //     news.news[0].publshedAt); // Converting into [DateTime] object
    // var result = GetTimeAgo.parse(convertedTimestamp);
    debugPrint("topHeadlines:- ${topHeadlineList.length}");
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      debugPrint("SelectedList:- $selectedIndex");
      if (selectedIndex == 0) {
      } else if (selectedIndex == 1) {
        _onRefresh();
        isHomeVisible = true;
      }else if (selectedIndex == 2) {
        _onRefresh();
        // isHomeVisible = true;
      } else {}
    });
  }

  void callBookmark() async {


    // bookmarkLoading=true;
    // setState((){});

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

  }

  void callDB() async {
    final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();

    final personDao = database.newsDao;
    //
    // bool result = await InternetConnectionChecker().hasConnection;
    // if (result == true) {
    //   debugPrint('YAY! Free cute dog pics!');
    //   dbList = News.newsList;
    //   debugPrint("apiList:- ${dbList.length}  ${News.newsList.length}");
    // } else {
    //   Fluttertoast.showToast(msg: "please connect to the internet");
    //   dbList = await personDao.findAllPersons();
    //
    //   debugPrint('No internet :( Reason:');
    //   debugPrint("databaseList:- ${dbList.length}");
    // }

    for (TodaysNews e in dbList) {
      urls.add(e.urlToImage);
    }
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

    getName();
    // _onRefresh();
    getNews();
    getTopHeadlineNews();
    callDB();
    getImage();

    callBookmark();

    var FilteredList;

if(widget.list != null){
  FilteredList = widget.list.where((item) => item["isDisable"]=="false").toList();
}else{
  FilteredList = widget.list;
}

    catList=FilteredList;

    debugPrint("catList:-  ${FilteredList.length}");
    for (dynamic e in FilteredList) {
      debugPrint("catList item:- $e");


    }
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
    Geolocator.requestPermission();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.NO_HEADER,
        animType: AnimType.BOTTOMSLIDE,
        title: 'Location Permission',
        desc: 'allow news app to access your location',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Geolocator.openLocationSettings();

        },
      ).show();

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
      Geolocator.openLocationSettings();

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
      locationMessage =
          "${placemarks[0].subLocality},${placemarks[0].locality}";
    });
    return await Geolocator.getCurrentPosition();
  }

  getFromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      debugPrint("Camera Image:-  $image");
      setState(() {
        imageFile = File(image.path);
        savedProfileImage(imageFile.path.toString());
        getImage();

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
        savedProfileImage(imageFile.path.toString());
        getImage();

      });
    }
  }

  showAlertDialog(BuildContext context) {
    // Navigator.of(context, rootNavigator: true).pop('dialog');
    // set up the button

    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Permission',
      desc: 'allow news app to access your camera and storage',
      btnCancelOnPress: () {
        getFromCamera();
      },
      btnCancelText: "Camera",
      btnOkText: "Gallery",
      btnOkOnPress: () {
        getFromGallery();
      },
    ).show();



  }

  Future<void> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("name")!;
    photo = prefs.getString("photo")!;

    debugPrint("isPhoto:= $userName $photo");
  }

  Future<void> getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usersPhoto = prefs.getString("photo")!;
    debugPrint("Profile Image:- ${usersPhoto}");
  }

  Future<void> savedProfileImage(String profileImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("photo", profileImage);
    debugPrint("cameeraImage:  $profileImage");
  }

  Future<void> signOutGoogle() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("isLogged", false);

    print("User Signed Out");
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
                    Text(
                      "Welcome \n$userName",
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
                itemCount: catList.length,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    imageAssetUrl: catList[index]["imageAssetUrl"],
                    categoryName: catList[index]["categorieName"],
                  );
                }),
          ),
              const SizedBox(
                height: 5,
              ),

          ///Top Headlines
            Visibility(
                visible: topHeadlineList.length==0?false:true,
                child: Column(children: [
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 20),
                child: const Text(
                  "Top Headlines",
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
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                height: 200.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: topHeadlineList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var convertedTimestamp = DateTime.parse(topHeadlineList[index]
                          .publshedAt); // Converting into [DateTime] object
                      var result = GetTimeAgo.parse(convertedTimestamp);
                      if (result == ("a day ago")) {
                        result = "1 day ago";
                      } else {
                        result = GetTimeAgo.parse(convertedTimestamp);
                      }
                      if (result == ("an hour ago")) {
                        result = "1 hour ago";
                      } else {
                        result = GetTimeAgo.parse(convertedTimestamp);
                      }
                      return NewsTile2(
                          imgUrl1: topHeadlineList[index].urlToImage ?? "",
                          title1: topHeadlineList[index].title ?? "",
                          desc1: topHeadlineList[index].description ?? "",
                          content1: topHeadlineList[index].content ?? "",
                          posturl1: topHeadlineList[index].articleUrl ?? "",
                          publishAt1: result ?? "",
                          author1: topHeadlineList[index].author ?? "");
                    }),
              )

            ],)),

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
                      itemCount: dbList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var convertedTimestamp = DateTime.parse(dbList[index]
                            .publshedAt); // Converting into [DateTime] object
                        var result = GetTimeAgo.parse(convertedTimestamp);
                        if (result == ("a day ago")) {
                          result = "1 day ago";
                        } else {
                          result = GetTimeAgo.parse(convertedTimestamp);
                        }
                        debugPrint("databaseListUI:- ${dbList.length}");

                        if (result == ("an hour ago")) {
                          result = "1 hour ago";
                        } else {
                          result = GetTimeAgo.parse(convertedTimestamp);
                        }
                        final contact = removeDuplicates(dbList)[index];
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
        // callDB();
        // callBookmark();

        // child =Text("Hello");

        child =BookmarkTab(finalBookmarkList:finalBookmarkList );
        // ListView.builder(
        //     itemCount: finalBookmarkList.length,
        //     shrinkWrap: true,
        //     physics: ClampingScrollPhysics(),
        //     itemBuilder: (context, index) {
        //       var convertedTimestamp = DateTime.parse(finalBookmarkList[index]
        //           .publshedAt); // Converting into [DateTime] object
        //       var result = GetTimeAgo.parse(convertedTimestamp);
        //       if (result == ("a day ago")) {
        //         result = "1 day ago";
        //       } else {
        //         result = GetTimeAgo.parse(convertedTimestamp);
        //       }
        //       if (result == ("an hour ago")) {
        //         result = "1 hour ago";
        //       } else {
        //         result = GetTimeAgo.parse(convertedTimestamp);
        //       }
        //       final contact = removeDuplicates(finalBookmarkList)[index];
        //       debugPrint("NewsDatabseB:- ${finalBookmarkList.length}");
        //       return NewsTile(
        //           imgUrl: contact.urlToImage ?? "",
        //           title: contact.title ?? "",
        //           desc: contact.description ?? "",
        //           content: contact.content ?? "",
        //           posturl: contact.articleUrl ?? "",
        //           publishAt: result ?? "",
        //           author: contact.author ?? "");
        //     });

        break;
      case 2:
        child = Container(
            height: 500,
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.7),
                                  BlendMode.dstATop),
                              image: CachedNetworkImageProvider("https://img.freepik.com/free-vector/flat-geometric-background_23-2149329827.jpg?t=st=1655459147~exp=1655459747~hmac=5c8e9adb11f8f20c68cb5f1b14828c3ae7fbca7706211895af0bffc87fbdcb9b&w=996"),
                              fit: BoxFit.cover)),
                    ),
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 130),
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
                                  backgroundImage:usersPhoto.contains("https")?CachedNetworkImageProvider(usersPhoto):Image.file(File(usersPhoto)).image),
                            ),
                            SizedBox(height: 10),
                            Text(
                              userName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        )),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _determinePosition();
                  },
                  child: const Text("Get Current Location"),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  locationMessage,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    signOutGoogle();
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            child: LoginPage()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                )
              ],
            ));

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
            PageTransition(
              type: PageTransitionType.leftToRightWithFade,
              child: CategoryNews(
                newsCategory: categoryName.toUpperCase(),
              ),
            ));
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


class BookmarkTab extends StatefulWidget {
  final  finalBookmarkList;

  const BookmarkTab({Key? key, this.finalBookmarkList, }) : super(key: key);

  @override
  State<BookmarkTab> createState() => _BookmarkTabState();
}
class _BookmarkTabState extends State<BookmarkTab> {
  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return _isLoading?SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ):widget.finalBookmarkList.length==0?SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: Center(
        child: Text("No Bookmarks !",style: TextStyle(fontSize: 20)),
      ),
    ):ListView.builder(
        itemCount: widget.finalBookmarkList.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          var convertedTimestamp = DateTime.parse(widget.finalBookmarkList[index]
              .publshedAt); // Converting into [DateTime] object
          var result = GetTimeAgo.parse(convertedTimestamp);
          if (result == ("a day ago")) {
            result = "1 day ago";
          } else {
            result = GetTimeAgo.parse(convertedTimestamp);
          }
          if (result == ("an hour ago")) {
            result = "1 hour ago";
          } else {
            result = GetTimeAgo.parse(convertedTimestamp);
          }
          // final contact = removeDuplicates(widget.finalBookmarkList)[index];
          debugPrint("NewsDatabseB:- ${widget.finalBookmarkList.length}");
          return NewsTile(
              imgUrl: widget.finalBookmarkList[index].urlToImage ?? "",
              title: widget.finalBookmarkList[index].title ?? "",
              desc: widget.finalBookmarkList[index].description ?? "",
              content: widget.finalBookmarkList[index].content ?? "",
              posturl: widget.finalBookmarkList[index].articleUrl ?? "",
              publishAt: result ?? "",
              author: widget.finalBookmarkList[index].author ?? "");
        });
  }
}

