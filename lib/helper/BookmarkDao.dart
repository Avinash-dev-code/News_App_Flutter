// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:newsdemoapp/models/Bookmark.dart';

import '../models/TodaysNews.dart';

@dao
abstract class BookmarkDao {
  @Query('SELECT * FROM Bookmark')
  Future<List<Bookmark>> getAllBookmark();

  @Query("DELETE FROM Bookmark WHERE url = :url")
  Future<void> deleteBookmark(String url);

  @Query('SELECT * FROM Bookmark WHERE url = :url')
  Future<Bookmark?> getBookmark(String url);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> addToBookmark(Bookmark bookmark);

  @Query('DELETE FROM Bookmark')
  Future<void> truncateTable();
}
