import 'package:flutter/material.dart';

import 'create_log.dart';
import 'database.dart';
import 'detail.dart';

//theme color to be used cross the app

Map<int, Color> color = {
  50: Color.fromRGBO(255, 182, 153, .1),
  100: Color.fromRGBO(255, 182, 153, .2),
  200: Color.fromRGBO(255, 182, 153, .3),
  300: Color.fromRGBO(255, 182, 153, .4),
  400: Color.fromRGBO(255, 182, 153, .5),
  500: Color.fromRGBO(255, 182, 153, .6),
  600: Color.fromRGBO(255, 182, 153, .7),
  700: Color.fromRGBO(255, 182, 153, .8),
  800: Color.fromRGBO(255, 182, 153, .9),
  900: Color.fromRGBO(255, 182, 153, 1),
};
MaterialColor colorCustom = MaterialColor(0xFFE1B699, color);

//calling main function when app started
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of the application.

        //theme color for the bar
        primarySwatch: colorCustom,
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
        child: ListTile(
          title: Text(logs[position].dateTime.toString()),
          onTap: () async {
            bool updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmtionDetail(
                  log: logs[position],
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _logsFuture = getLogs();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List<EmotionLog>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(child: _buildList(snapshot.data));
                } else if (snapshot.hasError) {
                  return Text('Error');
                } else {
                  // Loading...
                  return Text('Loading');
                }
              },
            )
          ],
        ),
      ),

      // ActionButton "plus" code
      floatingActionButton: FloatingActionButton(
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
  }
}
