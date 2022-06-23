import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:newsdemoapp/views/Profile.dart';
import 'package:newsdemoapp/views/ReorderedListView.dart';
import 'package:newsdemoapp/views/login_page.dart';
import 'package:newsdemoapp/views/Profile_Page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsdemoapp/helper/TopHeadlines.dart';
import 'package:newsdemoapp/helper/data.dart';
import 'package:newsdemoapp/helper/widgets.dart';
import 'package:newsdemoapp/models/TodaysNews.dart';
import 'package:newsdemoapp/models/categorie_model.dart';
import 'package:newsdemoapp/views/categorie_news.dart';
import 'package:path_provider/path_provider.dart';
import '../helper/NewsDB.dart';

import '../helper/Rabit.dart';
import '../helper/news.dart';
import 'package:get_time_ago/get_time_ago.dart';

import '../models/Bookmark.dart';
import '../models/article.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'CardView.dart';
import 'article_view.dart';

class HomePage extends StatefulWidget {
  final list;
  final channel = IOWebSocketChannel.connect('wss://stream.binance.com:9443/ws/ethusdt@trade');

   HomePage({Key? key, this.list}) : super(key: key);

  // const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _loading;
  late bool isHomeVisible;
  var newslist;


  late Stream broadcastStream;


  var jsonData;
  String Data="";


  List<CategorieModel> categories = <CategorieModel>[];
  List<TodaysNews> apiList = [];
  List<TodaysNews> dbList = [];
  List<TodaysNews> indiaList = [];
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

  var catList = [];

  bool isBookmarked=false;

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
  Future getIndiaNews() async {


    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      await news.getNewsIndia();
      debugPrint('YAY! Free cute dog pics!');
      indiaList = News.IndianNews;
    }



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

