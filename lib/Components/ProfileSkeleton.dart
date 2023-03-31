import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Calls.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Helpers/MapPreview.dart';
import 'package:venture/Helpers/NumberFormat.dart';
import 'package:venture/Helpers/RefreshIndicator.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Helpers/PhotoHero.dart';
import 'package:venture/Screens/DisplayContentListScreen/DisplayContentListScreen.dart';
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
  bool _isLoadingContent = false;
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

  _initializeAsyncDependencies([bool showLoading = true]) async {
    // TODO: Incorporate user content caching
    if(showLoading) setState(() => _isLoadingContent = true);
    var results = await getContent(context, [userData.userKey!]);
    setState(() => _isLoadingContent = false);

    setState(() {
      pinContent = results.where((e) => e.contentFormat == ContentFormat.pinContent).toList();
      pins = results.where((e) => e.contentFormat == ContentFormat.pin).toList();
      userData.pinCount = pins!.length;
    });
  }

  void goToSettings() {
    SettingsScreen screen = SettingsScreen();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  _saveProfileData(String name, String bio) {
    Get.back();
  }

  _showEditProfileModal(UserModel user, ThemeData theme) {
    TextEditingController nameController = TextEditingController(text: user.displayName);
    TextEditingController bioController = TextEditingController(text: user.userBio);

    Get.bottomSheet(
      DismissKeyboard(
        child: Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode ? ColorConstants.gray900 : Colors.grey.shade50,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: theme.textTheme.subtitle1
                    ),
                  ),
                  Text("Edit profile", style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.w500)),
                  MaterialButton(
                    onPressed: () => _saveProfileData(nameController.text, bioController.text),
                    child: Text(
                      "Save",
                      style: theme.textTheme.subtitle1!.copyWith(
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            user.userAvatar!,
                          ),
                          fit: BoxFit.cover
                        )
                      ),
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            color: Colors.white.withOpacity(0.3),
                            child: Container(
                              height: getProportionateScreenHeight(80),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _themesController.getContainerBgColor(),
                                  width: 2.0
                                ),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: NetworkImage(user.userAvatar!)
                                )
                              )
                            ),
                          )
                        )
                      )
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? ColorConstants.gray600 : ColorConstants.gray50,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Name",
                              style: theme.textTheme.bodyText2,
                            ),
                            Flexible(
                              child: TextField(
                                controller: nameController,
                                readOnly: isLoading,
                                // controller: descTxtController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                  hintText: "",
                                ),
                              )
                            )
                          ],
                        ),
                      )
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? ColorConstants.gray600 : ColorConstants.gray50,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bio",
                              style: theme.textTheme.bodyText2,
                            ),
                            Flexible(
                              child: TextField(
                                maxLines: 5,
                                readOnly: isLoading,
                                // controller: descTxtController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                  hintText: "",
                                ),
                              )
                            )
                          ],
                        ),
                      )
                    ),
                    SizedBox(height: 50)
                  ],
                )
              )
            ],
          ),
        )
      )
    );
  }

  Future<void> _refreshUser() async {
    HapticFeedback.mediumImpact();
    var result = await FirebaseAPI().getUserDetails(userKey: userData.userKey.toString());
    if(result != null) {
      var u = UserModel.fromFirebaseMap(result.docs.first.data());
      setState(() => userData = u);
    }

    _initializeAsyncDependencies(false);
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
                  image: NetworkImage(
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
                              primary: _themesController.getContainerBgColor(),
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
                              primary: _themesController.getContainerBgColor(),
                              shape: CircleBorder(),
                            ),
                          ) : Container()
                        ],
                      )
                    ),
                    // child: Padding(
                    //   padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       widget.enableBackButton ? Expanded(
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             ElevatedButton(
                    //               onPressed: () => Navigator.of(context).pop(),
                    //               child: Icon(
                    //                 IconlyLight.arrow_left,
                    //                 color: primaryOrange,
                    //                 size: 25,
                    //               ),
                    //               style: ElevatedButton.styleFrom(
                    //                 elevation: 0,
                    //                 shadowColor: Colors.transparent,
                    //                 primary: _themesController.getContainerBgColor(),
                    //                 shape: CircleBorder(),
                    //                 splashFactory: NoSplash.splashFactory,
                    //               ),
                    //             )
                    //           ]
                    //         )
                    //       ) : Expanded(child:Container()),

                    //       _refreshing ? Expanded(
                    //         child: Column(
                    //           children: [
                    //             CupertinoActivityIndicator(
                    //               radius: 13,
                    //             ) 
                    //           ],
                    //         )
                    //       ) : Expanded(child:Container()),

                    //       widget.enableSettingsButton ? Expanded(
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.end,
                    //           children: [
                    //             ElevatedButton(
                    //               onPressed: () => goToSettings(),
                    //               child: Icon(
                    //                 IconlyLight.setting,
                    //                 color: primaryOrange,
                    //               ),
                    //               style: ElevatedButton.styleFrom(
                    //                 elevation: 0,
                    //                 primary: _themesController.getContainerBgColor(),
                    //                 shape: CircleBorder(),
                    //                 splashFactory: NoSplash.splashFactory,
                    //               ),
                    //             )
                    //           ],
                    //         )
                    //       ) : Expanded(child:Container()),
                    //     ],
                    //   )
                    // ),
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
                  width: 2.0
                ),
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: NetworkImage(user.userAvatar!)
                )
              )
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
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                user.displayName != null && user.displayName != '' ? user.displayName! : user.userName!,
                style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
              )
            )
          ),
          user.userBio == null ? Container() : Center(
            child: Text(
              user.userBio!,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0
              ),
            )
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .15),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          ZoomTapAnimation(
                            child: Text(
                              NumberFormat.format(userData.followerCount),
                              style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          ),
                          Text(
                            "Followers",
                            style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey, fontSize: 12),
                          )
                        ],
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
                              NumberFormat.format(userData.followingCount),
                              style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          ),
                          Text(
                            "Following",
                            style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey, fontSize: 12),
                          )
                        ],
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
            "textColor": Colors.white,
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
        padding: EdgeInsets.only(top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ElevatedButton(
            //   child: Icon(IconlyBroken.location, color: Colors.orange, size: 30),
            //   onPressed: () {},
            //   style: ElevatedButton.styleFrom(
            //     shape: CircleBorder(),
            //     primary: Colors.white 
            //   ),
            // ),
            ElevatedButton(
              onPressed: () => widget.isUser ? _showEditProfileModal(user, theme) : handleFollowStatus(),
              child: Text(
                widget.isUser ? "Edit Profile" :
                userData.isFollowing! ? "Following" : "Follow"
              ),
              style: ElevatedButton.styleFrom(
                // minimumSize: Size(150, 35),
                elevation: 0,
                primary: widget.isUser ? primaryOrange : userData.isFollowing! ? _themesController.getContainerBgColor() : primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: widget.isUser ? Colors.transparent :  userData.isFollowing! ? Get.isDarkMode ? Colors.white : Colors.black : Colors.transparent
                  )
                )
              ),
            ),
            // ElevatedButton(
            //   child: Icon(IconlyBroken.send, color: Colors.orange, size: 30),
            //   onPressed: () {},
            //   style: ElevatedButton.styleFrom(
            //     shape: CircleBorder(),
            //     primary: Colors.white 
            //   ),
            // )
          ],
        )
      )
    );
  }

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
              "Pins",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            )
          ),
          Tab(
            child: Text(
              "Content",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            )
          )
        ],
      ),
    );
  }

  SliverFillRemaining _buildUserContents(UserModel user) {
    return SliverFillRemaining(
      hasScrollBody: true,
      child: !_isLoadingContent ?
        _buildTabView() :
        GridView.builder(
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
        )
    );
  }

  _buildTabView() {
    return TabBarView(
      children: [
        pins != null && pins!.isNotEmpty ? GridView.builder(
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
        ) : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: CustomIcon(
                    size: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.white,
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
          ),
        pinContent != null && pinContent!.isNotEmpty ? GridView.builder(
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
        ) : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: CustomIcon(
                    size: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.white,
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
          ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // return  DefaultTabController(
    //   length: 2,
    //   child:CustomScrollView(
    //     shrinkWrap: true,
    //     // physics: BouncingScrollPhysics(),
    //     slivers: [
    //       _buildHeaderWithAvatar(widget.user),
    //       _buildUserDetails(theme, widget.user),
    //       _buildRowButtons(widget.user, theme),
    //       _buildUserSubDetails(widget.user),
    //       _buildTabs(),
    //       _buildUserContents(widget.user),
    //     ],
    //   ),
    // );
    return Scaffold(body:DefaultTabController(
      length: 2,
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
          edgeOffset: MediaQuery.of(context).size.height * 0.06,
          builder: (context, controller) {
            return CupertinoActivityIndicator(
              radius: 13,
            );
          },
        )
      ),
    )); 
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
                Navigator.of(context).push(CupertinoPageRoute<void>(
                  builder: (BuildContext context) {
                    return DisplayContentListScreen(content: pinContent, user: user, contents: pinContents);
                  }
                ));
                // Navigator.of(context).push(ScaleRoute(
                //   page:
                //     DisplayContentListScreen(content: pinContent, user: user, contents: pinContents)));
              },
            )
          ),
          pinContent.contentUrls.length > 1 ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: Align(
              alignment: Alignment.topRight,
              child: CustomIcon(
                icon: 'assets/icons/photo-gallery.svg',
                size: 30,
                color: Colors.white,
              )
            ),
          ) : Container()
        ]
      )
    );
  }
}