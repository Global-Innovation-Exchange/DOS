import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'additional_log.dart';
import 'database.dart';
import 'utils.dart';

class CreateLog extends StatefulWidget {
  @override
  _CreateLogState createState() => _CreateLogState();
}

class _CreateLogState extends State<CreateLog> {
  final _table = EmotionTable();
  EmotionLog _log;
  TextEditingController _dateTimeController;

  Future _selectDateTime(BuildContext context) async {
    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: _log.dateTime,
      firstDate: DateTime(_log.dateTime.year - 10),
      lastDate: _log.dateTime,
    );
    if (selectedDate == null) return;

    final TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_log.dateTime),
    );
    if (selectedTime == null) return;

    final newDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    setState(() {
      _log.dateTime = newDateTime;
      _dateTimeController.text = formatDateTime(newDateTime);
    });
  }

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    // Remove any component less than minute
    now = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    _dateTimeController =
        TextEditingController(text: formatDateTime(now));

    _log = EmotionLog();
    _log.scale = 3;
    _log.dateTime = now;
    _log.emotion = Emotion.joy;
  }

  @override
  Widget build(BuildContext context) {
    List<String> values = ["Strong", "2", "3", "4", "Weak"];
    //datetime picker widget
    Widget selectDate = new Container(
      padding: new EdgeInsets.all(8.0),
      color: new Color(0X3311111),
      child: TextFormField(
        controller: _dateTimeController,
        readOnly: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today),
          prefixText: "Enter Date",
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: new BorderSide(),
          ),
        ),
        onTap: () {
          _selectDateTime(context);
        },
      ),
    );
    Widget selectedEmotionIcon = new Expanded(
      flex: 7,
      child: getEmotionImage(_log.emotion),
    );

    Widget selectedEmotionScale = new Expanded(
      flex: 1,
      child: new Container(
        child: Slider(
          value: _log.scale.toDouble(),
          min: 1.0,
          max: 5.0,
          activeColor: Color(0xffE1B699),
          inactiveColor: Colors.black12,
          divisions: 4,
          label: _log.scale.toString(),
          onChanged: (v) {
            setState(() {
              _log.scale = v.toInt();
            });
          },
        ),
      ),
    );
    Widget scaleNumbers = new Expanded(
      flex: 1,
      child: new Container(
        child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  values.length, (index) => Text(values[index].toString())),
            )),
      ),
    );

    Widget iconsList = new Expanded(
      flex: 7,
      child: new GridView.count(
        scrollDirection: Axis.horizontal,
        childAspectRatio: 0.77,
        crossAxisCount: 2,
        crossAxisSpacing: 1.0,
        children: Emotion.values
            .sublist(1)
            .map(
              (e) => _displayGridItem(
                emotion: e,
                onTap: () {
                  setState(() {
                    _log.emotion = e;
                  });
                },
              ),
            )
            .toList(),
      ),
    );

    Widget saveButton = new Expanded(
      flex: 2,
      child: new Container(
        child: ButtonTheme(
          minWidth: double.infinity,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdditionalLog(log: _log),
                ),
              );
            },
            child: Text('Write in Journal'),
          ),
        ),
      ),
    );

    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        selectDate,
        selectedEmotionIcon,
        selectedEmotionScale,
        scaleNumbers,
        SizedBox(height: 25.0),
        iconsList,
        saveButton,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Log'),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text('SAVE'),
            onPressed: () async {
              await _table.insertEmotionLog(_log);
              Navigator.pop(context, true);
            },
          )
        ],
      ),
      backgroundColor: themeColor,
      body: new Padding(
        padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: body,
      ),
    );
  }

  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }
}

Widget _displayGridItem({Emotion emotion, GestureTapCallback onTap}) {
  return new InkWell(
    child: new Container(
      padding: new EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
            Radius.circular(10.0)), // set rounded corner radius
      ),
      margin: EdgeInsets.only(right: 7.5, left: 9, bottom: 9.0),
      child: getEmotionImage(emotion),
    ),
    onTap: onTap,
  );
}
