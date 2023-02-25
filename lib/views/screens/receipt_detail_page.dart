import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sp_app/models/core/receipt.dart';
import 'package:sp_app/views/screens/full_screen_image.dart';
import 'package:sp_app/views/utils/AppColor.dart';
import 'package:sp_app/views/widgets/item_tile.dart';
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

  late final TextEditingController _itemNameController =
      TextEditingController();
  late final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      changeAppBarColor(_scrollController);
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

  // fab to write review
  showFAB(TabController tabController) {
    int reviewTabIndex = 2;
    if (tabController.index == reviewTabIndex) {
      return true;
    }
    return false;
  }

  showSaveDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Save receipt'),
            content: Container(
                width: MediaQuery.of(context).size.width,
                height: 64,
                color: Colors.white,
                child: Column(children: const [
                  TextField(
                    decoration: InputDecoration(
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  showEditDialog(context, data) {
    if (data != null) {
      _itemNameController.text = data.name;
      _priceController.text = data.price;
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
                width: MediaQuery.of(context).size.width,
                height: 160,
                color: Colors.white,
                child: Column(children: [
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
                                'http://images.google.com/images?um=1&hl=en&safe=active&nfpr=1&q=your_search_query');
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
                      onPressed: () {},
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
                    showSaveDialog(context);
                  },
                  icon:
                      const Icon(Icons.save_alt_rounded, color: Colors.white)),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
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
                      image:
                          Image.asset(widget.data.photo, fit: BoxFit.cover))));
            },
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(widget.data.photo), fit: BoxFit.cover)),
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
                        widget.data.price.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                // Receipt Title
                Container(
                  margin: const EdgeInsets.only(bottom: 12, top: 16),
                  child: Text(
                    widget.data.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter'),
                  ),
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
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: widget.data.items.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var data = widget.data.items[index];
              return GestureDetector(
                  onTap: () {
                    showEditDialog(context, data);
                  },
                  child: ItemTile(
                    data: data,
                  ));
            },
          ),
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
