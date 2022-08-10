import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Models/User.dart';
import 'package:venture/Constants.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin<HomeTab> {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: CustomScrollView(
        // physics: ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0.5,
            shadowColor: Colors.grey,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsetsDirectional.only(
                start: 16.0,
                bottom: 16.0,
              ),
              centerTitle: false,
              title: Text("Home",
                style: TextStyle(
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'LeagueSpartan',
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                )
              ),
            ),
            actions: <Widget>[
              ValueListenableBuilder(
                valueListenable: User().userKey, 
                builder: (context, value, _) {
                  return value != 0 ? Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: 16.0,
                      bottom: 12.0,
                    ),
                    child: ZoomTapAnimation(
                      onTap: () => print("ADD CONTENT"),
                      child: Icon(IconlyBroken.plus, size: 32),
                    )
                  ) : Container();
                }
              )
            ],
          ),

          CupertinoSliverRefreshControl(
        
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 2));
            },
          ),
          
          SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  child: Text('List Item $index'),
                );
              },
            ),
          )
        ],
      )
    );
  }
}