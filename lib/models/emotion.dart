import 'package:flutter/material.dart';

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

Image getEmotionImage(Emotion e) {
  return Image.asset('assets/images/${e.index}.png');
}