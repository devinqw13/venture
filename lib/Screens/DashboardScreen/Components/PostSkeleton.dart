import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class PostSkeleton extends StatelessWidget {
  PostSkeleton({Key? key}) : super(key: key);

  // final ThemesController _themesController = Get.find();

  Widget _buildHeaderDetails(BuildContext context) {
    return Row(
      children: [
        Skeleton.circular(
          width: 60,
          height: 60
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton.rectangular(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.6
            ),
            SizedBox(height: 5),
            Skeleton.rectangular(
              height: 15,
              width: MediaQuery.of(context).size.width * 0.3
            )
          ],
        )
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Skeleton.rectangular(
      height: 250,
      borderRadius: 20.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.1)
        )
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderDetails(context),
            SizedBox(height: 10),
            _buildContent(context)
            // ListTile(
            //   // dense: true,
            //   horizontalTitleGap: 0,
            //   contentPadding: EdgeInsets.symmetric(horizontal: 0),
            //   leading: Skeleton.circular(
            //     width: 100,
            //     height: 100
            //   ),
            //   title: Container(
            //     color: Colors.red,
            //     height: 20
            //   ),
            //   subtitle: Skeleton.rectangular(
            //     height: 15,
            //     width: 100
            //   ),
            // )
          ],
        )
      )
    );
  }
}