import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseServices.dart';
import 'package:venture/Screens/ProfileScreen.dart/ProfileScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class LikedByScreen extends StatefulWidget {
  final String? documentId;
  final int numOfLikes;
  LikedByScreen({Key? key, required this.documentId, this.numOfLikes = 0}) : super(key: key);

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
    bool isFollowing = data['followers'].contains(FirebaseServices().firebaseId());

    return FirebaseServices().firebaseId() != data['firebase_id'] ? ElevatedButton(
      onPressed: () => FirebaseServices().updateFollowStatus(data['firebase_id'], !isFollowing),
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
          icon: Icon(IconlyLight.arrow_left, size: 28),
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
          PaginateFirestore(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            query: FirebaseServices().likedByQuery(widget.documentId),
            itemBuilderType: PaginateBuilderType.listView,
            isLive: true, 
            itemsPerPage: 20,
            // padding: EdgeInsets.only(top: 100),
            header: SliverToBoxAdapter(
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:'Liked by ',
                      ),
                      TextSpan(
                        text: "$numOfLikes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                )
              )
            ),
            onEmpty: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
                  // SizedBox(height: 20,),
                  Text('No likes yet'),
                ],
              ),
            ),
            // padding: const EdgeInsets.only(bottom: 90),
            itemBuilder: (context, documentSnapshot, index) {
              String userFirebaseId = documentSnapshot[index].id;
              return FutureBuilder(
                future: FirebaseServices().getUserFromFirebaseId(userFirebaseId),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    var docSnapshot = snapshot.data as DocumentSnapshot<Map<String, dynamic>>?;
                    var data = docSnapshot!.data();
                    return UserLikeCard(user: data!);
                  }
                  return Container();
                }
              );
            },
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
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  _handleFollowStatus(bool isFollowing) {
    FirebaseServices().updateFollowStatus(user['firebase_id'], !isFollowing);

    if(isFollowing) {
      setState(() {
        user['followers'].removeWhere((e) => e == FirebaseServices().firebaseId());
      });
    }else {
      setState(() {
        user['followers'].add(FirebaseServices().firebaseId());
      });
    }
  }

  buildFollowButton() {
    bool isFollowing = user['followers'].contains(FirebaseServices().firebaseId());

    return FirebaseServices().firebaseId() != user['firebase_id'] ? ElevatedButton(
      onPressed: () => _handleFollowStatus(isFollowing),
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
    return ListTile(
      onTap: () => goToProfile(),
      leading: ZoomTapAnimation(
        child: MyAvatar(photo: user['photo_url'])
      ),
      trailing: buildFollowButton(),
      title: Text(
        user['username'],
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),
      ),
      subtitle: user['display_name'] != null ? Text(
        user['display_name']
      ) : null,
    );
  }
}