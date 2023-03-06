import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sp_app/models/core/receipt.dart';
import 'package:sp_app/views/screens/receipt_detail_page.dart';
import 'package:sp_app/views/utils/AppColor.dart';
import 'package:sp_app/views/utils/datetime_converter.dart';

class ReceiptTile extends StatelessWidget {
  final Receipt data;
  final Function() refreshDB;
  ReceiptTile({required this.data, required this.refreshDB});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => ReceiptDetailPage(data: data)))
            .then((_) => refreshDB());
      },
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.whiteSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Receipt Photo
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.blueGrey,
                image: DecorationImage(
                    image: FileImage(File(data.photo)), fit: BoxFit.cover),
              ),
            ),
            // Receipt Info
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt title
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        data.title,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontFamily: 'inter'),
                      ),
                    ),
                    // Receipt Calories and Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.black, size: 12),
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: Text(
                            intToDate(data.date),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SvgPicture.asset(
                          'assets/icons/peso.svg',
                          color: Colors.black,
                          width: 10,
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: Text(
                            data.price.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: Text(
                            data.id.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
