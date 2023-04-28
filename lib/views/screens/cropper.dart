import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_crop/image_crop.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amethyst/models/core/receipt.dart';
import 'package:amethyst/models/helper/db_helper.dart';
import 'package:amethyst/views/screens/receipt_detail_page.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:diacritic/diacritic.dart';

import '../utils/AppColor.dart';
import '../utils/misc_utils.dart';

class CropperScreen extends StatefulWidget {
  final File imageFile;
  final String imagePath;
  const CropperScreen(
      {super.key, required this.imageFile, required this.imagePath});

  @override
  State<CropperScreen> createState() => _CropperScreenState();
}

class _CropperScreenState extends State<CropperScreen> {
  final cropKey = GlobalKey<CropState>();

  DBHelper db = DBHelper();

  /// File imageFile -> the image from the camera
  /// File file -> the cropped image
  /// File thresholdFile -> the cropped image with OpenCV threshold applied
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

    // crop image
    final file = await ImageCrop.cropImage(
      file: widget.imageFile,
      area: area,
    );

    // perform thresholding using opencv
    Uint8List byteImage = await Cv2.adaptiveThreshold(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: file.path,
      maxValue: 255,
      adaptiveMethod: Cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
      thresholdType: Cv2.THRESH_BINARY,
      blockSize: 11,
      constantValue: 12,
    );

    // save threshold image in temp folder
    final tempDir = await getTemporaryDirectory();
    String thresholdLocation =
        '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png';
    File thresholdFile = await File(thresholdLocation).create();
    thresholdFile.writeAsBytesSync(byteImage);

    // create new entry in receipt DB
    Receipt receiptData = Receipt(
        id: -1,
        title: 'New Receipt',
        photo: widget.imagePath,
        date: DateTime.now().millisecondsSinceEpoch,
        price: 0);

    int trueId = await db.insertReceipt(receiptData);
    receiptData.id = trueId;

    // parse the text from the image
    List<String> receiptList =
        await processImage(InputImage.fromFile(thresholdFile));

    List<String> itemList = [];
    List<double> priceList = [];

    // divide receiptList to itemList and priceList
    for (var i = 0; i < receiptList.length; i++) {
      if (isNumeric(receiptList[i])) {
        priceList.add(double.parse(receiptList[i]));
      } else {
        // treat numbers with comma separator as prices and replace , with .
        if (RegExp(r"^[0-9]+,[0-9]+$").hasMatch(receiptList[i])) {
          priceList.add(double.parse(receiptList[i].replaceAll(',', '.')));
        }

        // skip quantity
        if (RegExp(r".* @ .*").hasMatch(receiptList[i]) ||
            RegExp(r".*[0-9].* X .*[0-9].*").hasMatch(receiptList[i])) continue;

        itemList.add(removeDiacritics(receiptList[i]));
      }
    }

    // insert itemList priceList pairs
    for (var i = 0; i < itemList.length; i++) {
      await db.insertItem(Item(
          id: -1,
          name: '',
          abbreviation: itemList[i],
          price: i < priceList.length ? priceList[i] : 0.0,
          receipt_id: trueId));
    }

    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ReceiptDetailPage(data: receiptData, isNewReceipt: true)));
  }

  String? _text;

  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<String>> processImage(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);
    _text = 'Recognized text:\n\n${recognizedText.text}';
    print(_text);

    List<String> itemList = [];

    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      // print(rect.toString());
      // print(cornerPoints.toString());
      // print(text);
      // print('NEXT');

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        print(line.text);
        print('NEXT');
        itemList.add(line.text);
        // for (TextElement element in line.elements) {
        //   // Same getters as TextBlock
        // }
      }
    }
    return itemList;
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
                            color: AppColor.whiteSoft,
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
                          Navigator.of(context).pop();
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
                                color: AppColor.whiteSoft,
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
                                  color: AppColor.whiteSoft,
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
