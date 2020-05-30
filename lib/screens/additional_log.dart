import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/audio_journal.dart';
import '../components/emotion_slider.dart';
import '../components/journal_datetime.dart';
import '../components/journal_tags.dart';
import '../components/journal_textfield.dart';
import '../models/emotion.dart';
import '../models/emotion_log.dart';
import '../models/emotion_source.dart';
import '../utils.dart';

class AdditionalLog extends StatefulWidget {
  AdditionalLog({Key key, this.log}) : super(key: key);

  final EmotionLog log;

  @override
  _AdditionalLogState createState() => _AdditionalLogState(log);
}

class _AdditionalLogState extends State<AdditionalLog> {
  _AdditionalLogState(EmotionLog log) {
    this._log = log;
  }

  EmotionLog _log;

  Widget build(BuildContext context) {
    Widget selectedDate = Container(
      height: 75,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: JournalDateTime(log: _log),
    );

    Widget selectedEmotion = Container(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: getEmotionImage(_log.emotion),
          ),
          Expanded(
            child: EmotionSlider(log: _log),
          ),
        ],
      ),
    );
    Widget _buildSource() {
      var children = EmotionSource.values.map((src) {
        var isSelected = _log.source == src;
        var color = isSelected ? Colors.white : Colors.black38;

        return CircleAvatar(
          radius: 30,
          backgroundColor: isSelected ? Color(0xffE1B699) : Colors.white,
          child: IconButton(
            icon: getEmotionSourceIcon(src, color: color),
            onPressed: () {
              setState(() {
                if (_log.source == src) {
                  _log.source = null;
                } else {
                  _log.source = src;
                }
              });
            },
          ),
        );
      }).toList();
      return Row(
        children: children,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      );
    }

    Widget emotionSource = Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("I feel this way because..."),
          SizedBox(height: 15.0),
          _buildSource(),
        ],
      ),
    );

    Widget journalText = Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: JorunalTextField(log: _log),
    );

    Widget journalVoice = Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: AudioJournal(log: _log),
    );

    Widget journalTags = Container(
      alignment: Alignment.center,
      width: 370,
      child: JournalTags(log: _log),
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
                SizedBox(
                  height: 20.0,
                  width: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          width: 1.0,
                          color: Color(0xFFE1B699),
                        ),
                      ),
                    ),
                  ),
                ),
                emotionSource,
                SizedBox(height: 23.0),
                journalVoice,
                journalText,
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Journal'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          FlatButton(
            child: Text('DONE',
                style: Theme.of(context).primaryTextTheme.subtitle1.apply(
                      fontSizeFactor: 1.2,
                    )),
            onPressed: () {
              Navigator.pop(context);
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
        child: scrollView,
      ),
    );
  }

  restReasons() {}
}
