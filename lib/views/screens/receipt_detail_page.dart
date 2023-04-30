import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amethyst/models/core/receipt.dart';
import 'package:amethyst/views/screens/full_screen_image.dart';
import 'package:amethyst/views/utils/AppColor.dart';
import 'package:amethyst/views/utils/api.dart';
import 'package:amethyst/views/widgets/item_tile.dart';
import '../../models/helper/db_helper.dart';
import '../utils/datetime_converter.dart';
import '../utils/misc_utils.dart';

class ReceiptDetailPage extends StatefulWidget {
  final Receipt data;
  final bool isNewReceipt;
  ReceiptDetailPage({required this.data, required this.isNewReceipt});

  @override
  _ReceiptDetailPageState createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage>
    with TickerProviderStateMixin {
  int MAX_ABBR_LENGTH = 38;

  late ScrollController _scrollController;

  late final TextEditingController _titleController =
      TextEditingController(text: widget.data.title);
  late final TextEditingController _itemNameController =
      TextEditingController();
  late final TextEditingController _abbreviationController =
      TextEditingController(); // for adding new items only
  late final TextEditingController _priceController = TextEditingController();

  List<List<String>> suggestionsTable = [[]];

  final _formKey = GlobalKey<FormState>();

  Color appBarColor = Colors.transparent;

  late Future<List<Item>> itemList;
  late double _totalPrice;
  int _itemCount = 0;

  int cursorWordPosition = 0;

  bool shouldFetchSuggestionsFromDB =
      true; // tells if suggestions should be fetched from db or from suggestions table variable

  DBHelper db = DBHelper();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      changeAppBarColor(_scrollController);
    });

    _totalPrice = widget.data.price;

    recalculateTotal();
    refreshDB();

    // expand all items if receipt is newly-captured
    if (widget.isNewReceipt) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => showDecodingModal(this.context));

      expandAllItems(this.context);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _itemNameController.dispose();
    _abbreviationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ==================================================== DATABASE RELATED ===================================================

  void refreshDB() async {
    if (mounted) {
      setState(() {
        itemList = db.getItems(widget.data.id);
      });
    }
  }

  Future<void> recalculateTotal() async {
    List<Item> presentItemList = await db.getItems(widget.data.id);
    double totalPrice = presentItemList.fold(0, (p, c) => p + c.price);

    db.updateReceipt(Receipt(
        id: widget.data.id,
        title: widget.data.title,
        photo: widget.data.photo,
        date: widget.data.date,
        price: totalPrice));

    setState(() {
      _totalPrice = totalPrice;
      _itemCount = presentItemList.length;
    });
  }

  // fetch the suggestions table given an item id (used in edit item dialog when showing the suggestions)
  Future<List<List<String>>> fetchSuggestionsTable(int item_id) async {
    if (shouldFetchSuggestionsFromDB) {
      List<Suggestion> suggestions = await db.getSuggestions(item_id);

      List<dynamic> decodedSuggestionsTable = jsonDecode(
          suggestions[0].word); // suggestion is the first result in the db

      suggestionsTable = rotateSuggestions(decodedSuggestionsTable);
    }

    return suggestionsTable;
  }

  // ==================================================== EXPANSION RELATED ===================================================

  // Expands an abbr using LSTM and KNN. This function is for the 'auto-fill' button
  Future<String> expandName(context, String abbreviation) async {
    // KNN
    Response response = await expandItemNameAPI(abbreviation, false);

    if (!response.success) {
      showSnackbar(context,
          'Abbreviation decoding failed. Please check your internet connection.');
      return '';
    }

    List<List<String>> table = rotateSuggestions(response.data);

    suggestionsTable = table;

    String name = '';
    List<dynamic> result = response.data;

    for (var i = 0; i < result.length; i++) {
      name += result[i][0] + ' ';
    }

    shouldFetchSuggestionsFromDB = false;

    // LSTM
    response = await expandItemNameAPI(abbreviation, true);

    if (!response.success) {
      showSnackbar(context,
          'Abbreviation decoding failed. Please check your internet connection.');
      return '';
    }

    // use LSTM only if LSTM model is confident (output is not '')
    if (response.data[0] != '') {
      name = response.data[0];
    }

    return name;
  }

  Future<bool> expandItemLSTM(Item item, context) async {
    Response response = await expandItemNameAPI(item.abbreviation, true);

    if (!response.success) {
      showSnackbar(context,
          'Abbreviation decoding failed. Please check your internet connection.');
      return false;
    }

    String name = response.data[0];

    // name will be empty if LSTM is not confident enough, in that case, do not update the name
    if (name != '') {
      await db.updateItem(Item(
          id: item.id,
          name: name,
          abbreviation: item.abbreviation,
          price: item.price,
          receipt_id: widget.data.id));
      refreshDB();
    }

    return true;
  }

  Future<bool> expandItemKNN(Item item, context) async {
    Response response = await expandItemNameAPI(item.abbreviation, false);

    if (!response.success) {
      showSnackbar(context,
          'Abbreviation decoding failed. Please check your internet connection.');
      return false;
    }

    String name = '';
    List<dynamic> result = response.data;

    for (var i = 0; i < result.length; i++) {
      name += result[i][0] + ' ';
    }

    await db.updateItem(Item(
        id: item.id,
        name: name,
        abbreviation: item.abbreviation,
        price: item.price,
        receipt_id: widget.data.id));

    String jsonSuggestions = jsonEncode(response.data);

    await db.deleteSuggestionsByItem(item.id);

    db.insertSuggestion(Suggestion(
        id: -1,
        receipt_id: item.receipt_id,
        item_id: item.id,
        word: jsonSuggestions));

    refreshDB();

    return true;

    // List<String> nameList = [];
    // for (var j = 0; j < response.data.length; j++) {
    //   nameList.add(response.data[j][0][1]);
    // }

    // String name = nameList.join(' ');

    // db.updateItem(Item(
    //     id: item.id,
    //     name: name,
    //     abbreviation: item.abbreviation,
    //     price: item.price,
    //     receipt_id: widget.data.id));
    // refreshDB();
  }

  int currentStep = 0;
  Timer? udpateNotificationAfter1Second;

  // expand all items and shows a progress bar notification
  Future<void> expandAllItems(context) async {
    int id = 1;
    List<Item> presentItemList = await db.getItems(widget.data.id);
    // KNN and LSTM runs alternately
    int maxStep = presentItemList.length * 2;

    // simulatedStep goes from 1 to itemlist * 2 + 1, currentStep goes from 1 to itemlist
    for (var simulatedStep = 1; simulatedStep <= maxStep + 1; simulatedStep++) {
      currentStep = (simulatedStep + 1) ~/ 2;

      String itemName;
      if (simulatedStep <= maxStep) {
        itemName = presentItemList[currentStep - 1].abbreviation;
      } else {
        itemName = '';
      }

      bool success = false;
      if (simulatedStep <= maxStep) {
        if (simulatedStep % 2 == 0) {
          success =
              await expandItemLSTM(presentItemList[currentStep - 1], context);
        } else {
          success =
              await expandItemKNN(presentItemList[currentStep - 1], context);
        }
      }

      if (!success) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: id,
                channelKey: 'basic_channel',
                title: 'Receipt decoding failed',
                body: 'Please check your internet connection.',
                category: NotificationCategory.Progress,
                locked: false));
        return;
      }

      if (udpateNotificationAfter1Second != null) continue;

      udpateNotificationAfter1Second = Timer(const Duration(seconds: 1), () {
        _updateCurrentProgressBar(
            id: id,
            simulatedStep: simulatedStep,
            maxStep: maxStep,
            length: presentItemList.length,
            itemName: itemName);
        udpateNotificationAfter1Second?.cancel();
        udpateNotificationAfter1Second = null;
      });
    }
  }

  void _updateCurrentProgressBar(
      {required int id,
      required int simulatedStep,
      required int maxStep,
      required int length,
      required String itemName}) {
    if (simulatedStep >= maxStep) {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: id,
              channelKey: 'basic_channel',
              title: 'Receipt decoding finished',
              body: 'All items in your receipt have been decoded.',
              category: NotificationCategory.Progress,
              locked: false));
    } else {
      int progress = min((simulatedStep / maxStep * 100).round(), 100);
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: id,
              channelKey: 'basic_channel',
              title: 'Decoding your receipt... ($currentStep/$length)',
              body: itemName,
              category: NotificationCategory.Progress,
              notificationLayout: NotificationLayout.ProgressBar,
              progress: progress,
              locked: true));
    }
  }

  // ==================================================== TYPE-AHEAD RELATED ===================================================

  Widget typeAheadItemBuilder(context, suggestion) {
    // determine which word the cursor is positioned
    cursorWordPosition = 0;
    for (var i = 0; i < _itemNameController.selection.baseOffset; i++) {
      if (_itemNameController.text[i] == ' ') {
        cursorWordPosition++;
      }
    }

    if (cursorWordPosition < suggestion.length) {
      return ListTile(title: Text(suggestion[cursorWordPosition]));
    }
    return const SizedBox();
  }

  void onSuggestionSelected(suggestion) {
    String startWords = '';
    String endWords = '';
    String buffer = '';

    // collect the words before the word where the cursor is
    for (var i = 0; i < _itemNameController.selection.baseOffset; i++) {
      if (_itemNameController.text[i] == ' ') {
        startWords = '$startWords$buffer';
        buffer = ' ';
      } else {
        buffer += _itemNameController.text[i];
      }
    }
    if (startWords.isNotEmpty) {
      startWords += ' ';
    }

    // collect the words after the word where the cursor is
    buffer = '';
    bool bufferStart = false;
    for (var i = _itemNameController.selection.baseOffset;
        i < _itemNameController.text.length;
        i++) {
      if (!bufferStart && _itemNameController.text[i] == ' ') {
        bufferStart = true;
      } else if (bufferStart && _itemNameController.text[i] != ' ') {
        buffer += _itemNameController.text[i];
      } else if (bufferStart && _itemNameController.text[i] == ' ') {
        endWords = '$endWords$buffer';
        buffer = ' ';
      }
    }
    if (buffer != ' ') {
      endWords += buffer;
    }

    _itemNameController.text =
        '$startWords${suggestion[cursorWordPosition]} $endWords';
  }

  // ==================================================== UI RELATED ===================================================

  String? _validateNames(String? value) {
    if (_itemNameController.text.isEmpty &&
        _abbreviationController.text.isEmpty) {
      return 'Either full name or abbreviated name required';
    }
    return null;
  }

  showLoading(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 10),
              SizedBox(
                height: 72,
                width: 72,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Decoding item abbreviation,\nplease wait...",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  changeAppBarColor(ScrollController scrollController) {
    if (scrollController.position.hasPixels) {
      if (scrollController.position.pixels > 2.0) {
        setState(() {
          appBarColor = AppColor.primary;
        });
      }
      if (scrollController.position.pixels <= 2.0) {
        setState(() {
          appBarColor = Colors.transparent;
        });
      }
    } else {
      setState(() {
        appBarColor = Colors.transparent;
      });
    }
  }

  showSnackbar(context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }

  showDecodingModal(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showDecodingTooltip = prefs.getBool('showDecodingTooltip') ?? true;

    return showDecodingTooltip
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Text(''),
                content: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child:
                        Column(mainAxisSize: MainAxisSize.min, children: const [
                      Text(
                          'Decoding your receipt abbreviations in the background. Do not close the app and allow about a minute while we update your receipt names.')
                    ])),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          prefs.setBool('showDecodingTooltip', false);
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.primary,
                        ),
                        child: const Text("DON'T SHOW AGAIN"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.primary,
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                  )
                ],
              );
            })
        : null;
  }

  // Delete a receipt/item
  showDeleteModal(context, String deletable, deleteFunction) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete $deletable'),
            content: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Are you sure you want to delete this $deletable?')
                ])),
            actions: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColor.primary,
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: deleteFunction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      child: const Text('DELETE'),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  // Rename the receipt
  showRenameDialog(context) {
    String originalName = _titleController.text;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Rename receipt'),
            content: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Form(
                    key: _formKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                          child: TextFormField(
                        controller: _titleController,
                        validator: validateText,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Receipt name',
                        ),
                      )),
                    ]))),
            actions: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextButton(
                      onPressed: () {
                        _titleController.text =
                            originalName; // reset controller value
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColor.primary,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          print(widget.data.id.toString());
                          print(_titleController.text);
                          db.updateReceipt(Receipt(
                              id: widget.data.id,
                              title: _titleController.text,
                              photo: widget.data.photo,
                              date: widget.data.date,
                              price: widget.data.price));
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      child: const Text('Rename'),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  // Add an item
  showAddDialog(context, receipt_id) {
    _itemNameController.text = '';
    _abbreviationController.text = '';
    _priceController.text = '';
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: AlertDialog(
                content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Form(
                        key: _formKey,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 306,
                            color: Colors.white,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _abbreviationController,
                                    validator: _validateNames,
                                    maxLength: MAX_ABBR_LENGTH,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText:
                                          'Abbreviated receipt name (optional)',
                                      counterText: '',
                                      counterStyle: TextStyle(fontSize: 0),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                        text: 'Auto-fill full item name',
                                        style:
                                            const TextStyle(color: Colors.blue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            if (_abbreviationController
                                                .text.isNotEmpty) {
                                              // Show the loading dialog
                                              showLoading(context);

                                              String name = await expandName(
                                                  context,
                                                  _abbreviationController.text);
                                              setState(() {
                                                if (name.isNotEmpty) {
                                                  _itemNameController.text =
                                                      name;
                                                }
                                              });

                                              // pop the loading dialog
                                              Navigator.of(context).pop();
                                            } else {
                                              showSnackbar(context,
                                                  'To use auto-fill, you must enter the abbreviated name from your receipt');
                                            }
                                          }),
                                  ),
                                  const SizedBox(height: 16),
                                  TypeAheadFormField(
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: _itemNameController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Item full name',
                                      ),
                                    ),
                                    suggestionsCallback: (pattern) {
                                      return suggestionsTable;
                                    },
                                    itemBuilder: typeAheadItemBuilder,
                                    transitionBuilder:
                                        (context, suggestionsBox, controller) {
                                      return suggestionsBox;
                                    },
                                    onSuggestionSelected: onSuggestionSelected,
                                    validator: _validateNames,
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                        text:
                                            'Search this item on Google Images',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            if (_itemNameController
                                                .text.isNotEmpty) {
                                              launchURL(
                                                  'http://images.google.com/images?um=1&hl=en&safe=active&nfpr=1&q=${_itemNameController.text}');
                                            } else {
                                              showSnackbar(context,
                                                  'Item name must not be empty.');
                                            }
                                          }),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _priceController,
                                    validator: validatePrice,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Price',
                                    ),
                                  ),
                                ])))),
                actions: [
                  Row(
                    children: [
                      SizedBox(
                        width: 160,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColor.primary,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              db.insertItem(Item(
                                  id: -1,
                                  name: _itemNameController.text,
                                  abbreviation: _abbreviationController.text,
                                  price: double.parse(_priceController.text),
                                  receipt_id: receipt_id));
                              recalculateTotal();
                              refreshDB();
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                          ),
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  )
                ],
              ));
        });
  }

  showEditDialog(context, data) {
    shouldFetchSuggestionsFromDB = true;

    if (data != null) {
      _abbreviationController.text = data.abbreviation;
      _itemNameController.text = data.name;
      _priceController.text = data.price.toStringAsFixed(2);
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: AlertDialog(
                content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Form(
                        key: _formKey,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 294,
                            color: Colors.white,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _abbreviationController,
                                    validator: _validateNames,
                                    maxLength: MAX_ABBR_LENGTH,
                                    // enabled: true,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Abbreviated receipt name',
                                      counterText: '',
                                      counterStyle: TextStyle(fontSize: 0),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                        text: 'Auto-fill full item name',
                                        style:
                                            const TextStyle(color: Colors.blue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            if (_abbreviationController
                                                .text.isNotEmpty) {
                                              // Show the loading dialog
                                              showLoading(context);

                                              String name = await expandName(
                                                  context,
                                                  _abbreviationController.text);
                                              setState(() {
                                                if (name.isNotEmpty) {
                                                  _itemNameController.text =
                                                      name;
                                                }
                                              });

                                              // pop the loading dialog
                                              Navigator.of(context).pop();
                                            } else {
                                              showSnackbar(context,
                                                  'To use auto-fill, you must enter the abbreviated name from your receipt');
                                            }
                                          }),
                                  ),
                                  const SizedBox(height: 16),
                                  TypeAheadFormField(
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: _itemNameController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Item full name',
                                      ),
                                    ),
                                    suggestionsCallback: (pattern) async {
                                      return await fetchSuggestionsTable(
                                          data.id);
                                    },
                                    itemBuilder: typeAheadItemBuilder,
                                    transitionBuilder:
                                        (context, suggestionsBox, controller) {
                                      return suggestionsBox;
                                    },
                                    onSuggestionSelected: onSuggestionSelected,
                                    validator: _validateNames,
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                        text:
                                            'Search this item on Google Images',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            if (_itemNameController
                                                .text.isNotEmpty) {
                                              launchURL(
                                                  'http://images.google.com/images?um=1&hl=en&safe=active&nfpr=1&q=${_itemNameController.text}');
                                            } else {
                                              showSnackbar(context,
                                                  'Item name must not be empty.');
                                            }
                                          }),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _priceController,
                                    validator: validatePrice,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Price',
                                    ),
                                  ),
                                ])))),
                actions: [
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColor.primary,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextButton(
                          onPressed: () => showDeleteModal(context, 'item', () {
                            db.deleteItem(data.id);
                            recalculateTotal();
                            refreshDB();

                            // pop the delete modal and the edit dialog
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 2);
                          }),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red[600],
                          ),
                          child: const Text('Delete'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              db.deleteSuggestionsByItem(data.id);

                              db.insertSuggestion(Suggestion(
                                  id: -1,
                                  receipt_id: data.receipt_id,
                                  item_id: data.id,
                                  word: convertSuggestionsForDB(
                                      suggestionsTable)));

                              await db.updateItem(Item(
                                  id: data.id,
                                  name: _itemNameController.text,
                                  abbreviation: _abbreviationController.text,
                                  price: double.parse(_priceController.text),
                                  receipt_id: data.receipt_id));
                              recalculateTotal();
                              refreshDB();
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                          ),
                          child: const Text('Edit'),
                        ),
                      ),
                    ],
                  )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AnimatedContainer(
          color: appBarColor,
          duration: const Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text('Receipt Detail',
                style: TextStyle(
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.popUntil(
                    context, (Route<dynamic> predicate) => predicate.isFirst);
              },
            ),
            actions: [
              IconButton(
                  onPressed: () => showDeleteModal(context, 'receipt', () {
                        File photo = File(widget.data.photo);
                        photo.delete();
                        db.deleteReceipt(widget.data.id);
                        Navigator.popUntil(context,
                            (Route<dynamic> predicate) => predicate.isFirst);
                      }),
                  icon: const Icon(Icons.delete, color: Colors.white)),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          onPressed: () {
            showAddDialog(context, widget.data.id);
          },
          backgroundColor: AppColor.primary,
          child: const Icon(Icons.add),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          // Section 1 - Receipt Image
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                      image: Image(
                          image: FileImage(File(widget.data.photo)),
                          fit: BoxFit.cover))));
            },
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(File(widget.data.photo)),
                      fit: BoxFit.cover)),
              child: Container(
                decoration: BoxDecoration(gradient: AppColor.linearBlackTop),
                height: 280,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          // Section 2 - Receipt Info
          Container(
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
            color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receipt Date and Price
                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        color: Colors.white, size: 16),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: Text(
                        intToDateTime(widget.data.date),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SvgPicture.asset(
                      'assets/icons/peso.svg',
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      width: 12,
                      height: 12,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: Text(
                        _totalPrice.toStringAsFixed(2),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.shopping_basket_outlined,
                        color: Colors.white, size: 16),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: Text(
                        _itemCount.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                // Receipt Title
                Container(
                  margin: const EdgeInsets.only(bottom: 0, top: 2),
                  child: Row(children: [
                    Flexible(
                        child: Text(
                      _titleController.text,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'inter'),
                    )),
                    IconButton(
                        onPressed: () {
                          showRenameDialog(context);
                        },
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 16)),
                  ]),
                ),
                // Receipt Description
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Click an item to edit. Click ",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 150 / 100),
                      ),
                      WidgetSpan(
                        child: Icon(
                          Icons.add,
                          size: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      TextSpan(
                        text: " to manually add an item.",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 150 / 100),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Tabbar ( Items, Tutorial, Reviews )
          // Container(
          //   height: 60,
          //   width: MediaQuery.of(context).size.width,
          //   color: AppColor.secondary,
          //   child: TabBar(
          //     controller: _tabController,
          //     onTap: (index) {
          //       setState(() {
          //         _tabController.index = index;
          //       });
          //     },
          //     labelColor: Colors.black,
          //     unselectedLabelColor: Colors.black.withOpacity(0.6),
          //     labelStyle:
          //         TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w500),
          //     indicatorColor: Colors.black,
          //     tabs: [
          //       Tab(
          //         text: 'Items',
          //       ),
          //       Tab(
          //         text: 'Tutorial',
          //       ),
          //       Tab(
          //         text: 'Reviews',
          //       ),
          //     ],
          //   ),
          // ),
          // IndexedStack based on TabBar index
          FutureBuilder(
              future: itemList,
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: snapshot.data.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var data = snapshot.data[index];
                      return GestureDetector(
                          onTap: () {
                            showEditDialog(context, data);
                          },
                          child: ItemTile(
                              data: data,
                              onEdit: () => showEditDialog(context, data),
                              onDelete: () =>
                                  showDeleteModal(context, 'item', () {
                                    db.deleteItem(data.id);
                                    recalculateTotal();
                                    refreshDB();

                                    Navigator.of(context).pop();
                                  })));
                    },
                  );
                }
              })

          // IndexedStack(
          //   index: _tabController.index,
          //   children: [
          //     // Items
          //     ListView.builder(
          //       shrinkWrap: true,
          //       padding: EdgeInsets.zero,
          //       itemCount: widget.data.items.length,
          //       physics: NeverScrollableScrollPhysics(),
          //       itemBuilder: (context, index) {
          //         return ItemTile(
          //           data: widget.data.items[index],
          //         );
          //       },
          //     ),
          //     // Tutorials
          //     ListView.builder(
          //       shrinkWrap: true,
          //       padding: EdgeInsets.zero,
          //       itemCount: widget.data.tutorial.length,
          //       physics: NeverScrollableScrollPhysics(),
          //       itemBuilder: (context, index) {
          //         return StepTile(
          //           data: widget.data.tutorial[index],
          //         );
          //       },
          //     ),
          //     // Reviews
          //     ListView.builder(
          //       shrinkWrap: true,
          //       padding: EdgeInsets.zero,
          //       itemCount: widget.data.reviews.length,
          //       physics: NeverScrollableScrollPhysics(),
          //       itemBuilder: (context, index) {
          //         return ReviewTile(data: widget.data.reviews[index]);
          //       },
          //     )
          //   ],
          // ),
        ],
      ),
    );
  }
}
