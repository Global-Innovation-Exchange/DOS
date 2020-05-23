import 'package:dos/models/emotion_log.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class JournalDateTime extends StatefulWidget {
  JournalDateTime({Key key, this.log}) : super(key: key);
  final EmotionLog log;

  @override
  _JournalDateTimeState createState() => _JournalDateTimeState(log);
}

class _JournalDateTimeState extends State<JournalDateTime> {
  _JournalDateTimeState(EmotionLog log) {
    this._log = log;
    this._dateTimeController =
        TextEditingController(text: formatDateTime(_log.dateTime));
  }

  EmotionLog _log;
  TextEditingController _dateTimeController;

  Future _selectDateTime(BuildContext context) async {
    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: _log.dateTime,
      firstDate: DateTime(_log.dateTime.year - 10),
      lastDate: DateTime.now(),
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
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _dateTimeController,
      readOnly: true,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(Icons.calendar_today),
        prefixText: "Enter Date",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onTap: () {
        _selectDateTime(context);
      },
    );
  }
}
