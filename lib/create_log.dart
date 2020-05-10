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
    List<String> values = ["Strong", "2", "3", "4", "Weak"];
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
      ),
    );
  }

  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }
}
