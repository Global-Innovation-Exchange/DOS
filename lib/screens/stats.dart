import 'dart:collection';

import 'package:dos/database.dart';
import 'package:dos/models/emotion_source.dart';
import 'package:flutter/cupertino.dart';
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
  StatRow({
    Key key,
    this.children,
    this.title,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);
  final List<Widget> children;
  final String title;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    // TODO: style so all rows has a common style
    return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
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
            Container(
              margin: EdgeInsets.only(bottom: 13),
              child: Text(this.title,
                  style: Theme.of(context).textTheme.subtitle1),
            ),
            Row(
                mainAxisAlignment: mainAxisAlignment,
                mainAxisSize: mainAxisSize,
                crossAxisAlignment: crossAxisAlignment,
                children: this.children),
          ],
        ));
  }
}

class SourceRow extends StatelessWidget {
  SourceRow({Key key, this.stats}) : super(key: key);
  final _StatResult stats;

  Widget _buildIcon(EmotionSource source, int count) {
    return Stack(
      children: <Widget>[
        Container(
          height: 56,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(right: 26),
          child: getEmotionSourceIcon(source, size: 35),
        ),
        new Positioned(
          //width: 40,
          //height: 40,
          left: 22,
          bottom: 29,
          //top: -2,
          //  bottom: -15
          child: CircleAvatar(
            radius: 13,
            backgroundColor: Colors.white,
            child: CircleAvatar(
                radius: 10,
                backgroundColor: themeForegroundColor,
                child: Text(
                  count.toString(),
                  style: TextStyle(color: Colors.black),
                )),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatRow(
      title: "Emotion Sources (Top 5)",
      children: stats.sourceCount.entries
          .take(5)
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
