import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/CustomOptionsPopupMenu.dart';
import 'package:venture/Components/DropShadow.dart';
import 'package:venture/Components/ReportSheet.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Helpers/MapPreview.dart';
import 'package:venture/Helpers/NumberFormat.dart';
import 'package:venture/Helpers/CustomRefresh.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/Conversation.dart';
import 'package:venture/Models/FirebaseUser.dart';
import 'package:venture/Models/Message.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Helpers/PhotoHero.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/DisplayContentListScreen/DisplayContentListScreen.dart';
import 'package:venture/Screens/EditProfileScreen/EditProfileScreen.dart';
import 'package:venture/Screens/FollowStatsScreen/FollowStatsScreen.dart';
import 'package:venture/Screens/MessagingScreen/MessagingScreen.dart';
import 'package:venture/Screens/PinScreen/PinScreen.dart';
import 'package:venture/Screens/SettingsScreen/SettingsScreen.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProfileSkeleton extends StatefulWidget {
  final UserModel user;
  final bool isUser;
  final bool enableBackButton;
  final bool enableSettingsButton;
  ProfileSkeleton({Key? key, required this.user, required this.isUser, required this.enableBackButton, required this.enableSettingsButton}) : super(key: key);

  @override
  _ProfileSkeleton createState() => _ProfileSkeleton();
}

class _ProfileSkeleton extends State<ProfileSkeleton> with TickerProviderStateMixin {
  final ThemesController _themesController = Get.find();
  bool isLoading = false;
  late UserModel userData;
  List<Content>? pins = [];
  List<Content>? pinContent = [];
  List<Pin> savedPins = [];
  bool _isLoadingContent = false;
  bool _isLoadingSavedPins = false;
  // bool _refreshing = false;
  
