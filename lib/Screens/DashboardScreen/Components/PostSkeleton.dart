import "dart:math";
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mime/mime.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/CustomOptionsPopupMenu.dart';
import 'package:venture/Components/DropShadow.dart';
import 'package:venture/Components/FadeOverlay.dart';
import 'package:venture/Components/ReportSheet.dart';
import 'package:venture/Components/VideoPlayer.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Helpers/Indicator.dart';
import 'package:venture/Helpers/LocationHandler.dart';
import 'package:venture/Helpers/PhotoHero.dart';
import 'package:venture/Helpers/RatePinSheet.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/CommentScreen/CommentScreen.dart';
import 'package:venture/Screens/DashboardScreen/Components/LoginOverlay.dart';
import 'package:venture/Screens/LikedByScreen/LikedByScreen.dart';
import 'package:venture/Screens/PinScreen/PinScreen.dart';
import 'package:venture/Screens/ProfileScreen/ProfileScreen.dart';
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
  final String? heroTag;
  PostSkeleton({Key? key, required this.content, this.heroTag}) : super(key: key);

  @override
  _PostSkeleton createState() => _PostSkeleton();
}

class _PostSkeleton extends State<PostSkeleton> with AutomaticKeepAliveClientMixin<PostSkeleton> {
  final ThemesController _themesController = Get.find();
  final HomeController _homeController = Get.find();
  CarouselController controller = CarouselController();
  int currentIndex = 0;
  late Offset doubleTapPosition;
  GlobalKey _key = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  // _showOptions(ThemeData theme) {
  //   Get.bottomSheet(
  //     Container(
  //       padding: EdgeInsets.all(16),
  //       height: 320,
  //       decoration: BoxDecoration(
  //         color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(16),
  //           topRight: Radius.circular(16),
  //         )
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ListTile(
  //             title: Text("Delete", style: theme.textTheme.bodyText1!.copyWith(color: Colors.red)),
  //             onTap: () {
  //               // _showDeleteConfirmation();
  //               Get.back();
  //             },
  //           ),
  //           SizedBox(height: 16),
  //         ],
  //       ),
  //     )
  //   );
  // }

  deletePost(Content content) async {
    var result = await showCustomDialog(
      context: context,
      barrierDismissible: false,
      title: 'Delete post?', 
      description: "Are you sure you want to delete this post? It will be permanently deleted.",
      descAlignment: TextAlign.center,
      buttonDirection: Axis.vertical,
      buttons: {
        "Delete": {
          "action": () => Navigator.of(context).pop(true),
          "fontWeight": FontWeight.bold,
          "textColor": Colors.red,
          "alignment": TextAlign.center
        },
        "Cancel": {
          "action": () => Navigator.of(context).pop(false),
          "textColor": Get.isDarkMode ? Colors.white : Colors.black,
          "alignment": TextAlign.center
        },
      }
    );

    if(result != null && result) {
      deleteContent(context, [content.contentKey], FirebaseAPI().firebaseId()!);
    }
  }

  goToProfile(Content content) {
    ProfileScreen screen  = ProfileScreen(userKey: content.user!.userKey!);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
  }

  ratePin(Content content) async  {
    var _ = await showRatePinSheet(context: context, title: content.pinName!, pinKey: content.pinKey!, content: content, user: content.user!);
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
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
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
          GestureDetector(
            onTap: () => ratePin(content),
            child: Column(
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
                  "${content.totalReviews ?? 0} ratings",
                  style: TextStyle(
                    fontSize: 15,
                    // fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
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
                GestureDetector(
                  onTap: () => goToProfile(content),
                  // child: Text(
                  //   content.user!.userName!,
                  //   style: theme.textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                  // )
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${content.user!.userName!} ",
                          style: theme.textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if(content.user!.isVerified!)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: CustomIcon(
                              icon: 'assets/icons/verified-account.svg',
                              size: 14,
                              color: primaryOrange,
                            )
                          )
                      ]
                    ),
                    // textAlign: TextAlign.center,
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
                            child: GestureDetector(
                              onTap: () => goToMaps(content.pinLocation, zoom: 10),
                              child: Text.rich(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: CustomIcon(
                                        size: 14,
                                        icon: 'assets/icons/location.svg',
                                        color: Colors.grey,
                                      )
                                    ),
                                    TextSpan(
                                      text: " ${snapshot.data![0].locality}, ${snapshot.data![0].administrativeArea}",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline
                                      ),
                                    )
                                  ]
                                )
                              )
                            ),
                            // child: Row(
                            //   mainAxisSize: MainAxisSize.min,
                            //   children: [
                            //     CustomIcon(
                            //       size: 14,
                            //       icon: 'assets/icons/location.svg',
                            //       color: Colors.grey,
                            //     ),
                            //     SizedBox(width: 3),
                            //     Text(
                            //       "${snapshot.data![0].locality}, ${snapshot.data![0].administrativeArea}",
                            //       style: TextStyle(
                            //         color: Colors.grey,
                            //         fontSize: 13,
                            //         decoration: TextDecoration.underline
                            //       ),
                            //       overflow: TextOverflow.ellipsis,
                            //       maxLines: 1,
                            //     )
                            //   ]
                            // )
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
            onTap: () => goToMaps(content.pinLocation),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 40
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: FutureBuilder(
                future: LocationHandler().getDistanceFromCoords(content.pinLocation!),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    );
                  } else {
                    return Text(
                      "${snapshot.data} miles",
                      style: theme.textTheme.bodyText2!.copyWith(color: Colors.white)
                    );
                    // return CircularProgressIndicator();
                  }
                }
              ),
              decoration: BoxDecoration(
                color: primaryOrange,
                borderRadius: BorderRadius.circular(50),
              ),
            )
          ),
        ],
      )
    );
  }

  _buildCaption(ThemeData theme, Content content) {
    if (content.contentCaption != null && content.contentCaption != '') {
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

  goToMaps(String? location, {double? zoom}) async {
    if(location != null) {
      List<String> loc = location.split(',');
      await _themesController.navigateMap(loc, zoom: zoom);
    }
    await Future.delayed(const Duration(milliseconds: 500), () {
      _homeController.goToTab(2);
    });

    Navigator.of(context).popUntil(ModalRoute.withName("/home"));
  }

  showLogin() {
    Navigator.of(context).push(
      FadeOverlay(
        child: LoginOverlay(enableBackButton: true, message: "Sign in or sign up to interact with posts.")
      )
    );
  }

  goToLikedBy(int numOfLikes, String contentKey) {
    LikedByScreen screen = LikedByScreen(numOfLikes: numOfLikes, contentKey: contentKey);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
  }

  Widget buildReactionButton(List<String>? reactions, Content content) {
    if(FirebaseAPI().firebaseId() == null) {
      return ZoomTapAnimation(
        onTap: () => showLogin(),
        child: Row(
          children: [
            Text(
              reactions != null ? reactions.length.toString() : "0",
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 16
              )
            ),
            SizedBox(width: 10),
            CustomIcon(
              icon: 'assets/icons/favorite.svg',
              size: 27,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            )
          ],
        )
      );
    } else {
      return Row(
        children: [
          ZoomTapAnimation(
            onTap: () => goToLikedBy(reactions != null ? reactions.length : 0, content.contentKey.toString()),
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                reactions != null ? reactions.length.toString() : "0",
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 16
                )
              )
            )
          ),
          // SizedBox(width: 10),
          reactions != null && reactions.contains(FirebaseAPI().firebaseId()) ? ZoomTapAnimation(
              onTap: () => FirebaseAPI().removeReactionV3(content.contentKey.toString()),
              child: CustomIcon(
                icon: 'assets/icons/favorite-filled.svg',
                size: 27,
                color: Colors.red,
              ),
            ) : ZoomTapAnimation(
            onTap: () => FirebaseAPI().addReactionV3(
              context,
              content.contentKey.toString(),
              content.pinKey.toString(),
              data: {
                "content_key": content.contentKey,
                "pin_key": content.pinKey,
                "user_key": content.user!.userKey,
                "content_image_url": content.contentUrls.first
              }
            ),
            child: CustomIcon(
              icon: 'assets/icons/favorite.svg',
              size: 27,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          )
        ],
      );
    }
  }

  goToCommentScreen(int? numOfComments, int contentKey) {
    CommentScreen screen = CommentScreen(numOfComments: numOfComments, content: widget.content);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
  }

  buildCommentButton(List<String>? comments, int contentKey) {
    return ZoomTapAnimation(
      onTap: () => goToCommentScreen(comments?.length, contentKey),
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Text(
              comments != null ? comments.length.toString() : "0",
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 16
              )
            ),
            SizedBox(width: 10),
            CustomIcon(
              icon: 'assets/icons/chat.svg',
              size: 27,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            )
          ],
        ),
      )
    );
  }

  bookmarkPin(Content content) async {
    await FirebaseAPI().setPinSaved(
      context,
      FirebaseAPI().firebaseId()!,
      content.pinKey.toString(),
      true
    );

    RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    double y = position.dy;
    double x = position.dx;
    Offset offset = Offset(
      x + (box.size.width / 2),
      y + (box.size.height / 2)
    );

    showOverlayMessage(context: context, offset: offset, message: "Bookmarked");
  }

  reportContent(Content content) async {
    var result = await showReportSheet(
      context: context,
      reportee: content.contentKey,
      type: "C"
    );

    if(result != null && result) {
      RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);
      double y = position.dy;
      double x = position.dx;
      Offset offset = Offset(
        x + (box.size.width / 2),
        y + (box.size.height / 2)
      );

      Future.delayed(Duration(seconds: 1), () {
        showOverlayMessage(context: context, offset: offset, message: "Report Submitted", duration: Duration(milliseconds: 1500));
      });
    }
  }

  _buildContentActions(ThemeData theme, Content content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // build reactions amount & icon
              StreamBuilder(
                stream: FirebaseAPI().getReactionsV3(content.contentKey.toString()),
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> reactionSnapshot) {

                  List<String>? reactions = reactionSnapshot.data?.docs.map((e) => e.data()['firebase_id'] as String).toList();

                  return buildReactionButton(reactions, content);

                }
              ),
              SizedBox(width: 20),
              // build comment amount & icon
              FutureBuilder(
                future: FirebaseAPI().getCommentsV2(content.contentKey.toString()),
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> commentSnapshot) {
                  List<String>? comments = commentSnapshot.data?.docs.map((e) => e.id).toList();

                  return buildCommentButton(comments, content.contentKey);
                }
              )
            ]
          ),

          VenUser().userKey.value != 0 ? CustomOptionsPopupMenu(
            popupItems: [
              if(content.user!.userKey == VenUser().userKey.value)
                CustomOptionPopupMenuItem(
                  text: Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  icon: CustomIcon(icon: "assets/icons/delete.svg", color: Colors.red, size: 25),
                  onTap: () => deletePost(content)
                ),
              CustomOptionPopupMenuItem(
                text: Text("Add to bookmarks"),
                onTap: () => bookmarkPin(content)
              ),
              if(content.user!.userKey != VenUser().userKey.value)
                CustomOptionPopupMenuItem(
                  text: Text("Report", style: TextStyle(color: Colors.red)),
                  icon: CustomIcon(icon: 'assets/icons/caution.svg' ,color: Colors.red, size: 27),
                  onTap: () => reportContent(content)
                )
            ]
          ) : Container()
        ],
      ),
    );
  }

  buildCarouselSlider(Content content) {
    return CarouselSlider(
      carouselController: controller,
      items: List<Widget>.generate(content.contentUrls.length, (index) {
        return ZoomOverlay(
          twoTouchOnly: true,
          minScale: 1,
          child: lookupMimeType(content.contentUrls[index].toString())!.contains("video") ?
          VideoContentPlayer(
            setVideoAspectRatio: false,
            path: content.contentUrls[index].toString(),
            showPauseIndicator: true,
          )
          : GestureDetector(
            onDoubleTap: () async {
              await FirebaseAPI().addReactionV3(
                context,
                content.contentKey.toString(),
                content.pinKey.toString(),
                data: {
                  "content_key": content.contentKey,
                  "pin_key": content.pinKey,
                  "user_key": content.user!.userKey,
                  "content_image_url": content.contentUrls.first
                }
              );
              showLikeHeart(context: context, offset: doubleTapPosition);
            },
            onDoubleTapDown: (details) {
              // final RenderBox box = context.findRenderObject() as RenderBox;
              doubleTapPosition = details.globalPosition;
            },
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
              // child: widget.heroTag != null ?
              //   PhotoHero(
              //     tag: widget.heroTag!,
              //     photoUrl: content.contentUrls[index].toString()
              //   ) : CachedNetworkImage(
              //     // fit: BoxFit.contain,
              //     fit: BoxFit.cover,
              //     imageUrl: content.contentUrls[index].toString(),
              //     progressIndicatorBuilder: (context, url, downloadProgress) {
              //       return Skeleton.rectangular(
              //         height: 250,
              //         // borderRadius: 20.0
              //       );
              //     }
              //   )

            )
          )
        );
      }),
      options: CarouselOptions(
        pageViewKey: PageStorageKey(content.contentKey),
        enableInfiniteScroll: false,
        disableCenter: true,
        viewportFraction: 1.0,
        onPageChanged: (index, _) {
          setState(() {
            currentIndex = index;
          });
        }
      ),
    );
  }

  _buildContent(Content content) {
    return Expanded(
      key: _key,
      child: Stack(
        children: [
          Positioned.fill(
            child: widget.heroTag != null ? Hero(
              transitionOnUserGestures: true,
              tag: widget.heroTag!,
              child: Material(
                color: Colors.transparent,
                child: buildCarouselSlider(content)
              )
            ) : buildCarouselSlider(content)
          ),
          content.contentUrls.length > 1 ? IgnorePointer(
            child: Padding(
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
    super.build(context);
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

void showLikeHeart({
  required BuildContext context,
  required Offset offset
}) {

  OverlayEntry overlayEntry;
  List<double> angles = [-120,0,120];
  double angle = angles[Random().nextInt(angles.length)];

  overlayEntry = OverlayEntry(
      builder: (context) => LikeHeartWidget(offset: offset, angle: angle)
  );
  Overlay.of(context).insert(overlayEntry);
  Timer(Duration(milliseconds: 500), () =>  overlayEntry.remove());

}

class LikeHeartWidget extends StatelessWidget {
  final Offset offset;
  final double angle;
  LikeHeartWidget({Key? key, required this.offset, this.angle = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: Transform.translate(
        offset: Offset(offset.dx - 50, offset.dy - 50),
        child: Transform.rotate(
          angle: angle,
          child: IgnorePointer(
            child: DropShadow(
              child: CustomIcon(
                icon: 'assets/icons/favorite-filled.svg',
                size: 100,
                color: Colors.red,
              )
            )
          )
        ),
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