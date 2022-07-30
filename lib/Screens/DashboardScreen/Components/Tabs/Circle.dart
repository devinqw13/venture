import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Screens/DashboardScreen/Components/CircleCard.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CircleTab extends StatefulWidget {
  CircleTab({Key? key}) : super(key: key);

  @override
  _CircleTabState createState() => _CircleTabState();
}

class _CircleTabState extends State<CircleTab> with AutomaticKeepAliveClientMixin<CircleTab> {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

  }

  List<Widget> circles() {
    List<Widget> _children = [];

    for(var i = 1; i < 10; i++) {
      Widget child = Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Get.isDarkMode ? ColorConstants.gray700 : Colors.grey.shade200
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Get.isDarkMode ? ColorConstants.gray500 : Colors.grey.shade300
              ),
              child: Center(
                child: Icon(Icons.add, size: 20, color: Colors.grey.shade500),
              ),
            ),
            SizedBox(height: 20),
            Text("Group $i")
          ],
        ),
      );
      _children.add(child);
    }
    return _children;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: CustomScrollView(
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
              title: Text("Circle",
                style: TextStyle(
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'LeagueSpartan',
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                )
              ),
            ),
            actions: <Widget>[
              
            ],
          ),
          CupertinoSliverRefreshControl(
        
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 2));
            },
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: 12, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ZoomTapAnimation(
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: 90,
                              maxWidth: 90,
                              maxHeight: 120,
                              minHeight: 120
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Get.isDarkMode ? ColorConstants.gray700 : Colors.grey.shade200
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Get.isDarkMode ? ColorConstants.gray500 : Colors.grey.shade300
                                  ),
                                  child: Center(
                                    child: Icon(Icons.add, size: 20, color: Colors.grey.shade500),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text("Create Circle",
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        ),
                        // LOOP THROUGH CIRCLES
                        for(var i = 1; i < 10; i++) 
                          ZoomTapAnimation(
                            child: CircleCard(index: i)
                          )
                        
                      ]
                    ),
                  ),
                ],
              ),
            ),
            // child: Container(
            //   height: 100.0,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: 10,
            //     itemBuilder: (context, index) {
            //       return Container(
            //         width: 100.0,
            //         child: Card(
            //           child: Text('data'),
            //         ),
            //       );
            //     },
            //   ),
            // )
          )
        ],
      )
    );
  }
}