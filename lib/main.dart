import 'package:dos/screens/logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'utils.dart';

//calling main function when app started
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOS',
      theme: ThemeData(
        // This is the theme of the application.
        primarySwatch: colorSwatch,
      ),
      home: LogsScreen(title: 'Emotion logs'),
    );
  }
}
