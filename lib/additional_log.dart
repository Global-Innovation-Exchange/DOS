import 'package:dos/database.dart';
import 'package:dos/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

import 'components/audio_journal.dart';
import 'components/journal_textfield.dart';
import 'models/emotion_log.dart';
import 'models/emotion_source.dart';

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
  }

  EmotionLog _log;
  TextEditingController _jorunalController;
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
    Widget body = Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
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
          AudioJournal(log: _log),
          SizedBox(height: 20),
          JorunalTextField(
            log: _log,
            minLines: 10,
          )
        ],
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: GestureDetector(
        onTap: () {
          // This is used to bring down the soft keyboard when other than
          // text field is tapped.
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(
          builder: (context, viewportConstraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _jorunalController.dispose();
    super.dispose();
  }
}
