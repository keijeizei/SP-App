import 'package:flutter/material.dart';
import 'package:sp_app/views/utils/AppColor.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;

  CustomAppBar({required this.title});

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      brightness: Brightness.dark,
      backgroundColor: AppColor.primary,
      title: title,
      elevation: 0,
      // actions: [
      //   Visibility(
      //     visible: showProfilePhoto,
      //     child: Container(
      //       margin: EdgeInsets.only(right: 16),
      //       alignment: Alignment.center,
      //       child: IconButton(
      //         onPressed: profilePhotoOnPressed,
      //         icon: Container(
      //           width: 32,
      //           height: 32,
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(100),
      //             color: Colors.white,
      //             image: DecorationImage(image: profilePhoto, fit: BoxFit.cover),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }
}
