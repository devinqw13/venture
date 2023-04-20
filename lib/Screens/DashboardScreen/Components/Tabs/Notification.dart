import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/PhotoHero.dart';
import 'package:venture/Helpers/TimeFormat.dart';
import 'package:venture/Models/Notification.dart';
import 'package:collection/collection.dart';
import 'package:venture/Screens/DisplayContentListScreen/DisplayContentListScreen.dart';
import 'package:venture/Screens/ProfileScreen/ProfileScreen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationTab extends StatefulWidget {
  NotificationTab({Key? key}) : super(key: key);

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> with AutomaticKeepAliveClientMixin<NotificationTab> {
  List<VentureNotification> allNotifications = [];

  @override
  bool get wantKeepAlive => true;

  formatNotifications(Map<String, dynamic> data) {
    List<VentureNotification> notifications = [];

    // if(data.containsKey("messages")) {
    //   for(var item in data['messages']) {
    //     VentureNotification noti = VentureNotification.fromMap(item, NotificationType.message);
    //     notifications.add(noti);
    //   }
    // }

    if(data.containsKey("reactions")) {
      int index = 0;
      for(var item in data['reactions']) {
        VentureNotification noti = VentureNotification.fromMap(item, NotificationType.reaction, index);
        notifications.add(noti);
        index++;
      }
    }

    if(data.containsKey("content_comments")) {
      int index = 0;
      for(var item in data['content_comments']) {
        VentureNotification noti = VentureNotification.fromMap(item, NotificationType.comment, index);
        notifications.add(noti);
        index++;
      }
    }

    if(data.containsKey("followed_you")) {
      int index = 0;
      for(var item in data['followed_you']) {
        VentureNotification noti = VentureNotification.fromMap(item, NotificationType.followed, index);
        notifications.add(noti);
        index++;
      }
    }
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    allNotifications = notifications;

    List<GroupNotification> grouped = [];
    var groupByDate = groupBy(notifications, (e) => DateTime.now().difference(e.timestamp).inDays >= 1);

    groupByDate.forEach((isLater, list) {
      grouped.add(GroupNotification(isLater ? "Previous" : "New", list));
    });

    grouped.sort((a, b) => a.title.compareTo(b.title));

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

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
      body: StreamBuilder(
        stream: FirebaseAPI().getNotificationsStream(),
        builder: (context, notifications) {
          if(notifications.hasData) {
            var data = notifications.data!.data();
            var results = formatNotifications(data!);
            if(results.isNotEmpty) {
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, i) {
                  return GroupedNotificationsWidget(group: results[i], notifications: allNotifications);
                }
              );
            }else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIcon(
                      icon: 'assets/icons/notification3.svg',
                      color: Colors.grey,
                      size: 70,
                    ),
                    SizedBox(height: 20),
                    Text("No notifications yet...")
                  ],
                )
              );
            }
          }
          return Container();
        }
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
  final List<VentureNotification> notifications;
  GroupedNotificationsWidget({Key? key, required this.group, required this.notifications}) : super(key: key);

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
          SpecificNotificationWidget(noti: item, notis: notifications)
      ],
    );
  }
}

class SpecificNotificationWidget extends StatefulWidget {
  final VentureNotification noti;
  final List<VentureNotification> notis;
  SpecificNotificationWidget({Key? key, required this.noti, required this.notis}) : super(key: key);

  @override
  _SpecificNotificationWidget createState() => _SpecificNotificationWidget();
}