  @override
  void initState() {
    super.initState();
    userData = widget.user;
    _initializeAsyncDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeAsyncDependencies([bool showLoadingContent = true, bool showLoadingSavedPins = true]) async {
    // TODO: Incorporate user content caching
    getUserContent(showLoadingContent);
    getSavedPins(showLoadingSavedPins);
  }

  getUserContent([bool showLoading = true]) async {
    if(showLoading) setState(() => _isLoadingContent = true);
    var results = await getContent(context, [userData.userKey!], 1);
    if(showLoading) setState(() => _isLoadingContent = false);

    setState(() {
      pinContent = results.where((e) => e.contentFormat == ContentFormat.pinContent).toList();
      pins = results.where((e) => e.contentFormat == ContentFormat.pin).toList();
      userData.pinCount = pins!.length;
    });
  }

  getSavedPins([bool showLoading = true]) async {
    if(showLoading) setState(() => _isLoadingSavedPins = true);
    var result = await FirebaseAPI().getSavedPins(FirebaseAPI().firebaseId()!);
    List<Pin> sPins = [];
    for(var item in result!.docs) {
      Map<String, dynamic> savedPin = item.data();

      var results = await getMapPins(context, pinKey: savedPin['pin_key'], ventureCurrentUser: VenUser().userKey.value);

      if(results.isNotEmpty) {
        Pin pin = results.first;
        sPins.add(pin);
      }
    }
    if(showLoading) setState(() => _isLoadingSavedPins = false);
    setState(() => savedPins = sPins);
  }

  void goToSettings() {
    SettingsScreen screen = SettingsScreen();
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
  }

  void goToUserFollowInfo(int tab) {
    FollowStatsScreen screen = FollowStatsScreen(user: userData, tab: tab);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
  }

  void goToEditProfile() async {
    EditProfileScreen screen = EditProfileScreen(user: userData);

    var result = await Navigator.of(context).push(SlideUpDownPageRoute(page: screen, closeDuration: 300));

    if(result != null) {
      setState(() => userData = result);
    }
  }

  reportUser(UserModel u) async {
    var result = await showReportSheet(
      context: context,
      reportee: u.userKey!,
      type: "U"
    );

    if(result != null && result) {
      double y = MediaQuery.of(context).size.height;
      double x = MediaQuery.of(context).size.width;
      Offset offset = Offset(
        x / 2,
        y / 2
      );

      Future.delayed(Duration(seconds: 1), () {
        showOverlayMessage(context: context, offset: offset, message: "Report Submitted", duration: Duration(milliseconds: 1500));
      });
    }
  }

  Conversation getConversationFromSnapshot(DocumentSnapshot convo, QuerySnapshot snapshot) {
    List<String> ownersList = [];
    List<String> typersList = [];
    Map<String, dynamic> ownersMap = {};
    String? fromName;
    var owners = convo.get('owners');
    if (owners is List) {
      ownersList = List<String>.from(owners);
    }
    else if (owners is Map) {
      ownersMap = Map<String, dynamic>.from(owners);
      ownersList = List<String>.from(ownersMap.keys);
      var fromOwner = ownersList.firstWhere((owner) => owner.toLowerCase().trim() != VenUser().userKey.value.toString().toLowerCase().trim(), orElse: () => ""); 
      if (fromOwner.isNotEmpty) {
        if (ownersMap[fromOwner].containsKey('name')) {
          fromName = ownersMap[fromOwner]['name'];
        }
      }
    }
    ownersList.sort((a,b) => a.compareTo(b));
    List<Message> messagesList = [];
    for (var message in snapshot.docs) {
      messagesList.add(Message(message));
    }
    Map convoMap = convo.data() as Map;
    if(convoMap.containsKey('typers')) {
      var typers = convo.get('typers');
      if (typers is List) {
        typersList = List<String>.from(typers);
      }
    }
    messagesList.sort((a,b) => a.timestamp.compareTo(b.timestamp));
    bool showUnread = false;
    
    if (messagesList.firstWhereOrNull((message) => message.userKey != VenUser().userKey.value.toString() && !message.isMessageRead!) != null) {
      showUnread = true;
    } else {
      showUnread = false;
    }
    Conversation conversation = Conversation(owners: ownersList, typers: typersList, messages: messagesList, showUnread: showUnread, conversationUID: convo.id, fromName: fromName);
    var otherUser = ownersList.firstWhere((owner) => owner.trim().toLowerCase() != VenUser().userKey.value.toString().trim().toLowerCase(), orElse: () => "");
    if (otherUser != "") {
      if (ownersMap.containsKey(otherUser)) {
        conversation.photoUrl = ownersMap[otherUser]['photo_url'];
      }
    }
    return conversation;
  }

  void openMessages() async {
    List<String> owners = [VenUser().userKey.value.toString(), userData.userKey.toString()];
    owners.sort((a,b) => a.compareTo(b));

    MessageUser? messageUser = MessageUser(userData.toJson());
    
    var convo = await FirebaseAPI().getConvoDoc(owners);
    if(convo.exists) {
      var messageQuerySnapshot = await FirebaseAPI().getConvoMessagesStream(owners);
      Conversation conversation = getConversationFromSnapshot(convo, messageQuerySnapshot);

      MessagingScreen screen = MessagingScreen(conversation: conversation, existingConvoUser: messageUser, owners: owners);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));

    }else {
      String conversationUIDString = owners.join(":");

      Conversation newConversation = Conversation(owners: owners, messages: [], conversationUID: conversationUIDString, showUnread: false, fromName: null);

      MessagingScreen screen = MessagingScreen(conversation: newConversation, newSendToUser: messageUser, owners: owners);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
    }
  }

  Future<void> _refreshUser() async {
    HapticFeedback.mediumImpact();
    var result = await FirebaseAPI().getUserDetailsV2(userKey: userData.userKey.toString());
    if(result != null) {
      var u = UserModel.fromFirebaseMap(result);
      setState(() => userData = u);
    }

    await _initializeAsyncDependencies(false);
  }

  SliverAppBar _buildHeaderWithAvatar(UserModel user) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: true,
      stretch: true,
      pinned: false,
      expandedHeight: MediaQuery.of(context).size.height * 0.22,
      // stretchTriggerOffset: 50,
      // onStretchTrigger: () async {
      //   await _refreshUser();
      //   return;
      // },
      flexibleSpace: Stack(
        children: [
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    user.userAvatar!,
                  ),
                  fit: BoxFit.cover
                )
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    // alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.3),
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.enableBackButton ?
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Icon(
                              IconlyLight.arrow_left,
                              color: primaryOrange,
                              size: 25,
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              backgroundColor: _themesController.getContainerBgColor(),
                              shape: CircleBorder(),
                            ),
                          ): Container(),
                          widget.enableSettingsButton ? ElevatedButton(
                            onPressed: () => goToSettings(),
                            child: Icon(
                              IconlyLight.setting,
                              color: primaryOrange,
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _themesController.getContainerBgColor(),
                              shape: CircleBorder(),
                            ),
                          ) : VenUser().userKey.value != 0 ? CustomOptionsPopupMenu(
                            backgroundColor: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.7),
                            shape: BoxShape.circle,
                            padding: EdgeInsets.all(6),
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            popupItems: [
                              CustomOptionPopupMenuItem(
                                text: Text(!userData.isBlocked ? "Block" : "Unblock", style: TextStyle(color: Colors.red)),
                                icon: !userData.isBlocked ? CustomIcon(icon: 'assets/icons/block-user.svg' ,color: Colors.red, size: 27) : null,
                                onTap: () => updateBlockStatus()
                              ),
                              CustomOptionPopupMenuItem(
                                text: Text("Report", style: TextStyle(color: Colors.red)),
                                icon: CustomIcon(icon: 'assets/icons/caution.svg' ,color: Colors.red, size: 27),
                                onTap: () => reportUser(user)
                              )
                            ]
                          ) : Container(),
                        ],
                      )
                    ),
                  )
                )
              )
            ),
            top: 0,
            left: 0,
            right: 0,
            bottom: 0
          ),

          Positioned(
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: _themesController.getContainerBgColor(),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),
            ),
            bottom: -1,
            left: 0,
            right: 0,
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(maxHeight: getProportionateScreenHeight(105)),
              decoration: BoxDecoration(
                color: _themesController.getContainerBgColor(),
                border: Border.all(
                  color: _themesController.getContainerBgColor(),
                  width: 0.1
                ),
                shape: BoxShape.circle,
                // image: DecorationImage(
                //   fit: BoxFit.contain,
                //   image: NetworkImage(user.userAvatar!)
                // )
              ),
              child: MyAvatar(
                photo: user.userAvatar!,
                size: getProportionateScreenHeight(50),
              ),
            ),
          )
        ],
      )
    );
  }

  SliverToBoxAdapter _buildUserDetails(ThemeData theme, UserModel user) {
    return SliverToBoxAdapter(
      child: ListView(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        user.displayName != null && user.displayName != '' ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${userData.displayName!} ",
                                style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if(user.isVerified!)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: CustomIcon(
                                    icon: 'assets/icons/verified-account.svg',
                                    size: 14,
                                    color: primaryOrange,
                                  )
                                ),
                              TextSpan(
                                text: "\n${userData.userName}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14
                                )
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ) :
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${user.userName!} ",
                                style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if(user.isVerified!)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: CustomIcon(
                                    icon: 'assets/icons/verified-account.svg',
                                    size: 14,
                                    color: primaryOrange,
                                  )
                                ),
                            ]
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    )
                  )
                ),
              ],
            )
          ),
          user.userBio == null || user.userBio == '' ? 
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
          ) : 
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Center(
              child: Text(
                user.userBio!,
                style: TextStyle(
                  fontSize: 16.0
                ),
              )
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .15),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: ZoomTapAnimation(
                        onTap: () => FirebaseAPI().firebaseId() == userData.fid || !userData.isBlocked ? goToUserFollowInfo(0) : null,
                        child: Column(
                          children: [
                            Text(
                              NumberFormat.format(userData.followerCount),
                              style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              "Followers",
                              style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey, fontSize: 12),
                            )
                          ],
                        )
                      )
                    )
                  ),

                  Container(
                    width: 1.0,
                    color: Colors.grey,
                    margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 10.0),
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                  ),

                  Expanded(
                    child: Center(
                      child: ZoomTapAnimation(
                        onTap: () => FirebaseAPI().firebaseId() == userData.fid || !userData.isBlocked ?  goToUserFollowInfo(1) : null,
                          child: Column(
                          children: [
                            Text(
                              NumberFormat.format(userData.followingCount),
                              style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              "Following",
                              style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey, fontSize: 12),
                            )
                          ],
                        )
                      )
                    )
                  ),

                  Container(
                    width: 1.0,
                    color: Colors.grey,
                    margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 10.0),
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                  ),

                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          ZoomTapAnimation(
                            child: Text(
                              NumberFormat.format(userData.pinCount!),
                              style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          ),
                          Text(
                            "Pins",
                            style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey, fontSize: 12),
                          )
                        ],
                      )
                    )
                  ),
                ],
              )
            )
          )
        ],
      )
    );
  }

  updateBlockStatus() {
    var _ = updateUserRelationship(
      context,
      userKey: VenUser().userKey.value,
      userFirebaseId: FirebaseAPI().firebaseId()!,
      relUserKey: userData.userKey!,
      relUserFirebaseId: userData.fid,
      blocked: userData.isBlocked ? false : true
    );

    setState(() {
      userData.isBlocked = !userData.isBlocked;
      if(userData.isFollowing! && userData.isBlocked){
        userData.isFollowing = false;
      }

    });
  }

  handleFollowStatus() async {

    if(userData.isFollowing!) {

      var result = await showCustomDialog(
        context: context,
        title: 'Unfollow ${userData.userName}', 
        description: "Are you sure you want to unfollow ${userData.userName}.",
        descAlignment: TextAlign.center,
        buttonDirection: Axis.vertical,
        buttons: {
          "Unfollow": {
            "action": () => Navigator.of(context).pop(true),
            "textColor": primaryOrange,
            "fontWeight": FontWeight.bold,
            "alignment": TextAlign.center
          },
          "Cancel": {
            "action": () => Navigator.of(context).pop(),
            "textColor": Get.isDarkMode ? Colors.white : Colors.black,
            "alignment": TextAlign.center
          }
        }
      );

      if(result != null && result) {
        FirebaseAPI().updateFollowStatusV2(widget.user.fid, !userData.isFollowing!);

        setState(() {
          // userData.followers.removeWhere((e) => e == FirebaseAPI().firebaseId());
          userData.isFollowing = false;
          userData.followerCount--;
        });
      }
    }else {
      FirebaseAPI().updateFollowStatusV2(widget.user.fid, !userData.isFollowing!);
      setState(() {
        userData.isFollowing = true;
        userData.followerCount++;
      });
    }
  }

  SliverToBoxAdapter _buildRowButtons(UserModel user, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * .25,
          right: MediaQuery.of(context).size.width * .25,
          top: 15
        ),
        child: Row(
          children: [
            Expanded(
              child: Container()
            ),

            ElevatedButton(
              onPressed: () => widget.isUser ? goToEditProfile() : userData.isBlocked ? updateBlockStatus() : handleFollowStatus(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Text(
                  widget.isUser ? "Edit Profile" : userData.isBlocked ? "Unblock" : userData.isFollowing! ? "Following" : "Follow",
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  ),
                )
              ),
              style: ElevatedButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.all(0),
                minimumSize: Size.zero,
                // minimumSize: Size(150, 35),
                elevation: 0,
                // primary: widget.isUser ? primaryOrange : userData.isFollowing! ? _themesController.getContainerBgColor() : primaryOrange,
                backgroundColor: widget.isUser ? _themesController.getContainerBgColor() : userData.isFollowing! ? _themesController.getContainerBgColor() : primaryOrange,
                shadowColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: widget.isUser ? Get.isDarkMode ? Colors.white : Colors.black  :  userData.isFollowing! ? Get.isDarkMode ? Colors.white : Colors.black : Colors.transparent,
                    width: 0.5
                  )
                )
              ),
            ),

            Expanded(
              child: !widget.isUser && !userData.isBlocked ? ElevatedButton(
                onPressed: () => openMessages(),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CustomIcon(
                    icon: 'assets/icons/send.svg',
                    color: Get.isDarkMode ? Colors.white : Colors.black, 
                    size: 18,
                  )
                ),
                style: ElevatedButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(0),
                  minimumSize: Size.zero,
                  shape: CircleBorder(
                    side: BorderSide(
                      color :Get.isDarkMode ? Colors.white : Colors.black,
                      width: 0.5
                    )
                  ),
                  backgroundColor: _themesController.getContainerBgColor()
                ),
              ) : Container()
            )
          ],
        )
      )
    );
  }

  // SliverToBoxAdapter _buildRowButtons(UserModel user, ThemeData theme) {
  //   return SliverToBoxAdapter(
  //     child: Padding(
  //       padding: EdgeInsets.only(top: 15),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           // ElevatedButton(
  //           //   child: Icon(IconlyBroken.location, color: Colors.orange, size: 30),
  //           //   onPressed: () {},
  //           //   style: ElevatedButton.styleFrom(
  //           //     shape: CircleBorder(),
  //           //     primary: Colors.white 
  //           //   ),
  //           // ),
  //           ElevatedButton(
  //             onPressed: () => widget.isUser ? goToEditProfile() : handleFollowStatus(),
  //             child: Text(
  //               widget.isUser ? "Edit Profile" :
  //               userData.isFollowing! ? "Following" : "Follow",
  //               style: TextStyle(
  //                 color: Get.isDarkMode ? Colors.white : Colors.black,
  //               ),
  //             ),
  //             style: ElevatedButton.styleFrom(
  //               // minimumSize: Size(150, 35),
  //               elevation: 0,
  //               // primary: widget.isUser ? primaryOrange : userData.isFollowing! ? _themesController.getContainerBgColor() : primaryOrange,
  //               backgroundColor: widget.isUser ? _themesController.getContainerBgColor() : userData.isFollowing! ? _themesController.getContainerBgColor() : primaryOrange,
  //               shadowColor: Colors.transparent,
  //               splashFactory: NoSplash.splashFactory,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20),
  //                 side: BorderSide(
  //                   color: widget.isUser ? Get.isDarkMode ? Colors.white : Colors.black  :  userData.isFollowing! ? Get.isDarkMode ? Colors.white : Colors.black : Colors.transparent,
  //                   width: 0.5
  //                 )
  //               )
  //             ),
  //           ),
  //           !widget.isUser ? ElevatedButton(
  //             onPressed: () {},
  //             child: Icon(
  //               IconlyBroken.send, 
  //               color: Get.isDarkMode ? Colors.white : Colors.black, 
  //               size: 18
  //             ),
  //             style: ElevatedButton.styleFrom(
  //               shape: CircleBorder(
  //                 side: BorderSide(
  //                   color:Get.isDarkMode ? Colors.white : Colors.black,
  //                   width: 0.5
  //                 )
  //               ),
  //               backgroundColor: _themesController.getContainerBgColor()
  //             ),
  //           ) : Container()
  //         ],
  //       )
  //     )
  //   );
  // }

  SliverToBoxAdapter _buildUserSubDetails(UserModel user) {
    return SliverToBoxAdapter(
      child: Container(
        // color: 
      ),
    );
  }

  SliverToBoxAdapter _buildTabs() {
    return SliverToBoxAdapter(
      child: TabBar(
        unselectedLabelColor: Get.isDarkMode ? null : Colors.black,
        labelColor: Get.isDarkMode ? null : primaryOrange,
        indicatorColor: primaryOrange,
        tabs: [
          Tab(
            child: Text(
              "Content",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            )
          ),
          Tab(
            child: Text(
              "Pins",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            )
          ),
          if(FirebaseAPI().firebaseId() == userData.fid)
            Tab(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'ProximaNova'
                  ),
                  children: [
                    TextSpan(
                      text: "Saved Pins ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        IconlyLight.hide,
                        size: 20,
                      )
                    )
                  ]
                )
              )
            ),
        ],
      ),
    );
  }

  SliverFillRemaining _buildUserContents(UserModel user) {
    return SliverFillRemaining(
      hasScrollBody: true,
      child: _buildTabView()
      // child: !_isLoadingContent ?
      //   _buildTabView() :
      //   GridView.builder(
      //     physics: NeverScrollableScrollPhysics(),
      //     padding: EdgeInsets.all(0),
      //     itemCount: 3,
      //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //       crossAxisCount: 3,
      //       mainAxisSpacing: 1.0,
      //       crossAxisSpacing: 1.0,
      //       childAspectRatio: 0.9
      //     ),
      //     itemBuilder: (context, i) {
      //       return Container(
      //         child: Skeleton.rectangular(height: 40)
      //       );
      //     }
      //   )
    );
  }

  _contentTab() {
    if(_isLoadingContent) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: 3,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 0.9
        ),
        itemBuilder: (context, i) {
          return Container(
            child: Skeleton.rectangular(height: 40)
          );
        }
      );
    }else if(pinContent != null && pinContent!.isNotEmpty && !userData.isBlocked){
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: pinContent!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 1.0
        ),
        itemBuilder: (context, i) {
          return PinContentBuilder(pinContent: pinContent![i], user: userData, pinContents: pinContent!);
        }
      );
    }else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: CustomIcon(
                size: MediaQuery.of(context).size.height * 0.1,
                color: Get.isDarkMode ? Colors.white : Colors.black,
                icon: 'assets/icons/photo.svg'
              )
            ),
            Text(
              "No pin content yet",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            )
          ],
        )
      );
    }
  }

  _pinsTab() {
    if(_isLoadingContent) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: 3,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 0.9
        ),
        itemBuilder: (context, i) {
          return Container(
            child: Skeleton.rectangular(height: 40)
          );
        }
      );
    }else if(pins != null && pins!.isNotEmpty && !userData.isBlocked) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: pins!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 1.0
        ),
        itemBuilder: (context, i) {
          // return Text(pins![i].pinName!);
          return PinBuilder(pin: pins![i]);
        },
      );
    }else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: CustomIcon(
                size: MediaQuery.of(context).size.height * 0.1,
                color: Get.isDarkMode ? Colors.white : Colors.black,
                icon: 'assets/icons/location2.svg'
              )
            ),
            Text(
              "No pins yet",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            )
          ],
        )
      );
    }
  }

  _savedPinsTab() {
    if(_isLoadingSavedPins) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: 3,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 0.9
        ),
        itemBuilder: (context, i) {
          return Container(
            child: Skeleton.rectangular(height: 40)
          );
        }
      );
    }else if(savedPins.isNotEmpty) {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: savedPins.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 1.0
        ),
        itemBuilder: (context, i) {
          return PinBuilderV2(pin: savedPins[i]);
        },
      );
    }else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: CustomIcon(
                size: MediaQuery.of(context).size.height * 0.1,
                color: Get.isDarkMode ? Colors.white : Colors.black,
                icon: 'assets/icons/location2.svg'
              )
            ),
            Text(
              "No saved pins",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            )
          ],
        )
      );
    }
  }

  _buildTabView() {
    return TabBarView(
      children: [
        _contentTab(),
        _pinsTab(),
        if(FirebaseAPI().firebaseId() == userData.fid)
          _savedPinsTab()
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: DefaultTabController(
        length: FirebaseAPI().firebaseId() == userData.fid ? 3 : 2,
        child: CustomRefreshIndicator(
          child: CustomScrollView(
            shrinkWrap: true,
            // physics: BouncingScrollPhysics(),
            slivers: [
              _buildHeaderWithAvatar(userData),
              _buildUserDetails(theme, userData),
              _buildRowButtons(userData, theme),
              _buildUserSubDetails(userData),
              _buildTabs(),
              _buildUserContents(userData),
            ],
          ),
          onRefresh: _refreshUser,
          builder: WidgetIndicatorDelegate(
            displacement: 0,
            backgroundColor: Colors.transparent,
            withRotation: false,
            // edgeOffset: MediaQuery.of(context).size.height * 0.06,
            edgeOffset: MediaQuery.of(context).padding.top,
            builder: (context, controller) {
              return CupertinoActivityIndicator(
                radius: 13,
              );
            },
          )
        ),
      )
    ); 
  }
}

