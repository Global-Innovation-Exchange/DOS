import 'package:dos/models/emotion_log.dart';
import 'package:flutter/material.dart';

class JorunalTextField extends StatefulWidget {
  JorunalTextField(
      {Key key, this.log, this.minLines, this.filled, this.fillColor, this.labelText})
      : super(key: key);

  final EmotionLog log;
  final int minLines;
  final Color fillColor;
  final bool filled;
  final String labelText;

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
        fillColor: widget.fillColor,
        filled: widget.filled,
        prefixIcon: Icon(Icons.edit),
        labelText: widget.labelText,
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
