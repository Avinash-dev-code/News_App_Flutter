// dao/person_dao.dart

import 'package:floor/floor.dart';

import '../models/TodaysNews.dart';

@dao
abstract class NewsDao {
  @Query('SELECT * FROM TodaysNews')
  Future<List<TodaysNews>> findAllPersons();

  @Query("SELECT EXISTS(SELECT * FROM TodaysNews WHERE title = :title)")
  Future<bool?> isTitle(String title);

  @Query('SELECT * FROM TodaysNews WHERE title = :title')
  Future<TodaysNews?> findPersonById(String title);

  @Query('SELECT *  FROM TodaysNews WHERE urlToImage IN(:urlToImage)')
  Future<List<TodaysNews>?> getBookmark(List<String> urlToImage );

  @Query('DELETE FROM TodaysNews')
  Future<void> truncateTable();



  @Query("UPDATE TodaysNews SET author=:author,description=:description,urlToImage=:urlToImage,publshedAt=:publshedAt,content=:content,articleUrl=:articleUrl WHERE title =:title")
  Future<void> update(String title, String author, String description,
      String urlToImage, String publshedAt, String content, String articleUrl);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertPerson(List<TodaysNews> list);
}