import 'package:dos/components/journal_datetime.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'additional_log.dart';
import 'components/emotion_slider.dart';
import 'database.dart';
import 'models/emotion.dart';
import 'models/emotion_log.dart';
import 'utils.dart';

class CreateLog extends StatefulWidget {
  @override
  _CreateLogState createState() => _CreateLogState();
}

class _CreateLogState extends State<CreateLog> {
  final _table = EmotionTable();
  EmotionLog _log;
  EmotionLog _original;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    // Remove any component less than minute
    now = DateTime(now.year, now.month, now.day, now.hour, now.minute);

    _log = EmotionLog();
    _log.scale = 3;
    _log.dateTime = now;
    _log.emotion = Emotion.happy;

    _original = _log.clone();
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
    List<String> values = ["1", "2", "3", "4", "5"];
    //datetime picker widget
    Widget selectDate = Container(
        padding: EdgeInsets.all(8.0),
        color: Color(0X3311111),
        child: JournalDateTime(log: _log));
    Widget selectedEmotionIcon = Expanded(
      flex: 7,
      child: getEmotionImage(_log.emotion),
    );

    Widget selectedEmotionScale = Expanded(
      flex: 1,
      child: Container(child: EmotionSlider(log: _log)),
    );
    Widget scaleNumbers = Expanded(
      flex: 1,
      child: Container(
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

    Widget iconsList = Expanded(
      flex: 7,
      child: GridView.count(
        scrollDirection: Axis.horizontal,
        childAspectRatio: 0.77,
        crossAxisCount: 2,
        crossAxisSpacing: 1.0,
        children: Emotion.values
            .sublist(1)
            .map(
              (e) => _displayGridItem(
                emotion: e,
                onTap: () {
                  setState(() {
                    _log.emotion = e;
                  });
                },
              ),
            )
            .toList(),
      ),
    );

    Widget journalButton = SafeArea(
      bottom: true,
      child: ButtonTheme(
        height: 50,
        minWidth: double.infinity,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: RaisedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdditionalLog(log: _log),
              ),
            );

            // Quick fix to foce update 
            // when additional log updated the scale
            setState(() {
              _log = _log;
            });
          },
          child: Text('Enter Detailed Journal'),
        ),
      ),
    );

    Widget body = Column(
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
        journalButton,
      ],
    );

    var handleBackPressed = () async {
      bool didLogChange = !await _log.equals(_original);
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

    return WillPopScope(
      onWillPop: handleBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Log'),
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: handleBackPressed,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('SAVE'),
              onPressed: () async {
                await _table.insertEmotionLog(_log);
                Navigator.pop(context, true);
              },
            )
          ],
        ),
        backgroundColor: themeColor,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: body,
        ),
      ),
    );
  }
}

Widget _displayGridItem({Emotion emotion, GestureTapCallback onTap}) {
  return InkWell(
    child: Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
            Radius.circular(10.0)), // set rounded corner radius
      ),
      margin: EdgeInsets.only(right: 7.5, left: 9, bottom: 9.0),
      child: getEmotionImage(emotion),
    ),
    onTap: onTap,
  );
}