class ProfileSkeletonShimmer extends StatelessWidget {
  final bool enableBackButton;
  final bool enableSettingsButton;
  ProfileSkeletonShimmer({Key? key, required this.enableBackButton, required this.enableSettingsButton}) : super(key: key);

  final ThemesController _themesController = Get.find();

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    void goToSettings() {
      SettingsScreen screen = SettingsScreen();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
    }

    SliverAppBar _buildHeader() {
      return SliverAppBar(
        automaticallyImplyLeading: false,
        floating: true,
        stretch: true,
        pinned: false,
        expandedHeight: MediaQuery.of(context).size.height * 0.22,
        flexibleSpace: Stack(
          children: [
            Positioned(
              child: Container(
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Stack(
                      children: [
                        Container(
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.white.withOpacity(0.3),
                                child: Skeleton.rectangular(height: MediaQuery.of(context).size.height),
                              )
                            )
                          )
                        ),
                        Container(
                      // alignment: Alignment.center,
                      // color: Colors.white.withOpacity(0.3),
                      child: Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            enableBackButton ?
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Icon(
                                IconlyLight.arrow_left,
                                color: primaryOrange,
                                size: 25,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                primary: _themesController.getContainerBgColor(),
                                shape: CircleBorder(),
                              ),
                            ): Container(),
                            enableSettingsButton ? ElevatedButton(
                              onPressed: () => goToSettings(),
                              child: Icon(
                                IconlyLight.setting,
                                color: primaryOrange,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                primary: _themesController.getContainerBgColor(),
                                shape: CircleBorder(),
                              ),
                            ) : Container()
                          ],
                        )
                      ),
                    )
                      ]
                    )
                  )
                )
              ),
              top: 0,
              left: 0,
              right: 0,
              bottom: 0
            ),

            Positioned(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: _themesController.getContainerBgColor(),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(35),
                  ),
                ),
              ),
              bottom: -1,
              left: 0,
              right: 0,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(maxHeight: getProportionateScreenHeight(105)),
                child: Skeleton.circular(height: MediaQuery.of(context).size.height * 1, seconds: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // image: DecorationImage(
                  //   fit: BoxFit.contain,
                  //   image: NetworkImage(data.userAvatar!)
                  // )
                )
              ),
            )
          ],
        )
      );
    }

    return CustomScrollView(
      slivers: [
        _buildHeader(),
        SliverToBoxAdapter(
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              // NAME
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Skeleton.rectangular(height: MediaQuery.of(context).size.height * 0.03, width: MediaQuery.of(context).size.width * 0.7)
                )
              ),
              // LOCATION
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 20.0),
                  child: Skeleton.rectangular(height: MediaQuery.of(context).size.height * 0.023, width: MediaQuery.of(context).size.width * 0.5, seconds: 3),
                )
              ),
            ],
          )
        )
      ],
    );
  }
}

