import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'database.dart';

class CreateLog extends StatefulWidget {
  @override
  _CreateLogState createState() => _CreateLogState();
}

class _CreateLogState extends State<CreateLog> {
  final _dateTimeFormatter = DateFormat.yMd().add_jm();
  final _table = EmotionTable();
  DateTime _logDateTime;
  TextEditingController _jorunalController;
  TextEditingController _dateTimeController;

  Future _selectDateTime(BuildContext context) async {
    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: _logDateTime,
      firstDate: DateTime(_logDateTime.year - 10),
      lastDate: _logDateTime,
    );
    if (selectedDate == null) return;

    final TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_logDateTime),
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
      _logDateTime = newDateTime;
      _dateTimeController.text = _dateTimeFormatter.format(_logDateTime);
    });
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Remove any component less than minute
    _logDateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    _jorunalController = TextEditingController();
    _dateTimeController =
        TextEditingController(text: _dateTimeFormatter.format(_logDateTime));
  }

  @override
  Widget build(BuildContext context) {
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
              await _table.insertEmotionLog(EmotionLog(
                  jorunal: _jorunalController.text, dateTime: _logDateTime, tags: ['test1', 'test2']));
              Navigator.pop(context, true);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _dateTimeController,
              readOnly: true,
              decoration: InputDecoration(
                icon: Icon(Icons.calendar_today),
                labelText: "Date",
                border: OutlineInputBorder(),
              ),
              onTap: () {
                _selectDateTime(context);
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _jorunalController,
              decoration: InputDecoration(
                labelText: "Journal",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void dispose() {
    _jorunalController.dispose();
    super.dispose();
  }
}
