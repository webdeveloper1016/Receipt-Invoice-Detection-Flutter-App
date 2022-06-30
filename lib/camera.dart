import 'dart:convert';

import 'package:camera_detection/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:tflite/tflite.dart';
import 'package:camera_detection/detail_inform.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class CameraFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String url;
  final int delay;
  final double confidence;
  CameraFeed(
      {required this.cameras,
      required this.setRecognitions,
      required this.url,
      required this.delay,
      required this.confidence});

  @override
  _CameraFeedState createState() => new _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  late CameraController controller;
  bool isDetecting = false;
  bool isCheck = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras.length < 1) {
      print('No Cameras Found.');
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        func();
      });
    }
  }

  final spinKit = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven ? Colors.red : Colors.green,
        ),
      );
    },
  );

  void func() {
    controller.startImageStream((CameraImage img) {
      if (!isDetecting) {
        isDetecting = true;
        Tflite.detectObjectOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          // rotation: img.width <= img.height ? 90 : 270,
          model: "YOLO",
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: 0,
          imageStd: 255,
          numResultsPerClass: 5,
          threshold: 0.1,
        ).then((recognitions) async {
          print(recognitions);
          widget.setRecognitions(recognitions!, img.height, img.width);
          for (var element in recognitions) {
            if (element['confidenceInClass'] > widget.confidence && element['detectedClass'] == "Receipt")
            {
              isCheck = true;

              await controller.stopImageStream();
              final up = await controller.takePicture();
              Map? result = await uploadImage(
                  filepath: up.path, url: widget.url, filename: up.name);
              print(result);

              if (result == null){
                isCheck = false;
                break;
              } else {
                isCheck = false;
                print(result);
                if (!Hive.isBoxOpen("settings")) await Hive.openBox("settings");
                int imagesUploaded = Hive.box("settings").get("imagesUploaded", defaultValue: 0);
                await Hive.box("settings").put("imagesUploaded", imagesUploaded + 1);
                await Hive.close();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailInform(paperData: result,)),
                );
              }
              // else if (reason == "good") {
              //   if (!Hive.isBoxOpen("settings")) await Hive.openBox("settings");
              //   int imagesUploaded =
              //       Hive.box("settings").get("imagesUploaded", defaultValue: 0);
              //   await Hive.box("settings")
              //       .put("imagesUploaded", imagesUploaded + 1);
              //   await Hive.close();
              // } else {
              //   Fluttertoast.showToast(
              //       msg: reason,
              //       toastLength: Toast.LENGTH_LONG,
              //       gravity: ToastGravity.CENTER,
              //       timeInSecForIosWeb: 1,
              //       backgroundColor: Colors.red,
              //       textColor: Colors.white,
              //       fontSize: 18.0);
              // }

              break;
            }
          }
          await Future.delayed(Duration(seconds: widget.delay));

          // if (!controller.value.isStreamingImages) func();

          isDetecting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    Orientation orientation = MediaQuery.of(context).orientation;

    // If the Future is complete, display the preview.
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    SpinKitWave LoadingSpinner() {
      return const SpinKitWave(color: Colors.white, size: 30,);
    }

    return OverflowBox(
      maxHeight: orientation == Orientation.landscape
          ? tmp.height
          : screenRatio > previewRatio
              ? screenH
              : screenW / previewW * previewH,
      maxWidth: orientation == Orientation.landscape
          ? tmp.width
          : screenRatio > previewRatio
              ? screenH / previewH * previewW
              : screenW,
      child: Stack(
        children: [
          CameraPreview(controller),
          isCheck ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingSpinner(),
              Padding(padding: EdgeInsets.all(16.0), child: Text('Analyzing...'),)
            ],
          ) : Text('')
        ],
      )
    );
  }
}
