import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'create_log.dart';
import 'database.dart';
import 'detail.dart';
import 'models/emotion.dart';
import 'models/emotion_log.dart';
import 'models/emotion_source.dart';
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
      home: MyHomePage(title: 'Emotion logs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final EmotionTable _emotionTable = EmotionTable();
  Future<List<EmotionLog>> _logsFuture;

  Future<List<EmotionLog>> getLogs() async {
    // TODO: (pref) Don't get all the logs and with all tags here
    return _emotionTable.getLogs(withTags: true);
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
                  child: Stack(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            child: getEmotionImage(logs[position].emotion),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 18),
                                child: Text(
                                  formatDateTime(logs[position].dateTime),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                              Container(
                                child: Slider(
                                    value: logs[position].scale.toDouble(),
                                    min: 1.0,
                                    max: 5.0,
                                    activeColor: Color(0xffE1B699),
                                    inactiveColor: Colors.black12,
                                    divisions: 4,
                                    label: logs[position].scale.toString(),
                                    onChanged: null),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 18),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      logs[position].source != null
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                  Text("Because  "),
                                                  CircleAvatar(
                                                      radius: 13,
                                                      backgroundColor:
                                                          Color(0xffE1B699),
                                                      child:
                                                          getEmotionSourceIcon(
                                                        logs[position].source,
                                                        color: Colors.white,
                                                      ))
                                                ])
                                          : SizedBox.shrink(),
                                    ]),
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              logs[position].journal == null
                                  ? SizedBox.shrink()
                                  : Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(children: <Widget>[
                                        Icon(
                                          Icons.spellcheck,
                                          color: Color(0xffE1B699),
                                        ),
                                        Text(' x ' +
                                            logs[position]
                                                .journal
                                                .length
                                                .toString()),
                                      ])),
                              logs[position].tags.length == 0
                                  ? SizedBox.shrink()
                                  : Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.style,
                                            color: Color(0xffE1B699),
                                          ),
                                          Text(' x ' +
                                              logs[position]
                                                  .tags
                                                  .length
                                                  .toString())
                                        ],
                                      ))
                            ],
                          ),
                        ],
                      ),
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
      ),
      backgroundColor: themeColor,
      body: logPreview,
      floatingActionButton: floatingButton,
    );
  }
}
