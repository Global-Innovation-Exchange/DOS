import 'package:flutter/cupertino.dart';
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
      height: 60,
      padding: EdgeInsets.all(8.0),

      // margin: EdgeInsets.only(top: 4),
      child: TextFormField(
          initialValue: formatDateTime(log.dateTime),
          readOnly: true,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Icon(Icons.calendar_today),
            prefixText: "Log Date",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          )),
    );

    Widget selectedEmotion = Expanded(
        flex: 9,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getEmotionImage(log.emotion),
              Slider(
                value: log.scale.toDouble(),
                min: 1.0,
                max: 5.0,
                activeColor: Color(0xffE1B699),
                inactiveColor: Colors.black12,
                divisions: 4,
                label: log.scale.toString(),
                onChanged: null,
              ),
            ],
          ),
        ));

    Widget journalText = Expanded(
        flex: 20,
        child: Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.only(top: 8),
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 9,
            maxLength: 7000,
            initialValue: '${log.journal ?? ''}',
            readOnly: true,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.all(15),
              labelText: 'your Journal',
              alignLabelWithHint: false,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ));
    Widget journalVoice = Expanded(
      flex: 5,
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
        flex: 9,
        child: GridView.count(
            scrollDirection: Axis.horizontal,
            childAspectRatio: 0.4,
            crossAxisCount: 2,
            crossAxisSpacing: 1.0,
            children: _generateGridItems().map((String value) {
              return _displayGridItem(value);
            }).toList()));

    Widget deleteButton = Expanded(
      flex: 5,
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
        selectedEmotion,
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

List<String> _generateGridItems() {
  List<String> gridItems = List<String>();
  for (int i = 1; i < 40; i++) {
    gridItems.add("#" + i.toString() + "tesTEST");
  }
  return gridItems;
}

Widget _displayGridItem(String value) {
  return Container(
    margin: EdgeInsets.only(left: 9, bottom: 9.0),
    padding: EdgeInsets.all(1),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.black12,
      border: Border.all(
          color: Colors.black12, // set border color
          width: 1.0), // set border width
      borderRadius:
          BorderRadius.all(Radius.circular(20.0)), // set rounded corner radius
    ),
    child: Text(value),
  );
}
