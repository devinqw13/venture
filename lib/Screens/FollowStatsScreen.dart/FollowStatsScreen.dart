import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class FollowStatsScreen extends StatefulWidget {
  FollowStatsScreen({Key? key}) : super(key: key);

  @override
  FollowStatsScreenState createState() => FollowStatsScreenState();
}

class FollowStatsScreenState extends State<FollowStatsScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          title: Text(
            'Comments',
            style: theme.textTheme.headline6,
          )
        ),
        body: Container(),
        // body: Column(
        //   children: [
        //     Expanded(
        //       child: ListView(
        //         children: [
        //           PaginateFirestore(
        //             physics: NeverScrollableScrollPhysics(),
        //             shrinkWrap: true,
        //             query: FirebaseAPI().commentQuery(widget.documentId),
        //             itemBuilderType: PaginateBuilderType.listView,
        //             isLive: true,
        //             itemsPerPage: 20,
        //             onEmpty: Container(
        //               padding: EdgeInsets.symmetric(vertical: 8),
        //               child: Column(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: [
        //                   // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
        //                   // SizedBox(height: 20,),
        //                   Text('No Followers'),
        //                 ],
        //               ),
        //             ),
        //             itemBuilder: (context, documentSnapshot, index) {
        //               // String documentId = documentSnapshot[index].id;
        //               var userData = documentSnapshot[index].data() as Map<String, dynamic>;
        //               return Container();
        //             }
        //           )
        //         ]
        //       )
        //     ),
        //   ],
        // ),
      )
    );
  }
}