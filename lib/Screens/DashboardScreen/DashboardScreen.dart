import 'package:flutter/material.dart';
import 'package:venture/Globals.dart' as globals;
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HomeController _homeController = Get.find();
  final ThemesController _themesController = Get.find();
  bool extendBody = true;

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  checkUserStatus() {
    print(globals.userDisabled);
  }

  Widget _bottomAppBarItem({icon, page, double? iconSize}) {
    if(icon.runtimeType == String) {
      icon = SvgPicture.asset(
        icon,
        height: iconSize,
        color: _homeController.currentPage == page ? primaryOrange : Get.isDarkMode ? Colors.white : Colors.grey
      );
    } else {
      icon = Icon(icon, color: _homeController.currentPage == page ? primaryOrange : Get.isDarkMode ? Colors.white : Colors.grey, size: iconSize);
    }
    return ZoomTapAnimation(
      onTap: () {
        if(_homeController.currentPage.value == 0 && page == 0) {
          _homeController.homeFeedController?.animateToPage(
            0, 
            curve: Curves.decelerate,
            duration: Duration(milliseconds: 300)
          );
        }
        _homeController.goToTab(page);
        setState(() => extendBody = page == 2 ? true : false);
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: icon
      )
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
            extendBody: extendBody,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 20),
              child: FloatingActionButton(
                isExtended: true,
                elevation: 0.0,
                backgroundColor: primaryOrange,
                onPressed: () {
                  _homeController.goToTab(2);
                  setState(() => extendBody = true);
                },
                // child: const Icon(IconlyBroken.location, color: Colors.white, size: 25,),
                child: SvgPicture.asset(
                  'assets/icons/location.svg',
                  height: 25,
                  color: Colors.white
                )
              )
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Container(
              color: Colors.transparent,
              child: BottomAppBar(
                elevation: 1.0,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(left: 23, right: 23, top: 4),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _bottomAppBarItem(
                        icon: 'assets/icons/home.svg',
                        page: 0,
                        iconSize: 27
                      ),
                      _bottomAppBarItem(
                        icon: 'assets/icons/search4.svg',
                        page: 1,
                        iconSize: 28
                      ),
                      const SizedBox.shrink(),
                      _bottomAppBarItem(
                        icon: 'assets/icons/notification2.svg',
                        page: 3,
                        iconSize: 30
                      ),
                      _bottomAppBarItem(
                        icon: 'assets/icons/avatar.svg',
                        page: 4,
                        iconSize: 27
                      )
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