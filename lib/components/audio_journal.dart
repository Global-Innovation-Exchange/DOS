import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound_player.dart';
import 'package:flutter_sound_lite/flutter_sound_recorder.dart';

import '../models/emotion_log.dart';
import '../utils.dart';

class AudioJournal extends StatefulWidget {
  AudioJournal({Key key, this.log}) : super(key: key);

  final EmotionLog log;

  @override
  _AudioJournalState createState() => _AudioJournalState(log);
}

class _AudioJournalState extends State<AudioJournal> {
  _AudioJournalState(EmotionLog log) {
    this._log = log;
    this._recorder = FlutterSoundRecorder();
    this._player = FlutterSoundPlayer();
    this._isRecording = false;
    this._isPlaying = false;
  }

  EmotionLog _log;
  FlutterSoundRecorder _recorder;
  FlutterSoundPlayer _player;
  bool _isRecording;
  bool _isPlaying;

  bool get _hasRecording {
    return _log.tempAudioPath != null;
  }

  Widget _buildIcon(
          {Icon icon, VoidCallback onPressed, Color foregroundColor}) =>
      CircleAvatar(
        backgroundColor: Color(0xffFEEFE6),
        foregroundColor: Color(0xFFE1B699),
        child: IconButton(
            padding: EdgeInsets.all(0), icon: icon, onPressed: onPressed),
      );

  Future _showOverridingDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Record",
            style: Theme.of(context).primaryTextTheme.subtitle1.apply(
                  fontSizeFactor: 1.3,
                )),
        content: Text(
            "There is existing an audio jorunal. If you record, the existing audio jorunal will be overwritten.",
            style: Theme.of(context).primaryTextTheme.subtitle1.apply(
                  fontSizeFactor: 1.3,
                )),
        actions: <Widget>[
          FlatButton(
            child: Text("RECORD"),
            onPressed: () async {
              await _recorder.startRecorder(uri: _log.tempAudioPath);
              Navigator.of(context).pop();
              setState(() {
                _isRecording = true;
              });
            },
          ),
          FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }

  Widget _buildRunableIcon(icon, {spinning = false}) {
    if (spinning) {
      return Stack(
        children: <Widget>[
          SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(),
          ),
          Positioned.fill(child: icon),
        ],
      );
    } else {
      return icon;
    }
  }

  Widget _buildRecorderIcon() {
    var icon;
    if (_isRecording) {
      icon = _buildIcon(
        icon: Icon(Icons.stop),
        foregroundColor: Colors.black38,
        onPressed: () async {
          await _recorder.stopRecorder();
          setState(() {
            _isRecording = false;
          });
        },
      );
    } else {
      var handlePressed = _isPlaying
          ? null
          : () async {
              if (!_hasRecording) {
                _log.tempAudioPath = await createTempAudioPath();
                await _recorder.startRecorder(uri: _log.tempAudioPath);
                setState(() {
                  _isRecording = true;
                });
              } else {
                await _showOverridingDialog();
              }
            };

      icon = _buildIcon(
        foregroundColor: !_hasRecording ? Colors.black : null,
        icon: Icon(Icons.mic),
        onPressed: handlePressed,
      );
    }
    return _buildRunableIcon(icon, spinning: _isRecording);
  }

  Widget _buildPlayerIcon() {
    if (!_hasRecording) {
      return SizedBox.shrink();
    }

    var icon;
    if (_isPlaying) {
      icon = _buildIcon(
        icon: Icon(Icons.stop),
        foregroundColor: Colors.black,
        onPressed: () async {
          await _player.stopPlayer();
          setState(() {
            _isPlaying = false;
          });
        },
      );
    } else {
      var handlePressed = _isRecording
          ? null
          : () async {
              await _player.startPlayer(_log.tempAudioPath, whenFinished: () {
                setState(() {
                  _isPlaying = false;
                });
              });
              setState(() {
                _isPlaying = true;
              });
            };

      icon = _buildIcon(
        foregroundColor: null,
        icon: Icon(Icons.play_arrow),
        onPressed: handlePressed,
      );
    }
    return _buildRunableIcon(icon, spinning: _isPlaying);
  }

  Widget _buildTrashIcon() {
    if (!_hasRecording) {
      return SizedBox.shrink();
    }
    var handlePressed = _isPlaying || _isRecording
        ? null
        : () async {
            bool deleted = await deleteFile(_log.tempAudioPath);
            if (deleted) {
              setState(() {
                _log.tempAudioPath = null;
              });
            }
          };
    return _buildIcon(icon: Icon(Icons.delete), onPressed: handlePressed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text("My Audio Journal"),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: <Widget>[
            _buildRecorderIcon(),
            SizedBox(width: 10),
            _buildPlayerIcon(),
            SizedBox(width: 10),
            _buildTrashIcon(),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _recorder.release();
    _player.release();
    super.dispose();
  }
}
