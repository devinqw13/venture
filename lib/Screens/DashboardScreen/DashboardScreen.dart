import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:venture/Controllers/ThemeController.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HomeController _homeController = Get.find();
  final ThemesController _themesController = Get.find();

  @override
  void initState() {
    super.initState();

  }

  Widget _bottomAppBarItem({icon, page}) {
    return ZoomTapAnimation(
      onTap: () => _homeController.goToTab(page),
      child: Icon(icon, color: _homeController.currentPage == page ? primaryOrange : Colors.grey, size: 27,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            extendBody: true,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: FloatingActionButton(
                backgroundColor: primaryOrange,
                onPressed: () => _homeController.goToTab(2),
                child: const Icon(IconlyBroken.location, color: Colors.white, size: 33,),
              )
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Container(
              color: Colors.transparent,
              child: BottomAppBar(
                elevation: 1.0,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _bottomAppBarItem(icon: IconlyBroken.home, page: 0),
                      _bottomAppBarItem(icon: IconlyBroken.search, page: 1),
                      const SizedBox.shrink(),
                      _bottomAppBarItem(icon: IconlyBroken.more_circle, page: 3),
                      _bottomAppBarItem(icon: IconlyBroken.profile, page: 4)
                    ],
                  ))
                )
              )
            ),
            body: PageView(
              controller: _homeController.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ..._homeController.pages
              ],
            )
          )
        ]
      ),
    );
  }
}