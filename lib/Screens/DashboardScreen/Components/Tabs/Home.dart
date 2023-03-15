import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FireBaseServices.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/DeleteContent.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/DashboardScreen/Components/PostSkeleton.dart';
import 'package:venture/Screens/MessagingScreen/ConversationScreen.dart';
import 'package:venture/Screens/UploadContentScreen/UploadContentScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin<HomeTab>, SingleTickerProviderStateMixin {
  final ThemesController _themesController = Get.find();
  List<Content> content = [];
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    // await _fetchCache();
    setState(() => isLoading = true);
    List<Content> results = await getContent(context, 0);
    setState(() => isLoading = false);

    setState(() {
      content = results;
    });
  }

  // _fetchCache() async {
  //   //TODO: RETRIEVE CACHED DATA AND SET
  // }

  // _refresh() async {
  //   if (isLoading) return;
  //   // setState(() => isLoading = true);
  //   // List<Content> results = await getContent(context, 0);
  //   // setState(() => isLoading = false);

  //   // setState(() {
  //   //   content = results;
  //   // });
  //   Future.delayed(const Duration(milliseconds: 3000), () {});
  // }

  goToUploadContent() async {
    UploadContentScreen screen = UploadContentScreen();
    var result = await Navigator.of(context).push(SlideUpDownPageRoute(page: screen));

    if(result != null) {
      Content item = result[0] as Content;
      showToast(context: context, color: Colors.green, msg: "Posted to ${item.user!.userName}", type: ToastType.INFO);
      setState(() {
        content.insert(0, item);
      });
      deleteFile(result[1]);
    }
  }

  goToMessaging() async {
    ConversationScreen screen = ConversationScreen();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  goToCircles() async {
    
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: VenUser().userKey, 
      builder: (context, userKey, _) {
        return DefaultTabController(
          length: 2,
          initialIndex: 1,
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TabBar(
                    enableFeedback: true,
                    isScrollable: true,
                    // indicator: CircleTabIndicator(color: primaryOrange, radius: 3),
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
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? ColorConstants.gray800.withOpacity(0.7) : ColorConstants.gray25.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(
                        child: CustomIcon(
                          icon: 'assets/icons/send.svg',
                          color: primaryOrange,
                          size: 27,
                        )
                      ),
                    )
                  ) : Container()
                ],
              ),
            ),
            body: Stack(
              children: [
                TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Container(),
                    PageView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: content.isEmpty ? 1 : content.length,
                      itemBuilder: (context, i) {
                        if(content.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .125),
                            child: PostSkeletonShimmer()
                          );
                        }else {
                          return Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .125),
                            child: PostSkeleton(content: content[i])
                          );
                        }
                      }
                    )
                  ]
                )
              ]
            )
          )
        );
      }
    );
  }
}