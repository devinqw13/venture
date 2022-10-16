import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/DeleteContent.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/Content.dart';
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
    // final theme = Theme.of(context);
    // return SafeArea(
    //   child: CustomScrollView(
    //     // physics: ClampingScrollPhysics(),
    //     slivers: [
    //       // SliverAppBar(
    //       //   elevation: 0.5,
    //       //   shadowColor: Colors.grey,
    //       //   pinned: true,
    //       //   flexibleSpace: FlexibleSpaceBar(
    //       //     titlePadding: EdgeInsetsDirectional.only(
    //       //       start: 16.0,
    //       //       bottom: 16.0,
    //       //     ),
    //       //     centerTitle: false,
    //       //     title: Text("Home",
    //       //       style: TextStyle(
    //       //         color: Get.isDarkMode ? Colors.white : Colors.black,
    //       //         fontFamily: 'LeagueSpartan',
    //       //         fontWeight: FontWeight.bold,
    //       //         fontSize: 24.0,
    //       //       )
    //       //     ),
    //       //   ),
    //       //   actions: <Widget>[
    //       //     ValueListenableBuilder(
    //       //       valueListenable: User().userKey, 
    //       //       builder: (context, value, _) {
    //       //         return value != 0 ? Padding(
    //       //           padding: EdgeInsetsDirectional.only(
    //       //             end: 16.0,
    //       //             bottom: 12.0,
    //       //           ),
    //       //           child: ZoomTapAnimation(
    //       //             onTap: () => goToMessaging(),
    //       //             child: Icon(IconlyBroken.more_circle, size: 32),
    //       //           )
    //       //         ) : Container();
    //       //       }
    //       //     ),
    //       //     ValueListenableBuilder(
    //       //       valueListenable: User().userKey, 
    //       //       builder: (context, value, _) {
    //       //         return value != 0 ? Padding(
    //       //           padding: EdgeInsetsDirectional.only(
    //       //             end: 16.0,
    //       //             bottom: 12.0,
    //       //           ),
    //       //           child: ZoomTapAnimation(
    //       //             onTap: () => goToUploadContent(),
    //       //             child: Icon(IconlyBroken.plus, size: 32),
    //       //           )
    //       //         ) : Container();
    //       //       }
    //       //     ),
    //       //   ],
    //       // ),
    //       // CupertinoSliverRefreshControl(
    //       //   onRefresh: () => _refresh(),
    //       // ),

    //       // SliverToBoxAdapter(
    //       //   child: ListView.builder(
    //       //     physics: NeverScrollableScrollPhysics(),
    //       //     itemCount: content.isEmpty ? 4 : content.length,
    //       //     shrinkWrap: true,
    //       //     itemBuilder: (context, i) {
    //       //       if(content.isEmpty) {
    //       //         return PostSkeletonShimmer();
    //       //       }else {
    //       //         return PostSkeleton(content: content[i]);
    //       //       }
    //       //     }
    //       //   ),
    //       // ),

    //       // =================== V2 ===================   
    //       header(),
    //       SliverToBoxAdapter(
    //         child: ListView.builder(
    //           physics: NeverScrollableScrollPhysics(),
    //           itemCount: content.isEmpty ? 4 : content.length,
    //           shrinkWrap: true,
    //           itemBuilder: (context, i) {
    //             if(content.isEmpty) {
    //               return PostSkeletonShimmer();
    //             }else {
    //               return PostSkeleton(content: content[i]);
    //             }
    //           }
    //         ),
    //       ),
    //     ],
    //   )
    // );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ZoomTapAnimation(
              onTap: () => goToCircles(),
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: CustomIcon(
                    icon: 'assets/icons/people.svg',
                    color: primaryOrange,
                    size: 27,
                  )
                ),
              )
            ),
            ZoomTapAnimation(
              onTap: () => goToMessaging(),
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.3),
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
            ),
          ],
        ),
      ),
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
        //   child: ZoomTapAnimation(
        //     onTap: () => goToCircles(),
        //     child: Container(
        //       // width: 20,
        //       decoration: BoxDecoration(
        //         color: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.3),
        //         borderRadius: BorderRadius.circular(10)
        //       ),
        //       child: Center(
        //         child: CustomIcon(
        //           icon: 'assets/icons/people.svg',
        //           color: primaryOrange,
        //           size: 27,
        //         ),
        //       ),
        //     )
        //   ),
        // ),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 20.0, top: 8.0, bottom: 8.0),
      //       child: ZoomTapAnimation(
      //         onTap: () => goToMessaging(),
      //         child: Container(
      //           padding: EdgeInsets.only(left: 8, right: 8),
      //           decoration: BoxDecoration(
      //             color: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.3),
      //             borderRadius: BorderRadius.circular(10)
      //           ),
      //           child: Center(
      //             child: CustomIcon(
      //               icon: 'assets/icons/send.svg',
      //               color: primaryOrange,
      //               size: 27,
      //             )
      //           ),
      //         )
      //       ),
      //     )
      //   ],
      // ),
      body: Stack(
        children: [
          PageView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: content.length,
            itemBuilder: (context, i) {
              if(content.isEmpty) {
                return PostSkeletonShimmer();
              }else {
                return Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: PostSkeleton(content: content[i])
                );
              }
              // return Stack(
              //   children: [
              //     Container(
              //       decoration: BoxDecoration(
              //         image: DecorationImage(
              //           image: CachedNetworkImageProvider(
              //             content[i].contentUrl
              //           ),
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     ),
              //     Positioned(
              //       bottom: 0,
              //       // alignment: Alignment.bottomCenter,
              //       child: Padding(
              //         padding: EdgeInsets.only(left: 20, right: 20, bottom: 80),
              //         child: Row(
              //           children: [
              //             Column(
              //               children: [
              //                 Text(
              //                   content[i].user!.userName!,
              //                   style: TextStyle(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.w600
              //                   ),
              //                 )
              //               ],
              //             )
              //           ],
              //         ),
              //       )
              //     )
              //   ],
              // );
            }
          )
        ]
      )
    );

  }
}