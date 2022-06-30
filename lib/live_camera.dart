import 'package:camera/camera.dart';
import 'package:camera_detection/camera.dart';
import 'package:camera_detection/main.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:camera_detection/bndbox.dart';
import 'dart:math' as math;

class LiveFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String url;
  final int delay;
  final double confidence;
  LiveFeed(
      {required this.cameras,
      required this.url,
      required this.delay,
      required this.confidence});
  @override
  _LiveFeedState createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> {
  late List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  initCameras() async {}
  loadTfModel() async {
    await Tflite.loadModel(
      model: "assets/models/yolov2_tiny.tflite",
      labels: "assets/models/yolov2_tiny.txt",
    );
  }

  /* 
  The set recognitions function assigns the values of recognitions, imageHeight and width to the variables defined here as callback
  */
  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTfModel();
    print(url);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            )),
      ),
      body: Stack(
        children: <Widget>[
          CameraFeed(
            cameras: widget.cameras,
            setRecognitions: setRecognitions,
            url: widget.url,
            confidence: widget.confidence,
            delay: widget.delay,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Please wait 3 seconds after placing the camera on the invoice or receipt."),
            ),
          )
          // BndBox(
          //     _recognitions == null ? [] : _recognitions,
          //     math.max(_imageHeight, _imageWidth),
          //     math.min(_imageHeight, _imageWidth),
          //     screen.height,
          //     screen.width,
          //     'yolo'),
        ],
      ),
    );
  }
}
