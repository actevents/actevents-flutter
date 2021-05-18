import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

typedef void OnPictureTaken(String path);

class PicturePreviewScreen extends StatefulWidget {
  final CameraDescription camera;
  const PicturePreviewScreen({
    Key key,
    @required this.camera,
    this.onPictureTaken
  }) : super(key: key);
  final OnPictureTaken onPictureTaken;
  @override
  _PicturePreviewScreenState createState() => _PicturePreviewScreenState();
}

class _PicturePreviewScreenState extends State<PicturePreviewScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _takePicture() async {
    try {
      await _initializeControllerFuture;
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      tempPath = tempPath + '/' + Uuid().v4() + '.jpg';
      await _controller.takePicture(tempPath);
      widget.onPictureTaken(tempPath);
    } catch (e) {
      // better error handling here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kamera"),
      ),
      body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt_outlined),
        onPressed: () async {
          print("Taking picture");
          await _takePicture();
        },
      ),
    );
  }
}
