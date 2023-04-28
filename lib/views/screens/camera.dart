import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:amethyst/views/screens/cropper.dart';

import '../../main.dart';
import '../utils/AppColor.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isCapturePressed = false;

  @override
  void initState() {
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(alignment: Alignment.center, children: [
              AspectRatio(
                  aspectRatio: 1 / controller!.value.aspectRatio,
                  child: Transform.scale(
                    scale: 1.15,
                    alignment: Alignment.topCenter,
                    child: CameraPreview(
                      controller!,
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) =>
                              onViewFinderTap(details, constraints),
                        );
                      }),
                    ),
                  )),
              Positioned(
                  top: MediaQuery.of(context).size.height / 2,
                  child: Text(
                      'Capture as close to the receipt as possible.\nKeep the text parallel to the lines.\nMake sure the item list with prices can be seen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'inter'))),
              Positioned.fill(
                  child: Transform.scale(
                      scale: 1.15,
                      child: const Image(
                        image: AssetImage(
                          "assets/images/overlay.png",
                        ),
                        repeat: ImageRepeat.repeat,
                      ))),
              Positioned(
                  bottom: 100,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: InkWell(
                    onTap: () async {
                      if (_isCapturePressed == true) return;

                      _isCapturePressed = true;

                      XFile? rawImage = await takePicture();
                      File imageFile = File(rawImage!.path);

                      int currentUnix = DateTime.now().millisecondsSinceEpoch;
                      final directory =
                          await getApplicationDocumentsDirectory();
                      String fileFormat = imageFile.path.split('.').last;

                      await imageFile.copy(
                        '${directory.path}/$currentUnix.$fileFormat',
                      );

                      print('${directory.path}/$currentUnix.$fileFormat');

                      _isCapturePressed = false;

                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CropperScreen(
                              imageFile: imageFile,
                              imagePath:
                                  '${directory.path}/$currentUnix.$fileFormat')));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.circle,
                            color: Colors.white38, size: 100),
                        Icon(Icons.circle,
                            color: _isCapturePressed
                                ? Colors.white38
                                : Colors.white,
                            size: 80),
                      ],
                    ),
                  ))
            ])
          : Container(),
    );
  }
}
