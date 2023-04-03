import 'dart:ui' as ui;
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/ProfileScreen.dart/ProfileScreen.dart';

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
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
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
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
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
        // body: Column(
        //   children: [
        //     Expanded(
        //       child: ListView(
        //         children: [
        //           PaginateFirestore(
        //             physics: NeverScrollableScrollPhysics(),
        //             shrinkWrap: true,
        //             query: FirebaseAPI().commentQuery(widget.documentId),
        //             itemBuilderType: PaginateBuilderType.listView,
        //             isLive: true,
        //             itemsPerPage: 20,
        //             onEmpty: Container(
        //               padding: EdgeInsets.symmetric(vertical: 8),
        //               child: Column(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: [
        //                   // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
        //                   // SizedBox(height: 20,),
        //                   Text('No Followers'),
        //                 ],
        //               ),
        //             ),
        //             itemBuilder: (context, documentSnapshot, index) {
        //               // String documentId = documentSnapshot[index].id;
        //               var userData = documentSnapshot[index].data() as Map<String, dynamic>;
        //               return Container();
        //             }
        //           )
        //         ]
        //       )
        //     ),
        //   ],
        // ),
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

class _UserCard extends State<UserCard> {
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
        user['isFollowing'] ? "Following" : "Follow"
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(100, 30),
        elevation: 0,
        backgroundColor: user['isFollowing'] ? 
        ColorConstants.gray600 : primaryOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )
      ),
    ) : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyAvatar(
            photo: user['photo_url']
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    user['display_name'] != null && user['display_name'] != '' ?
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: user['username'] + "\n",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            ),
                          ),
                          TextSpan(
                            text: user['display_name'],
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12
                            )
                          ),
                        ],
                      ),
                    ) :
                    Text(
                      user['username'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                      ),
                    ),
                    buildFollowButton()
                  ],
                )
              ],
            )
          )
        ],
      )
    );
  }
}