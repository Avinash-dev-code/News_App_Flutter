import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newsdemoapp/helper/news.dart';
import 'package:newsdemoapp/helper/widgets.dart';
import 'package:get_time_ago/get_time_ago.dart';

class CategoryNews extends StatefulWidget {
  final String newsCategory;

  CategoryNews({required this.newsCategory});

  @override
  _CategoryNewsState createState() => _CategoryNewsState();
}

class _CategoryNewsState extends State<CategoryNews> {
  var newslist;
  bool _loading = true;
  NewsForCategorie news = NewsForCategorie();
  DateTime currentDate = DateTime.now();
  @override
  void initState() {
    getNews();
    // TODO: implement initState
    super.initState();
  }

  void getNews() async {
    DateTime tempDate2 = new DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(currentDate.toString());
    DateFormat formatter=DateFormat("yyyy-MM-dd");
    String formattedDate1 = formatter.format(tempDate2);

    await news.getNewsForCategory(widget.newsCategory,formattedDate1,formattedDate1);

    newslist = news.news;
    setState(() {
      _loading = false;
    });
  }
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
        getNews();
      });
    }
  }
  String firstLetter(String letter) {
    String finalLetter =
        letter[0].toUpperCase() + letter.substring(1).toLowerCase();
    return finalLetter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              firstLetter(widget.newsCategory),
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 5),
            Text(
              "News",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            )
          ],
        ),
        actions: <Widget>[
          Opacity(
            opacity: 0,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(
                  Icons.share,
                )),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children:(<Widget>[

                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: ListView.builder(
                        itemCount: news.news.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          var convertedTimestamp = DateTime.parse(news
                              .news[index]
                              .publshedAt); // Converting into [DateTime] object
                          var result = GetTimeAgo.parse(convertedTimestamp);
                          if(result==("a day ago"))
                          {
                            result="1 day ago";
                          }
                          else {
                            result=GetTimeAgo.parse(convertedTimestamp);
                          }
                          return NewsTile(
                            imgUrl: news.news[index].urlToImage ?? "",
                            title: news.news[index].title ?? "",
                            desc: news.news[index].description ?? "",
                            content: news.news[index].content ?? "",
                            posturl: news.news[index].articleUrl ?? "",
                            publishAt: result ?? "",
                            author: news.news[index].author ?? "",
                          );
                        }),
                  ),
                ])
              ),
            ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.calendar_today),
        backgroundColor: Colors.blue,
        onPressed: () {
          selectDate(context);
        },
      ),
    );
  }
}
