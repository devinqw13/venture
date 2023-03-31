import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:venture/Calls.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/DashboardScreen/Components/LoginOverlay.dart';
import 'package:venture/Components/ProfileSkeleton.dart';
import 'package:venture/Models/VenUser.dart';
// import 'package:venture/Controllers/ThemeController.dart';
// import 'package:get/get.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({Key? key}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with AutomaticKeepAliveClientMixin<ProfileTab> {
  // final ThemesController _themesController = Get.find();
  AsyncMemoizer _memoizer = AsyncMemoizer();
  
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
      // TODO: Incorporate user data caching
      // var res = await getUser(context, userKey);
      // return res;
      var res = await FirebaseAPI().getUserDetails(userKey: userKey.toString());

      if(res != null) {
        var user = UserModel.fromFirebaseMap(res.docs.first.data());
        return user;
      }else {
        return null;
      }
    });
  }

  Widget _buildBody(int userKey) {
    var apiCall = _fetch(userKey);

    return FutureBuilder(
      future: apiCall,
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return ProfileSkeletonShimmer(enableBackButton: false, enableSettingsButton: true);
        }else {
          UserModel data = snapshot.data as UserModel;
          return ProfileSkeleton(user: data, isUser: true, enableBackButton: false, enableSettingsButton: true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final theme = Theme.of(context);
    SizeConfig().init(context);
    return ValueListenableBuilder(
        valueListenable: VenUser().userKey, 
        builder: (context, value, _) {
          return Stack(
            children: [
              value != 0 ? _buildBody(value as int) : Container(),
              value == 0 ? ProfileSkeletonShimmer(enableBackButton: false, enableSettingsButton: false) : Container(),
              value == 0 ? LoginOverlay(enableSettings: true) : Container(),
            ]
          );
        }
      );
      // child: Stack(
      //   children: [
      //     // value != 0 ? _buildBody(value as int) : Container(),
      //     ProfileSkeletonShimmer(),
      //     // LoginOverlay(enableSettings: true),
      //   ]
      // )
  }
}