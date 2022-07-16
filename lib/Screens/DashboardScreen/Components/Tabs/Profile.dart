import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:iconly/iconly.dart';

class ProfileTab extends GetView<HomeController> {
  ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: false,
            expandedHeight: MediaQuery.of(context).size.height * 0.12,
            flexibleSpace: Stack(
              children: [
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://images.pexels.com/photos/62389/pexels-photo-62389.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
                        ),
                        fit: BoxFit.cover
                      )
                    ),
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.white.withOpacity(0.3),
                        )
                      )
                    )
                  ),
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0
                ),
                Positioned(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                  bottom: -1,
                  left: 0,
                  right: 0,
                ),
                // Row(
                //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Container(
                //       decoration: BoxDecoration(
                //         shape: BoxShape.circle,
                //         image: DecorationImage(
                //           fit: BoxFit.cover,
                //           image: NetworkImage("https://i.pinimg.com/736x/f9/81/d6/f981d67d2ab128e21f0ae278082d0426.jpg")
                //         )
                //       )
                //     ),
                //   ],
                // )
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage("https://i.pinimg.com/736x/f9/81/d6/f981d67d2ab128e21f0ae278082d0426.jpg")
                      )
                    )
                  ),
                )
              ],
            )
          ),
          SliverToBoxAdapter(
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Devin Williams",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0
                      ),
                    )
                  )
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 20.0),
                    child: Text(
                      "Cincinnati, OH",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15.0
                      ),
                    )
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ElevatedButton(
                    //   child: Icon(IconlyBroken.location, color: Colors.orange, size: 30),
                    //   onPressed: () {},
                    //   style: ElevatedButton.styleFrom(
                    //     shape: CircleBorder(),
                    //     primary: Colors.white 
                    //   ),
                    // ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(360, 40),
                        elevation: 10,
                        shadowColor: primaryOrange,
                        primary: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        )
                      ),
                    ),
                    // ElevatedButton(
                    //   child: Icon(IconlyBroken.send, color: Colors.orange, size: 30),
                    //   onPressed: () {},
                    //   style: ElevatedButton.styleFrom(
                    //     shape: CircleBorder(),
                    //     primary: Colors.white 
                    //   ),
                    // )
                  ],
                ),

              ],
            )
          )
          // SliverFixedExtentList(
          //   itemExtent: 50.0,
          //   delegate: SliverChildBuilderDelegate(
          //     (BuildContext context, int index) {
          //       return Container(
          //         alignment: Alignment.center,
          //         color: Colors.lightBlue[100 * (index + 1 % 9)],
          //         child: Text('List Item $index'),
          //       );
          //     },
          //   ),
          // )
        ],
      )
    );
  }
}