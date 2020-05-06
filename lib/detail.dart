import 'package:flutter/material.dart';

class DetailWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Detail'),
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              child: Text('SAVE'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Center(
          child: RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Go back!'),
          ),
        ));
  }
}
