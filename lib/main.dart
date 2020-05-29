import 'package:dos/screens/create_log.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
          height: 85.0,
          width: 85.0,
          child: FittedBox(
              child: FloatingActionButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                side: BorderSide(color: Color(0xFFE1B699), width: 3.0)),
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.add,
              color: Color(0xFFE1B699),
            ),
            onPressed: () async {
              bool updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateLog()),
              );

              if (updated != null) {
                setState(() {});
              }
            },
          ))),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: themeForegroundColor,
        currentIndex: _currentIndex,
        selectedItemColor: themeColor,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(
              MdiIcons.book,
              size: 35,
            ),
            title: new Text('Log'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(
              MdiIcons.chartBar,
              size: 35,
            ),
            title: new Text('Stats'),
          ),
        ],
      ),
    );
  }
}
