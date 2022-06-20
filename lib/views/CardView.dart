import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newsdemoapp/models/Bookmark.dart';

import '../helper/NewsDB.dart';
import '../models/TodaysNews.dart';
import 'package:like_button/like_button.dart';

class CardView extends StatelessWidget {
  String? newsSource;
  String? image;
  String? title;
  String? dateTime;
  String? articleURL;
  List<TodaysNews> news2 = [];
  bool isClick = false;

  CardView({
    required this.newsSource,
    required this.image,
    required this.title,
    required this.dateTime,
    required this.articleURL,
  });

  Future<void> share() async {
    await FlutterShare.share(
        title: 'Share Article',
        linkUrl: articleURL,
        chooserTitle: 'Example Chooser Title');
  }

  void callDB(Bookmark bookmark) async {
    final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();

    final bookmarkDao = database.bookmarkDao;

    bookmarkDao.addToBookmark(bookmark);

    debugPrint("callDB:- $bookmark");

  }


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              Expanded(
                  child: Container(
                margin: EdgeInsets.all(10),
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(image!), fit: BoxFit.cover)),
                ),
              )),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Text(newsSource!,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 12)),
                    ),
                    Flexible(
                        flex: 7,
                        child: Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(title!,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        )),
                    Row(
                      children: [
                        Container(
                          width: 85,
                          child: Text(
                            dateTime.toString(),
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        SizedBox(width: 10),

                        Container(
                          child: IconButton(
                            icon: const Icon(
                              Icons.book_outlined,
                            ),
                            iconSize: 20,
                            color: Colors.black,
                            onPressed: () async {
                              final database = await $FloorNewsDB
                                  .databaseBuilder('NewsDB.db')
                                  .build();

                              final bookmarkDao = database.bookmarkDao;
                              Fluttertoast.showToast(
                                  msg: "Added bookmark successfully!");

                              
                              Bookmark bookmark =
                                  Bookmark(url: image.toString());
                              if(bookmark.url==image.toString())
                                {

                                }
                              else
                                {

                                }
                              bookmarkDao.addToBookmark(bookmark);
                              debugPrint("callBookmarkDB:- ${bookmark.url}");
                            },
                          ),

                        ), Container(
                          child: IconButton(
                            icon: const Icon(
                              Icons.share,
                            ),
                            iconSize: 20,
                            color: Colors.black,
                            onPressed: () {
                              share();
                            },
                          ),
                        ),
                      ],
                    )
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
            ],
          ),
        ),
      ),
    );
  }
}
