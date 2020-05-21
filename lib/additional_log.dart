import 'dart:io';

import 'package:dos/database.dart';
import 'package:dos/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:flutter_sound_lite/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AdditionalLog extends StatefulWidget {
  AdditionalLog({Key key, this.log}) : super(key: key);

  final EmotionLog log;

  @override
  _AdditionalLogState createState() => _AdditionalLogState(log);
}

class _AdditionalLogState extends State<AdditionalLog> {
  _AdditionalLogState(EmotionLog log) {
    this._log = log;
    this._jorunalController = TextEditingController(text: log.journal);
    this._recorder = FlutterSoundRecorder();
    this._isRecording = false;
  }

  EmotionLog _log;
  TextEditingController _jorunalController;
  FlutterSoundRecorder _recorder;
  bool _isRecording;
  EmotionTable _db = EmotionTable();

  Widget _buildSource() {
    var children = EmotionSource.values.map((src) {
      var isSelected = _log.source == src;
      var color = isSelected ? Colors.white : Colors.black38;

      return Container(
          margin: EdgeInsets.only(bottom: 30),
          padding: EdgeInsets.only(right: 15),
          child: CircleAvatar(
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
          ));
    }).toList();
    return Row(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Detailed Journal'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          FlatButton(
            child: Text('DONE'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: themeColor,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ChipsInput(
              initialValue: _log.tags ?? <String>[],
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: "Tags",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10.0),
                  )),
              maxChips: 50,
              findSuggestions: (String query) async {
                List<String> results = await _db.getTagsStartWith(query, 5);
                if (query != null &&
                    query.length > 0 &&
                    results.indexOf(query) == -1) {
                  // add the input string if only the input is not empty string
                  // and the result doesn't contain the exact string
                  results.add(query);
                }
                return results;
              },
              onChanged: (tags) {
                // Don't need to wrap it setState because UI change is managed by ChipsInput
                _log.tags = tags;
              },
              chipBuilder: (context, state, tagString) {
                return InputChip(
                  key: ObjectKey(tagString),
                  label: Text(tagString),
                  avatar: CircleAvatar(
                    child: Text('#'),
                  ),
                  onDeleted: () => state.deleteChip(tagString),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              },
              suggestionBuilder: (context, state, tagString) {
                return ListTile(
                  key: ObjectKey(tagString),
                  leading: CircleAvatar(
                    child: Text('#'),
                  ),
                  title: Text(tagString),
                  onTap: () => state.selectSuggestion(tagString),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                InkWell(
                    onTap: () async {
                      if (!_isRecording) {
                        if (_log.tempAudioPath == null) {
                          _log.tempAudioPath = await _createTempFilePath();
                        }
                        await _recorder.startRecorder(uri: _log.tempAudioPath);
                      } else {
                        await _recorder.stopRecorder();
                      }
                      setState(() {
                        _isRecording = !_isRecording;
                      });
                    },
                    child: Padding(
                        padding: EdgeInsets.only(top: 0.0),
                        child: Icon(
                          !_isRecording ? Icons.mic : Icons.stop,
                        ))),
                Text(!_isRecording ? "Record audio Journal" : "Recording..."),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextFormField(
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                controller: _jorunalController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.only(left: 15, top: 30), // prevent text overlap
                  labelText: '\nWrite in your journal',  // weird spacing
                  alignLabelWithHint: false,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                onChanged: (value) {
                  // Not wrapping in setState because field is manged by controller
                  _log.journal = value;
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15, top: 20),
                    child: Text(
                      "I feel this way because of",
                    ),
                  ),
                ),
                _buildSource(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _jorunalController.dispose();
    _recorder.release();
    super.dispose();
  }
}

Future<String> _createTempFilePath() async {
  Directory tempDir = await getTemporaryDirectory();
  bool exists = true;
  File tempFile;
  while (exists) {
    String filename = '${Uuid().v4()}.aac';
    tempFile = File('${tempDir.path}/$filename');
    exists = await tempFile.exists();
  }
  return tempFile.path;
}
