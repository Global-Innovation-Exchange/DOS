import 'package:dos/screens/create_log.dart';
import 'package:dos/screens/logs.dart';
import 'package:dos/screens/stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        textTheme: GoogleFonts.itimTextTheme(
          Theme.of(context).textTheme.apply(
                fontSizeFactor: 1.1,
                fontSizeDelta: 2.0,
              ),

          // c itimTextTheme
          //d shortStack
          // e delius
        ),
        primaryTextTheme: GoogleFonts.ralewayTextTheme(),
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
  Key _key = ObjectKey(DateTime.now());

  Widget _getBody(int index, Key key) {
    switch (index) {
      case 0:
        return LogsScreen(title: 'Emotion Logs', key: key);
      case 1:
        return StatScreen(key: key);
      default:
        return SettingScreen();
    }
  }

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
                setState(() {
                  // Use key to force update the child for now
                  _key = ObjectKey(DateTime.now());
                });
              }
            },
          ))),
      body: _getBody(_currentIndex, _key),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: themeForegroundColor,
        currentIndex: _currentIndex,
        selectedItemColor: themeColor,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(
              MdiIcons.cardAccountDetails,
              size: 35,
            ),
            title: new Text('Log'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(
              MdiIcons.chartBellCurve,
              size: 35,
            ),
            title: new Text('Stats'),
          ),
        ],
      ),
    );
  }
}
