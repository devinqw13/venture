import 'package:flutter/material.dart';
import 'package:venture/Constants.dart';

class NotificationTab extends StatefulWidget {
  NotificationTab({Key? key}) : super(key: key);

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> with AutomaticKeepAliveClientMixin<NotificationTab> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white.withOpacity(0.2),
            elevation: 0.5,
            shadowColor: Colors.grey,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsetsDirectional.only(
                bottom: 10.0,
              ),
              centerTitle: true,
              // titlePadding: EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                'Notifications',
                style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ]
      )
    );
  }
}