import 'package:dos/database.dart';
import 'package:dos/models/emotion_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class JournalTags extends StatefulWidget {
  JournalTags({Key key, this.log}) : super(key: key);
  final EmotionLog log;
  final EmotionTable _db = EmotionTable();

  @override
  _JournalTagsState createState() => _JournalTagsState();
}

class _JournalTagsState extends State<JournalTags> {
  @override
  Widget build(BuildContext context) {
    return ChipsInput(
        initialValue: widget.log.tags ?? <String>[],
        //_log.tags,
        decoration: InputDecoration(
          hintText: "Add or Create tags",
          prefixIcon: Icon(MdiIcons.tag),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(style: BorderStyle.none),
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        maxChips: 50,
        findSuggestions: (String query) async {
          List<String> results = await widget._db.getTagsStartWith(query, 5);
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
          setState(() {
            widget.log.tags = tags;
          });
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
        });
  }

  void dispose() {
    super.dispose();
  }
}
