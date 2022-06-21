// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NewsDB.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorNewsDB {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$NewsDBBuilder databaseBuilder(String name) => _$NewsDBBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$NewsDBBuilder inMemoryDatabaseBuilder() => _$NewsDBBuilder(null);
}

class _$NewsDBBuilder {
  _$NewsDBBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$NewsDBBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$NewsDBBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<NewsDB> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$NewsDB();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$NewsDB extends NewsDB {
  _$NewsDB([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  NewsDao? _newsDaoInstance;

  BookmarkDao? _bookmarkDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TodaysNews` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `author` TEXT NOT NULL, `description` TEXT NOT NULL, `urlToImage` TEXT NOT NULL, `publshedAt` TEXT NOT NULL, `content` TEXT NOT NULL, `articleUrl` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Bookmark` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `url` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  NewsDao get newsDao {
    return _newsDaoInstance ??= _$NewsDao(database, changeListener);
  }

  @override
  BookmarkDao get bookmarkDao {
    return _bookmarkDaoInstance ??= _$BookmarkDao(database, changeListener);
  }
}

class _$NewsDao extends NewsDao {
  _$NewsDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _todaysNewsInsertionAdapter = InsertionAdapter(
            database,
            'TodaysNews',
            (TodaysNews item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'author': item.author,
                  'description': item.description,
                  'urlToImage': item.urlToImage,
                  'publshedAt': item.publshedAt,
                  'content': item.content,
                  'articleUrl': item.articleUrl
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TodaysNews> _todaysNewsInsertionAdapter;

  @override
  Future<List<TodaysNews>> findAllPersons() async {
    return _queryAdapter.queryList('SELECT * FROM TodaysNews',
        mapper: (Map<String, Object?> row) => TodaysNews(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String,
            author: row['author'] as String,
            content: row['content'] as String,
            publshedAt: row['publshedAt'] as String,
            urlToImage: row['urlToImage'] as String,
            articleUrl: row['articleUrl'] as String));
  }

  @override
  Future<bool?> isTitle(String title) async {
    await _queryAdapter.queryNoReturn(
        'SELECT EXISTS(SELECT * FROM TodaysNews WHERE title = ?1)',
        arguments: [title]);
  }

  @override
  Future<TodaysNews?> findPersonById(String title) async {
    return _queryAdapter.query('SELECT * FROM TodaysNews WHERE title = ?1',
        mapper: (Map<String, Object?> row) => TodaysNews(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String,
            author: row['author'] as String,
            content: row['content'] as String,
            publshedAt: row['publshedAt'] as String,
            urlToImage: row['urlToImage'] as String,
            articleUrl: row['articleUrl'] as String),
        arguments: [title]);
  }

  @override
  Future<List<TodaysNews>?> getBookmark(List<String> urlToImage) async {
    const offset = 1;
    final _sqliteVariablesForUrlToImage =
        Iterable<String>.generate(urlToImage.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT *  FROM TodaysNews WHERE urlToImage IN(' +
            _sqliteVariablesForUrlToImage +
            ')',
        mapper: (Map<String, Object?> row) => TodaysNews(
            id: row['id'] as int?,
            title: row['title'] as String,
            description: row['description'] as String,
            author: row['author'] as String,
            content: row['content'] as String,
            publshedAt: row['publshedAt'] as String,
            urlToImage: row['urlToImage'] as String,
            articleUrl: row['articleUrl'] as String),
        arguments: [...urlToImage]);
  }

  @override
  Future<void> truncateTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM TodaysNews');
  }

  @override
  Future<void> update(
      String title,
      String author,
      String description,
      String urlToImage,
      String publshedAt,
      String content,
      String articleUrl) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE TodaysNews SET author=?2,description=?3,urlToImage=?4,publshedAt=?5,content=?6,articleUrl=?7 WHERE title =?1',
        arguments: [
          title,
          author,
          description,
          urlToImage,
          publshedAt,
          content,
          articleUrl
        ]);
  }

  @override
  Future<void> insertPerson(List<TodaysNews> list) async {
    await _todaysNewsInsertionAdapter.insertList(
        list, OnConflictStrategy.replace);
  }
}

class _$BookmarkDao extends BookmarkDao {
  _$BookmarkDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _bookmarkInsertionAdapter = InsertionAdapter(
            database,
            'Bookmark',
            (Bookmark item) =>
                <String, Object?>{'id': item.id, 'url': item.url});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Bookmark> _bookmarkInsertionAdapter;

  @override
  Future<List<Bookmark>> getAllBookmark() async {
    return _queryAdapter.queryList('SELECT * FROM Bookmark',
        mapper: (Map<String, Object?> row) =>
            Bookmark(id: row['id'] as int?, url: row['url'] as String));
  }

  @override
  Future<void> deleteBookmark(String url) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Bookmark WHERE url = ?1', arguments: [url]);
  }

  @override
  Future<Bookmark?> getBookmark(String url) async {
    return _queryAdapter.query('SELECT * FROM Bookmark WHERE url = ?1',
        mapper: (Map<String, Object?> row) =>
            Bookmark(id: row['id'] as int?, url: row['url'] as String),
        arguments: [url]);
  }

  @override
  Future<void> truncateTable() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Bookmark');
  }

  @override
  Future<void> addToBookmark(Bookmark bookmark) async {
    await _bookmarkInsertionAdapter.insert(
        bookmark, OnConflictStrategy.replace);
  }
}
