import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:async/async.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/DashboardScreen/Components/LoginOverlay.dart';
import 'package:venture/Screens/DashboardScreen/Components/ProfileSkeleton.dart';
import 'package:venture/Screens/SettingsScreen/SettingsScreen.dart';
import 'package:venture/Models/User.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:get/get.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({Key? key}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with AutomaticKeepAliveClientMixin<ProfileTab> {
  final ThemesController _themesController = Get.find();
  AsyncMemoizer _memoizer = AsyncMemoizer();
  static double avatarMaximumRadius = 40.0;
  static double avatarMinimumRadius = 15.0;
  double avatarRadius = avatarMaximumRadius;
  double expandedHeader = 130.0;
  double translate = -avatarMaximumRadius;
  bool isExpanded = true;
  double offset = 0.0;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
  }

  void goToSettings() {
    SettingsScreen settingsScreen = SettingsScreen();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => settingsScreen));
  }

  _fetch(int userKey) {
    return _memoizer.runOnce(() async {
      var res = await getUser(context, userKey);
      return res;
    });
  }

  Widget _buildBody(int userKey) {
    var apiCall = _fetch(userKey);
    return FutureBuilder(
      future: apiCall,//getUser(context, userKey),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          return ProfileSkeleton();
        }else {
          UserModel data = snapshot.data as UserModel;
          return CustomScrollView(
            // physics: ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
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
                              data.userAvatar!,
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
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: NetworkImage(data.userAvatar!)
                          )
                        )
                      ),
                    )
                  ],
                )
              ),
              SliverToBoxAdapter(
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 5),
                    data.displayName == null ? Container() : Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          "Devin Williams",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0
                          ),
                        )
                      )
                    ),
                    SizedBox(height: 5),
                    data.userLocation == null ? Container() : Center(
                      child: Text(
                        "Cincinnati, OH",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.0
                        ),
                      )
                    ),
                    Row(
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    SizeConfig().init(context);
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: User().userKey, 
        builder: (context, value, _) {
          return Stack(
            children: [
              value != 0 ? _buildBody(value as int) : Container(),
              value == 0 ? ProfileSkeleton() : Container(),
              value == 0 ? LoginOverlay() : Container(),
              value == 0 ? Positioned(
                right: 5,
                top: 5,
                child: ElevatedButton(
                  onPressed: () => goToSettings(),
                  child: Icon(IconlyLight.setting),
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shadowColor: primaryOrange,
                    primary: primaryOrange,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(20.0),
                    // )
                    shape: CircleBorder(),
                  ),
                )
              ) : Container(),
            ]
          );
        }
      )
    );
  }
}

class MyAvatar extends StatelessWidget {
  final double? size;
  final String? photo;

  const MyAvatar({Key? key, this.size, @required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[800]!,
              width: 2.0,
            ),
            shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: CircleAvatar(
            radius: size,
            backgroundImage: NetworkImage("https://venture-content.s3.amazonaws.com/images/default-avatar.jpg"),
          ),
        ),
      ),
    );
  }
}