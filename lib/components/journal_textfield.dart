import 'package:dos/models/emotion_log.dart';
import 'package:flutter/material.dart';

class JorunalTextField extends StatefulWidget {
  JorunalTextField(
      {Key key,
      this.log,
      this.minLines,
      this.filled,
      this.fillColor,
      this.labelText})
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
  FocusNode myFocusNode = new FocusNode();
  EmotionLog _log;
  TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: myFocusNode,
      maxLines: null,
      minLines: widget.minLines,
      maxLength: 7000,
      textAlignVertical: TextAlignVertical.top,
      enableInteractiveSelection: true, // allow selection
      controller: _controller,
      decoration: InputDecoration(
        fillColor: myFocusNode.hasFocus ? Colors.white : widget.fillColor,
        filled: true,
        prefixIcon: Icon(Icons.edit),
        labelText: "Written Journal",
        alignLabelWithHint: false,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(15.0),
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
    myFocusNode.dispose();
    super.dispose();
  }
}
