import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/FireBaseServices.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/Indicator.dart';
import 'package:venture/Helpers/LocationHandler.dart';
import 'package:venture/Screens/PinScreen/PinScreen.dart';
import 'package:venture/Screens/ProfileScreen.dart/ProfileScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Components/ExpandableText.dart';
import 'package:venture/Helpers/TimeFormat.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Helpers/ZoomOverlay.dart';

class PostSkeleton extends StatefulWidget{
  final Content content;
  PostSkeleton({Key? key, required this.content}) : super(key: key);

  @override
  _PostSkeleton createState() => _PostSkeleton();
}

class _PostSkeleton extends State<PostSkeleton> {
  final ThemesController _themesController = Get.find();
  final HomeController _homeController = Get.find();
  CarouselController controller = CarouselController();
  int currentIndex = 0;

  _showOptions(ThemeData theme) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        height: 320,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("Delete", style: theme.textTheme.bodyText1!.copyWith(color: Colors.red)),
              onTap: () {
                // _showDeleteConfirmation();
                Get.back();
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      )
    );
  }

  deletePost() {
    print("DELETE POST");
  }

  goToProfile(Content content) {
    ProfileScreen screen  = ProfileScreen(userKey: content.user!.userKey!);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildTitle(ThemeData theme, Content content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ZoomTapAnimation(
              onTap: () {
                PinScreen screen = PinScreen(pinKey: content.pinKey!);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
              },
              child: Text(
                content.pinName!,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 2,
                style: theme.textTheme.headline4!.copyWith(),
              )
            )
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  CustomIcon(
                    icon: 'assets/icons/star.svg',
                    size: 27,
                    color: primaryOrange,
                  ),
                  Text(
                    "${content.rating ?? 0.toInt()}",
                    style: TextStyle(
                      fontSize: 17,
                      // fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
              Text(
                "${content.totalReviews ?? 0} reviews",
                style: TextStyle(
                  fontSize: 15,
                  // fontWeight: FontWeight.bold
                ),
              )
            ],
          )
        ],
      )
    );
  }

  Widget _buildHeaderDetails(ThemeData theme, Content content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          ZoomTapAnimation(
            onTap: () => goToProfile(content),
            child: MyAvatar(
              size: 18,
              photo: content.user!.userAvatar!
            )
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // content.user!.displayName != null ?
                // Text(content.user!.displayName!,
                //   style: theme.textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                // ) :
                // Text('@'+content.user!.userName!,
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold
                //   ),
                // ),
                GestureDetector(
                  onTap: () => goToProfile(content),
                  child: Text(
                    content.user!.userName!,
                    style: theme.textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                  )
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    content.pinLocation != null ? FutureBuilder<List<Placemark>>(
                      future: LocationHandler.addressFromCoords(context, double.parse(content.pinLocation!.split(',')[0]), double.parse(content.pinLocation!.split(',')[1])),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) {
                          return Container();
                        } else {
                          return Flexible(
                            fit: FlexFit.loose,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIcon(
                                  size: 15,
                                  icon: 'assets/icons/location.svg',
                                  color: primaryOrange,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  "${snapshot.data![0].locality}, ${snapshot.data![0].administrativeArea}",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              ]
                            )
                          );
                        }
                      }
                     ) : Container(),
                    content.pinLocation != null ? Text(
                      " ${String.fromCharCode(0x00B7)} ",
                      style: TextStyle(
                        // fontSize: 25
                      ),
                    ) : Container(),
                    TimeFormat().withoutDate(
                      content.timestamp,
                      numericDates: false,
                      style: TextStyle(
                        color: Colors.grey
                      )
                    )
                  ],
                )
              ],
            )
          ),
          ZoomTapAnimation(
            onTap: () {
              
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: FutureBuilder(
                future: LocationHandler.getDistanceFromCoords(content.pinLocation!),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return Text(
                      "Maps",
                      style: theme.textTheme.bodyText2!.copyWith(color: Colors.white)
                    );
                  } else {
                    return Text(
                      "${snapshot.data} miles",
                      style: theme.textTheme.bodyText2!.copyWith(color: Colors.white)
                    );
                  }
                }
              ),
              decoration: BoxDecoration(
                color: primaryOrange,
                borderRadius: BorderRadius.circular(50),
              ),
            )
          )
        ],
      )
    );
  }

  _buildCaption(ThemeData theme, Content content) {
    if (content.contentCaption != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        child: ExpandableText(
          content.contentCaption,
          trimLines: 2,
          // style: theme.textTheme.bodyText1
        )
      );
    } else {
      return Container();
    }
  }

  goToMaps(String? location) {
    _homeController.goToTab(2);
    if(location != null) {
      List<String> loc = location.split(',');
      _themesController.navigateMap(loc);
    }
  }

  _buildContentActions(ThemeData theme, Content content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          StreamBuilder(
            stream: FirebaseServices().getReactions(content.contentKey.toString()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("Like");
              } else {
                var data = snapshot.data as List<dynamic>;
                return Row(
                  children: [
                    ZoomTapAnimation(
                      child: Text(
                        data.length.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                    SizedBox(width: 10),
                    ZoomTapAnimation(
                      child: Text(
                        "Like",
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                    )
                  ],
                );
              }
            }
          )
        ],
      ),
    );
  }

  _buildContent(Content content) {
    return Expanded(
      child: Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider(
              carouselController: controller,
              items: List<Widget>.generate(content.contentUrls.length, (index) {
                return ZoomOverlay(
                  twoTouchOnly: true,
                  minScale: 1,
                  child: ClipRRect(
                    // borderRadius: BorderRadius.circular(20.0),
                    child: CachedNetworkImage(
                      // fit: BoxFit.contain,
                      fit: BoxFit.cover,
                      imageUrl: content.contentUrls[index].toString(),
                      progressIndicatorBuilder: (context, url, downloadProgress) {
                        return Skeleton.rectangular(
                          height: 250,
                          // borderRadius: 20.0
                        );
                      }
                    )
                  )
                );
              }),
              options: CarouselOptions(
                enableInfiniteScroll: false,
                disableCenter: true,
                viewportFraction: 1.0,
                onPageChanged: (index, _) {
                  setState(() {
                    currentIndex = index;
                  });
                }
              ),
            )
          ),
          content.contentUrls.length > 1 ? Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Indicator(
                  length: content.contentUrls.length,
                  index: currentIndex
                )
              ],
            )
          ): Container()
        ]
      )
      // child: ZoomOverlay(
      //   twoTouchOnly: true,
      //   minScale: 1,
      //   child: ClipRRect(
      //     // borderRadius: BorderRadius.circular(20.0),
      //     child: CachedNetworkImage(
      //       // width: double.infinity,
      //       fit: BoxFit.cover,
      //       imageUrl: content.contentUrl,
      //       progressIndicatorBuilder: (context, url, downloadProgress) {
      //         return Skeleton.rectangular(
      //           height: 250,
      //           borderRadius: 20.0
      //         );
      //       }
      //     )
      //   )
      // )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
        color: _themesController.getContainerBgColor(),
      ),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(theme, widget.content),
          _buildHeaderDetails(theme, widget.content),
          _buildCaption(theme, widget.content),
          _buildContentActions(theme, widget.content),
          SizedBox(height: 5),
          _buildContent(widget.content)
        ],
      )
    );
  }
}

class PostSkeletonShimmer extends StatelessWidget {
  PostSkeletonShimmer({Key? key}) : super(key: key);
  final ThemesController _themesController = Get.find();

  Widget _buildHeaderDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
        child: Row(
        children: [
          Skeleton.circular(
            width: 45,
            height: 45
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton.rectangular(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.6
              ),
              SizedBox(height: 5),
              Skeleton.rectangular(
                height: 15,
                width: MediaQuery.of(context).size.width * 0.3
              )
            ],
          )
        ],
      )
    );
  }

  Widget _buildContent(BuildContext context) {
    return Expanded(
      child: Skeleton.rectangular(
        height: double.infinity,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _themesController.getContainerBgColor(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderDetails(context),
          SizedBox(height: 10),
          _buildContent(context)
        ],
      )
    );
  }
}