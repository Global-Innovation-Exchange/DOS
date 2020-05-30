import 'dart:collection';

import 'package:dos/components/emotion_chart.dart';
import 'package:dos/database.dart';
import 'package:dos/models/emotion.dart';
import 'package:dos/models/emotion_source.dart';
import 'package:dos/screens/credits.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../database.dart';
import '../models/emotion_log.dart';
import '../utils.dart';

class StatScreen extends StatefulWidget {
  StatScreen({Key key}) : super(key: key);
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
              TrendingTagsRow(stats: stats),
              SourceRow(stats: stats),
              JournalCountRow(stats: stats),
              EmotionChartsRow(stats: stats),
              FlatButton(
                child: Text('Credits'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreditScreen()),
                  );
                },
              ),
              SizedBox(
                height: kBottomNavigationBarHeight,
              ),
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
class StatRowContainer extends StatelessWidget {
  StatRowContainer({
    Key key,
    this.child,
    this.title,
  }) : super(key: key);
  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    // TODO: style so all rows has a common style
    return Container(
      margin: EdgeInsets.only(top: 25, right: 20, left: 20),
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
            child: Text(this.title,
                style: Theme.of(context).primaryTextTheme.subtitle1.apply(
                      fontSizeFactor: 1.4,
                    )),
          ),
          Container(
            width: double.infinity,
            child: child,
          ),
        ],
      ),
    );
  }
}

class SourceRow extends StatelessWidget {
  SourceRow({Key key, this.stats}) : super(key: key);
  final _StatResult stats;

  Widget _buildIcon(EmotionSource source, int count, BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        height: 56,
        padding: EdgeInsets.only(right: 26),
        child: getEmotionSourceIcon(source, size: 35, color: Colors.black54),
      ),
      new Positioned(
        left: 22,
        bottom: 29,
        child: CircleAvatar(
            radius: 13.5,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 10.5,
              backgroundColor: themeForegroundColor,
              child: Text(count.toString(),
                  style: Theme.of(context).textTheme.subtitle1),
            )),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StatRowContainer(
        title: "Emotion Sources (Top 5)",
        child: Wrap(
          spacing: 1,
          children: stats.sourceCount.entries
              .take(5)
              .map((entry) => _buildIcon(entry.key, entry.value, context))
              .toList(),
        ));
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

