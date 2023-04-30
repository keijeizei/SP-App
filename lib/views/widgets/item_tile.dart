import 'package:flutter/material.dart';
import 'package:amethyst/models/core/receipt.dart';

class ItemTile extends StatelessWidget {
  final Item data;
  final Function() onEdit;
  final Function() onDelete;
  ItemTile({required this.data, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
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
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '₱${data.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'inter',
                        color: Colors.black),
                  ),
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.more_vert,
                  //     color: Colors.grey[800],
                  //   ),
                  //   splashRadius: 16,
                  //   iconSize: 16,
                  //   onPressed: () {},
                  // )
                  PopupMenuButton<void Function()>(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: onEdit,
                          child: const Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: onDelete,
                          child: const Text('Delete'),
                        ),
                      ];
                    },
                    onSelected: (fn) => fn(),
                  )
                ],
              )),
          // Container(child: )
        ],
      ),
    );
  }
}
