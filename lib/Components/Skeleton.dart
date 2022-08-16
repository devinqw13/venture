import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

class Skeleton extends StatelessWidget {
  // Skeleton({Key? key, this.width, this.height}) : super(key: key);

  final double? width, height;
  final ShapeBorder shapeBorder;
  final BoxShape boxShape;
  final double? borderRadius;
  final int seconds;

  const Skeleton.rectangular({Key? key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
    this.seconds = 2
  }) :
      boxShape = BoxShape.rectangle,
      shapeBorder = const RoundedRectangleBorder(),
      super(key: key);

  const Skeleton.circular({Key? key, 
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
    this.seconds = 2
  }) : 
      boxShape = BoxShape.circle,
      shapeBorder = const CircleBorder(),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Get.isDarkMode ? Color(0xff2a2a2a) : Colors.grey[300]!,
      highlightColor: Get.isDarkMode ? Color(0xff3a3a3a) : Colors.grey[100]!,
      period: Duration(seconds: seconds),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[400]!,
          borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
          shape: boxShape
        ),
        // decoration: BoxDecoration(
        //   color: Colors.grey[400]!,
        //   shape: shapeBorder,

        // ),
      ),
    );
  }
}