    return StatRowContainer(
      title: 'Total Days',
      child: Container(
        alignment: Alignment.center,
        child: Wrap(
          spacing: 35,
          children: [
            Column(
              children: <Widget>[
                Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.green,
                ),
                Text('$daysLogged days logged',
                    style: Theme.of(context).textTheme.subtitle1),
              ],
            ),
            Column(
              children: <Widget>[
                Icon(
                  Icons.close,
                  size: 50,
                  color: Colors.red,
                ),
                Text('$daysNotLogged days not logged',
                    style: Theme.of(context).textTheme.subtitle1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TrendingTagsRow extends StatelessWidget {
  TrendingTagsRow({Key key, this.stats}) : super(key: key);
  final _StatResult stats;

  @override
  Widget build(BuildContext context) {
    return StatRowContainer(
        title: "Trending Tags (Top 5)",
        child: Container(
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: 15,
            children: stats.tagCount.entries
                .take(5)
                .map(
                  (t) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: <Widget>[
                          InputChip(
                            key: ObjectKey(t.key),
                            label: Text(
                              t.key,
                            ),
                            disabledColor: themeColor,
                            avatar: CircleAvatar(
                              backgroundColor: themeForegroundColor,
                              child: Text(
                                '#',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          Text(
                            t.value == 1
                                ? "${t.value} time"
                                : "${t.value} times",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ));
  }
}

class JournalCountRow extends StatelessWidget {
  JournalCountRow({Key key, this.stats}) : super(key: key);
  final _StatResult stats;

  Widget _buildIcon(IconData iconData, int count, BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 56,
          padding: EdgeInsets.only(right: 26),
          child: Icon(
            iconData,
            size: 35,
            color: Colors.black54,
          ),
        ),
        new Positioned(
          left: 22,
          bottom: 29,
          child: CircleAvatar(
            radius: 13.5,
            backgroundColor: Colors.white,
            child: CircleAvatar(
                radius: 10.5,
                backgroundColor: themeForegroundColor,
                child: Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.subtitle1,
                )),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final numOfLog = stats.jounralCount;
    final int numOfLogWithSource = numOfLog[0];
    final int numOfLogWithTags = numOfLog[1];
    final int numOfLogWithAudio = numOfLog[2];
    final int numOfLogWithJournal = numOfLog[3];
    return StatRowContainer(
      title: "Journal Counts",
      child: Wrap(
        spacing: 1,
        children: [
          _buildIcon(MdiIcons.tag, numOfLogWithTags, context),
          _buildIcon(
              MdiIcons.headDotsHorizontalOutline, numOfLogWithSource, context),
          _buildIcon(Icons.mic, numOfLogWithAudio, context),
          _buildIcon(MdiIcons.textBox, numOfLogWithJournal, context),
        ],
      ),
    );
  }
}

class EmotionChartRow extends StatelessWidget {
  EmotionChartRow(
      {Key key,
      this.emotion,
      this.logs,
      this.year,
      this.month,
      this.height = 100})
      : super(key: key);
  final Emotion emotion;
  final List<EmotionLog> logs;
  final int year;
  final int month;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: double.infinity,
      child: Row(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(width: 50, height: 50, child: getEmotionImage(emotion)),
            Text('x${logs.length}'),
          ],
        ),
        Expanded(
          child: EmotionChart.fromLogs(
            logs,
            year,
            month,
            animate: true,
          ),
        ),
      ]),
    );
  }
}

class EmotionChartsRow extends StatelessWidget {
  EmotionChartsRow({Key key, this.stats}) : super(key: key);
  final _StatResult stats;

  @override
  Widget build(BuildContext context) {
    return StatRowContainer(
      title: "Charts",
      child: Column(
        children: stats
            .getEmotionMap()
            .entries
            .take(5)
            .map(
              (e) => EmotionChartRow(
                emotion: e.key,
                logs: e.value,
                year: stats.year,
                month: stats.month,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatResult {
  _StatResult(
    this.year,
    this.month,
    this.audioIds,
    this.logs,
    this.firstLog,
    this.sourceCount,
    this.tagCount,
  );

  int year;
  int month;
  Set<int> audioIds;
  List<EmotionLog> logs;
  EmotionLog firstLog;
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
    final now = DateTime.now();
    // If first log is null, which means there is no log records at all
    if (firstLog != null) {
      // Round the first log to day
      final firstLogDay = DateTime(
        firstLog.dateTime.year,
        firstLog.dateTime.month,
        firstLog.dateTime.day,
      );
      while (time.month == month && time.isBefore(now)) {
        // Only count from the very the first log day
        if (time.isAfter(firstLogDay) || time.isAtSameMomentAs(firstLogDay)) {
          if (dayLogged.contains(time.day)) {
            daysLogged++;
          } else {
            daysNotLogged++;
          }
        }
        time = time.add(Duration(days: 1));
      }
    }
    return [daysLogged, daysNotLogged];
  }

  get jounralCount {
    int numOfLogWithSource = 0;
    int numOfLogWithTags = 0;
    int numOfLogWithAudio = 0;
    int numOfLogWithJournal = 0;
    logs.forEach((log) {
      numOfLogWithSource += (log.source != null) ? 1 : 0;
      numOfLogWithTags += (log.tags != null && log.tags.length > 0) ? 1 : 0;
      numOfLogWithAudio += (audioIds.contains(log.id)) ? 1 : 0;
      numOfLogWithJournal +=
          (log.journal != null && log.journal.length > 0) ? 1 : 0;
    });
    return [
      numOfLogWithSource,
      numOfLogWithTags,
      numOfLogWithAudio,
      numOfLogWithJournal,
    ];
  }

  LinkedHashMap<Emotion, List<EmotionLog>> getEmotionMap(
      {sorted = true, desc = true}) {
    LinkedHashMap<Emotion, List<EmotionLog>> map =
        Map<Emotion, List<EmotionLog>>();
    this.logs.forEach((l) {
      if (l.emotion != null && l.scale != null) {
        if (!map.containsKey(l.emotion)) {
          map[l.emotion] = List<EmotionLog>();
        }
        map[l.emotion].add(l);
      }
    });

    if (sorted) {
      // Sorted most logged
      int descInt = desc ? -1 : 1;
      final sortedList = map.entries.toList()
        ..sort((a, b) => a.value.length.compareTo(b.value.length) * descInt);
      map = LinkedHashMap.fromEntries(sortedList);
    }
    return map;
  }

  static Future<_StatResult> load(EmotionTable db, int year, int month) async {
    final audioIdsFuture = getAudioIds();
    final logsFuture = db.getMonthlyLogs(year, month, withTags: true);
    final firstLogFuture = db.getFirstLog();
    final sourceCountFuture = db.getMonthlySourceCount(year, month);
    final tagCountFuture = db.getMonthlyTagCount(year, month);
    // concurrently wait all
    await Future.wait([
      audioIdsFuture,
      logsFuture,
      firstLogFuture,
      sourceCountFuture,
      tagCountFuture,
    ]);
    final audioIds = await audioIdsFuture;
    final logs = await logsFuture;
    final firstLog = await firstLogFuture;
    final sourceCount = await sourceCountFuture;
    final tagCount = await tagCountFuture;
    return _StatResult(
        year, month, audioIds, logs, firstLog, sourceCount, tagCount);
  }
}
