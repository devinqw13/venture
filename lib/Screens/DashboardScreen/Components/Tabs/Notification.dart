import 'package:flutter/material.dart';
import 'package:venture/Components/FadeOverlay.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/CustomIcon.dart';

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
            elevation: 0.2,
            shadowColor: Colors.grey,
            forceElevated: true,
            pinned: false,
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(FadeOverlay());
                },
                child: Text("TEST")
              )
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
                style: theme.textTheme.headline6!.copyWith(fontFamily: "CoolveticaCondensed",color: primaryOrange, fontSize: 24),
              ),
            ),
          ),
        ]
      )
    );
  }
}