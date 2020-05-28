import 'dart:collection';

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
  Future<_StatResult> _statFuture;

  Future<_StatResult> getLogs(int year, int month) {
    return _StatResult.load(_db, year, month);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _statFuture = getLogs(now.year, now.month);
  }

  Widget _buildLayout(_StatResult stats) {
    return LayoutBuilder(
      builder: (context, viewportConstraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
          child: Column(
            children: <Widget>[
              SourceRow(stats: stats),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget logPreview = FutureBuilder<_StatResult>(
      future: _statFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildLayout(snapshot.data);
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
  SourceRow({Key key, this.stats}) : super(key: key);
  final _StatResult stats;

  Widget _buildIcon(EmotionSource source, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: <Widget>[
          getEmotionSourceIcon(source, size: 40),
          Text(count.toString()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatRow(
      title: "Source",
      children: stats.sourceCount.entries
          .map((entry) => _buildIcon(entry.key, entry.value))
          .toList(),
    );
  }
}

class _StatResult {
  _StatResult(
    this.audioIds,
    this.logs,
    this.sourceCount,
    this.tagCount,
  );

  Set<int> audioIds;
  List<EmotionLog> logs;
  LinkedHashMap<EmotionSource, int> sourceCount;
  LinkedHashMap<String, int> tagCount;

  static Future<_StatResult> load(EmotionTable db, int year, int month) async {
    final audioIds = await getAudioIds();
    final logs = await db.getMonthlyLogs(year, month, withTags: true);
    final sourceCount = await db.getMonthlySourceCount(year, month);
    final tagCount = await db.getMonthlyTagCount(year, month);
    return _StatResult(audioIds, logs, sourceCount, tagCount);
  }
}
