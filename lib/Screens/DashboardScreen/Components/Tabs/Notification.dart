import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/FadeOverlay.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Screens/LoginScreen/LoginScreen.dart';

class NotificationTab extends StatefulWidget {
  NotificationTab({Key? key}) : super(key: key);

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> with AutomaticKeepAliveClientMixin<NotificationTab> {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => FadeOverlay()));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    // return SafeArea(
    //   child: CustomScrollView(
    //     slivers: [
    //       SliverAppBar(
    //         // backgroundColor: Colors.white.withOpacity(0.2),
    //         automaticallyImplyLeading: false,
    //         elevation: 0.2,
    //         shadowColor: Colors.grey,
    //         forceElevated: true,
    //         pinned: false,
    //         actions: [
    //           // MaterialButton(
    //           //   onPressed: () {
    //           //     // Navigator.of(context).push(FadeOverlay());
    //           //     LoginScreen screen = LoginScreen();
    //           //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
    //           //   },
    //           //   child: Text("TEST")
    //           // )
    //         ],
    //         flexibleSpace: FlexibleSpaceBar(
    //           titlePadding: EdgeInsetsDirectional.only(
    //             bottom: 10.0,
    //           ),
    //           centerTitle: true,
    //           // titlePadding: EdgeInsets.symmetric(horizontal: 16),
    //           title: Text(
    //             'Notifications',
    //             // style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.w600),
    //             style: TextStyle(
    //               fontFamily: "CoolveticaCondensed",
    //               // fontWeight: FontWeight.bold,
    //               letterSpacing: 0.5,
    //               fontSize: 23,
    //               color: Get.isDarkMode ? Colors.white : Colors.black
    //             ),
    //           )
    //         ),
    //       ),
    //     ]
    //   )
    // );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: Get.isDarkMode ? ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7) : ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Get.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: "CoolveticaCondensed",
            // fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 23,
            color: Get.isDarkMode ? Colors.white : Colors.black
          ),
        )
      ),
      body: Container()
    );
  }
}