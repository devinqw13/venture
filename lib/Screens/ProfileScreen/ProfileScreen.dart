import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Components/ProfileSkeleton.dart';
import 'package:venture/Models/VenUser.dart';

class ProfileScreen extends StatefulWidget {
  final int userKey;
  ProfileScreen({Key? key, required this.userKey}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>  {
  AsyncMemoizer _memoizer = AsyncMemoizer();

  _fetch(int userKey) {
    return _memoizer.runOnce(() async {
      // TODO: Incorporate user content caching
      // var res = await getUser(context, userKey);
      // return res;

      var res = await FirebaseAPI().getUserDetailsV2(userKey: userKey.toString());
      
      if(res != null) {
        var user = UserModel.fromFirebaseMap(res);
        return user;
      }else {
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var apiCall = _fetch(widget.userKey);
    SizeConfig().init(context);
    return Scaffold(
      body: FutureBuilder(
        future: apiCall,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return ProfileSkeletonShimmer(enableBackButton: true, enableSettingsButton: VenUser().userKey.value == widget.userKey);
          }else {
            UserModel data = snapshot.data as UserModel;
            return ProfileSkeleton(user: data, isUser: VenUser().userKey.value == widget.userKey, enableBackButton: true, enableSettingsButton: VenUser().userKey.value == widget.userKey);
          }
        },
      )
    );
  }
}