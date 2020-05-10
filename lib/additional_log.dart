import 'package:dos/database.dart';
import 'package:dos/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

class AdditionalLog extends StatefulWidget {
  AdditionalLog({Key key, this.log}) : super(key: key);

  final EmotionLog log;

  @override
  _AdditionalLogState createState() => _AdditionalLogState(log);
}

class _AdditionalLogState extends State<AdditionalLog> {
  _AdditionalLogState(EmotionLog log) {
    this._log = log;
    this._jorunalController = TextEditingController(text: log.jorunal);
  }

  EmotionLog _log;
  TextEditingController _jorunalController;
  EmotionTable _db = EmotionTable();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Log'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text('Done'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _jorunalController,
              decoration: InputDecoration(
                labelText: 'Jorunal',
                border: inputBorder,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (value) {
                // Not wrapping in setState because field is manged by controller 
                _log.jorunal = value;
              },
            ),
            SizedBox(height: 20),
            ChipsInput(
              initialValue: _log.tags ?? <String>[],
              decoration: InputDecoration(
                labelText: "Tags",
                border: inputBorder,
              ),
              maxChips: 50,
              findSuggestions: (String query) async {
                List results = await _db.getTagsStartWith(query, 5);
                if (query != null && query.length > 0) {
                  // add the input string if only the input is not empty string
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
                  avatar: CircleAvatar(child: Text('#')),
                  onDeleted: () => state.deleteChip(tagString),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              },
              suggestionBuilder: (context, state, tagString) {
                return ListTile(
                  key: ObjectKey(tagString),
                  leading: CircleAvatar(child: Text('#')),
                  title: Text(tagString),
                  onTap: () => state.selectSuggestion(tagString),
                );
              },
            )
          ],
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
