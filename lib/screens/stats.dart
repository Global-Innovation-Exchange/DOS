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
              DaysLoggedRow(stats: stats),
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
            margin: EdgeInsets.only(bottom: 25),
            child:
                Text(this.title, style: Theme.of(context).textTheme.bodyText1),
          ),
          Row(
              mainAxisAlignment: mainAxisAlignment,
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: crossAxisAlignment,
              children: this.children),
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
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: themeForegroundColor,
                  child: Text(
                    count.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                )),
          ),
          new Positioned(
            left: -4,
            bottom: -6,
            child: getEmotionSourceIcon(source, size: 26),
          ),
        ],
      ),
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

class DaysLoggedRow extends StatelessWidget {
  DaysLoggedRow({Key key, this.stats}) : super(key: key);
  final _StatResult stats;

  @override
  Widget build(BuildContext context) {
    final tuple = stats.daysLogged;
    final daysLogged = tuple[0];
    final daysNotLogged = tuple[1];

    return StatRow(
      title: "Days Logged",
      children: [
        Text('Days Logged: $daysLogged'),
        Text('Days Not Logged: $daysNotLogged'),
      ],
    );
  }
}

class _StatResult {
  _StatResult(
    this.year,
    this.month,
    this.audioIds,
    this.logs,
    this.sourceCount,
    this.tagCount,
  );

  int year;
  int month;
  Set<int> audioIds;
  List<EmotionLog> logs;
  LinkedHashMap<EmotionSource, int> sourceCount;
  LinkedHashMap<String, int> tagCount;

  get daysLogged {
    Set<int> dayLogged = Set<int>();
    logs.forEach((element) {
      dayLogged.add(element.dateTime.day);
    });

    var daysLogged = 0;
    var daysNotLogged = 0;
    var time = DateTime(year, month);
    while (time.month == month) {
      if (dayLogged.contains(time.day)) {
        daysLogged++;
      } else {
        daysNotLogged++;
      }
      time = time.add(Duration(days: 1));
    }
    return [daysLogged, daysNotLogged];
  }

  static Future<_StatResult> load(EmotionTable db, int year, int month) async {
    final audioIdsFuture = getAudioIds();
    final logsFuture = db.getMonthlyLogs(year, month, withTags: true);
    final sourceCountFuture = db.getMonthlySourceCount(year, month);
    final tagCountFuture = db.getMonthlyTagCount(year, month);
    // concurrently wait all
    await Future.wait([
      audioIdsFuture,
      logsFuture,
      sourceCountFuture,
      tagCountFuture,
    ]);
    final audioIds = await audioIdsFuture;
    final logs = await logsFuture;
    final sourceCount = await sourceCountFuture;
    final tagCount = await tagCountFuture;
    return _StatResult(year, month, audioIds, logs, sourceCount, tagCount);
  }
}
