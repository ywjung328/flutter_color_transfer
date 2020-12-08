import 'dart:io';

import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  ResultPage({Key key, this.input, this.style, this.result}) : super(key: key);
  final input, style, result;
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Result')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(File(widget.input)),
              SizedBox(height: 10),
              Image.file(File(widget.style)),
              SizedBox(height: 10),
              Image.memory(widget.result),
            ],
          ),
        ),
      ),
    );
  }
}
