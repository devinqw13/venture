import 'dart:ui' as ui;
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Screens/ProfileScreen/ProfileScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class LikedByScreen extends StatefulWidget {
  final String contentKey;
  final int numOfLikes;
  LikedByScreen({Key? key, required this.contentKey, this.numOfLikes = 0}) : super(key: key);

  @override
  _LikedByScreen createState() => _LikedByScreen();
}

class _LikedByScreen extends State<LikedByScreen> {
  late int numOfLikes;

  @override
  void initState() {
    super.initState();
    numOfLikes = widget.numOfLikes;
  }

  buildFollowButton(Map<String, dynamic> data) {
    bool isFollowing = data['followers'].contains(FirebaseAPI().firebaseId());

    return FirebaseAPI().firebaseId() != data['firebase_id'] ? ElevatedButton(
      onPressed: () => FirebaseAPI().updateFollowStatus(data['firebase_id'], !isFollowing),
      child: Text(
        isFollowing ? "Following" : "Follow"
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(100, 30),
        elevation: 0,
        primary: isFollowing ? 
        ColorConstants.gray600 : primaryOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )
      ),
    ) : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
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
          'Liked by',
          style: theme.textTheme.headline6,
        )
      ),
      body: ListView(
        children: [
          FirestoreListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            pageSize: 20,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            query: FirebaseAPI().likedByQueryV2(widget.contentKey),
            emptyBuilder: (context) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
                    // SizedBox(height: 20,),
                    Text('No likes yet'),
                  ],
                ),
              );
            },
            itemBuilder: (context, documentSnapshot) {
              Map<String, dynamic> docData = documentSnapshot.data()! as Map<String, dynamic>;
              String userFirebaseId = docData['firebase_id'];
              return FutureBuilder(
                future: FirebaseAPI().getUserFromFirebaseId(userFirebaseId),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    var docSnapshot = snapshot.data;
                    return UserLikeCard(user: docSnapshot!);
                  }
                  return Container();
                }
              );
            }
          )
        ]
      )
    );
  }
}

class UserLikeCard extends StatefulWidget {
  final Map<String, dynamic> user;
  UserLikeCard({Key? key, required this.user}) : super(key: key);

  @override
  _UserLikeCard createState() => _UserLikeCard();
}

class _UserLikeCard extends State<UserLikeCard> {
  late Map<String, dynamic> user;

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
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
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
    // bool isFollowing = user['followers'].contains(FirebaseAPI().firebaseId());

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
        padding: EdgeInsets.symmetric( vertical: 8, horizontal: 16),
        backgroundColor: user['isFollowing'] ? 
        ColorConstants.gray900 : primaryOrange,
        foregroundColor: Colors.transparent
      )
    ) : Container();
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.user['user_deactivated']) {
      return InkWell(
        onTap: () => goToProfile(),
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
                                  fontSize: 14
                                ),
                              ),
                              if(user['verified'])
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: CustomIcon(
                                    icon: 'assets/icons/verified-account.svg',
                                    size: 14,
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
                                  fontSize: 14
                                ),
                              ),
                              if(user['verified'])
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: CustomIcon(
                                    icon: 'assets/icons/verified-account.svg',
                                    size: 14,
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
        )
      );
    }else {
      return Container();
    }
  }
}