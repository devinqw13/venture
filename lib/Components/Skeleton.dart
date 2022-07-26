import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  // Skeleton({Key? key, this.width, this.height}) : super(key: key);

  final double? width, height;
  final ShapeBorder shapeBorder;
  final int seconds;

  const Skeleton.rectangular({Key? key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
    this.seconds = 2
  }) : super(key: key);

  const Skeleton.circular({Key? key, 
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const CircleBorder(),
    this.seconds = 2
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(seconds: seconds),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[400]!,
          shape: shapeBorder,

        ),
      ),
    );
  }
}