import 'package:flutter/material.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/FireBaseServices.dart';
import 'package:get_storage/get_storage.dart';

class AccountSettingsScreen extends StatefulWidget {
  AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen>  {

  _logout() async {
    final storage = GetStorage();
    storage.remove("user_key");
    VenUser().userKey.value = 0;
    // await FirebaseServices().removeFirebaseTokens();
    await FirebaseServices().logout();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // expandedHeight: 100.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              // titlePadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                'Your account',
                style: theme.textTheme.headline6,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ZoomTapAnimation(
                onTap: () => _logout(),
                child: Text("Log out",
                  style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                )
              )
            )
          )
        ],
      ),
    );
  }
}