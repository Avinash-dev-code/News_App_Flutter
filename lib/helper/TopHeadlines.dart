import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newsdemoapp/models/article.dart';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:intl/intl.dart';

import 'package:newsdemoapp/secret.dart';

class TopHeadlines {
  List<Article> news = [];

  Future<void> getNews() async {
    var now =  DateTime.now();
    var formatter =  DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    var newDate = DateTime(now.year, now.month, now.day);

    debugPrint("Minus Date :- ${formatter.format(newDate)}");

    var url = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=$apiKey";

    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);
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

