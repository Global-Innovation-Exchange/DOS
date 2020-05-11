import 'package:flutter/material.dart';

import 'create_log.dart';
import 'database.dart';

class EmtionDetail extends StatelessWidget {
  EmtionDetail({Key key, this.log}) : super(key: key);
  final EmotionTable _table = EmotionTable();
  final EmotionLog log;

  @override
  Widget build(BuildContext context) {
    Widget selectedDate = new Container(
      padding: new EdgeInsets.all(8.0),
      margin: EdgeInsets.only(top: 4),
      child: TextFormField(
        initialValue: '${log.dateTime}',
        readOnly: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today),
          prefixText: "Log Date",
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: new BorderSide(),
          ),
        ),
      ),
    );
    Widget selectedEmotionIcon = new Expanded(
        flex: 2,
        child: new Container(
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/1.png'),
              Slider(
                value: 3,
                min: 1.0,
                max: 5.0,
                activeColor: Color(0xffE1B699),
                inactiveColor: Colors.black12,
                divisions: 4,
                label: value.toInt().toString(),
                onChanged: null,
              ),
            ],
          ),
        ));

    Widget journalText = new Expanded(
        flex: 5,
        child: new Container(
          padding: new EdgeInsets.all(8.0),
          margin: EdgeInsets.only(top: 8),
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 9,
            maxLength: 7000,
            initialValue: '${log.jorunal}',
            readOnly: true,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: new BorderSide(),
              ),
            ),
          ),
        ));
    Widget journalVoice = new Expanded(
      flex: 1,
      child: new Container(
        padding: new EdgeInsets.all(8.0),
        margin: EdgeInsets.only(top: 8),
        child: TextFormField(
          initialValue: 'This is for the audio record',
          readOnly: true,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.play_arrow), border: InputBorder.none),
        ),
      ),
    );
    Widget journalTags = new Expanded(
      flex: 1,
      child: new Container(
        padding: new EdgeInsets.all(8.0),
        margin: EdgeInsets.only(top: 8),
        color: Colors.pink,
        child: TextFormField(
          initialValue: (log.tags ?? []).map((t) => '#$t').join(", "),
          readOnly: true,
          textAlign: TextAlign.left,
          decoration: InputDecoration(border: InputBorder.none),
        ),
      ),
    );

    Widget deleteButton = new Expanded(
      flex: 2,
      child: new Container(
        child: ButtonTheme(
          minWidth: double.infinity,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: RaisedButton(
            onPressed: () async {
              if (log.id != null) {
                await _table.deleteEmotionLog(log.id);
                Navigator.pop(context, true);
              }
            },
            child: Text('DELETE'),
          ),
        ),
      ),
    );
    Widget body = new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(),
        ),
        selectedDate,
        SizedBox(height: 25.0),
        selectedEmotionIcon,
        journalText,
        journalVoice,
        journalTags,
        deleteButton,
      ],
    );
    // This makes each child fill the full width of the screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Details'),
        actions: <Widget>[
          FlatButton(
            //textColor: Colors.white,
            child: Text('EDIT'),
            onPressed: () {},
          )
        ],
      ),
      backgroundColor: Color(0xffFEEFE6),
      body: new Padding(
        padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: body,
      ),
    );
  }
}
