import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Components/ExpandableText.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/MapPreview.dart';
import 'package:venture/Helpers/TimeFormat.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Screens/ProfileScreen.dart/ProfileScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';

class PinSkeleton extends StatefulWidget {
  final Pin pin;
  final bool enableBackButton;
  PinSkeleton({Key? key, required this.pin, required this.enableBackButton}) : super(key: key);

  @override
  _PinSkeleton createState() => _PinSkeleton();
}

class _PinSkeleton extends State<PinSkeleton> with TickerProviderStateMixin {
  final ThemesController _themesController = Get.find();
  DraggableScrollableController dragController = DraggableScrollableController();
  double? _detailsHeight;
  final GlobalKey key3 = GlobalKey();
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  goToUserProfile() {
    ProfileScreen screen = ProfileScreen(userKey: widget.pin.user!.userKey!);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => screen));
  }

  overviewBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.pin.description != null && widget.pin.description!.isNotEmpty ? 
          ExpandableText(
            widget.pin.description,
            trimLines: 8,
          ) :
          Text(
            "No description provided",
            style: TextStyle(
              fontStyle: FontStyle.italic
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Text(
                "Created by ",
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
              ZoomTapAnimation(
                onTap: () => goToUserProfile(),
                child: Text(
                  widget.pin.user!.userName!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                )
              )
            ],
          ),
          SizedBox(height: 15),
          MapPreview(
            latitude: double.parse(widget.pin.latLng.split(',')[0]), longitude: double.parse(widget.pin.latLng.split(',')[1]),
            height: 150,
          )
        ],
      )
    );
  }

  commentsBody(ScrollController controller) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: controller,
            child: FirestoreListView(
              padding: EdgeInsets.all(0),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              query: FirebaseAPI().commentQuery("76Rk5UxIg8K23uFaa4Uh"),
              emptyBuilder: (context) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
                      // SizedBox(height: 20,),
                      Text('Be the first to comment.'),
                    ],
                  ),
                );
              },
              itemBuilder: (context, documentSnapshot) {
                // String documentId = documentSnapshot[index].id;
                var commentData = documentSnapshot.data() as Map<String, dynamic>;
                return FutureBuilder(
                  future: FirebaseAPI().getUserFromFirebaseId(commentData['firebase_id']),
                  builder: (context, snapshot) {
                    var date = DateTime.parse(commentData['timestamp'].toDate().toString()).toString();

                    if(snapshot.hasData) {
                      var docSnapshot = snapshot.data as Map<String, dynamic>;
                      var userData = docSnapshot;

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            MyAvatar(photo: userData['photo_url']),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      userData['username'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14
                                      ),
                                    ),
                                    SizedBox(height: 7),
                                    Text(
                                      commentData['comment'],
                                      style: TextStyle(
                                        fontSize: 16
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    TimeFormat()
                                      .withoutDate(
                                        date,
                                        style: TextStyle(
                                          color: Colors.grey
                                        )
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      );
                    }
                    return Container();
                  }
                );
              }
            )
          )
        ),
        Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 15),
          color: Get.isDarkMode ? ColorConstants.gray600 : Colors.white,
          child: Focus(
            onFocusChange: (hasFocus) {
              if(hasFocus) {
                // controller.animateTo(
                //   _scrollController.position.maxScrollExtent,
                //   duration: const Duration(milliseconds: 500),
                //   curve: Curves.easeOut);
                print(controller.position);
              }
            },
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                hintText: "Add a comment",
              )
            )
          ),
        )
      ],
    );
    // return Column(
    //   children: [
    //     Expanded(
    //       // child: ListView.builder(
    //       //   controller: controller,
    //       //   padding: EdgeInsets.symmetric(horizontal: 10),
    //       //   shrinkWrap: true,
    //       //   itemCount: 100,
    //       //   itemBuilder: (context, i) {
    //       //     return Text(i.toString());
    //       //   },
    //       // )
    //       child: PaginateFirestore(
    //         scrollController: controller,
    //         shrinkWrap: true,
    //         query: FirebaseAPI().commentQuery("76Rk5UxIg8K23uFaa4Uh"),
    //         itemBuilderType: PaginateBuilderType.listView,
    //         isLive: false,
    //         itemsPerPage: 20,
    //         onEmpty: Container(
    //           padding: EdgeInsets.symmetric(vertical: 8),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
    //               // SizedBox(height: 20,),
    //               Text('Be the first to comment.'),
    //             ],
    //           ),
    //         ),
    //         itemBuilder: (context, documentSnapshot, index) {
    //           // String documentId = documentSnapshot[index].id;
    //           var commentData = documentSnapshot[index].data() as Map<String, dynamic>;
    //           return FutureBuilder(
    //             future: FirebaseAPI().getUserFromFirebaseId(commentData['firebase_id']),
    //             builder: (context, snapshot) {
    //               var date = DateTime.parse(commentData['timestamp'].toDate().toString()).toString();

    //               if(snapshot.hasData) {
    //                 var docSnapshot = snapshot.data as DocumentSnapshot<Map<String, dynamic>>?;
    //                 var userData = docSnapshot!.data();

    //                 return Padding(
    //                   padding: EdgeInsets.symmetric(vertical: 10),
    //                   child: Row(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: <Widget>[
    //                       MyAvatar(photo: userData!['photo_url']),
    //                       Expanded(
    //                         child: Container(
    //                           padding: EdgeInsets.only(left: 10),
    //                           child: Column(
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: <Widget>[
    //                               Text(
    //                                 userData['username'],
    //                                 style: TextStyle(
    //                                   fontWeight: FontWeight.bold,
    //                                   fontSize: 14
    //                                 ),
    //                               ),
    //                               SizedBox(height: 7),
    //                               Text(
    //                                 commentData['comment'],
    //                                 style: TextStyle(
    //                                   fontSize: 16
    //                                 ),
    //                               ),
    //                               SizedBox(height: 5),
    //                               TimeFormat()
    //                                 .withoutDate(
    //                                   date,
    //                                   style: TextStyle(
    //                                     color: Colors.grey
    //                                   )
    //                                 )
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   )
    //                 );
    //               }
    //               return Container();
    //             }
    //           );
    //         }
    //       )
    //     ),
    //     Container(
    //       padding: EdgeInsets.only(bottom: 20),
    //       color: Get.isDarkMode ? ColorConstants.gray600 : Colors.white,
    //       child: TextField(
    //         decoration: InputDecoration(
    //           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
    //           hintText: "Add a comment",
    //         )
    //       ),
    //     )
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DismissKeyboard(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
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
                  primary: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.7),
                  shape: CircleBorder(),
                ),
              ): Container(),
              VenUser().userKey.value == widget.pin.user!.userKey ?
              ElevatedButton(
                onPressed: () => print("CREATOR SETTINGS"),
                child: Icon(
                  IconlyLight.setting,
                  color: primaryOrange,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: primaryOrange,
                  primary: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.7),
                  shape: CircleBorder(),
                ),
              ): Container(),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              // padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
              height: _detailsHeight ?? MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: Colors.grey,
                image: widget.pin.featuredPhoto != null ? DecorationImage(
                  image: NetworkImage(
                    widget.pin.featuredPhoto!,
                  ),
                  fit: BoxFit.cover
                ): null,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0, -(MediaQuery.of(context).size.height / 1200)),
                        end: Alignment(0, MediaQuery.of(context).size.height / 1100),
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6)
                        ]
                      )
                    ),
                  ),
                  Padding(
                    // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: MediaQuery.of(context).size.height * 0.075
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                widget.pin.title!,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 2,
                                style: theme.textTheme.headline3!.copyWith(color: Colors.white),
                              )
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    CustomIcon(
                                      icon: 'assets/icons/star.svg',
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "${widget.pin.rating ?? 0.0}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  "${widget.pin.totalReviews ?? 0} reviews",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        ZoomTapAnimation(
                          onTap: () => print("GO TO MAP"),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Text(
                              "Directions",
                              style: theme.textTheme.bodyText2!.copyWith(color: Colors.white)
                            ),
                            decoration: BoxDecoration(
                              color: primaryOrange,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          )
                        )
                      ]
                    )
                  ),
                ],
              )
            ),
            NotificationListener<DraggableScrollableNotification>(
              onNotification: (d) {
                setState(() {
                  _detailsHeight = MediaQuery.of(context).size.height * ((1-d.extent) + 0.05);
                });
                return true;
              },
              child: DraggableScrollableSheet(
                minChildSize: 0.4,
                initialChildSize: 0.4,
                maxChildSize: 0.7,
                controller: dragController,
                builder: (context, scrollController) => Stack(
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: _themesController.getContainerBgColor(),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0),
                        )
                      ),
                      child: CustomScrollView(
                        physics: ClampingScrollPhysics(),
                        controller: scrollController,
                        slivers: [

                          SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverChildDelegate(
                              Container(
                                color: _themesController.getContainerBgColor(),
                                  child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: Container(
                                      width: 30,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: ColorConstants.gray100,
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                    ),
                                  )
                                )
                              ),
                              0
                            )
                          ),

                          SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverChildDelegate(
                              Container(
                                color: _themesController.getContainerBgColor(),
                                child: TabBar(
                                  isScrollable: true,
                                  indicator: CircleTabIndicator(color: primaryOrange, radius: 3),
                                  labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                  unselectedLabelColor: Get.isDarkMode ? Colors.white : Colors.black,
                                  labelColor: primaryOrange,
                                  controller: tabController,
                                  tabs: [
                                    Tab(
                                      child: Text(
                                        "Overview",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),
                                      )
                                    ),
                                    Tab(
                                      child: Text(
                                        "Comments",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),
                                      )
                                    )
                                  ]
                                )
                              ),
                              0
                            )
                          ),
                          
                          SliverFillRemaining(
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              controller: tabController,
                              children: [
                                overviewBody(),
                                commentsBody(scrollController)
                              ]
                            ),
                          )

                        ],
                      )
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: Transform.translate(
                          offset: Offset(0, -30),
                          child: ZoomTapAnimation(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primaryOrange,
                                shape: BoxShape.circle
                              ),
                              child: CustomIcon(
                                icon: 'assets/icons/bookmark.svg',
                                size: 25,
                                color: Colors.white
                              ),
                            ),
                          ),
                        )
                      )
                    ),
                  ]
                )
              )
            ),
          ],
        ),
      )
    );
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color, required double radius}) : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset = offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

class SliverChildDelegate extends SliverPersistentHeaderDelegate {
  final double vMaxExtent;
  SliverChildDelegate(this.child, this.vMaxExtent);

  final Widget child;

  @override
  double get minExtent => 40;
  @override
  double get maxExtent => 40;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      child: child,
    );
  }

  @override
  bool shouldRebuild(SliverChildDelegate oldDelegate) {
    return false;
  }
}