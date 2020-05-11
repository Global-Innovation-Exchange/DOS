import 'package:flutter/material.dart';

import 'database.dart';
import 'utils.dart';

class EmtionDetail extends StatelessWidget {
  EmtionDetail({Key key, this.log}) : super(key: key);
  final EmotionTable _table = EmotionTable();
  final EmotionLog log;

  @override
  Widget build(BuildContext context) {
    Widget selectedDate = Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(top: 4),
      child: TextFormField(
        initialValue: formatDateTime(log.dateTime),
        readOnly: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today),
          prefixText: "Log Date",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(),
          ),
        ),
      ),
    );
    Widget selectedEmotionIcon = Expanded(
        flex: 2,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getEmotionImage(log.emotion),
              Slider(
                value: 3,
                min: 1.0,
                max: 5.0,
                activeColor: Color(0xffE1B699),
                inactiveColor: Colors.black12,
                divisions: 4,
                label: 3.toInt().toString(),
                onChanged: null,
              ),
            ],
          ),
        ));

    Widget journalText = Expanded(
        flex: 5,
        child: Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.only(top: 8),
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 9,
            maxLength: 7000,
            initialValue: '${log.jorunal ?? ''}',
            readOnly: true,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              labelText: 'Jorunal',
              alignLabelWithHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(),
              ),
            ),
          ),
        ));
    Widget journalVoice = Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(8.0),
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
    Widget journalTags = Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(8.0),
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

    Widget deleteButton = Expanded(
      flex: 2,
      child: Container(
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
    Widget body = Column(
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
      backgroundColor: themeColor,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: body,
      ),
    );
  }
}
