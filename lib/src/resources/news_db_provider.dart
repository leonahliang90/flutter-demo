import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../models/item_model.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'repository.dart';

class NewsDbProvider implements Source, Cache {
  Database db;

  final tableName = "items";

  NewsDbProvider() {
    init();
  }

  init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "$tableName.db");
    db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database newDb, int version) {
          newDb.execute("""
            CREATE TABLE $tableName
              (
                id INTEGER PRIMARY KEY,
                type TEXT,
                by TEXT,
                time INTEGER,
                text TEXT,
                parent INTEGER,
                kids BLOB,
                dead INTEGER,
                deleted INTEGER,
                url TEXT,
                score INTEGER,
                title TEXT,
                descendants INTEGER
              )
          """);
        },
      );
  }

  // Todo - store and fetch top ids
  Future<List<int>> fetchTopIds() {
    return null;
  }

  Future<ItemModel>fetchItem(int id) async {
    final maps = await db.query(
      "$tableName",
      columns: null,
      where: "id = ?",
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return ItemModel.fromDb(maps.first);
    } 

    return null;
  }

  Future<int> addItem(ItemModel item) {
    return db.insert("$tableName", item.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> clear() {
    return db.delete("$tableName");
  }
}

// declare Singleton
final newsDbProvider = NewsDbProvider();