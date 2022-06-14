// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:newsdemoapp/models/Bookmark.dart';

import '../models/TodaysNews.dart';

@dao
abstract class BookmarkDao {
  @Query('SELECT * FROM Bookmark')
  Future<List<Bookmark>> getAllBookmark();

  @Insert()
  Future<void> addToBookmark(Bookmark bookmark);
}