import 'package:dos/database.dart';
import 'package:dos/models/emotion_source.dart';
import 'package:flutter/material.dart';

import '../database.dart';
import '../models/emotion_log.dart';
import '../utils.dart';

class StatScreen extends StatefulWidget {
  @override
  _StatScreenState createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  final EmotionTable _db = EmotionTable();
  Future<List<EmotionLog>> _logsFuture;
  Set<int> _audioIds = Set<int>();

  Future<List<EmotionLog>> getLogs(int year, int month) async {
    _audioIds = await getAudioIds();
    return await _db.getMonthlyLogs(year: year, month: month, withTags: true);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _logsFuture = getLogs(now.year, now.month);
  }

  Widget _buildLayout(List<EmotionLog> logs, Set<int> audioIds) {
    return LayoutBuilder(
      builder: (context, viewportConstraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
          child: Column(
            children: <Widget>[
              SourceRow(logs: logs),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget logPreview = FutureBuilder<List<EmotionLog>>(
      future: _logsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildLayout(snapshot.data, _audioIds);
        } else if (snapshot.hasError) {
          return Text('Error');
        } else {
          // Loading...
          return Text('Loading');
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Stats"),
      ),
      backgroundColor: themeColor,
      body: logPreview,
    );
  }
}

// This is a row element that have all the shared style
class StatRow extends StatelessWidget {
  StatRow({Key key, this.children, this.title}) : super(key: key);
  final List<Widget> children;
  final String title;

  @override
  Widget build(BuildContext context) {
    // TODO: style so all rows has a common style
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeForegroundColor,
        borderRadius: BorderRadius.all(
          // set rounded corner radius
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(this.title, style: Theme.of(context).textTheme.headline5),
          Row(children: this.children),
        ],
      ),
    );
  }
}

class SourceRow extends StatelessWidget {
  SourceRow({Key key, this.logs}) : super(key: key);
  final List<EmotionLog> logs;

  @override
  Widget build(BuildContext context) {
    return StatRow(
      title: "Source",
      children: <Widget>[
        getEmotionSourceIcon(EmotionSource.home, size: 50),
      ],
    );
  }
}
