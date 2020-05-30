import 'package:dos/models/emotion_log.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
    _focusNode = FocusNode();
    _isFocus = false;
  }
  FocusNode _focusNode;
  EmotionLog _log;
  TextEditingController _controller;
  bool _isFocus;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      maxLines: null,
      minLines: widget.minLines,
      maxLength: 7000,
      textAlignVertical: TextAlignVertical.top,
      enableInteractiveSelection: true, // allow selection
      controller: _controller,
      decoration: InputDecoration(
        fillColor: _isFocus ? Colors.white : widget.fillColor,
        filled: true,
        prefixIcon: Icon(MdiIcons.textBox),
        labelText: "My Written Journal",
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
    _focusNode.dispose();
    super.dispose();
  }
}
