import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Helpers/NumberFormat.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Screens/SettingsScreen/SettingsScreen.dart';
import 'package:venture/Screens/EditProfileScreen/EditProfileScreen.dart';
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

class _ProfileSkeleton extends State<ProfileSkeleton> {
  final ThemesController _themesController = Get.find();
  bool isLoading = false;

  void goToSettings() {
    SettingsScreen screen = SettingsScreen();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  // void goToEditProfile(int? userKey) {
  //   final EditProfileScreen screen = EditProfileScreen(userKey: userKey!);
  //   Navigator.of(context).push(SlideUpDownPageRoute(page: screen, closeDuration: 400));
  // }

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
            mainAxisSize: MainAxisSize.min,
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
                          color: ColorConstants.gray50,
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
                          color: ColorConstants.gray50,
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
              // Container(
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //       image: NetworkImage(
              //         user.userAvatar!,
              //       ),
              //       fit: BoxFit.cover
              //     )
              //   ),
              //   child: ClipRRect(
              //     child: BackdropFilter(
              //       filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              //       child: Container(
              //         padding: EdgeInsets.symmetric(vertical: 12),
              //         alignment: Alignment.center,
              //         color: Colors.white.withOpacity(0.3),
              //         child: Container(
              //           height: getProportionateScreenHeight(80),
              //           decoration: BoxDecoration(
              //             border: Border.all(
              //               color: _themesController.getContainerBgColor(),
              //               width: 2.0
              //             ),
              //             shape: BoxShape.circle,
              //             image: DecorationImage(
              //               fit: BoxFit.contain,
              //               image: NetworkImage(user.userAvatar!)
              //             )
              //           )
              //         ),
              //       )
              //     )
              //   )
              // ),
              // SizedBox(height: 20),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 10),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 10),
              //     decoration: BoxDecoration(
              //       color: ColorConstants.gray50,
              //       borderRadius: BorderRadius.circular(10)
              //     ),
              //     child: Row(
              //       children: [
              //         Text(
              //           "Name",
              //           style: theme.textTheme.bodyText2,
              //         ),
              //         Flexible(
              //           child: TextField(
              //             controller: nameController,
              //             readOnly: isLoading,
              //             // controller: descTxtController,
              //             decoration: InputDecoration(
              //               contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              //               hintText: "",
              //             ),
              //           )
              //         )
              //       ],
              //     ),
              //   )
              // ),
              // SizedBox(height: 10),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 10),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              //     decoration: BoxDecoration(
              //       color: ColorConstants.gray50,
              //       borderRadius: BorderRadius.circular(10)
              //     ),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           "Bio",
              //           style: theme.textTheme.bodyText2,
              //         ),
              //         Flexible(
              //           child: TextField(
              //             maxLines: 5,
              //             readOnly: isLoading,
              //             // controller: descTxtController,
              //             decoration: InputDecoration(
              //               contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              //               hintText: "",
              //             ),
              //           )
              //         )
              //       ],
              //     ),
              //   )
              // ),
            ],
          ),
        )
      )
    );
  }

  _followAction(UserModel user) {
    print("FOLLOW/UNFOLLOW");
  }

  SliverAppBar _buildHeaderWithAvatar(UserModel user) {
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
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: primaryOrange,
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
                border: Border.all(
                  color: _themesController.getContainerBgColor(),
                  width: 4.0
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  ZoomTapAnimation(
                    child: Text(
                      NumberFormat.format(user.followerCount!),
                      style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  ),
                  Text(
                    "Followers",
                    style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey),
                  )
                ],
              ),
              Column(
                children: [
                  ZoomTapAnimation(
                    child: Text(
                      NumberFormat.format(user.followingCount!),
                      style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  ),
                  Text(
                    "Following",
                    style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey),
                  )
                ],
              ),
              Column(
                children: [
                  ZoomTapAnimation(
                    child: Text(
                      NumberFormat.format(user.pinCount!),
                      style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  ),
                  Text(
                    "Pins",
                    style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey),
                  )
                ],
              ),
            ],
          )
        ],
      )
    );
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
              onPressed: () => widget.isUser ? _showEditProfileModal(user, theme) : _followAction(user),
              child: Text(
                widget.isUser ? "Edit Profile" :
                user.isFollowing! ? "Following" : "Follow"
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(170, 35),
                elevation: 0,
                primary: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        _buildHeaderWithAvatar(widget.user),
        _buildUserDetails(theme, widget.user),
        _buildRowButtons(widget.user, theme),
        _buildUserSubDetails(widget.user)
        // SliverFixedExtentList(
        //   itemExtent: 50.0,
        //   delegate: SliverChildBuilderDelegate(
        //     (BuildContext context, int index) {
        //       return Container(
        //         alignment: Alignment.center,
        //         color: Colors.lightBlue[100 * (index + 1 % 9)],
        //         child: Text('List Item $index'),
        //       );
        //     },
        //   ),
        // )
      ],
    );
  }
}

class ProfileSkeletonShimmer extends StatelessWidget {
  ProfileSkeletonShimmer({Key? key}) : super(key: key);

  final ThemesController _themesController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: false,
          automaticallyImplyLeading: false,
          expandedHeight: MediaQuery.of(context).size.height * 0.15,
          flexibleSpace: Stack(
            children: [
              Positioned(
                child: Container(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.white.withOpacity(0.3),
                        child: Skeleton.rectangular(height: MediaQuery.of(context).size.height * 0.12),
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
                  height: 55,
                  decoration: BoxDecoration(
                    color: _themesController.getContainerBgColor(),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
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
                  constraints: BoxConstraints(maxHeight: getProportionateScreenHeight(103)),
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
              // Center(
              //   child: Skeleton.circular(height: MediaQuery.of(context).size.height * 1, seconds: 3),
              // )
            ],
          )
        ),
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
        // SliverFixedExtentList(
        //   itemExtent: 50.0,
        //   delegate: SliverChildBuilderDelegate(
        //     (BuildContext context, int index) {
        //       return Container(
        //         alignment: Alignment.center,
        //         color: Colors.lightBlue[100 * (index + 1 % 9)],
        //         child: Text('List Item $index'),
        //       );
        //     },
        //   ),
        // )
      ],
    );
  }
}