import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/DashboardScreen/Components/PostSkeleton.dart';

class DisplayContentListScreen extends StatefulWidget {
  final Content content;
  final List<Content> contents;
  final UserModel? user;
  DisplayContentListScreen({Key? key, required this.content, this.user, this.contents = const []}) : super(key: key);

  @override
  _DisplayContentListScreenState createState() => _DisplayContentListScreenState();
}

class _DisplayContentListScreenState extends State<DisplayContentListScreen> {
  late PageController scrollController;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    int index = 0;
    if(widget.contents.length > 1) {
      index = widget.contents.lastIndexWhere((e) => e == widget.content);
    }
    scrollController = PageController(initialPage: index);
  }

  @override
  Widget build(BuildContext context) {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.user != null ? Text(
              widget.user!.userName!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey
              ),
            ) : Container(),
            Text(
              'Content',
              style: theme.textTheme.headline6,
            )
          ],
        )
      ),
      body: widget.contents.isNotEmpty && widget.contents.length > 1 ? PageView.builder(
        controller: scrollController,
        itemCount: widget.contents.length,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, i) {
          if(widget.contents[i] == widget.content) {
            return PostSkeleton(content: widget.contents[i], heroTag: widget.contents[i].contentUrls.first);
          }
          return PostSkeleton(content: widget.contents[i]);
        }
      ) :
      PostSkeleton(content: widget.content, heroTag: widget.content.contentUrls.first)
    );
  }
}


