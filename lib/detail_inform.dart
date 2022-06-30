import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'dart:convert';

class DetailInform extends StatefulWidget{
  DetailInform({required this.paperData});
  final Map paperData;
  @override
  _DetailInformState createState() => _DetailInformState();
}

class _DetailInformState extends State<DetailInform> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  final titles = ["List 1", "List 2", "List 3"];
  final subtitles = [
    "Here is list 1 subtitle",
    "Here is list 2 subtitle",
    "Here is list 3 subtitle"
  ];
  final icons = [Icons.ac_unit, Icons.access_alarm, Icons.access_time];

  @override
  Widget build(BuildContext context) {
    var data = widget.paperData['document'];
    data.forEach((index, value) => print('$index.________________$value'));
    print(data['line_items']);
    // TODO: implement build
    return MaterialApp(
      title: 'Result',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(
              subtitle: Text(data.values.toList()[index].toString()),
              title: Text(data.keys.toList()[index].toString()),
            );
          },
        ),
      ),
    );
  }
}