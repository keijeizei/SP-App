import 'package:flutter/material.dart';
import 'package:amethyst/views/utils/AppColor.dart';

// ignore: must_be_immutable
class CustomBottomNavigationBar extends StatefulWidget {
  int selectedIndex;
  Function onItemTapped;
  CustomBottomNavigationBar(
      {required this.selectedIndex, required this.onItemTapped});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 80, right: 80, bottom: 20),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            currentIndex: widget.selectedIndex,
            onTap: (int x) => widget.onItemTapped(x),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: [
              (widget.selectedIndex == 0)
                  ? BottomNavigationBarItem(
                      icon:
                          Icon(Icons.receipt_rounded, color: AppColor.primary),
                      label: '')
                  : BottomNavigationBarItem(
                      icon:
                          Icon(Icons.receipt_outlined, color: Colors.grey[600]),
                      label: ''),
              (widget.selectedIndex == 1)
                  ? BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt, color: AppColor.primary),
                      label: '')
                  : BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt_outlined,
                          color: Colors.grey[600]),
                      label: ''),
            ],
          ),
        ),
      ),
    );
  }
}
