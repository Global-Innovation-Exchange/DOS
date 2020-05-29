import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../database.dart';
import '../models/emotion.dart';
import '../models/emotion_log.dart';
import '../models/emotion_source.dart';
import '../utils.dart';
import 'detail.dart';

class LogsScreen extends StatefulWidget {
  LogsScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final EmotionTable _emotionTable = EmotionTable();
  Future<_LogResult> _logResultFuture;

  Future<_LogResult> getResult() {
    return _LogResult.load(_emotionTable);
  }

  Widget _buildDayList(List<EmotionLog> logs, DateTime day) {}

  Widget _buildList(_LogResult result) {
    // Group by calendar day
    final map = LinkedHashMap<DateTime, List<EmotionLog>>();
    result.logs.forEach((log) {
      final key =
          DateTime(log.dateTime.year, log.dateTime.month, log.dateTime.day);
      if (!map.containsKey(key)) {
        map[key] = List<EmotionLog>();
      }

      map[key].add(log);
    });

    return ListView.builder(
        itemCount: result.logs.length,
        itemBuilder: (context, position) {
          bool last = result.logs.length == (position + 1);
          double btm;
          last ? btm = kFloatingActionButtonMargin + 30 : btm = 4;
          return Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              margin:
                  EdgeInsets.only(top: 15, bottom: btm, right: 15, left: 15),
              child: LogRow(
                log: result.logs[position],
                hasAudio: result.audioIds.contains(result.logs[position].id),
                onTap: () async {
                  EmotionLog log = result.logs[position];
                  await log.initTempPath();
                  bool updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmotionDetail(
                        log: log,
                      ),
                    ),
                  );

                  if (updated != null) {
                    setState(() {
                      // Force update
                      _logResultFuture = getResult();
                    });
                  }
                },
              ));
        });
  }

  @override
  void initState() {
    super.initState();

    _logResultFuture = getResult();
  }

  @override
  Widget build(BuildContext context) {
    Widget logPreview = FutureBuilder<_LogResult>(
      future: _logResultFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildList(snapshot.data);
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      backgroundColor: themeColor,
      body: Container(
        child: logPreview,
      ),
    );
  }
}

class LogRow extends StatelessWidget {
  final EmotionLog log;
  final bool hasAudio;
  final GestureTapCallback onTap;

  const LogRow({
    Key key,
    @required this.log,
    @required this.hasAudio,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 100,
        width: 100,
        alignment: Alignment(1.0, 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(10.0)), // set rounded corner radius
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Emotion icon
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: getEmotionImage(log.emotion),
            ),
            Padding(
              padding: EdgeInsets.only(top: 7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    DateFormat('kk:mm a ').format(log.dateTime) +
                        DateFormat.yMMMd().format(log.dateTime),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black45,
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                        disabledActiveTrackColor: themeForegroundColor,
                        disabledThumbColor: themeForegroundColor,
                        disabledInactiveTickMarkColor: themeForegroundColor),
                    child: Slider(
                        value: log.scale.toDouble(),
                        min: 1.0,
                        max: 5.0,
                        divisions: 4,
                        label: log.scale.toString(),
                        onChanged: null),
                  ),
                ],
              ),
            ),
            LogIconGrid(
              log: log,
              hasAudio: hasAudio,
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}

class LogSourceIcon extends StatelessWidget {
  final EmotionSource source;
  const LogSourceIcon({Key key, this.source}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: source != null ? 1.0 : 0,
      child: CircleAvatar(
        radius: 13,
        backgroundColor: themeForegroundColor,
        child: getEmotionSourceIcon(
          // Use source as a place holder since it's going to be hidden by opacity
          source ?? EmotionSource.home,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class LogIcon extends StatelessWidget {
  final IconData data;
  final bool visible;
  LogIcon({
    Key key,
    @required this.data,
    @required this.visible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: visible ? 1 : 0,
      child: Icon(
        data,
        color: themeForegroundColor,
      ),
    );
  }
}

class LogIconGrid extends StatelessWidget {
  final EmotionLog log;
  final bool hasAudio;

  const LogIconGrid({Key key, this.log, this.hasAudio}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LogIcon(
              data: MdiIcons.tag,
              visible: log.tags != null && log.tags.length > 0,
            ),
            SizedBox(width: 8),
            LogSourceIcon(source: log.source),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            LogIcon(data: Icons.mic, visible: hasAudio),
            SizedBox(width: 8),
            LogIcon(
              data: MdiIcons.textBox,
              visible: log.journal != null && log.journal.length > 0,
            ),
          ],
        ),
      ],
    );
  }
}

class _LogResult {
  final List<EmotionLog> logs;
  final Set<int> audioIds;

  _LogResult({this.logs, this.audioIds});
  static Future<_LogResult> load(EmotionTable db) async {
    // TODO: (pref) Don't get all the logs and with all tags here
    final logsFuture = db.getAllLogs(withTags: true);
    final audioIdsFuture = getAudioIds();
    // concurrently wait all
    await Future.wait([
      logsFuture,
      audioIdsFuture,
    ]);
    final logs = await logsFuture;
    final audioIds = await audioIdsFuture;
    return _LogResult(logs: logs, audioIds: audioIds);
  }
}
