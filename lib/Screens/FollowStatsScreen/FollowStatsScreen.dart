import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/ProfileScreen/ProfileScreen.dart';

class FollowStatsScreen extends StatefulWidget {
  final UserModel user;
  final int? tab;
  FollowStatsScreen({Key? key, required this.user, this.tab}) : super(key: key);

  @override
  FollowStatsScreenState createState() => FollowStatsScreenState();
}

class FollowStatsScreenState extends State<FollowStatsScreen> {
  late int tab;

  @override
  void initState() {
    super.initState();
    tab = widget.tab ?? 0;
  }

  Widget followersTabView() {
    return FirestoreListView(
      shrinkWrap: true,
      pageSize: 50,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      query: FirebaseAPI().followersQuery(widget.user.fid),
      emptyBuilder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
              // SizedBox(height: 20,),
              Text('No followers yet.'),
            ],
          ),
        );
      },
      itemBuilder: (context, documentSnapshot) {
        String userFirebaseId = documentSnapshot.id;
        return FutureBuilder(
          future: FirebaseAPI().getUserFromFirebaseId(userFirebaseId),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              var docSnapshot = snapshot.data;
              return UserCard(user: docSnapshot!);
            }
            return Container();
          }
        );
      }
    );
  }

  Widget followingTabView() {
    return FirestoreListView(
      shrinkWrap: true,
      pageSize: 50,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      query: FirebaseAPI().followingQuery(widget.user.fid),
      emptyBuilder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
              // SizedBox(height: 20,),
              Text('Not following anyone yet.'),
            ],
          ),
        );
      },
      itemBuilder: (context, documentSnapshot) {
        String userFirebaseId = documentSnapshot.id;
        return FutureBuilder(
          future: FirebaseAPI().getUserFromFirebaseId(userFirebaseId),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              var docSnapshot = snapshot.data;
              return UserCard(user: docSnapshot!);
            }
            return Container();
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      initialIndex: tab,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(IconlyLight.arrow_left, size: 25),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
            widget.user.userName!,
            style: theme.textTheme.headline6,
          )
        ),
        body: Column(
          children: [
            TabBar(
              unselectedLabelColor: Get.isDarkMode ? null : Colors.black,
              labelColor: Get.isDarkMode ? null : primaryOrange,
              indicatorColor: primaryOrange,
              tabs: [
                Tab(
                  child: Text(
                    "Followers",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
                Tab(
                  child: Text(
                    "Following",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  )
                )
              ]
            ),
            Expanded(
              child: TabBarView(
                children: [
                  followersTabView(),
                  followingTabView()
                ]
              ),
            )
          ],
        ),
      )
    );
  }
}

class UserCard extends StatefulWidget {
  final Map<String, dynamic> user;
  UserCard({Key? key, required this.user}) : super(key: key);

  @override
  _UserCard createState() => _UserCard();
}

class _UserCard extends State<UserCard> with AutomaticKeepAliveClientMixin<UserCard> {
  late Map<String, dynamic> user;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() {
    setState(() => user = widget.user);
  }

  goToProfile() {
    ProfileScreen screen = ProfileScreen(userKey: int.parse(user['user_key']));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  _handleFollowStatus(bool isFollowing) {
    FirebaseAPI().updateFollowStatusV2(user['firebase_id'], !isFollowing);

    if(isFollowing) {
      setState(() {
        // user['followers'].removeWhere((e) => e == FirebaseAPI().firebaseId());
        user['isFollowing'] = false;
      });
    }else {
      setState(() {
        // user['followers'].add(FirebaseAPI().firebaseId());
        user['isFollowing'] = true;
      });
    }
  }

  Widget buildFollowButton() {

    return FirebaseAPI().firebaseId() != user['firebase_id'] ? ElevatedButton(
      onPressed: () => _handleFollowStatus(user['isFollowing']),
      child: Text(
        user['isFollowing'] ? "Following" : "Follow",
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
            color: user['isFollowing'] ? Get.isDarkMode ? Colors.white : Colors.black : Colors.transparent
          )
        ),
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric( vertical: 5, horizontal: 16),
        backgroundColor: user['isFollowing'] ? 
        ColorConstants.gray900 : primaryOrange,
        foregroundColor: Colors.transparent
      )
    ) : Container();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InkWell(
      onTap: () {
        ProfileScreen screen = ProfileScreen(userKey: int.parse(user['user_key']));
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
      },
      child: Card(
      margin: EdgeInsets.only(bottom: 10, top: 10),
      elevation: 0,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: user['biography'] != null && user['biography'] != '' ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          MyAvatar(
            photo: user['photo_url']
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: user['biography'] != null && user['biography'] != '' ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    user['display_name'] != null && user['display_name'] != '' ?
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${user['username']} ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Get.isDarkMode ? Colors.white : Colors.black
                            ),
                          ),
                          if(user['verified'])
                            WidgetSpan(
                              child: CustomIcon(
                                icon: 'assets/icons/verified-account.svg',
                                size: 16,
                                color: primaryOrange,
                              )
                            ),
                          TextSpan(
                            text: "\n${user['display_name']}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12
                            )
                          ),
                        ],
                      ),
                    ) :
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${user['username']} ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Get.isDarkMode ? Colors.white : Colors.black
                            ),
                          ),
                          if(user['verified'])
                            WidgetSpan(
                              child: CustomIcon(
                                icon: 'assets/icons/verified-account.svg',
                                size: 16,
                                color: primaryOrange,
                              )
                            ),
                        ]
                      )
                    ),
                    buildFollowButton()
                  ],
                ),
                user['biography'] != null && user['biography'] != '' ? Text(
                  user['biography'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                : Container()
              ],
            )
          )
        ],
      )
    ));
  }
}