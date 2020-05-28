import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dos/models/emotion_source.dart';
import 'package:dos/utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/emotion_log.dart';

final String tableLogs = 'logs';
final String tableTags = 'tags';
final String tableLogTags = 'log_tags';

List<DateTime> getDateTimesOfMonth(int year, int month) {
  if (month < 1 || month > 12) {
    throw RangeError.range(month, 1, 12);
  }

  // in local time zone
  final startTime = DateTime(year, month);
  int endYear = year + (month + 1 / 12).toInt();
  int endMonth = (month + 1) % 12;
  final endTime = DateTime(endYear, endMonth);
  return [startTime, endTime];
}

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

  // TEST ONLY DO NOT USE IN PROD
  Future<List<String>> getTags() async {
    final Database db = await database;
    final maps = await db.query(tableTags);
    return List.generate(maps.length, (i) => maps[i]['tag']);
  }

  Future<List<String>> getTagsBy(int logId) async {
    final Database db = await database;
    final maps = await db.rawQuery(
        'SELECT t.tag FROM log_tags lt INNER JOIN tags t ON lt.tag_id = t.id WHERE lt.log_id = ?',
        [logId]);
    return List.generate(maps.length, (i) => maps[i]['tag']);
  }

  // UNBOUNDED DON NO USE IN PROD
  Future<LinkedHashMap<String, int>> getTagCount() async {
    final Database db = await database;
    final maps = await db.rawQuery(
      'SELECT t.tag, COUNT(*) FROM log_tags lt INNER JOIN tags t ON lt.tag_id = t.id GROUP BY t.tag ORDER BY COUNT(*) DESC',
    );

    final count = LinkedHashMap<String, int>();
    maps.forEach((element) {
      count[element["tag"]] = element['COUNT(*)'];
    });

    return count;
  }

  Future<List<String>> getTagsStartWith(String str, int limit) async {
    if (str == null) {
      return <String>[];
    }
    final Database db = await database;
    final maps = await db.query(tableTags,
        columns: ['tag'],
        where: 'tag LIKE ?',
        whereArgs: ['$str%'],
        limit: limit,
        orderBy: 'id DESC');
    return List.generate(maps.length, (i) => maps[i]['tag']);
  }

  Future<LinkedHashMap<EmotionSource, int>> getMonthlySourceCount(
      int year, int month,
      {countNull = false}) {
    final dateTimes = getDateTimesOfMonth(year, month);
    return getSourceCount(dateTimes[0], dateTimes[1], countNull: countNull);
  }

  Future<LinkedHashMap<EmotionSource, int>> getSourceCount(
      DateTime from, DateTime to,
      {countNull = false}) async {
    final Database db = await database;
    final maps = await db.rawQuery(
      'SELECT source, COUNT(*) FROM logs WHERE datetime >= ? AND datetime <= ? GROUP BY source ORDER BY COUNT(*) DESC',
      [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
    );

    final count = LinkedHashMap<EmotionSource, int>();
    maps.forEach((element) {
      final srcInt = element["source"];
      final key = srcInt != null ? EmotionSource.values[srcInt] : null;
      if (key != null || (key == null && countNull)) {
        count[key] = element['COUNT(*)'];
      }
    });

    return count;
  }

  Future<List<EmotionLog>> getAllLogs({withTags = false}) async {
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

  Future<List<EmotionLog>> getMonthlyLogs(int year, int month,
      {withTags = false}) {
    final dateTimes = getDateTimesOfMonth(year, month);
    return getLogs(dateTimes[0], dateTimes[1], withTags: withTags);
  }

  Future<List<EmotionLog>> getLogs(DateTime from, DateTime to,
      {withTags = false}) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The EmotionLogs.
    final List<Map<String, dynamic>> maps = await db.query(tableLogs,
        where: "datetime >= ? AND datetime <= ?",
        whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
        orderBy: 'datetime DESC');

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

    await db.transaction((txn) async {
      // Update the given EmotionLog.
      await txn.update(
        tableLogs,
        log.toMap(),
        // Ensure that the EmotionLog has a matching id.
        where: "id = ?",
        // Pass the EmotionLog's id as a whereArg to prevent SQL injection.
        whereArgs: [log.id],
      );

      // Remove all assoication of tags and reinsert
      await txn.delete(tableLogTags, where: "log_id = ?", whereArgs: [log.id]);
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
            [log.id.toString()] + log.tags);
      }

      File audioFile = await getLogAudioFile(log.id);
      if (log.tempAudioPath != null) {
        await moveFile(log.tempAudioPath, audioFile.path);
      } else {
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
      }
    });
  }

  Future<void> deleteEmotionLog(int id) async {
    // Get a reference to the database.
    final db = await database;
    await db.transaction((txn) async {
      // Remove the EmotionLog from the database.
      await txn.delete(
        tableLogs,
        // Use a `where` clause to delete a specific log.
        where: "id = ?",
        // Pass the EmotionLog's id as a whereArg to prevent SQL injection.
        whereArgs: [id],
      );

      // Remove the optional audio
      File audioFile = await getLogAudioFile(id);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
    });
  }
}
