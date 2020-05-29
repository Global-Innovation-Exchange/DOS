import 'package:flutter/material.dart';

class DividerWrap extends StatelessWidget {
  final Widget child;
  final double height;
  final double thickness;
  final double indent;
  final double innerIndent;
  final Color color;

  const DividerWrap({
    Key key,
    this.child,
    this.height,
    this.thickness,
    this.indent,
    this.innerIndent,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          child: Divider(
        height: this.height,
        thickness: this.thickness,
        color: color,
        indent: indent,
        endIndent: innerIndent,
      )),
      child,
      Expanded(
          child: Divider(
        height: this.height,
        thickness: this.thickness,
        color: color,
        indent: innerIndent,
        endIndent: indent,
      )),
    ]);
  }
}
