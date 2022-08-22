import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:async/async.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/DashboardScreen/Components/LoginOverlay.dart';
import 'package:venture/Screens/DashboardScreen/Components/ProfileSkeleton.dart';
import 'package:venture/Screens/SettingsScreen/SettingsScreen.dart';
import 'package:venture/Models/User.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:get/get.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({Key? key}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with AutomaticKeepAliveClientMixin<ProfileTab> {
  final ThemesController _themesController = Get.find();
  AsyncMemoizer _memoizer = AsyncMemoizer();
  static double avatarMaximumRadius = 40.0;
  static double avatarMinimumRadius = 15.0;
  double avatarRadius = avatarMaximumRadius;
  double expandedHeader = 130.0;
  double translate = -avatarMaximumRadius;
  bool isExpanded = true;
  double offset = 0.0;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
  }

  // void goToSettings() {
  //   SettingsScreen settingsScreen = SettingsScreen();
  //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => settingsScreen));
  // }

  _fetch(int userKey) {
    return _memoizer.runOnce(() async {
      var res = await getUser(context, userKey);
      return res;
    });
  }

  Widget _buildBody(int userKey) {
    var apiCall = _fetch(userKey);

    return FutureBuilder(
      future: apiCall,
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return ProfileSkeletonShimmer();
        }else {
          UserModel data = snapshot.data as UserModel;
          return ProfileSkeleton(user: data);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    SizeConfig().init(context);
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: User().userKey, 
        builder: (context, value, _) {
          return Stack(
            children: [
              value != 0 ? _buildBody(value as int) : Container(),
              value == 0 ? ProfileSkeletonShimmer() : Container(),
              value == 0 ? LoginOverlay(enableSettings: true) : Container(),
            ]
          );
        }
      )
      // child: Stack(
      //   children: [
      //     // value != 0 ? _buildBody(value as int) : Container(),
      //     ProfileSkeletonShimmer(),
      //     // LoginOverlay(enableSettings: true),
      //   ]
      // )
    );
  }
}