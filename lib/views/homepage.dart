import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
