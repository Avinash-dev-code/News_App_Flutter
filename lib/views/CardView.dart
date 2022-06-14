import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newsdemoapp/models/Bookmark.dart';

import '../helper/NewsDB.dart';
import '../models/TodaysNews.dart';

class CardView extends StatelessWidget {
  String? newsSource;
  String? image;
  String? title;
  String? dateTime;
  List<TodaysNews> news2 = [];


  CardView({
    required this.newsSource,
    required this.image,
    required this.title,
    required this.dateTime,
  });
  void callDB(Bookmark bookmark) async {
    final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();

    final bookmarkDao = database.bookmarkDao;

    bookmarkDao.addToBookmark(bookmark);


    debugPrint("callDB:- $bookmark");
    //
    // for (TodaysNews e in news2) {
    //   urls.add(e.urlToImage);
    //
    // }
    // bookmark=(await personDao.getBookmark(urls))!;
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
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(newsSource!,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 12)),
                    ),
                    Flexible(
                        flex: 4,
                        child: Container(
                          child: Text(title!,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        )),
                    SizedBox(
                      child: Text(
                        dateTime.toString(),
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.caption,
                      ),


                    ),

                  ],
                ),
              ),
              // Expanded(
              //     child: Padding(
              //       padding: const EdgeInsets.all(6),
              //       child: Container(
              //         height: 80,
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(10),
              //             color: Colors.black,
              //             image: DecorationImage(
              //                 image: NetworkImage(image!), fit: BoxFit.fill)),
              //       ),
              //     )),
              Expanded(

                  child: Container(
                    width: 200,
                    margin: EdgeInsets.all(5),
                    child: Container(
                      child: Container(
                        decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black,
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.6), BlendMode.dstATop),
                                image: NetworkImage(image!),
                                fit: BoxFit.fill)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(

                              child: IconButton(
                                icon: const Icon(
                                  Icons.bookmark,
                                ),
                                iconSize: 30,
                                color: Colors.white,
                                onPressed: () async{
                                  final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();

                                  final bookmarkDao = database.bookmarkDao;
                                  Fluttertoast.showToast(msg: "Added bookmark successfully!");

                                  Bookmark bookmark=Bookmark(url:image.toString());
                                  bookmarkDao.addToBookmark(bookmark);
                                  debugPrint("callBookmarkDB:- $bookmark");

                                },
                              ),
                            ),


                          ],
                        ),
                      ),
                    ),
                  )


































              )

            ],
          ),
        ),
      ),
    );
  }
}

