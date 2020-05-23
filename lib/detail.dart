import 'package:dos/audio_journal.dart';
import 'package:dos/components/emotion_slider.dart';
import 'package:dos/components/journal_datetime.dart';
import 'package:dos/components/journal_textfield.dart';
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
      child: JournalDateTime(log: log),
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
            child: EmotionSlider(log: log),
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
      child: JorunalTextField(log: log),
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
