import 'dart:ui' as ui;
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Components/NotificationBadge.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/CustomRefresh.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/DashboardScreen/Components/PostSkeleton.dart';
import 'package:venture/Screens/MessagingScreen/ConversationScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin<HomeTab>, SingleTickerProviderStateMixin {
  final ThemesController _themesController = Get.find();
  final HomeController _homeController = Get.find();
  bool didInitialFollowingFetch = false;
  List<Content> exploreContent = [];
  List<Content> followingContent = [];
  bool isExploreLoading = false;
  bool isFollowingLoading = false;
  int tabIndex = 1;
  late TabController tabController;
  PageController exploreController = PageController(keepPage: true);
  PageController followingController = PageController(keepPage: true);
  IndicatorController exploreRefreshController = IndicatorController();
  IndicatorController followingRefreshController = IndicatorController();
  final exploreRefreshKey = GlobalKey<CustomRefreshIndicatorState>();
  final followingRefreshKey = GlobalKey<CustomRefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _homeController.homeFeedController = exploreController;
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    _getExploreContent();
    // if(FirebaseAPI().firebaseId() != null) _getFollowingContent();
  }

  Future<void> _getFollowingContent() async {
    setState(() => isFollowingLoading = true);
    var result = await FirebaseAPI().followingQuery(FirebaseAPI().firebaseId()).get();

    List<String> firebaseIds = result.docs.map((e) => e.id).toList();
    firebaseIds.add(FirebaseAPI().firebaseId()!);

    List<int> userKeys = [];
    for(var id in firebaseIds) {
      var user = await FirebaseAPI().getUserFromFirebaseId(id);
      userKeys.add(int.parse(user['user_key']));
    }

    List<Content> results = await getContent(context, userKeys, 0);
    setState(() {
      isFollowingLoading = false;
      followingContent = results;
      didInitialFollowingFetch = true;
    });
  }

  Future<void> _getExploreContent() async {
    // await _fetchCache();
    setState(() => isExploreLoading = true);
    List<Content> results = await getContent(context, [0], 0);
    setState(() => isExploreLoading = false);

    setState(() {
      exploreContent = results;
    });
  }

  // _fetchCache() async {
  //   //TODO: RETRIEVE CACHED DATA AND SET
  // }

  // goToUploadContent() async {
  //   UploadContentScreen screen = UploadContentScreen();
  //   var result = await Navigator.of(context).push(SlideUpDownPageRoute(page: screen));

  //   if(result != null) {
  //     Content item = result[0] as Content;
  //     showToast(context: context, color: Colors.green, msg: "Posted to ${item.user!.userName}", type: ToastType.INFO);
  //     setState(() {
  //       exploreContent.insert(0, item);
  //     });
  //     deleteFile(result[1]);
  //   }
  // }

  goToMessaging() async {
    ConversationScreen screen = ConversationScreen();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  goToCircles() async {
    
  }

  Future<void> _refreshFollowing() async {
    await _getFollowingContent();
  }

  Future<void> _refreshExplore() async {
    await _getExploreContent();
  }

  RxInt unreadCount() {
    var result = _homeController.messageTracker.values.where((element) => element.length > 0).toList();

    return result.length.obs;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    AppBar appBar = AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: Get.isDarkMode ? ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7) : ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Get.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
          ),
        ),
      ),
      title: ValueListenableBuilder(
        valueListenable: VenUser().userKey, 
        builder: (context, userKey, _) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TabBar(
                controller: tabController,
                onTap: (page) async {
                  if(page == 1) {
                    setState(() => _homeController.homeFeedController = exploreController);

                    if(tabIndex == page) {
                      await _homeController.homeFeedController?.animateToPage(
                        0, 
                        curve: Curves.decelerate,
                        duration: Duration(milliseconds: 300)
                      );

                      exploreRefreshKey.currentState!.refresh(
                        draggingCurve: Curves.easeOutBack,
                      );
                    }

                  }

                  if(page == 0) {
                    setState(() => _homeController.homeFeedController = followingController);

                    if(FirebaseAPI().firebaseId() != null && !didInitialFollowingFetch) _getFollowingContent();

                    if(tabIndex == page) {
                      await _homeController.homeFeedController?.animateToPage(
                        0, 
                        curve: Curves.decelerate,
                        duration: Duration(milliseconds: 300)
                      );

                      followingRefreshKey.currentState!.refresh(
                        draggingCurve: Curves.easeOutBack,
                      );
                    }
                  }

                  setState(() => tabIndex = page);
                },
                enableFeedback: true,
                isScrollable: true,
                indicatorColor: Colors.white.withOpacity(0),
                labelPadding: EdgeInsets.only(right: userKey != 0 ? 10.0 : 0.0),
                unselectedLabelColor: Get.isDarkMode ? Colors.white : Colors.black,
                labelColor: primaryOrange,
                tabs: [
                  userKey != 0 ? Tab(
                    child: Text(
                      "Following",
                      style: TextStyle(
                        fontFamily: "CoolveticaCondensed",
                        // fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontSize: 23
                      ),
                    )
                  ) : Container(),
                  Tab(
                    child: Text(
                      "Explore",
                      style: TextStyle(
                        fontFamily: "CoolveticaCondensed",
                        // fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontSize: 23
                      ),
                    )
                  ),
                ],
              ),
              userKey != 0 ? ZoomTapAnimation(
                onTap: () => goToMessaging(),
                child: Obx(() => NotificationBadge(
                  hideZero: true,
                  itemCount: unreadCount().value,
                  icon: CustomIcon(
                    icon: 'assets/icons/send.svg',
                    color: primaryOrange,
                    size: 27,
                  )
                ))
              ) : Container()
            ],
          );
        }
      )
    );

    final topPadding = appBar.preferredSize.height + MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Stack(
        children: [
          TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              CustomRefresh(
                indicatorKey: followingRefreshKey,
                controller: followingRefreshController,
                edgeOffset: topPadding,
                onAction: _refreshFollowing,
                child: PageView.builder(
                  allowImplicitScrolling: true, // Preload next items
                  controller: followingController,
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: followingContent.isEmpty ? 1 : followingContent.length,
                  itemBuilder: (context, i) {
                    if(followingContent.isEmpty && isFollowingLoading) {
                      return Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: PostSkeletonShimmer()
                      );
                    } else if(followingContent.isEmpty && !isFollowingLoading) {
                      return Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Start following users to view their pins/posts")
                          ],
                        )
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: PostSkeleton(content: followingContent[i])
                      );
                    }
                  }
                ),
              ),

              CustomRefresh(
                indicatorKey: exploreRefreshKey,
                controller: exploreRefreshController,
                edgeOffset: topPadding,
                onAction: _refreshExplore,
                child: PageView.builder(
                  allowImplicitScrolling: true, // Preload next items
                  controller: exploreController,
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: exploreContent.isEmpty ? 1 : exploreContent.length,
                  itemBuilder: (context, i) {
                    if(exploreContent.isEmpty && isExploreLoading) {
                      return Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: PostSkeletonShimmer()
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: PostSkeleton(content: exploreContent[i])
                      );
                    }
                  }
                ),
              )
            ]
          )
        ]
      )
    );
  }
}