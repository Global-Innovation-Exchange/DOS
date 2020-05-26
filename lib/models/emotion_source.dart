import 'package:flutter/material.dart';

enum EmotionSource {
  home,
  work,
  money,
  //humanchild,
  people,
  sleep,
}

Icon getEmotionSourceIcon(EmotionSource src, {Color color, double size}) {
  IconData iconData;
  switch (src) {
    case EmotionSource.home:
      iconData = Icons.home;
      break;

    case EmotionSource.work:
      iconData = Icons.work;
      break;

    case EmotionSource.money:
      iconData = Icons.attach_money;
      break;

//    case EmotionSource.humanchild:
//      iconData = Icons.child_care;
//      break;

    case EmotionSource.people:
      iconData = Icons.group;
      break;

    case EmotionSource.sleep:
      iconData = Icons.hotel;
      break;
  }

  return Icon(iconData, color: color, size: size);
}