class PinBuilder extends StatelessWidget {
  final Content pin;
  PinBuilder({Key? key, required this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: () {
        PinScreen screen = PinScreen(pinKey: pin.pinKey!);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: MapPreview(
              latitude: double.parse(pin.pinLocation!.split(',')[0]),
              longitude: double.parse(pin.pinLocation!.split(',')[1]),
              borderRadius: 0,
              height: double.infinity,
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Text(
                      pin.pinName!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }
}

class PinBuilderV2 extends StatelessWidget {
  final Pin pin;
  PinBuilderV2({Key? key, required this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: () {
        PinScreen screen = PinScreen(pinKey: pin.pinKey);
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: PhotoHero(
              tag: pin.featuredPhoto!,
              photoUrl: pin.featuredPhoto!
            )
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: Get.isDarkMode ? ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4) : ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Text(
                      pin.title!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    )
                  ),
                )
              )
            )
          )
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Container(
          //           color: Colors.black.withOpacity(0.4),
          //           child: Text(
          //             pin.title!,
          //             textAlign: TextAlign.center,
          //             maxLines: 1,
          //             overflow: TextOverflow.ellipsis,
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               color: Colors.white
          //             ),
          //           ),
          //         )
          //       )
          //     ]
          //   )
          // )
        ]
      )
    );
  }
}

