import 'package:flutter/material.dart';
import 'package:sp_app/views/utils/AppColor.dart';

class SearchFilterModal extends StatefulWidget {
  final int sortMode;
  final Function(int) updateSortMode;
  const SearchFilterModal(
      {super.key, required this.sortMode, required this.updateSortMode});

  @override
  State<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends State<SearchFilterModal> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        // Section 1 - Header
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: AppColor.primaryExtraSoft,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 60,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      const Text('Reset', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const Text(
                'Sort by',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 60,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
        // Sort By Option
        Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          child: GestureDetector(
              onTap: () {
                widget.updateSortMode(0);
                Navigator.of(context).pop();
              },
              child: ListTileTheme(
                selectedColor: AppColor.primary,
                textColor: Colors.grey,
                child: ListTile(
                  selected: widget.sortMode == 0,
                  title: const Text('Newest first',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              )),
        ),
        // Sort By Option
        Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          child: GestureDetector(
              onTap: () {
                widget.updateSortMode(1);
                Navigator.of(context).pop();
              },
              child: ListTileTheme(
                selectedColor: AppColor.primary,
                textColor: Colors.grey,
                child: ListTile(
                  selected: widget.sortMode == 1,
                  title: const Text('Oldest first',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              )),
        ),
        // Sort By Option
        Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          child: GestureDetector(
              onTap: () {
                widget.updateSortMode(2);
                Navigator.of(context).pop();
              },
              child: ListTileTheme(
                selectedColor: AppColor.primary,
                textColor: Colors.grey,
                child: ListTile(
                  selected: widget.sortMode == 2,
                  title: const Text('Cheapest first',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              )),
        ),
        // Sort By Option
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: GestureDetector(
                onTap: () {
                  widget.updateSortMode(1);
                  Navigator.of(context).pop();
                },
                child: ListTileTheme(
                  selectedColor: AppColor.primary,
                  textColor: Colors.grey,
                  child: ListTile(
                    selected: widget.sortMode == 3,
                    title: const Text('Most expensive first',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                ))),
      ],
    );
  }
}
