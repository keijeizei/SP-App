import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sp_app/models/core/receipt.dart';
import 'package:sp_app/models/helper/receipt_helper.dart';
import 'package:sp_app/views/screens/receipt_detail_page.dart';
import 'package:sp_app/views/screens/search_page.dart';
import 'package:sp_app/views/utils/AppColor.dart';
import 'package:sp_app/views/widgets/custom_app_bar.dart';
import 'package:sp_app/views/widgets/dummy_search_bar.dart';
import 'package:sp_app/views/widgets/receipt_tile.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/helper/db_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<Receipt> bookmarkedReceipt = ReceiptHelper.bookmarkedReceipt;

  DBHelper db = DBHelper();

  late Future<List<Receipt>> savedReceipt;

  @override
  void initState() {
    super.initState();
    refreshDB();
  }

  void refreshDB() {
    setState(() {
      savedReceipt = db.getReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('SP',
            style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          // Section 1 - Featured Receipt - Wrapper
          Container(
            // height: 350,
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  height: 245,
                  color: AppColor.primary,
                ),
                // Section 1 - Content
                Column(
                  children: [
                    // Search Bar
                    DummySearchBar(),
                    // Header
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Saved Receipts',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'inter'),
                          ),
                        ],
                      ),
                    ),
                    // ListView
                    // Container(
                    //   margin: const EdgeInsets.only(top: 4),
                    //   // height: 220,
                    //   child: ListView.separated(
                    //     shrinkWrap: true,
                    //     padding: const EdgeInsets.symmetric(horizontal: 16),
                    //     itemCount: bookmarkedReceipt.length,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     separatorBuilder: (context, index) {
                    //       return const SizedBox(height: 16);
                    //     },
                    //     itemBuilder: (context, index) {
                    //       return ReceiptTile(
                    //         data: bookmarkedReceipt[index],
                    //       );
                    //     },
                    //   ),
                    // ),
                    FutureBuilder(
                        future: savedReceipt,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return Container(
                              margin: const EdgeInsets.only(top: 4),
                              // height: 220,
                              child: snapshot.data.isEmpty
                                  ? Column(children: [
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      const Text(
                                        'No saved receipts',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'inter'),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "Add a receipt by clicking the ",
                                            ),
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            TextSpan(
                                              text: " button.",
                                            ),
                                          ],
                                        ),
                                      )
                                    ])
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      itemCount: snapshot.data.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(height: 16);
                                      },
                                      itemBuilder: (context, index) {
                                        return ReceiptTile(
                                          data: snapshot.data[index],
                                          refreshDB: refreshDB,
                                        );
                                      },
                                    ),
                            );
                          }
                        })
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
