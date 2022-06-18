import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:newsdemoapp/models/TodaysNews.dart';
import 'package:newsdemoapp/models/article.dart';
import 'dart:convert';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:newsdemoapp/secret.dart';

import 'NewsDB.dart';

class News {
  static List<TodaysNews> news = [];
  static List<TodaysNews> newsList = [];

  Future<void> getNews(String startDate, String endDate) async {
    var now = DateTime.now();
    DateTime tempDate1 = new DateFormat("yyyy-MM-dd").parse(startDate);
    DateTime tempDate2 = new DateFormat("yyyy-MM-dd").parse(endDate);
    DateFormat formatter = DateFormat("yyyy-MM-dd");
    String formattedDate1 = formatter.format(tempDate1);
    String formattedDate2 = formatter.format(tempDate2);
    var newDate = DateTime(now.year, now.month, now.day - 5);
    news.clear();
    var url =
        "https://newsapi.org/v2/everything?q=tesla&from=$formattedDate1&to=${formattedDate2}&sortBy=popularity&apiKey=$apiKey";
    debugPrint('topHeald: ${url}');

    var response = await http.get(Uri.parse(url));
    debugPrint(
        "responseDate:- $formattedDate1 $formattedDate2 $url ${response.body}");
    final database = await $FloorNewsDB.databaseBuilder('NewsDB.db').build();

    final personDao = database.newsDao;
    final bookmarkDao = database.bookmarkDao;

    var jsonData = jsonDecode(response.body);
    debugPrint('movieTitle: $response');
    if (jsonData['status'] == "ok") {
      debugPrint("newslist1:- ${newsList.length}");

      newsList.clear();
       debugPrint("newslist2:- ${newsList.length}");
      jsonData["articles"].forEach((element) async {
        if (element['urlToImage'] != null && element['description'] != null) {
          // Article article = Article(
          //   title: element['title'],
          //   author: element['author'],
          //   description: element['description'],
          //   urlToImage: element['urlToImage'],
          //   publshedAt: element['publishedAt'],
          //   content: element["content"],
          //   articleUrl: element["url"],
          // );
          TodaysNews todaysNews = TodaysNews(
              title: element['title'],
              author: element['author']!,
              description: element['description'],
              urlToImage: element['urlToImage'],
              publshedAt: element['publishedAt'],
              content: element["content"],
              articleUrl: element["url"]);
           newsList.add(todaysNews);

            debugPrint;

          news.add(todaysNews);
        }
      });
        if(newsList.isNotEmpty)
          {
            debugPrint("newslistInside:- ${newsList.length}");

            await personDao.truncateTable();
            await personDao.insertPerson(newsList);
          }
    }
    // debugPrint('Number of persons: ${box.get("author")}');
    // Future.delayed(const Duration(milliseconds: 2000), () {
  }
}

class NewsForCategorie {
  List<Article> news = [];

  Future<void> getNewsForCategory(
      String category, String startDate, String endDate) async {
    var now = DateTime.now();
    DateTime tempDate1 = new DateFormat("yyyy-MM-dd").parse(startDate);
    DateTime tempDate2 = new DateFormat("yyyy-MM-dd").parse(endDate);
    DateFormat formatter = DateFormat("yyyy-MM-dd");
    String formattedDate1 = formatter.format(tempDate1);
    String formattedDate2 = formatter.format(tempDate2);
    /*String url = "http://newsapi.org/v2/everything?q=$category&apiKey=${apiKey}";*/
    var url =
        "https://newsapi.org/v2/everything?q=$category&from=$formattedDate1&to=${formattedDate2}&sortBy=popularity&apiKey=$apiKey";

    var response = await http.get(Uri.parse(url));
    news.clear();
    var jsonData = jsonDecode(response.body);
    debugPrint("listofCalender:= ${url}");
    if (jsonData['status'] == "ok") {
      jsonData["articles"].forEach((element) {
        if (element['urlToImage'] != null && element['description'] != null) {
          Article article = Article(
            title: element['title'],
            author: element['author'],
            description: element['description'],
            urlToImage: element['urlToImage'],
            publshedAt: element['publishedAt'],
            content: element["content"],
            articleUrl: element["url"],
          );

          news.add(article);
        }
      });
    }
  }
}
