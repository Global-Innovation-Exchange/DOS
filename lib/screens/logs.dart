import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../database.dart';
import '../models/emotion.dart';
import '../models/emotion_log.dart';
import '../models/emotion_source.dart';
import '../utils.dart';
import 'create_log.dart';
import 'detail.dart';
import 'stats.dart';

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
  Future<List<EmotionLog>> _logsFuture;
  Set<int> _audioIds = Set<int>();
  var list;

  Future<List<EmotionLog>> getLogs() async {
    // TODO: (pref) Don't get all the logs and with all tags here
    _audioIds = await getAudioIds();
    list = await _emotionTable.getAllLogs(withTags: true);
    return list;
  }

  Widget _buildSourceIcon(EmotionSource source) {
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

  Widget _buildIcon(IconData data, bool visible) {
    return Opacity(
      opacity: visible ? 1 : 0,
      child: Icon(
        data,
        color: themeForegroundColor,
      ),
    );
  }

  Widget _buildGrid(EmotionLog log) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildIcon(
              MdiIcons.tag,
              log.tags != null && log.tags.length > 0,
            ),
            SizedBox(width: 8),
            _buildSourceIcon(log.source),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildIcon(Icons.mic, _audioIds.contains(log.id)),
            SizedBox(width: 8),
            _buildIcon(
              MdiIcons.textBox,
              log.journal != null && log.journal.length > 0,
            ),
          ],
        ),
      ],
    );
  }

  ListView _buildList(List<EmotionLog> logs) {
    return ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, position) => Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              margin: EdgeInsets.only(top: 14, bottom: 4, right: 15, left: 15),
              child: InkWell(
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
                        child: getEmotionImage(logs[position].emotion),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              DateFormat('kk:mm a ')
                                      .format(logs[position].dateTime) +
                                  DateFormat.yMMMd()
                                      .format(logs[position].dateTime),
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black45,
                              ),
                            ),
                            SliderTheme(
                              data: SliderThemeData(
                                disabledInactiveTrackColor:
                                    themeForegroundColor,
                                disabledActiveTrackColor: themeForegroundColor,
                                disabledThumbColor: themeForegroundColor,
                              ),
                              child: Slider(
                                  value: logs[position].scale.toDouble(),
                                  min: 1.0,
                                  max: 5.0,
                                  divisions: 4,
                                  label: logs[position].scale.toString(),
                                  onChanged: null),
                            ),
                          ],
                        ),
                      ),
                      _buildGrid(logs[position]),
                    ],
                  ),
                ),
                onTap: () async {
                  EmotionLog log = logs[position];
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
                      _logsFuture = getLogs();
                    });
                  }
                },
              ),
            ));
  }

  @override
  void initState() {
    super.initState();

    _logsFuture = getLogs();
  }

  @override
  Widget build(BuildContext context) {
    Widget logPreview = FutureBuilder<List<EmotionLog>>(
      future: _logsFuture,
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
    Widget floatingButton = Container(
      alignment: Alignment(1.0, 1.0),
      padding: EdgeInsets.all(12),
      child: FloatingActionButton(
        onPressed: () async {
          bool updated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateLog()),
          );

          if (updated != null) {
            setState(() {
              _logsFuture = getLogs();
            });
          }
        },
        tooltip: 'Create Log',
        child: Icon(Icons.add),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        // TODO: Change to bottom nav bar
        actions: <Widget>[
          FlatButton(
            child: Text("Stats"),
            onPressed: () {
              return Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatScreen(),
                ),
              );
            },
          )
        ],
      ),
      backgroundColor: themeColor,
      body: logPreview,
      floatingActionButton: floatingButton,
    );
  }
}
