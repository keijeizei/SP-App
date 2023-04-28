import 'package:flutter/material.dart';
import 'package:amethyst/models/core/receipt.dart';

class ItemTile extends StatelessWidget {
  final Item data;
  ItemTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // don't show name or abbreviation if they are empty
                children: data.name.isEmpty
                    ? [
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              data.abbreviation,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 150 / 100),
                            )),
                      ]
                    : data.abbreviation.isEmpty
                        ? [
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  data.name,
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 150 / 100),
                                ))
                          ]
                        : [
                            Text(
                              data.name,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 150 / 100),
                            ),
                            Text(
                              data.abbreviation,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w200,
                                  height: 150 / 100),
                            ),
                          ],
              )),
          Flexible(
            flex: 3,
            child: Text(
              '₱${data.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'inter',
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
