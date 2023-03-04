import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sp_app/models/core/receipt.dart';
import 'package:sp_app/views/screens/full_screen_image.dart';
import 'package:sp_app/views/utils/AppColor.dart';
import 'package:sp_app/views/widgets/item_tile.dart';
import '../../models/helper/db_helper.dart';
import '../utils/datetime_converter.dart';

class ReceiptDetailPage extends StatefulWidget {
  final Receipt data;
  ReceiptDetailPage({required this.data});

  @override
  _ReceiptDetailPageState createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;

  late final TextEditingController _titleController =
      TextEditingController(text: widget.data.title);
  late final TextEditingController _itemNameController =
      TextEditingController();
  late final TextEditingController _abbreviationController =
      TextEditingController(); // for adding new items only
  late final TextEditingController _priceController = TextEditingController();

  late Future<List<Item>> itemList;

  late double _totalPrice;

  DBHelper db = DBHelper();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      changeAppBarColor(_scrollController);
    });

    _totalPrice = widget.data.price;

    // db.insertItem(Item(
    //     id: -1,
    //     name: 'Itlog69',
    //     abbreviation: 'ITLG69',
    //     price: 124.36,
    //     receipt_id: 1));

    refreshDB();
  }

  void refreshDB() async {
    setState(() {
      itemList = db.getItems(widget.data.id);
    });
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
    });
  }

  Color appBarColor = Colors.transparent;

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

  // Rename the receipt
  showRenameDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Rename receipt'),
            content: Container(
                width: MediaQuery.of(context).size.width,
                height: 64,
                color: Colors.white,
                child: Column(children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Receipt name',
                    ),
                  ),
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
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        db.updateReceipt(Receipt(
                            id: widget.data.id,
                            title: _titleController.text,
                            photo: widget.data.photo,
                            date: widget.data.date,
                            price: widget.data.price));
                        Navigator.of(context).pop();
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

  // Delete the receipt
  showDeleteDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete receipt'),
            content: Container(
                width: MediaQuery.of(context).size.width,
                height: 64,
                color: Colors.white,
                child: Column(children: const [
                  Text('Are you sure you want to delete this receipt?'),
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
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        db.deleteReceipt(widget.data.id);
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      child: const Text('Delete'),
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
    _priceController.text = '';
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              body: AlertDialog(
                content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 280,
                        color: Colors.white,
                        child: Column(children: [
                          TextField(
                            controller: _abbreviationController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Receipt abbreviated name (optional)',
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                                text: 'Auto-fill full item name',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (_abbreviationController
                                        .text.isNotEmpty) {
                                      print(
                                          'http:// this is the api call ${_abbreviationController.text}');
                                    } else {
                                      showSnackbar(context,
                                          'Enter the abbreviated name from your receipt to auto-fill.');
                                    }
                                  }),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _itemNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Item name',
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                                text: 'Search this item on Google Images',
                                style: const TextStyle(
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print(
                                        'http://images.google.com/images?um=1&hl=en&safe=active&nfpr=1&q=${_itemNameController.text}');
                                  }),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Price',
                            ),
                          ),
                        ]))),
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
                            foregroundColor: Colors.grey[600],
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            db.insertItem(Item(
                                id: -1,
                                name: _itemNameController.text,
                                abbreviation: _abbreviationController.text,
                                price: double.parse(_priceController.text),
                                receipt_id: receipt_id));
                            recalculateTotal();
                            refreshDB();
                            Navigator.of(context).pop();
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
    if (data != null) {
      _itemNameController.text = data.name;
      _priceController.text = data.price.toString();
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    color: Colors.white,
                    child: Column(children: [
                      TextField(
                        controller:
                            TextEditingController(text: data.abbreviation),
                        enabled: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Detected receipt name',
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _itemNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Item name',
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                            text: 'Search this item on Google Images',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                print(
                                    'http://images.google.com/images?um=1&hl=en&safe=active&nfpr=1&q=${_itemNameController.text}');
                              }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Price',
                        ),
                      ),
                    ]))),
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
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: TextButton(
                      onPressed: () {
                        db.deleteItem(data.id);
                        recalculateTotal();
                        refreshDB();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[600],
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await db.updateItem(Item(
                            id: data.id,
                            name: _itemNameController.text,
                            abbreviation: data.abbreviation,
                            price: double.parse(_priceController.text),
                            receipt_id: data.receipt_id));
                        recalculateTotal();
                        refreshDB();
                        Navigator.of(context).pop();
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
          );
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
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    showDeleteDialog(context);
                  },
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
                // Receipt Calories and Time
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
                    const SizedBox(width: 10),
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
                        _totalPrice.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                // Receipt Title
                Container(
                  margin: const EdgeInsets.only(bottom: 12, top: 16),
                  child: Row(children: [
                    Text(
                      _titleController.text,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'inter'),
                    ),
                    IconButton(
                        onPressed: () {
                          showRenameDialog(context);
                        },
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 16)),
                  ]),
                ),
                // Receipt Description
                Text(
                  "Click an item to edit.",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 150 / 100),
                ),
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
          // TODO: fix data.items by querying the items from db, .items has been removed from Receipt model
          FutureBuilder(
              future: itemList,
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
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
                          ));
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
