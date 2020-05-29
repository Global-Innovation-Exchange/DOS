import 'package:flutter/material.dart';

import '../utils.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      backgroundColor: themeColor,
      body: Text('Test Setting Screen'),
    );
  }
}