class PinContentBuilder extends StatelessWidget {
  final Content pinContent;
  final List<Content> pinContents;
  final UserModel user;
  final Size size;
  PinContentBuilder({Key? key, required this.pinContent, required this.user, this.size = const Size(130, 130), this.pinContents = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      child: Stack(
        children: [
          Positioned.fill(
            child: PhotoHero(
              tag: pinContent.contentUrls.first,
              photoUrl: pinContent.contentUrls.first,
              onTap: () {
                // Navigator.of(context).push(SwipeablePageRoute(builder: (context) {
                //   return DisplayContentListScreen(content: pinContent, user: user, contents: pinContents);
                // }));
                Navigator.of(context).push(CupertinoPageRoute<void>(
                  builder: (BuildContext context) {
                    return DisplayContentListScreen(content: pinContent, user: user, contents: pinContents);
                  }
                ));
              },
            )
          ),
          pinContent.contentUrls.length > 1 ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topRight,
                child: CustomIcon(
                  icon: 'assets/icons/photo-gallery.svg',
                  size: 30,
                  color: Colors.white,
                )
              )
            ),
          ) : Container()
        ]
      )
    );
  }
}

void showOverlayMessage({
  required BuildContext context,
  required Offset offset,
  required String message,
  Duration duration = const Duration(milliseconds: 1000)
}) {
  OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
      builder: (context) => OverlayMessageWidget(offset: offset, msg: message)
  );
  Overlay.of(context).insert(overlayEntry);
  Timer(duration, () =>  overlayEntry.remove());
}

class OverlayMessageWidget extends StatelessWidget {
  final Offset offset;
  final String msg;
  OverlayMessageWidget({Key? key, required this.offset, required this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textSpan = TextSpan(
      text: msg,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white
      )
    );
    final Size size = (TextPainter(
        text: textSpan,
        // maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout())
    .size;

    return Positioned(
      top: 0,
      left: 0,
      child: Transform.translate(
        offset: Offset(offset.dx - (size.width / 2), offset.dy - (size.height / 2)),
        child: IgnorePointer(
          child: DropShadow(
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstants.gray600.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: DefaultTextStyle(
                style: TextStyle(),
                child: Text.rich(
                  textSpan,
                  textAlign: TextAlign.center,
                ),
              )
            )
          )
        )
      ),
    );
  }
}