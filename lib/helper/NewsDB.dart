// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:newsdemoapp/helper/NewsDao.dart';
import 'package:newsdemoapp/models/Bookmark.dart';

import 'package:newsdemoapp/models/TodaysNews.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'BookmarkDao.dart';


part 'NewsDB.g.dart';
// the generated code will be there

@Database(version: 1, entities: [TodaysNews,Bookmark])
abstract class NewsDB extends FloorDatabase {
  NewsDao get newsDao;
  BookmarkDao get bookmarkDao;
}