import 'package:flutter/material.dart';

enum EmotionSource {
  home,
  work,
  money,
  //humanchild,
  people,
  sleep,
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

    case EmotionSource.sleep:
      {
        icon = Icon(Icons.hotel, color: color);
      }
      break;
  }

  return icon;
}
