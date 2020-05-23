import 'dart:io';

import 'package:dos/utils.dart';
import 'package:path_provider/path_provider.dart';

import 'emotion.dart';
import 'emotion_source.dart';

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

  /// Initialize the temp path base on the id
  initTempPath() async {
    this.tempAudioPath = null;
    if (this.id != null) {
      File f = await getAudioFile();
      if (await f.exists()) {
        String temp = await createTempAudioPath();
        bool copied = await copyFile(f.path, temp);
        if (copied) {
          this.tempAudioPath = temp;
        }
      }
    }
  }

  Future<String> getAudioPath() {
    return getLogAudioPath(this.id);
  }

  Future<File> getAudioFile() {
    return getLogAudioFile(this.id);
  }
}

Future<String> getLogAudioPath(int id) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  return '${appDir.path}/$id.acc';
}

Future<File> getLogAudioFile(int id) async {
  return File(await getLogAudioPath(id));
}
