import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';

class CircleCard extends StatelessWidget {
  CircleCard({Key? key, this.index}) : super(key: key);
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Icon(Icons.group, size: 20, color: Colors.grey.shade500),
            ),
          ),
          SizedBox(height: 20),
          Text("Group $index",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}