import 'dart:io';

import 'package:dos/utils.dart';
import 'package:flutter/foundation.dart';
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
      this.tags,
      this.tempAudioPath});

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

  Future<bool> equals(EmotionLog original) async {
    bool isEqual = this.dateTime == original.dateTime &&
        this.emotion == original.emotion &&
        this.scale == original.scale &&
        this.journal == original.journal &&
        this.source == original.source &&
        setEquals(this.tags?.toSet(), original.tags?.toSet()) &&
        this.tempAudioPath == original.tempAudioPath;

    if (isEqual && tempAudioPath != null) {
      // This is for the case where user just modified the audio is the detail page
      File f = await getLogAudioFile(id);
      File temp = File(tempAudioPath);
      bool bothExist = await Future.wait([f.exists(), temp.exists()])
          .then((value) => value.every((exist) => exist));
      if (bothExist) {
        DateTime ogFileMod = await f.lastModified();
        DateTime timeFileMod = await temp.lastModified();
        isEqual &= ogFileMod == timeFileMod;
      }
    }
    return isEqual;
  }

  EmotionLog clone() {
    return EmotionLog(
        id: this.id,
        dateTime: this.dateTime,
        emotion: this.emotion,
        scale: this.scale,
        journal: this.journal,
        source: this.source,
        tags: this.tags?.toList(),
        tempAudioPath: this.tempAudioPath);
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