  Future<void> share(String url) async {
    await FlutterShare.share(
        title: 'Share Article',
        linkUrl: url,
        chooserTitle: 'Example Chooser Title');
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
      } else if (selectedIndex == 2) {
        _onRefresh();
        // isHomeVisible = true;
      } else {}
    });
  }

  void callBookmark() async {
    // bookmarkLoading=true;


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
    debugPrint("finalBookmarkList :- ${finalBookmarkList.length}");
    setState((){

    removeDuplicates(finalBookmarkList);
    });
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

    broadcastStream = widget.channel.stream.asBroadcastStream();



    getName();
    // _onRefresh();
    getNews();
    getIndiaNews();
    getTopHeadlineNews();
    callDB();
    // getImage();4


    // getBookmarked("abc");

    callBookmark();
    // getBookmarked(widget.image.toString());

    var FilteredList;

    if (widget.list != null) {
      FilteredList =
          widget.list.where((item) => item["isDisable"] == "false").toList();
      catList = FilteredList;
    }
// else{
//   FilteredList = widget.list;
// }
  }
  void getBookmarked(String url) async {
    final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();

    final bookmarkDao = database.bookmarkDao;

//  ##  CARE : uncomment to truncate bookmark table
    await bookmarkDao.truncateTable();

    // List<Bookmark> data1=await bookmarkDao.getAllBookmark();
    //
    // for(Bookmark e in data1){
    //   debugPrint("BookmarkData item:- ${e.url}");
    //   if(e.url == url){
    //     debugPrint("BookmarkData item:- ${e.url} found to be bookmarked");
    //     setState((){
    //       isBookmarked=true;
    //     });
    //     break;
    //   }
    // }
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    getNews();
    getIndiaNews();
    getTopHeadlineNews();
    callDB();
    callBookmark();
    _refreshController.refreshCompleted();
  }


  // void _onLoading() async {
  //   // monitor network fetch
  //   callDB();
  //   callBookmark();
  //   await Future.delayed(Duration(milliseconds: 1000));
  //   // if failed,use loadFailed(),if no data return,use LoadNodata()
  //
  //   if (mounted) {
  //     setState(() {});
  //   }
  //   _refreshController.loadComplete();
  // }


  Future<void> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("name")!;
    photo = prefs.getString("photo")!;
    debugPrint("isPhoto:= $userName $photo");
  }

  // Future<void> getImage() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   usersPhoto = prefs.getString("photo")!;
  //   debugPrint("Profile Image:- ${usersPhoto}");
  // }

  @override
  void dispose() {
    widget.channel.sink.close();
    Fluttertoast.showToast(msg: "destroyed..");
    super.dispose();
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
              Column(children: [
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
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Welcome $userName",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontFamily: 'AirbnbCerealBook',
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                          ),

                        ])),
                   Rabit(stream: broadcastStream),




              ],),

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
            height: 20,
          ),

          ///Top Headlines
          Visibility(
              visible: topHeadlineList.length == 0 ? false : true,
              child: Column(
                children: [
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
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    height: 200.0,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topHeadlineList.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          var convertedTimestamp = DateTime.parse(topHeadlineList[
                                  index]
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
                ],
              )),
              SizedBox(height: 20),

          ///News For India
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: const Text(
                    "India",
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                    height: 120.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left:10.0),
                      child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: indiaList.length,
                                itemBuilder: (BuildContext context, int i) {
                                  var convertedTimestamp = DateTime.parse(indiaList[
                                          i]
                                      .publshedAt); // Converting into [DateTime] object
                                  var result =
                                      GetTimeAgo.parse(convertedTimestamp);
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
                                  return Container(
                                    width: MediaQuery.of(context).size.width - 30,
                                    child:
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.bottomToTop,
                                                child: ArticleView(postUrl: indiaList[i].articleUrl)));

                                      },
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: Row(
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 5,
                                                child: SizedBox(
                                                  width: 100,
                                                  height: 100,
                                                  child: Container(
                                                    margin: const EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        top: 5,
                                                        bottom: 5),
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                        color: Colors.black,
                                                        image: DecorationImage(
                                                            image:
                                                                CachedNetworkImageProvider(
                                                                    indiaList[i]
                                                                        .urlToImage!),
                                                            fit: BoxFit.cover)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 10,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top: 10),
                                                        child: Text(
                                                            indiaList[i].author!,
                                                            maxLines: 1,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: const TextStyle(
                                                                fontSize: 12)),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(top: 7),
                                                        child: Text(
                                                            indiaList[i].title!,
                                                            maxLines: 2,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              width: 85,
                                                              child: Text(
                                                                result,
                                                                maxLines: 1,
                                                                textAlign:
                                                                    TextAlign.start,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                IconButton(
                                                                  icon: const Icon(
                                                                    Icons
                                                                        .bookmark_border_outlined,
                                                                  ),
                                                                  iconSize: 20,
                                                                  color:
                                                                      Colors.black,
                                                                  onPressed:
                                                                      () async {

                                                                        final database = await $FloorNewsDB
                                                                            .databaseBuilder('NewsDB.db')
                                                                            .build();

                                                                        final bookmarkDao = database.bookmarkDao;
                                                                        Fluttertoast.showToast(
                                                                            msg: "Added bookmark successfully!");


                                                                        Bookmark bookmark =
                                                                        Bookmark(url: indiaList[i].urlToImage.toString());
                                                                        bookmarkDao.addToBookmark(bookmark);
                                                                        debugPrint("callBookmarkDB:- ${bookmark.url}");
                                                                        setState((){
                                                                          isBookmarked=true;
                                                                        });






                                                                      },
                                                                ),
                                                                IconButton(
                                                                  icon: const Icon(
                                                                    Icons.share,
                                                                  ),
                                                                  iconSize: 20,
                                                                  color:
                                                                      Colors.black,
                                                                  onPressed:
                                                                      () async {
                                                                    share(indiaList[i].articleUrl);
                                                                      },
                                                                ),

                                                              ],
                                                            ),
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          )),
                    )),
              ]),
