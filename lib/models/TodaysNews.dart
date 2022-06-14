import 'package:floor/floor.dart';

@entity
class TodaysNews {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String title;

  String author;

  String description;

  String urlToImage;

  String publshedAt;

  String content;

  String articleUrl;



  TodaysNews({
      this.id,
      required this.title,
      required this.description,
      required this.author,
      required this.content,
      required this.publshedAt,
      required this.urlToImage,
      required this.articleUrl}
      );
}
