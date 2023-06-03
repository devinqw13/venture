import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/ProfileScreen/ProfileScreen.dart';

class BlockedUsersScreen extends StatefulWidget {
  BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen>  {
  List<String> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    var result = await FirebaseAPI().getBlockedUsers(FirebaseAPI().firebaseId()!);
    var list = result.docs.map((e) => e.id).toList();
    setState(() => blockedUsers = list);
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
        centerTitle: true,
        title: Text(
          'Blocked users',
          style: theme.textTheme.headline6,
        )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          // shrinkWrap: true,
          children: [
            Container(),
            blockedUsers.isNotEmpty ? ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: blockedUsers.length,
              itemBuilder: (context, i) {
                return FutureBuilder(
                  future: FirebaseAPI().getUserFromFirebaseId(blockedUsers[i]),
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      var docSnapshot = snapshot.data as Map<String, dynamic>;
                      var userData = docSnapshot;

                      return UserCard(user: userData);
                    }
                    return Container();
                  }
                );
              }
            ) : Center(
              child: Text("No blocked users."),
            )
          ],
        )
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

    user = widget.user;
    user['blocked'] = true;
  }

  updateBlockStatus() {
    var _ = updateUserRelationship(
      context,
      userKey: VenUser().userKey.value,
      userFirebaseId: FirebaseAPI().firebaseId()!,
      relUserKey: int.parse(user['user_key']),
      relUserFirebaseId: user['firebase_id'],
      blocked: user['blocked'] ? false : true
    );

    setState(() => user['blocked'] = !user['blocked']);
  }

  buildUnblockButton() {
    return ElevatedButton(
      onPressed: () => updateBlockStatus(),
      child: Text(
        user['blocked'] ? "Unblock" : "Block",
        style: TextStyle(
          color: Colors.white
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: Size.zero,
        padding: EdgeInsets.symmetric( vertical: 8, horizontal: 16),
        backgroundColor: user['blocked'] ? primaryOrange : primaryBlue,
        foregroundColor: Colors.transparent
      )
    );
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyAvatar(
              photo: widget.user['photo_url']
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.user['display_name'] != null && widget.user['display_name'] != '' ?
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "${widget.user['username']} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Get.isDarkMode ? Colors.white : Colors.black
                              ),
                            ),
                            if(widget.user['verified'])
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: CustomIcon(
                                  icon: 'assets/icons/verified-account.svg',
                                  size: 14,
                                  color: primaryOrange,
                                )
                              ),
                            TextSpan(
                              text: "\n${widget.user['display_name']}",
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
                              text: "${widget.user['username']} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Get.isDarkMode ? Colors.white : Colors.black
                              ),
                            ),
                            if(widget.user['verified'])
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
                      buildUnblockButton()
                    ],
                  )
                ]
              )
            )
          ],
        )
      )
    );
  }
}