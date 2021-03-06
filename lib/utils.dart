import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final _dateTimeFormatter = DateFormat.yMd().add_jm();
String formatDateTime(DateTime dt) {
  return _dateTimeFormatter.format(dt);
}

// Theme color to be used cross the app
Map<int, Color> color = {
  50: Color.fromRGBO(255, 182, 153, .1),
  100: Color.fromRGBO(255, 182, 153, .2),
  200: Color.fromRGBO(255, 182, 153, .3),
  300: Color.fromRGBO(255, 182, 153, .4),
  400: Color.fromRGBO(255, 182, 153, .5),
  500: Color.fromRGBO(255, 182, 153, .6),
  600: Color.fromRGBO(255, 182, 153, .7),
  700: Color.fromRGBO(255, 182, 153, .8),
  800: Color.fromRGBO(255, 182, 153, .9),
  900: Color.fromRGBO(255, 182, 153, 1),
};

MaterialColor colorSwatch = MaterialColor(0xFFE1B699, color);
Color themeForegroundColor = Color(0xFFE1B699);
Color themeColor = Color(0xffFEEFE6);

OutlineInputBorder inputBorder = new OutlineInputBorder(
  borderRadius: new BorderRadius.circular(10.0),
  borderSide: new BorderSide(),
);

// https://stackoverflow.com/a/55614133/2563765
Future<File> moveFile(String sourcePath, String newPath) async {
  File sourceFile = File(sourcePath);
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (e) {
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}

Future<bool> copyFile(String sourcePath, String newPath) async {
  File sourceFile = File(sourcePath);
  try {
    // prefer using rename as it is probably faster
    File f = await sourceFile.copy(newPath);
    await f.setLastModified(await sourceFile.lastModified());
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteFile(String path) async {
  File file = File(path);
  try {
    await file.delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<String> createTempAudioPath() async {
  Directory tempDir = await getTemporaryDirectory();
  bool exists = true;
  File tempFile;
  while (exists) {
    String filename = '${Uuid().v4()}.aac';
    tempFile = File('${tempDir.path}/$filename');
    exists = await tempFile.exists();
  }
  return tempFile.path;
}

Future<Set<int>> getAudioIds() async {
  final isAAC = RegExp(r'^([0-9]+)\.acc$');
  final Set<int> ids = Set();
  final completer = Completer<Set<int>>();
  Directory d = await getApplicationDocumentsDirectory();
  var lister = d.list(recursive: false, followLinks: false);
  lister.listen(
    (file) {
      String filename = basename(file.path);
      final match = isAAC.firstMatch(filename);
      if (match != null) {
        ids.add(int.parse(match.group(1)));
      }
    },
    onDone: () => completer.complete(ids),
    onError: (error) => completer.completeError(error),
  );
  return await completer.future;
}

List<DateTime> getDateTimesOfMonth(int year, int month) {
  if (month < 1 || month > 12) {
    throw RangeError.range(month, 1, 12);
  }

  // in local time zone
  final startTime = DateTime(year, month);
  int endYear = year + (month + 1) ~/ 12;
  int endMonth = (month + 1) % 12;
  final endTime = DateTime(endYear, endMonth);
  return [startTime, endTime];
}
