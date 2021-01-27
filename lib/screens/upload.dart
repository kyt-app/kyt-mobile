import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kyt/global/myColors.dart';
import 'package:kyt/global/mySpaces.dart';
import 'package:kyt/global/myStrings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class Upload extends StatefulWidget {
  static String id = "upload";
  final CameraDescription camera;

  const Upload({ Key key, @required this.camera }) : super(key: key);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String imagePath;
  bool noImage = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.darkPrimary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Center(
            child: Text(
              MyStrings.travellerLabel,
              style: Theme.of(context).textTheme.headline6.copyWith(color: MyColors.lightGrey),
            ),
          ),
          MySpaces.vSmallGapInBetween,
          noImage ? FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ) : SizedBox(),
          !noImage ? ShowImage(imagePath: imagePath) : SizedBox()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
            await _controller.takePicture(path);

            setState(() {
              imagePath = path;
              noImage = false;
            });

          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imagePath;
  const ShowImage({ Key key, this.imagePath }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(imagePath);

    File image = File(imagePath);
    List<int> imageBytes = image.readAsBytesSync();
    print(imageBytes);

    // TODO: post to Azure CV OCR to get text
    // post text to api

    return Container(
      child: Image.file(File(imagePath))
    );
  }
}
