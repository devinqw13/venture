import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Components/ProfileSkeleton.dart';

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
      var res = await getUser(context, userKey);
      return res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var apiCall = _fetch(widget.userKey);
    // SizeConfig().init(context);
    return SafeArea(
      child: FutureBuilder(
        future: apiCall,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return ProfileSkeletonShimmer();
          }else {
            UserModel data = snapshot.data as UserModel;
            return ProfileSkeleton(user: data);
          }
        },
      )
    );
  }
}