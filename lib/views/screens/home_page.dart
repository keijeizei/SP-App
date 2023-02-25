import 'package:flutter/material.dart';
import 'package:sp_app/models/core/receipt.dart';
import 'package:sp_app/models/helper/receipt_helper.dart';
import 'package:sp_app/views/screens/search_page.dart';
import 'package:sp_app/views/utils/AppColor.dart';
import 'package:sp_app/views/widgets/custom_app_bar.dart';
import 'package:sp_app/views/widgets/dummy_search_bar.dart';
import 'package:sp_app/views/widgets/receipt_tile.dart';

class HomePage extends StatelessWidget {
  List<Receipt> bookmarkedReceipt = ReceiptHelper.bookmarkedReceipt;

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
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      // height: 220,
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bookmarkedReceipt.length,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 16);
                        },
                        itemBuilder: (context, index) {
                          return ReceiptTile(
                            data: bookmarkedReceipt[index],
                          );
                        },
                      ),
                    ),
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
