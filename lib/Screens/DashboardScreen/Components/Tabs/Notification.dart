import 'package:flutter/material.dart';
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

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            // backgroundColor: Colors.white.withOpacity(0.2),
            automaticallyImplyLeading: false,
            elevation: 0.2,
            shadowColor: Colors.grey,
            forceElevated: true,
            pinned: false,
            actions: [
              // MaterialButton(
              //   onPressed: () {
              //     // Navigator.of(context).push(FadeOverlay());
              //     LoginScreen screen = LoginScreen();
              //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
              //   },
              //   child: Text("TEST")
              // )
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsetsDirectional.only(
                bottom: 10.0,
              ),
              centerTitle: true,
              // titlePadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                'Notifications',
                // style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.w600),
                style: TextStyle(
                  fontFamily: "CoolveticaCondensed",
                  // fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 23
                ),
              )
            ),
          ),
        ]
      )
    );
  }
}