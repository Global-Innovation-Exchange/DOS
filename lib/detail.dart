import 'package:dos/components/audio_journal.dart';
import 'package:dos/components/emotion_slider.dart';
import 'package:dos/components/journal_datetime.dart';
import 'package:dos/components/journal_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/journal_tags.dart';
import 'database.dart';
import 'models/emotion.dart';
import 'models/emotion_log.dart';
import 'models/emotion_source.dart';
import 'utils.dart';

class EmotionDetail extends StatefulWidget {
  EmotionDetail({Key key, this.log}) : super(key: key);
  final EmotionLog log;

  @override
  _EmotionDetailState createState() => _EmotionDetailState(log.clone());
}

class _EmotionDetailState extends State<EmotionDetail> {
  _EmotionDetailState(EmotionLog log) {
    _log = log;
  }

  final EmotionTable _table = EmotionTable();
  EmotionLog _log;
  bool _expandSources = false;

  Future<bool> _showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete log"),
        content: Text("Are you sure to delete this log entry?"),
        actions: <Widget>[
          FlatButton(
            child: Text("YES"),
            onPressed: () async {
              await _table.deleteEmotionLog(_log.id);
              Navigator.of(dialogContext).pop(true);
            },
          ),
          FlatButton(
              child: Text("NO"),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              }),
        ],
      ),
    );
  }

  Future<bool> _showBackDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async {
          // This is needed so that when user press anything other than buttons
          // this dialog will still return a boolean
          Navigator.of(dialogContext).pop(false);
          return true;
        },
        child: AlertDialog(
          content: Text("You have unsaved changes, are you sure to leave?"),
          actions: <Widget>[
            FlatButton(
              child: Text("YES"),
              onPressed: () async {
                Navigator.of(dialogContext).pop(true);
              },
            ),
            FlatButton(
                child: Text("NO"),
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedDate = Container(
      height: 60,
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

        return Container(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 20,
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
                    _expandSources = false;
                  });
                },
              ),
            ));
      }).toList();
      return Row(children: children);
    }

    Widget _selectedSource() {
      return _log.source != null
          ? CircleAvatar(
              backgroundColor: Color(0xffE1B699),
              child: getEmotionSourceIcon(
                _log.source,
                color: Colors.white,
              ))
          : SizedBox.shrink();
    }

    Widget emotionSource = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("I feel this way because..."),
        SizedBox(height: 15.0),
        Row(
          children: <Widget>[
            IconButton(
              iconSize: 20,
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _expandSources = !_expandSources;
                });
              },
            ),
            _expandSources ? _buildSource() : _selectedSource(),
          ],
        ),
      ],
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

    Widget deleteButton = SafeArea(
      bottom: true,
      child: ButtonTheme(
        height: 50,
        minWidth: double.infinity,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: RaisedButton(
          onPressed: () async {
            if (_log.id != null) {
              bool deleted = await _showDeleteDialog(context);
              if (deleted) {
                Navigator.pop(context, true);
              }
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
                SizedBox(height: 30.0),
                journalVoice,
                journalText,
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

    Future<Null> Function() handleBackPressed = () async {
      bool didLogChange = !await _log.equals(widget.log);
      if (didLogChange) {
        bool confirmed = await _showBackDialog(context);
        if (!confirmed) {
          // Cancelled the dialog so user will continue to edit
          return;
        }
      }

      // Clean up the temp audio copied
      if (_log.tempAudioPath != null) {
        await deleteFile(_log.tempAudioPath);
      }
      Navigator.pop(context, false);
    };

    // This makes each child fill the full width of the screen
    return WillPopScope(
      onWillPop: handleBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Journal'),
          leading:
              IconButton(icon: Icon(Icons.clear), onPressed: handleBackPressed),
          actions: <Widget>[
            FlatButton(
              child: Text('SAVE'),
              onPressed: () async {
                await _table.updateEmotionLog(_log);
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
      ),
    );
  }

  restReasons() {}
}
