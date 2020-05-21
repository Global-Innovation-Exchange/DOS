import 'dart:io';

import 'package:dos/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

final _dateTimeFormatter = DateFormat.yMd().add_jm();
String formatDateTime(DateTime dt) {
  return _dateTimeFormatter.format(dt);
}

Image getEmotionImage(Emotion e) {
  return Image.asset('assets/images/${e.index}.png');
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

Future<File> getLogAudioFile(int logId) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  return File('${appDir.path}/$logId.acc');
}

Icon getEmotionSourceIcon(EmotionSource src, {Color color}) {
  Icon icon;
  switch (src) {
    case EmotionSource.home:
      {
        icon = Icon(
          Icons.home,
          color: color,
        );
      }
      break;

    case EmotionSource.work:
      {
        icon = Icon(Icons.work, color: color);
      }
      break;

    case EmotionSource.money:
      {
        icon = Icon(Icons.attach_money, color: color);
      }
      break;

//    case EmotionSource.humanchild:
//      {
//        icon = Icon(Icons.child_care, color: color);
//      }
//      break;
    case EmotionSource.people:
      {
        icon = Icon(Icons.group, color: color);
        //icon = Icon(Icons.local_hospital);
        //icon = Icon(Icons.school, color: color);
      }
      break;
  }

  return icon;
}