class _SpecificNotificationWidget extends State<SpecificNotificationWidget> {
  String? contentPhoto;
  bool? _isFollowing;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    if(widget.noti.contentPhoto != null && widget.noti.contentPhoto!.isNotEmpty) {
      contentPhoto = widget.noti.contentPhoto;
    }
  }

  Widget displayContentPhoto() {
    if(contentPhoto != null && lookupMimeType(contentPhoto!)!.contains('video')) {
      return FutureBuilder(
        future: VideoThumbnail.thumbnailData(
          video: contentPhoto!,
          imageFormat: ImageFormat.PNG,
          maxWidth: 40,
          quality: 100,
        ),
        builder: (context, i) {
          if(i.hasData) {
            return Container(
              width: 40,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: MemoryImage(i.data!),
                  fit: BoxFit.cover
                )
              ),
            );
            // return Image.memory(
            //   i.data!,
            //   width: 40,
            //   height: 50,
            //   fit: BoxFit.cover,
            // );
          }else {
            return Skeleton.rectangular(
              width: 40,
              height: 50,
              borderRadius: 5.0
            );
          }
        }
      );
    }else if(contentPhoto != null ) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          width: 40,
          height: 50,
          imageUrl: contentPhoto!,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Skeleton.rectangular(
              width: 40,
              height: 50,
              // borderRadius: 20.0
            );
          }
        )
      );
    }else {
      return Container();
    }
  }

  _handleFollowStatus(bool isFollowing, Map<String, dynamic> user) {
    FirebaseAPI().updateFollowStatusV2(user['firebase_id'], !isFollowing);

    if(isFollowing) {
      setState(() {
        _isFollowing = false;
      });
    }else {
      setState(() {
        _isFollowing = true;
      });
    }
  }

  displayFollowBack(Map<String, dynamic> user, bool isFlwing) {

    return ElevatedButton(
      onPressed: () => _handleFollowStatus(user['isFollowing'], user),
      child: Text(
        isFlwing ? "Following" : "Follow",
        style: TextStyle(
          color: Colors.white
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isFlwing ? Get.isDarkMode ? Colors.white : Colors.black : Colors.transparent
          )
        ),
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric( vertical: 5, horizontal: 16),
        backgroundColor: _isFollowing ?? user['isFollowing'] ? 
        ColorConstants.gray900 : primaryOrange,
        foregroundColor: Colors.transparent
      )
    );
  }

  goToProfile(Map<String, dynamic> user) {
    ProfileScreen screen  = ProfileScreen(userKey: int.parse(user['user_key']));
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
  }

  _handleTap(NotificationType type) async {
    if(type == NotificationType.comment ||
      type == NotificationType.reaction
    ) {
      DisplayContentListScreen screen = DisplayContentListScreen(contentKey: widget.noti.contentKey);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
    }
  }

  markAsRead() {
    if(widget.noti.read == false) {
      List<VentureNotification> list = widget.notis.where((e) => e.notificationType == widget.noti.notificationType).toList();
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      List<Map<String, dynamic>> firestoreData = list.map((e) => e.toJson()).toList();
      firestoreData[widget.noti.index!]['read'] = true;

      FirebaseAPI().updateNotificationsRead(firestoreData, widget.noti.notificationType);
    }
  }

  @override
  Widget build(BuildContext context) {
    String bodyText = '';
    
    if(widget.noti.notificationType == NotificationType.comment) {
      bodyText = 'Commented on your post: ${widget.noti.comment}';
    }else if(widget.noti.notificationType == NotificationType.message) {
      bodyText = "Sent you a message: ${widget.noti.message}";
    }else if(widget.noti.notificationType == NotificationType.reaction) {
      bodyText = "Liked your post.";
    }else if(widget.noti.notificationType == NotificationType.followed) {
      bodyText = "Followed you!";
    }

    return FutureBuilder(
      future: FirebaseAPI().getUserFromFirebaseId(widget.noti.firebaseId),
      builder: (context, snapshot) {
        var user = snapshot.data;
        if(snapshot.hasData) {
          return VisibilityDetector(
            key: UniqueKey(),
            onVisibilityChanged: (d) {
              if(d.visibleFraction > 0.0) {
                markAsRead();
              }
            },
            child: GestureDetector(
              onTap: () => _handleTap(widget.noti.notificationType),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16.0),
                color: !widget.noti.read ? primaryOrange.withOpacity(0.2) : null, 
                child: Row(
                  children: [
                    ZoomTapAnimation(
                      onTap: () => goToProfile(user),
                      child: MyAvatar(
                        photo: user!['photo_url'],
                        size: 30,
                      )
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          user['display_name'] != null && user['display_name'] != '' ?
                                          user['display_name'] : user['username'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        TimeFormat().withoutDate(widget.noti.timestamp.toString())
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(child:Text(bodyText)),
                                      ],
                                    )
                                    // Text(bodyText)
                                  ],
                                )
                              ),
                              SizedBox(width: 20),
                              contentPhoto != null ? displayContentPhoto() : Container(),
                              widget.noti.notificationType == NotificationType.followed ? displayFollowBack(user, _isFollowing ?? user['isFollowing']) : Container()
                            ],
                          )
                        ],
                      )
                    )
                  ],
                )
              )
            )
          );
        }
        return Container();
      }
    );
  }
}