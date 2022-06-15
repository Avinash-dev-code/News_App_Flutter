
import 'package:floor/floor.dart';

@entity
class Bookmark{

  @PrimaryKey(autoGenerate: true)
  int? id;

  String url;


  Bookmark({this.id,required this.url});




}