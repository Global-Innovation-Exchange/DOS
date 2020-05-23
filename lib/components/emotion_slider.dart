
import 'package:dos/models/emotion_log.dart';
import 'package:flutter/material.dart';

class EmotionSlider extends StatefulWidget {
  EmotionSlider({Key key, this.log}) : super(key: key);
  final EmotionLog log;

  @override
  _EmotionSliderState createState() => _EmotionSliderState();
}

class _EmotionSliderState extends State<EmotionSlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: widget.log.scale.toDouble(),
      min: 1.0,
      max: 5.0,
      activeColor: Color(0xffE1B699),
      inactiveColor: Colors.black12,
      divisions: 4,
      label: widget.log.scale.toString(),
      onChanged: (value) {
        setState(() {
          widget.log.scale = value.toInt();
        });
      },
    );
  }
}