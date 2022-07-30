/////////////////////////////////////////
///// TODO: PASS THROUGH LIST OF COLORS - 2 COLORS
///// TODO: DETERMINE LUM IN ALL THE COLORS IN LIST
///// TODO: DETERMINE WHICH COLOR SHOULD BE FIRST IN LIST BASED ON CONVAVE  &     CONVAX
////////////////////////////////
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';

// class NeumorphContainer extends StatefulWidget {
//   final double? width;
//   final double? height;
//   final Widget? child;
//   final double borderRadius;
//   final double blurRadius;
//   final List<BoxShadow>? boxShadow;
//   final NeumorphStyle style;
//   final List<Color>? colors;

//   NeumorphContainer({Key? key,
//     this.width,
//     this.height,
//     this.borderRadius = 0.0,
//     this.blurRadius = 0.0,
//     this.boxShadow,
//     this.child,
//     this.style = NeumorphStyle.flat,
//     this.colors
//   }): 
//       super(key: key);

//   @override
//   _NeumorphContainer createState() => _NeumorphContainer();
// }

class NeumorphContainer extends StatelessWidget {

  final double? width;
  final double? height;
  final Widget? child;
  final double borderRadius;
  final double blurRadius;
  final List<BoxShadow>? boxShadow;
  final List<Color>? colors;
  NeumorphStyle? style;
  bool isFlat = false;

  NeumorphContainer.concave({Key? key,
    this.width,
    this.height,
    this.borderRadius = 0.0,
    this.blurRadius = 0.0,
    this.boxShadow,
    this.colors,
    this.child
  }): 
      // colors = const [Color(0xffe6e6e6), Color(0xffffffff)],
      style = NeumorphStyle.concave,
      isFlat = false,
      super(key: key);

  NeumorphContainer.convex({Key? key,
    this.width,
    this.height,
    this.borderRadius = 0.0,
    this.blurRadius = 0.0,
    this.boxShadow,
    this.colors,
    this.child
  }): 
      // colors = const [Color(0xffffffff),Color(0xffe6e6e6)],
      style = NeumorphStyle.convex,
      isFlat = false,
      super(key: key);

  NeumorphContainer.flat({Key? key,
    this.width,
    this.height,
    this.borderRadius = 0.0,
    this.blurRadius = 0.0,
    this.boxShadow,
    this.child
  }): colors = const [],
      isFlat = true,
      super(key: key);

  
  List<Color> kColors(NeumorphStyle style) {
    print("HERE");
    if (style == NeumorphStyle.concave) { // CONCAVE
      if (Get.isDarkMode) {
        return [ColorConstants.gray900, ColorConstants.gray600];
      } else {
        return [Color(0xffe6e6e6), Color(0xffffffff)];
      }
    } else { // CONVEX
      if (Get.isDarkMode) {
        return [ColorConstants.gray600, ColorConstants.gray900];
      } else {
        return [Color(0xffffffff), Color(0xffe6e6e6)];
      }
    }

    // if (style == NeumorphStyle.convex) {
    //   if (Get.isDarkMode) {
    //     return [ColorConstants.gray700,ColorConstants.gray900];
    //   } else {
    //     return [Color(0xffffffff),Color(0xffe6e6e6)];
    //   }
    // }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isFlat ? Colors.white : null,
        gradient: isFlat ? null : LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: colors != null ? colors! : kColors(style!)
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow
        // boxShadow: [
        //   BoxShadow(
        //     color: Color(0xffcccccc),
        //     blurRadius: blurRadius,
        //     offset: Offset(0, 0)
        //   ),
        //   BoxShadow(
        //     color: Color(0xffffffff),
        //     blurRadius: blurRadius,
        //     offset: Offset(0, 0)
        //   )
        // ]
      ),
      child: child
    );
  }
}

enum NeumorphStyle {
  flat,
  convex,
  concave
}

class NeumorphDefaultColors {
  List<List<Color>> concave = [
    [Color(0xffe6e6e6), Color(0xffffffff)],
    [ColorConstants.gray400, ColorConstants.gray100]
  ];
  List<List<Color>> convex = [
    [Color(0xffffffff),Color(0xffe6e6e6)],
    [ColorConstants.gray100, ColorConstants.gray400]
  ];
}