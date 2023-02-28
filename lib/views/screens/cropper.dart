import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_crop/image_crop.dart';
import 'package:sp_app/views/screens/full_screen_image.dart';

import '../utils/AppColor.dart';

class CropperScreen extends StatefulWidget {
  final File imageFile;
  const CropperScreen({super.key, required this.imageFile});

  @override
  State<CropperScreen> createState() => _CropperScreenState();
}

class _CropperScreenState extends State<CropperScreen> {
  final cropKey = GlobalKey<CropState>();

  Future<void> cropImage(context) async {
    // final scale = cropKey.currentState.scale;
    final area = cropKey.currentState?.area ?? const Rect.fromLTRB(0, 0, 0, 0);
    // if (area == null) {
    //   // cannot crop, widget is not setup
    //   return;
    // }

    // // scale up to use maximum possible number of pixels
    // // this will sample image in higher resolution to make cropped image larger
    // final sample = await ImageCrop.sampleImage(
    //   file: _file,
    //   preferredSize: (2000 / scale).round(),
    // );

    final file = await ImageCrop.cropImage(
      file: widget.imageFile,
      area: area,
    );

    debugPrint('$file');

    processImage(InputImage.fromFile(file));

    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FullScreenImage(image: Image.file(file))));
  }

  String? _text;

  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<void> processImage(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);
    _text = 'Recognized text:\n\n${recognizedText.text}';
    print('hihi');
    print(_text);
    print(recognizedText.blocks);

    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      print(rect.toString());
      print(cornerPoints.toString());
      print('haha');

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        // Image Wrapper
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          // Image Widget
          child: Column(children: [
            Expanded(
              flex: 8,
              child: Stack(alignment: Alignment.center, children: [
                Crop(
                  key: cropKey,
                  image: FileImage(widget.imageFile),
                ),
                Positioned(
                    bottom: 24,
                    child: Text(
                        'Crop the image to only\ninclude the item list and their prices.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColor.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'inter')))
              ]),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          cropImage(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(
                              color: AppColor.secondary.withOpacity(0.5),
                              width: 1),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(
                                color: AppColor.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'inter')),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () {
                            cropImage(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: AppColor.primarySoft,
                          ),
                          child: Text('Crop',
                              style: TextStyle(
                                  color: AppColor.secondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'inter')),
                        )),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
