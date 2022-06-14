import 'package:flutter/material.dart';
import 'package:newsdemoapp/views/Profile.dart';
import 'package:newsdemoapp/views/article_view.dart';
import 'package:page_transition/page_transition.dart';
import '../views/CardView.dart';

PreferredSizeWidget MyAppBar() {

  return AppBar(
    iconTheme: const IconThemeData(color: Colors.black),
    title: Row(children: <Widget>[
      Container(
          width: 25,
          child: const Padding(
            padding: EdgeInsets.only(right: 7),
            child: FittedBox(child: Icon(Icons.circle), fit: BoxFit.fitWidth),
          )),
      Container(
          width: 200,
          child: const Text(
            "News Now",
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          )),
      Container(
          width: 40,
        margin: EdgeInsets.only(left: 55),
        alignment: Alignment.topRight,

          child:GestureDetector(
            onTap: () {
            },
              child:const CircleAvatar(
                radius: 30.0,
                backgroundImage:
                NetworkImage("https://w7.pngwing.com/pngs/550/997/png-transparent-user-icon-foreigners-avatar-child-face-heroes.png"),
                backgroundColor: Colors.transparent,
              )),
          ),

    ]),
    backgroundColor: Colors.transparent,
    elevation: 0.0,
  );
}

class NewsTile extends StatelessWidget {
  final String imgUrl, title, desc, content, posturl, publishAt, author;

  NewsTile(
      {required this.imgUrl,
      required this.desc,
      required this.title,
      required this.content,
      required this.posturl,
      required this.publishAt,
      required this.author});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {

          Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ArticleView(postUrl: posturl)));

          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => ArticleView(
          //               postUrl: posturl,
          //             )));
        },
        child: Container(
            child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: CardView(
            newsSource: author,
            image: imgUrl,
            title: title,
            dateTime: publishAt,
          ),
        )));
  }
}

class NewsTile2 extends StatelessWidget {
  final String imgUrl1, title1, desc1, content1, posturl1, publishAt1, author1;

  const NewsTile2(
      {required this.imgUrl1,
      required this.desc1,
      required this.title1,
      required this.content1,
      required this.posturl1,
      required this.publishAt1,
      required this.author1});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ArticleView(
                        postUrl: posturl1,
                      )));
        },
        child: Container(
          width: 300,
          margin: EdgeInsets.only(left: 15, right: 15),
          child: Container(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.6), BlendMode.dstATop),
                      image: NetworkImage(imgUrl1),
                      fit: BoxFit.fill)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 250,
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                      title1,
                      maxLines: 2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: 250,
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      author1,
                      style: const TextStyle(
                          fontFamily: 'AirbnbCerealBook',
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ));
  }
}


class BookmarkTile extends StatelessWidget {
  final String imgUrl1, title1, desc1, content1, posturl1, publishAt1, author1;

  const BookmarkTile(
      {required this.imgUrl1,
      required this.desc1,
      required this.title1,
      required this.content1,
      required this.posturl1,
      required this.publishAt1,
      required this.author1});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ArticleView(
                        postUrl: posturl1,
                      )));
        },
        child: Container(
          width: 300,
          margin: EdgeInsets.only(left: 15, right: 15),
          child: Container(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.6), BlendMode.dstATop),
                      image: NetworkImage(imgUrl1),
                      fit: BoxFit.fill)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 250,
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                      title1,
                      maxLines: 2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: 250,
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      author1,
                      style: const TextStyle(
                          fontFamily: 'AirbnbCerealBook',
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
