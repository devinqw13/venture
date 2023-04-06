import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Models/Notification.dart';
import 'package:collection/collection.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class NotificationTab extends StatefulWidget {
  NotificationTab({Key? key}) : super(key: key);

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> with AutomaticKeepAliveClientMixin<NotificationTab> {
  List<VentureNotification> notifications = [];
  List<GroupNotification> groupedNotifications = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    _getNotifications();
    // if(FirebaseAPI().firebaseId() != null) _getFollowingContent();
  }

  _getNotifications() async {
    var result = await FirebaseAPI().getNotifications();
    Map<String, dynamic>? data = result.data();
    
    if(data != null && data.containsKey("messages")) {
      for(var item in data['messages']) {
        VentureNotification noti = VentureNotification.fromMap(item, NotificationType.message);
        notifications.add(noti);
      }
    }

    if(data != null && data.containsKey("content_comment")) {
      for(var item in data['content_comment']) {
        VentureNotification noti = VentureNotification.fromMap(item, NotificationType.comment);
        notifications.add(noti);
      }
    }

    if(data != null && data.containsKey("followed_you")) {
      for(var item in data['followed_you']) {
        VentureNotification noti = VentureNotification.fromMap(item, NotificationType.followed);
        notifications.add(noti);
      }
    }

    List<GroupNotification> grouped = [];
    var groupByDate = groupBy(notifications, (e) => DateTime.now().difference(e.timestamp).inDays >= 1);

    groupByDate.forEach((isLater, list) {
      // // Header
      // print('$isLater:');
      
      // // Group
      // list.forEach((listItem) {
      //   print('${listItem.notificationType}, ${listItem.timestamp}');
      // });

      grouped.add(GroupNotification(isLater ? "Previous" : "New", list));
    });
    grouped.sort((a, b) => a.title.compareTo(b.title));
    setState(() => groupedNotifications = grouped);
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          itemCount: groupedNotifications.length,
          itemBuilder: (context, i) {
            return GroupedNotificationsWidget(group: groupedNotifications[i]);
          }
        )
      )
    );
  }
}

class GroupNotification {
  late String title;
  late List<VentureNotification> items;

  GroupNotification(this.title, this.items);
}

class GroupedNotificationsWidget extends StatelessWidget {
  final GroupNotification group;
  GroupedNotificationsWidget({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        SizedBox(height: 10),
        for(var item in group.items)
          SpecificNotificationWidget(noti: item)
      ],
    );
  }
}

class SpecificNotificationWidget extends StatelessWidget {
  final VentureNotification noti;
  SpecificNotificationWidget({Key? key, required this.noti}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String bodyText = '';
    
    if(noti.notificationType == NotificationType.comment) {
      bodyText = 'Commented on your post: ${noti.comment}';
    }else if(noti.notificationType == NotificationType.message) {
      bodyText = "Sent you a message: ${noti.message}";
    }else if(noti.notificationType == NotificationType.reaction) {
      bodyText = "Liked your post.";
    }else if(noti.notificationType == NotificationType.followed) {
      bodyText = "Followed you!";
    }

    return FutureBuilder(
      future: FirebaseAPI().getUserFromFirebaseId(noti.firebaseId),
      builder: (context, snapshot) {
        var user = snapshot.data;
        if(snapshot.hasData) {
          return ListTile(
            leading: ZoomTapAnimation(
              child: MyAvatar(photo: user!['photo_url'])
            ),
            title: user['display_name'] != null && user['display_name'] != '' ?
            Text(user['display_name'], style: TextStyle(fontWeight: FontWeight.bold)) :
            Text(user['username'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(bodyText),
          );
        }
        return Container();
      }
    );
  }
}