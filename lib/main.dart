import 'package:dos/screens/logs.dart';
import 'package:dos/screens/stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'screens/settings.dart';
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
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    LogsScreen(title: 'Emotion Logs'),
    StatScreen(),
    SettingScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // this will be set when a new tab is tapped
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(MdiIcons.book),
            title: new Text('Log'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(MdiIcons.chartBar),
            title: new Text('Stats'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          )
        ],
      ),
    );
  }
}
