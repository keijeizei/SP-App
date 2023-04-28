import 'package:flutter/material.dart';

class AppColor {
  static Color primary = const Color(0xFF5d2b8f);
  static Color primarySoft = const Color(0xff853dcc);
  static Color primaryExtraSoft = const Color.fromARGB(255, 244, 238, 244);
  static Color secondary = const Color.fromARGB(255, 240, 166, 251);
  static Color whiteSoft = const Color(0xFFF8F8F8);
  static LinearGradient bottomShadow = LinearGradient(colors: [
    const Color(0xFF5d2b8f).withOpacity(0.2),
    const Color(0xFF5d2b8f).withOpacity(0)
  ], begin: Alignment.bottomCenter, end: Alignment.topCenter);
  static LinearGradient linearBlackBottom = LinearGradient(
      colors: [Colors.black.withOpacity(0.45), Colors.black.withOpacity(0)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter);
  static LinearGradient linearBlackTop = LinearGradient(
      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);
}