///News for you
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 20,top: 20),
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
                    SizedBox(height: 5),
                    SizedBox(
                        height: 400,
                        child: Padding(
                          padding: const EdgeInsets.only(left:10.0),
                          child: Container(
                              height: MediaQuery.of(context).size.height,
                              child: Expanded(
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: dbList.length,
                                    itemBuilder: (BuildContext context, int i) {
                                      var convertedTimestamp = DateTime.parse(dbList[
                                      i]
                                          .publshedAt); // Converting into [DateTime] object
                                      var result =
                                      GetTimeAgo.parse(convertedTimestamp);
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
                                      return Container(
                                        width: MediaQuery.of(context).size.width - 20,
                                        child:
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    type: PageTransitionType.bottomToTop,
                                                    child: ArticleView(postUrl: dbList[i].articleUrl)));

                                          },
                                          child: Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: Column(
                                                // mainAxisAlignment:
                                                //     MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 5,
                                                    child: SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Container(

                                                        decoration: BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            borderRadius:
                                                            BorderRadius.only(
                                                              topRight: Radius.circular(10),
                                                              topLeft: Radius.circular(10)
                                                            ),
                                                            color: Colors.black,
                                                            image: DecorationImage(
                                                                image:
                                                                CachedNetworkImageProvider(
                                                                    dbList[i]
                                                                        .urlToImage!),
                                                                fit: BoxFit.cover)),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,

                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 20,left: 20,right: 20,bottom: 0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                              EdgeInsets.only(top: 0),
                                                              child: Text(
                                                                  dbList[i].title!,

                                                                  maxLines: 2,
                                                                  textAlign:
                                                                  TextAlign.start,
                                                                  style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                            ),
                                                          ),

                                                          Expanded(
                                                            child: Padding(
                                                              padding: EdgeInsets.only(
                                                                  top: 5),
                                                              child:
                                                              Text(
                                                                  dbList[i].description!,
                                                                  maxLines: 3,

                                                                  textAlign:
                                                                  TextAlign.start,
                                                                  style: const TextStyle(
                                                                      fontSize: 12)),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child: SizedBox(

                                                                child: Row(

                                                                  children: [
                                                                    Text("by: ",style: TextStyle(fontSize: 12)),
                                                                    Flexible(
                                                                      child: Container(
                                                                        padding: new EdgeInsets.only(right: 1.0),
                                                                        child: Text(
                                                                          '${dbList[i].author}',
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: new TextStyle(
                                                                            fontSize: 13.0,
                                                                            fontFamily: 'Roboto',
                                                                            color: new Color(0xFF212121),
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                          ],),
                                                              )),
                                                          Expanded(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    child: Text(
                                                                      result,
                                                                      maxLines: 1,
                                                                      textAlign:
                                                                      TextAlign.start,
                                                                      style: Theme.of(
                                                                          context)
                                                                          .textTheme
                                                                          .caption,
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                    children: [
                                                                      IconButton(
                                                                        icon: const Icon(
                                                                          Icons
                                                                              .bookmark_border_outlined,
                                                                        ),
                                                                        iconSize: 20,
                                                                        color:
                                                                        Colors.black,
                                                                        onPressed:
                                                                            () async {

                                                                          final database = await $FloorNewsDB
                                                                              .databaseBuilder('NewsDB.db')
                                                                              .build();

                                                                          final bookmarkDao = database.bookmarkDao;
                                                                          Fluttertoast.showToast(
                                                                              msg: "Added bookmark successfully!");


                                                                          Bookmark bookmark =
                                                                          Bookmark(url: dbList[i].urlToImage.toString());
                                                                          bookmarkDao.addToBookmark(bookmark);
                                                                          debugPrint("callBookmarkDB:- ${bookmark.url}");
                                                                          setState((){
                                                                            isBookmarked=true;
                                                                          });






                                                                        },
                                                                      ),
                                                                      IconButton(
                                                                        icon: const Icon(
                                                                          Icons.share,
                                                                        ),
                                                                        iconSize: 20,
                                                                        color:
                                                                        Colors.black,
                                                                        onPressed:
                                                                            () async {
                                                                          share(dbList[i].articleUrl);
                                                                        },
                                                                      ),

                                                                    ],
                                                                  ),
                                                                ],
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              )),
                        )),
                  ]),

        ]));

        break;
      case 1:
        // callDB();
        // callBookmark();

        // child =Text("Hello");

        child = BookmarkTab(finalBookmarkList: finalBookmarkList);
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
        child = Profile_Page();

        break;

      case 3:
        child = ReorderedListView(list: widget.list, isSinglePage: false);
        // child=ReorderedListView(list: catList,isSinglePage:false);
        break;
    }
    return Scaffold(
      appBar: MyAppBar(),
      body: SafeArea(
          child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: _onRefresh,
              dragStartBehavior: DragStartBehavior.down,
              physics: const AlwaysScrollableScrollPhysics(),

              child: SingleChildScrollView(child: child))),
      bottomNavigationBar: BottomNavigationBar(
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.lightBlueAccent,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Bookmark',
              backgroundColor: Colors.lightBlueAccent),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.lightBlueAccent),
          BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
              activeIcon: Icon(Icons.category, color: Colors.black),
              tooltip: "Categories",
              backgroundColor: Colors.lightBlueAccent),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        //New
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
  final finalBookmarkList;

  const BookmarkTab({
    Key? key,
    this.finalBookmarkList,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? SizedBox(
            height: MediaQuery.of(context).size.height / 1.3,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : widget.finalBookmarkList.length == 0
            ? SizedBox(
                height: MediaQuery.of(context).size.height / 1.3,
                child: Center(
                  child: Text("No Bookmarks !", style: TextStyle(fontSize: 20)),
                ),
              )
            : ListView.builder(
                itemCount: widget.finalBookmarkList.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  var convertedTimestamp = DateTime.parse(widget
                      .finalBookmarkList[index]
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

                  final contact = removeDuplicates(widget.finalBookmarkList)[index];
                  debugPrint(
                      "NewsDatabseB:- ${widget.finalBookmarkList.length}");
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
