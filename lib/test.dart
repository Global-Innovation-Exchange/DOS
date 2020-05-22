import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound_player.dart';

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

    Widget selectedEmotion = Container(
      height: 100,
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
    );

    Widget emotionSource = log.source != null
        ? Row(children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Because.."),
                )),
            CircleAvatar(
                backgroundColor: Color(0xffE1B699),
                child: getEmotionSourceIcon(
                  log.source,
                  color: Colors.white,
                ))
          ])
        : SizedBox.shrink();

    Widget journalText = Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(top: 0),
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        maxLength: 7000,
        initialValue: '${log.journal ?? ''}',
        //readOnly: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.all(15),
          labelText: 'your Journal',
          alignLabelWithHint: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );

    Widget journalVoice = Align(
      alignment: Alignment.bottomLeft,
      child: AudioButton(log: log),
    );

    Widget journalTags = Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Wrap(
          spacing: 10.0, // gap between adjacent chips
          runSpacing: 0.0, // gap between lines
          children: log.tags.map((t) => _createChip(t)).toList(),
        ),
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
      ),
      backgroundColor: themeColor,
      body: body,
    );
  }
}

Widget _createChip(String value) {
  return Chip(avatar: CircleAvatar(child: Text('#')), label: Text(value));
}

class AudioButton extends StatefulWidget {
  AudioButton({Key key, this.log}) : super(key: key);
  final EmotionLog log;

  @override
  _AudioButtonState createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  String _audioPath;
  bool _isPlaying = false;
  FlutterSoundPlayer _player = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();

    _initAudioPath();
  }

  void _initAudioPath() async {
    File f = await getLogAudioFile(widget.log.id);
    if (await f.exists()) {
      setState(() {
        _audioPath = f.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _audioPath == null
        ? SizedBox.shrink()
        : Row(
            children: <Widget>[
              IconButton(
                icon: Icon(!_isPlaying ? Icons.play_arrow : Icons.stop),
                onPressed: () async {
                  if (!_isPlaying) {
                    _player.startPlayer(_audioPath, whenFinished: () {
                      setState(() {
                        _isPlaying = false;
                      });
                    });
                    setState(() {
                      _isPlaying = true;
                    });
                  } else {
                    _player.stopPlayer();
                    setState(() {
                      _isPlaying = false;
                    });
                  }
                },
              ),
              Text('Audio journal')
            ],
          );
  }

  @override
  void dispose() {
    _player.release();
    super.dispose();
  }
}
