import 'dart:async';
import 'dart:io';

import 'package:dos/utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableLogs = 'logs';
final String tableTags = 'tags';

class EmotionTable {
  static EmotionTable _emotionTable; // Singleton table
  static Database _database; // Singleton Database

  EmotionTable._createInstance(); // Defining a named generative constructor

  // A factory method to create a singleton table class
  factory EmotionTable() {
    if (_emotionTable == null) {
      _emotionTable = EmotionTable._createInstance();
    }
    return _emotionTable;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'log_database.db'),
      // Add support for cascade delete
      onConfigure: (db) => db.execute("PRAGMA foreign_keys = ON"),
      // When the database is first created, create a table to store logs.
      onCreate: (db, version) {
        var batch = db.batch();
        batch.execute(
          "CREATE TABLE logs(" +
              "id INTEGER PRIMARY KEY AUTOINCREMENT," +
              // millisconds since epoch in UTC
              "datetime INTEGER," +
              "emotion INTEGER," +
              "scale INTEGER," +
              "source INTEGER," +
              "journal TEXT)",
        );
        batch.execute(
            "CREATE TABLE tags(id INTEGER PRIMARY KEY AUTOINCREMENT, tag TEXT NOT NULL UNIQUE)");
        batch.execute("CREATE TABLE log_tags(" +
            "log_id INTEGER," +
            "tag_id INTEGER," +
            "FOREIGN KEY(log_id) REFERENCES logs(id) ON DELETE CASCADE," +
            "FOREIGN KEY(tag_id) REFERENCES tags(id) ON DELETE CASCADE)");
        batch.execute("CREATE INDEX log_index ON log_tags(log_id)");
        batch.execute("CREATE INDEX tag_index ON log_tags(tag_id)");
        batch.execute("CREATE INDEX datetime_index ON logs(datetime)");
        return batch.commit();
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insertEmotionLog(EmotionLog log) async {
    // Get a reference to the database.
    final Database db = await database;
    int logId;
    // Insert the EmotionLog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same log is inserted
    // multiple times, it replaces the previous data.
    await db.transaction((txn) async {
      logId = await txn.insert(
        tableLogs,
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (log.tags != null && log.tags.length > 0) {
        // Insert all tags. If there is conflict in insertion the row id
        // might be null, so we can't use the return value to create log_tags.
        // https://github.com/tekartik/sqflite/issues/402
        await Future.wait(log.tags.map((t) => txn.insert(tableTags, {'tag': t},
            conflictAlgorithm: ConflictAlgorithm.ignore)));

        // TODO: Limit where in count for safety
        // Find all the tags and insert into the log_tags
        await txn.execute(
            "INSERT INTO log_tags (log_id, tag_id) " +
                "SELECT ?, id FROM tags WHERE tag IN (" +
                log.tags.map((t) => "?").join(",") +
                ")",
            [logId.toString()] + log.tags);
      }
      if (log.tempAudioPath != null) {
        File audioFile = await getLogAudioFile(logId);
        await moveFile(log.tempAudioPath, audioFile.path);
      }
    });

    return logId;
  }

  Future<List<String>> getTagsBy(int logId) async {
    final Database db = await database;
    var maps = await db.rawQuery(
        'SELECT t.tag FROM log_tags lt INNER JOIN tags t ON lt.tag_id = t.id WHERE lt.log_id = ?',
        [logId]);
    return List.generate(maps.length, (i) => maps[i]['tag']);
  }

  Future<List<String>> getTagsStartWith(String str, int limit) async {
    if (str == null) {
      return <String>[];
    }
    final Database db = await database;
    var maps = await db.query(tableTags,
        columns: ['tag'],
        where: 'tag LIKE ?',
        whereArgs: ['$str%'],
        limit: limit,
        orderBy: 'id DESC');
    return List.generate(maps.length, (i) => maps[i]['tag']);
  }

  Future<List<EmotionLog>> getLogs({withTags = false}) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The EmotionLogs.
    final List<Map<String, dynamic>> maps =
        await db.query(tableLogs, orderBy: 'datetime DESC');

    // Convert the List<Map<String, dynamic> into a List<EmotionLog>.
    var logs = List.generate(
      maps.length,
      (i) => EmotionLog.fomObject(maps[i]),
    );

    if (withTags) {
      // Get all the tags (expensive)
      await Future.wait(logs.map((l) async {
        l.tags = await getTagsBy(l.id);
      }));
    }
    return logs;
  }

  Future<void> updateEmotionLog(EmotionLog log) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given EmotionLog.
    await db.update(
      tableLogs,
      log.toMap(),
      // Ensure that the EmotionLog has a matching id.
      where: "id = ?",
      // Pass the EmotionLog's id as a whereArg to prevent SQL injection.
      whereArgs: [log.id],
    );
  }

  Future<void> deleteEmotionLog(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the EmotionLog from the database.
    await db.delete(
      tableLogs,
      // Use a `where` clause to delete a specific log.
      where: "id = ?",
      // Pass the EmotionLog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}

class EmotionLog {
  int id;
  DateTime dateTime;
  Emotion emotion;
  EmotionSource source;
  int scale;
  String journal;
  List<String> tags;
  String tempAudioPath;

  EmotionLog(
      {this.id,
      this.dateTime,
      this.emotion,
      this.scale,
      this.journal,
      this.source,
      this.tags});

  EmotionLog.fomObject(dynamic o) {
    this.id = o['id'];
    this.dateTime = DateTime.fromMillisecondsSinceEpoch(o['datetime']);
    this.emotion = Emotion.values[o['emotion'] ?? 0];
    this.scale = o['scale'];
    this.source =
        o['source'] != null ? EmotionSource.values[o['source']] : null;
    this.journal = o['journal'];
  }

  Map<String, dynamic> toMap() {
    var map = {
      'datetime': dateTime.millisecondsSinceEpoch,
      'emotion': emotion?.index,
      'scale': scale,
      'source': source?.index,
      'journal': journal,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Implement toString to make it easier to see information about
  // each log when using the print statement.
  @override
  String toString() {
    return 'EmotionLog{id: $id, journal: $journal datetime: $dateTime}';
  }
}

enum EmotionSource {
  home,
  work,
  money,
  //humanchild,
  people,
}

enum Emotion {
  none,
  happy,
  sad,
  scared,
  surprised,
  angry,
  cry,
  love,
  sleeping,
  bad,
  zombie,
  sick,
  laughing,
  hungry,
  kiss,
  painter,
  waiting,
  music,
  sick2,
  cool,
  model,
  angel,
  inLove,
  worker,
  pirate,
  writer,
  exercise,
  detective,
  cook,
  employee,
  run,
}
