import 'package:dos/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

OutlineInputBorder inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10.0),
  borderSide: BorderSide(),
);