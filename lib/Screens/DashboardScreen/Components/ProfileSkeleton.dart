import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:get/get.dart';

class ProfileSkeleton extends StatelessWidget {
  ProfileSkeleton({Key? key}) : super(key: key);

  final ThemesController _themesController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      physics: ClampingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: false,
          expandedHeight: MediaQuery.of(context).size.height * 0.12,
          flexibleSpace: Stack(
            children: [
              Positioned(
                child: Container(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.white.withOpacity(0.3),
                        child: Skeleton.rectangular(height: MediaQuery.of(context).size.height * 0.12),
                      )
                    )
                  )
                ),
                top: 0,
                left: 0,
                right: 0,
                bottom: 0
              ),
              Positioned(
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: _themesController.getContainerBgColor(),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
                bottom: -1,
                left: 0,
                right: 0,
              ),
              Center(
                child: Skeleton.circular(height: MediaQuery.of(context).size.height * 1, seconds: 3),
              )
            ],
          )
        ),
        SliverToBoxAdapter(
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              // NAME
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Skeleton.rectangular(height: MediaQuery.of(context).size.height * 0.03, width: MediaQuery.of(context).size.width * 0.7)
                )
              ),
              // LOCATION
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 20.0),
                  child: Skeleton.rectangular(height: MediaQuery.of(context).size.height * 0.023, width: MediaQuery.of(context).size.width * 0.5, seconds: 3),
                )
              ),
            ],
          )
        )
        // SliverFixedExtentList(
        //   itemExtent: 50.0,
        //   delegate: SliverChildBuilderDelegate(
        //     (BuildContext context, int index) {
        //       return Container(
        //         alignment: Alignment.center,
        //         color: Colors.lightBlue[100 * (index + 1 % 9)],
        //         child: Text('List Item $index'),
        //       );
        //     },
        //   ),
        // )
      ],
    );
  }
}