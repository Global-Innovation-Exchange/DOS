import 'package:flutter/material.dart';

import 'database.dart';

class EmtionDetail extends StatelessWidget {
  EmtionDetail({Key key, this.log}) : super(key: key);
  final EmotionTable _table = EmotionTable();
  final EmotionLog log;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail')),
      body: Column(
        children: <Widget>[
          Text('${log.dateTime}'),
          Text('Tags: ' + (log.tags ?? []).map((t) => '#$t').join(", ")),
          Text('Jorunal: ${log.jorunal}'),
          RaisedButton(
            child: Row(
              children: [
                Icon(Icons.delete),
                Text('Delete'),
              ],
            ),
            onPressed: () async {
              if (log.id != null) {
                await _table.deleteEmotionLog(log.id);
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
    );
  }
}
