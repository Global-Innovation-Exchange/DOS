<<<<<<< HEAD
import 'package:flutter/cupertino.dart';
=======
>>>>>>> 610bf56fd6a8d5e6581bf8adf6052f19ea3df0f6
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'additional_log.dart';
import 'database.dart';
import 'utils.dart';

class CreateLog extends StatefulWidget {
  @override
  _CreateLogState createState() => _CreateLogState();
}

class _CreateLogState extends State<CreateLog> {
  final _dateTimeFormatter = DateFormat.yMd().add_jm();
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
      _dateTimeController.text = _dateTimeFormatter.format(_log.dateTime);
    });
  }

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    // Remove any component less than minute
    now = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    _dateTimeController =
        TextEditingController(text: _dateTimeFormatter.format(now));

    _log = EmotionLog();
    _log.scale = 3;
    _log.dateTime = now;
    _log.emotion = Emotion.happy;
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
      child: Image.asset('assets/images/1.png'),
    );

    Widget selectedEmotionScale = new Expanded(
      flex: 1,
      child: new Container(
        child: Slider(
          value: value,
          min: 1.0,
          max: 5.0,
          activeColor: Color(0xFFE1B699),
          inactiveColor: Colors.black12,
          divisions: 4,
          label: value.toInt().toString(),
          onChanged: (_value) {
            setState(() {
              value = _value;
            });
            print(_value);
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
            children: _generateGridItems().map((String value) {
              return _displayGridItem(value);
            }).toList()));

    Widget saveButton = new Expanded(
      flex: 2,
      child: new Container(
        child: ButtonTheme(
          minWidth: double.infinity,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: RaisedButton(
            onPressed: () {},
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

=======
    List<String> values = ["Weak", "2", "3", "4", "Strong"];
>>>>>>> 610bf56fd6a8d5e6581bf8adf6052f19ea3df0f6
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
<<<<<<< HEAD
              await _table.insertEmotionLog(EmotionLog(
                  jorunal: _jorunalController.text,
                  dateTime: _logDateTime,
                  tags: ['test1', 'test2']));
=======
              await _table.insertEmotionLog(_log);
>>>>>>> 610bf56fd6a8d5e6581bf8adf6052f19ea3df0f6
              Navigator.pop(context, true);
            },
          )
        ],
      ),
<<<<<<< HEAD
      backgroundColor: Color(0xffFEEFE6),
      body: new Padding(
        padding: new EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: body,
=======
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _dateTimeController,
              readOnly: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
                prefixText: "Enter Date",
                border: inputBorder,
              ),
              onTap: () {
                _selectDateTime(context);
              },
            ),
            SizedBox(height: 20),
            Container(
              child: Image.asset('assets/images/1.png'),
              height: 180,
              width: 180,
            ),
            Slider(
              value: _log.scale.toDouble(),
              min: 1.0,
              max: 5.0,
              activeColor: colorSwatch,
              inactiveColor: Colors.black12,
              divisions: 4,
              label: _log.scale.toString(),
              onChanged: (v) {
                setState(() {
                  _log.scale = v.toInt();
                });
              },
            ),
            Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      values.length, (index) => Text(values[index].toString())),
                )),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
              height: 90.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.white, // set border color
                          width: 3.0), // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)), // set rounded corner radius
                    ),
                    margin: EdgeInsets.only(right: 20.0),
                    child: Image.asset('assets/images/2.png'),
                  ),
                  Container(
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.white, // set border color
                          width: 3.0), // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)), // set rounded corner radius
                    ),
                    margin: EdgeInsets.only(right: 20.0),
                    child: Image.asset('assets/images/3.png'),
                  ),
                  Container(
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.white, // set border color
                          width: 3.0), // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)), // set rounded corner radius
                    ),
                    margin: EdgeInsets.only(right: 20.0),
                    child: Image.asset('assets/images/4.png'),
                  ),
                  Container(
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.white, // set border color
                          width: 3.0), // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)), // set rounded corner radius
                    ),
                    margin: EdgeInsets.only(right: 20.0),
                    child: Image.asset('assets/images/5.png'),
                  ),
                  Container(
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.white, // set border color
                          width: 3.0), // set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)), // set rounded corner radius
                    ),
                    margin: EdgeInsets.only(right: 20.0),
                    child: Image.asset('assets/images/6.png'),
                  ),
                ],
              ),
            ),
            RaisedButton(
              child: Text('Addition Log'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdditionalLog(log: _log),
                  ),
                );
              },
            ),
          ],
        ),
>>>>>>> 610bf56fd6a8d5e6581bf8adf6052f19ea3df0f6
      ),
    );
  }

  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }
}

Widget _displayGridItem(String value) {
  return new GestureDetector(
      child: new Container(
        padding: new EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: Colors.white, // set border color
              width: 1.0), // set border width
          borderRadius: BorderRadius.all(
              Radius.circular(10.0)), // set rounded corner radius
        ),
        margin: EdgeInsets.only(right: 7.5, left: 9, bottom: 9.0),
        child: new Image(image: AssetImage('assets/images/' + value + ".png")),
      ),
      onTap: () {});
}

List<String> _generateGridItems() {
  List<String> gridItems = new List<String>();
  for (int i = 1; i < 13; i++) {
    gridItems.add(i.toString());
  }
  return gridItems;
}
