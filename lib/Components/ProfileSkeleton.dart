import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Helpers/NumberFormat.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Screens/SettingsScreen/SettingsScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProfileSkeleton extends StatefulWidget {
  final UserModel user;
  ProfileSkeleton({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileSkeleton createState() => _ProfileSkeleton();
}

class _ProfileSkeleton extends State<ProfileSkeleton> {
  final ThemesController _themesController = Get.find();

  void goToSettings() {
    SettingsScreen settingsScreen = SettingsScreen();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => settingsScreen));
  }

  SliverAppBar _buildHeaderWithAvatar(UserModel user) {
    return SliverAppBar(
      floating: true,
      stretch: true,
      pinned: false,
      expandedHeight: MediaQuery.of(context).size.height * 0.15,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(),
                        Padding(
                          padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height * 0.15) / 9),
                          child: ElevatedButton(
                            onPressed: () => goToSettings(),
                            child: Icon(IconlyLight.setting),
                            style: ElevatedButton.styleFrom(
                              elevation: 3,
                              shadowColor: primaryOrange,
                              primary: primaryOrange,
                              shape: CircleBorder(),
                            ),
                          )
                        )
                      ],
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
        ],
      )
    );
  }

  SliverToBoxAdapter _buildUserDetails(ThemeData theme, UserModel user) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            user.displayName == null ? Container() : Center(
              child: Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: Text(
                  user.displayName!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0
                  ),
                )
              )
            ),
            SizedBox(height: 5),
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
                ZoomTapAnimation(
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: NumberFormat.format(user.followerCount!),
                          style: theme.textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.w900
                          )
                        ),
                        TextSpan(
                          text: ' followers',
                          style: theme.textTheme.bodyText2
                        )
                      ],
                    ),
                  )
                ),
                ZoomTapAnimation(
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: NumberFormat.format(user.followingCount!),
                          style: theme.textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.w900
                          )
                        ),
                        TextSpan(
                          text: ' following',
                          style: theme.textTheme.bodyText2
                        )
                      ],
                    ),
                  )
                ),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: NumberFormat.format(0),
                        style: theme.textTheme.subtitle1!.copyWith(
                          fontWeight: FontWeight.w900
                        )
                      ),
                      TextSpan(
                        text: ' pins',
                        style: theme.textTheme.bodyText2
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        )
      )
    );
  }

  SliverToBoxAdapter _buildRowButtons(UserModel user) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 10),
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
              onPressed: () {},
              child: Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(360, 40),
                elevation: 10,
                shadowColor: primaryOrange,
                primary: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
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
        ),
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
        _buildRowButtons(widget.user),
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