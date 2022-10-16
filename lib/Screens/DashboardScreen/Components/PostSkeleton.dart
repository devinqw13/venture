import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/LocationHandler.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Components/ExpandableText.dart';
import 'package:venture/Helpers/TimeFormat.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Models/Content.dart';

class PostSkeleton extends StatefulWidget{
  final Content content;
  PostSkeleton({Key? key, required this.content}) : super(key: key);

  @override
  _PostSkeleton createState() => _PostSkeleton();
}

class _PostSkeleton extends State<PostSkeleton> {
  final ThemesController _themesController = Get.find();
  final HomeController _homeController = Get.find();

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

  Widget _buildHeaderDetails(ThemeData theme, Content content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          ZoomTapAnimation(
            onTap: () => print("GO TO PROFILE"),
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
                content.user!.displayName != null ?
                Text(content.user!.displayName!,
                  style: theme.textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                ) :
                Text('@'+content.user!.userName!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
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
                    TimeFormat().withDate(
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
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Row(
          //       children: [
          //         CustomIcon(
          //           icon: 'assets/icons/star.svg',
          //           size: 23,
          //           color: primaryOrange,
          //         ),
          //         SizedBox(width: 2),
          //         Text(
          //           content.rating == null ? "No Rating" : content.rating.toString(),
          //           style: TextStyle(
          //             fontWeight: FontWeight.w600
          //           ),
          //         )
          //       ],
          //     ),
          //     Text(
          //       "${content.totalReviews} reviews"
          //     )
          //   ],
          // )
          // ValueListenableBuilder(
          //   valueListenable: User().userKey, 
          //   builder: (context, value, _) {
          //     return value == 0 ? Container() : CustomOptionsPopupMenu(
          //       popupItems: [
          //         if(value == content.user!.userKey)
          //           CustomOptionPopupMenuItem(
          //             text: Text(
          //               "Delete Post",
          //               style: theme.textTheme.subtitle1!.copyWith(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 16),
          //             ),
          //             icon: Icon(IconlyLight.delete, color: Colors.red),
          //             onTap: () => print("DELETE POST")
          //           ),
          //         if(value == content.user!.userKey)
          //           CustomOptionPopupMenuItem(
          //             text: Text(
          //               "Edit",
          //               style: theme.textTheme.subtitle1!,
          //             ),
          //             onTap: () => print("EDIT")
          //           )
          //       ],
          //     );
          //   }
          // )
          // ElevatedButton(
          //   onPressed: () => _showOptions(theme),
          //   child: Icon(Icons.more_horiz),
          //   style: ElevatedButton.styleFrom(
          //     padding: EdgeInsets.all(0),
          //     // elevation: 0,
          //     // shadowColor: primaryOrange,
          //     primary: Colors.transparent,
          //     // shape: RoundedRectangleBorder(
          //     //   borderRadius: BorderRadius.circular(20.0),
          //     // )
          //     shape: CircleBorder(),
          //   ),
          // )
        ],
      )
    );
  }

  _buildCaption(ThemeData theme, Content content) {
    if (content.contentCaption != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
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
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Row(
        children: [
          FutureBuilder(
            future: LocationHandler.getDistanceFromCoords(content.pinLocation!),
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return Container();
              } else {
                return ZoomTapAnimation(
                  onTap: () => goToMaps(content.pinLocation!),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Text(
                      "${snapshot.data} miles",
                      style: theme.textTheme.bodyText2!.copyWith(color: Colors.white)
                    ),
                    decoration: BoxDecoration(
                      color: primaryOrange,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  )
                );
                // return ElevatedButton(
                //   onPressed: () => goToMaps(content.pinLocation!),
                //   child: Row(
                //     children: [
                //       Text(
                //         "${snapshot.data} miles",
                //         style: TextStyle(
                //           color: Colors.white
                //         ),
                //       )
                //     ],
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     elevation: 0,
                //     primary: primaryOrange,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(20.0),
                //     )
                //   ),
                // );
              }
            }
          )
        ],
      ),
    );
  }

  _buildContent(Content content) {
    return Expanded(
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(20.0),
        child: CachedNetworkImage(
          width: double.infinity,
          fit: BoxFit.cover,
          imageUrl: content.contentUrl,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Skeleton.rectangular(
              height: 250,
              borderRadius: 20.0
            );
          }
        )
      )
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

  Widget _buildHeaderDetails(BuildContext context) {
    return Row(
      children: [
        Skeleton.circular(
          width: 60,
          height: 60
        ),
        SizedBox(width: 20),
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
    );
  }

  Widget _buildContent(BuildContext context) {
    return Skeleton.rectangular(
      height: 250,
      borderRadius: 20.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          children: [
            _buildHeaderDetails(context),
            SizedBox(height: 10),
            _buildContent(context)
          ],
        )
      )
    );
  }
}