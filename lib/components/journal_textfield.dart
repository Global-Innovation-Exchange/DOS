import 'package:dos/models/emotion_log.dart';
import 'package:flutter/material.dart';

class JorunalTextField extends StatefulWidget {
  JorunalTextField({Key key, this.log, this.minLines}) : super(key: key);

  final EmotionLog log;
  final int minLines;

  @override
  _JorunalTextFieldState createState() => _JorunalTextFieldState(log);
}

class _JorunalTextFieldState extends State<JorunalTextField> {
  _JorunalTextFieldState(log) {
    _log = log;
    _controller = TextEditingController(text: _log.journal);
  }

  EmotionLog _log;
  TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: null,
      minLines: widget.minLines,
      maxLength: 7000,
      textAlignVertical: TextAlignVertical.top,
      enableInteractiveSelection: true, // allow selection
      controller: _controller,
      decoration: InputDecoration(
        //fillColor: Colors.white,
        //filled: true,
        prefixIcon: Icon(Icons.edit),
        // labelText: 'Text Journal',
        alignLabelWithHint: false,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.none),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      keyboardType: TextInputType.multiline,
      onChanged: (value) {
        // Not wrapping in setState because field is manged by controller
        _log.journal = value;
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
