import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/DashboardScreen/Components/PostSkeleton.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class DisplayContentListScreen extends StatefulWidget {
  final Content? content;
  final int? contentKey;
  final List<Content> contents;
  final UserModel? user;
  DisplayContentListScreen({Key? key, this.content, this.contentKey, this.user, this.contents = const []}) 
    :
      // assert(false, 'Must use content or contentKey.'),
      super(key: key);

  @override
  _DisplayContentListScreenState createState() => _DisplayContentListScreenState();
}

class _DisplayContentListScreenState extends State<DisplayContentListScreen> {
  late PageController scrollController;
  // late SwipeablePageRoute<void> pageRoute;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    await setInitPageIndex();
    // await setContent();
  }

  // Future<void> setContent() async {
  //   if(widget.content != null) {
  //     content = widget.content!;
  //   }else {
  //     var result = await getContent(context, [0], 0, contentKey: widget.contentKey);
  //     print(result);
  //   }
  // }

  Future<void> setInitPageIndex() async {
    int index = 0;
    if(widget.contents.length > 1) {
      index = widget.contents.lastIndexWhere((e) => e == widget.content);
    }
    scrollController = PageController(initialPage: index);
  }

  @override
  Widget build(BuildContext context) {
    // pageRoute = context.getSwipeablePageRoute<void>()!;
    // setState(() => pageRoute.canSwipe = false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, size: 25),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: Get.isDarkMode ? ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7) : ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Get.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        centerTitle: true,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.user != null ? "${widget.user!.userName!}\n" : '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey
                    )
                  ),
                  TextSpan(
                    text: 'Content',
                    style: theme.textTheme.headline6!
                  )
                ]
              )
            ]
          )
        )
        // title: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     widget.user != null ? Text(
        //       widget.user!.userName!,
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         color: Colors.grey
        //       ),
        //     ) : Container(),
        //     Text(
        //       'Content',
        //       textAlign: TextAlign.center,
        //       style: theme.textTheme.headline6,
        //     )
        //   ],
        // )
      ),
      // body: widget.contents.isNotEmpty && widget.contents.length > 1 ? PageView.builder(
      //   controller: scrollController,
      //   itemCount: widget.contents.length,
      //   physics: AlwaysScrollableScrollPhysics(),
      //   scrollDirection: Axis.vertical,
      //   itemBuilder: (context, i) {
      //     if(widget.contents[i] == widget.content) {
      //       return PostSkeleton(content: widget.contents[i], heroTag: widget.contents[i].contentUrls.first);
      //     }
      //     return PostSkeleton(content: widget.contents[i]);
      //   }
      // ) :
      // PostSkeleton(content: widget.content, heroTag: widget.content.contentUrls.first)
      body: widget.contents.isNotEmpty && widget.contents.length > 1 ? 
      Column(
        children: [
          Expanded(
            child: PageView.builder(
              allowImplicitScrolling: true, // Preload next items
              controller: scrollController,
              itemCount: widget.contents.length,
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {},
              itemBuilder: (context, i) {
                if(widget.contents[i] == widget.content) {
                  return PostSkeleton(content: widget.contents[i], heroTag: widget.contents[i].contentUrls.first);
                }
                return PostSkeleton(content: widget.contents[i]);
              }
            )
          )
        ]
      ) : widget.content != null ?
      PostSkeleton(content: widget.content!, heroTag: widget.content!.contentUrls.first) : widget.contentKey != null ?
      FutureBuilder(
        future: getContent(context, [0], 0, contentKey: widget.contentKey),
        builder: (context, content) {
          if(content.hasData) {
            if(content.data!.isNotEmpty) {
              return PostSkeleton(content: content.data!.first);
            }else {
              Future.delayed(Duration(milliseconds: 100), () {
                Navigator.pop(context);
              });
              return PostSkeletonShimmer();
            }
          }
          return PostSkeletonShimmer();
        }
      ) : PostSkeletonShimmer()
    );
  }
}


