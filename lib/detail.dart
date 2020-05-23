import 'package:dos/audio_journal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'database.dart';
import 'models/emotion.dart';
import 'models/emotion_log.dart';
import 'models/emotion_source.dart';
import 'utils.dart';

class EmotionDetail extends StatelessWidget {
  EmotionDetail({Key key, this.log}) : super(key: key);
  final EmotionTable _table = EmotionTable();
  final EmotionLog log;

  @override
  Widget build(BuildContext context) {
    Widget selectedDate = Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DateTimeChange(log: log),
    );

    Widget selectedEmotion = Container(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: getEmotionImage(log.emotion),
          ),
          Expanded(
            child: ScaleChange(log: log),
          ),
        ],
      ),
    );

    Widget emotionSource = log.source != null
        ? Row(children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text("Because.."),
            ),
            CircleAvatar(
                backgroundColor: Color(0xffE1B699),
                child: getEmotionSourceIcon(
                  log.source,
                  color: Colors.white,
                ))
          ])
        : SizedBox.shrink();

    Widget journalText = Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: JournalChange(log: log),
    );

    Widget journalVoice = Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: AudioJournal(log: log),
    );

    Widget journalTags = Align(
      alignment: Alignment.center,
      child: Wrap(
        spacing: 10.0, // gap between adjacent chips
        runSpacing: 0.0, // gap between lines
        children: log.tags.map((t) => _createChip(t)).toList(),
      ),
    );

    Widget deleteButton = SafeArea(
      bottom: true,
      child: ButtonTheme(
        height: 50,
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
    );

    Widget scrollView = LayoutBuilder(
      builder: (context, viewportConstraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: <Widget>[
                selectedDate,
                SizedBox(height: 15.0),
                selectedEmotion,
                SizedBox(height: 10.0),
                journalTags,
                SizedBox(height: 15.0),
                journalVoice,
                journalText,
                emotionSource,
              ],
            ),
          ),
        ),
      ),
    );

    Widget body = Column(
      children: <Widget>[
        Expanded(child: scrollView),
        deleteButton,
      ],
    );

    // This makes each child fill the full width of the screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal'),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () async {
            Navigator.pop(context, false);
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('SAVE'),
            onPressed: () async {
              await _table.updateEmotionLog(log);
              Navigator.pop(context, true);
            },
          )
        ],
      ),
      backgroundColor: themeColor,
      body: GestureDetector(
        onTap: () {
          // This is used to bring down the soft keyboard when other than
          // text field is tapped.
          FocusScope.of(context).unfocus();
        },
        child: body,
      ),
    );
  }
}

Widget _createChip(String value) {
  return Chip(avatar: CircleAvatar(child: Text('#')), label: Text(value));
}

class ScaleChange extends StatefulWidget {
  ScaleChange({Key key, this.log}) : super(key: key);
  final EmotionLog log;

  @override
  _ScaleChangeState createState() => _ScaleChangeState();
}

class _ScaleChangeState extends State<ScaleChange> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: widget.log.scale.toDouble(),
      min: 1.0,
      max: 5.0,
      activeColor: Color(0xffE1B699),
      inactiveColor: Colors.black12,
      divisions: 4,
      label: widget.log.scale.toString(),
      onChanged: (value) {
        setState(() {
          widget.log.scale = value.toInt();
        });
      },
    );
  }
}

class DateTimeChange extends StatefulWidget {
  DateTimeChange({Key key, this.log}) : super(key: key);
  final EmotionLog log;

  @override
  _DateTimeChangeState createState() => _DateTimeChangeState(log);
}

class _DateTimeChangeState extends State<DateTimeChange> {
  _DateTimeChangeState(EmotionLog log) {
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

class JournalChange extends StatefulWidget {
  JournalChange({Key key, this.log}) : super(key: key);
  final EmotionLog log;

  @override
  _JournalChangeState createState() => _JournalChangeState(log);
}

class _JournalChangeState extends State<JournalChange> {
  _JournalChangeState(EmotionLog log) {
    this._log = log;
    this._jorunalController = TextEditingController(text: _log.journal);
  }

  EmotionLog _log;
  TextEditingController _jorunalController;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _jorunalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _jorunalController,
      onChanged: (value) {
        // Not wrapping in setState because field is manged by controller
        _log.journal = value;
      },
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLength: 7000,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.all(15),
        labelText: 'Your Journal',
        alignLabelWithHint: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
