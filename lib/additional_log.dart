import 'package:dos/database.dart';
import 'package:dos/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

class AdditionalLog extends StatefulWidget {
  @override
  _AdditionalLogState createState() => _AdditionalLogState();
}

class _AdditionalLogState extends State<AdditionalLog> {
  TextEditingController _jorunalController = TextEditingController();
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
            onPressed: () async {
              // TODO: return the original object
              Navigator.pop(context, true);
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
            ),
            SizedBox(height: 20),
            ChipsInput(
              initialValue: ['tag1'],
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
              onChanged: (data) {
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
