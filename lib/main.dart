import 'package:camera/camera.dart';
import 'package:camera_detection/live_camera.dart';
import 'package:camera_detection/widgets/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

late List<CameraDescription> cameras;
late String url;
late int delay;
late double confidence;
late Box box;
late int imagesUploaded;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  box = await Hive.openBox('settings');
  url = await box.get("url", defaultValue: "https://www.eraudit.space/api/process");
  delay = await box.get("delay", defaultValue: 0);
  confidence = await box.get("confidence", defaultValue: 0.35);
  imagesUploaded = await box.get("imagesUploaded", defaultValue: 0);
  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    box.compact();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Receipt Detector App"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
            ),
            onPressed: aboutDialog,
          ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: Hive.box('settings').listenable(),
          builder: (context, Box box, widget) {
            return Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 100.0,
                              height: 100.0,
                              margin: EdgeInsets.all(20),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 2, color: Colors.white)),
                              child: Center(
                                child: Text(
                                  "${box.get("imagesUploaded", defaultValue: 0)}",
                                  style: const TextStyle(fontSize: 40.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
                            Text("Images uploaded"),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50.0,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: Row(
                              children: [
                                Text("Start Detection"),
                                const SizedBox(
                                  width: 12.0,
                                ),
                                const Icon(
                                  Icons.video_camera_back_outlined,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LiveFeed(
                                    cameras: cameras,
                                    url:
                                        box.get("url", defaultValue: "https://www.eraudit.space/api/process"),
                                    confidence: box.get("confidence",
                                        defaultValue: 0.55),
                                    delay: box.get("delay", defaultValue: 0),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  aboutDialog() async {
    await showDialog(context: context, builder: (context) => Settings());
  }
}
