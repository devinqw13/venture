import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:visibility_detector/visibility_detector.dart';

// class Indicator extends StatelessWidget {
//   final int length;
//   final int index;

//   const Indicator({Key? key, required this.length, required this.index}) : super(key: key);

//   _indicator(bool isActive) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       height: 6,
//       width: isActive ? 50 : 10,
//       margin: EdgeInsets.only(right: 5),
//       decoration: BoxDecoration(
//         color: isActive ? Colors.white : Colors.grey.shade500,
//         borderRadius: BorderRadius.circular(5)
//       ),
//     );
//   }

//   List<Widget> buildIndicator() {
//     List<Widget> indicators = [];
//     for (int i = 0; i<length; i++) {
//       if (index == i) {
//         indicators.add(_indicator(true));
//       } else {
//         indicators.add(_indicator(false));
//       }
//     }

//     return indicators;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.6),
//         borderRadius: BorderRadius.circular(20)
//       ),
//       child: Row(
//         children: buildIndicator(),
//       ),
//     );
//   }

// }

class Indicator extends StatefulWidget {
  final int length;
  final int index;
  Indicator({Key? key, required this.length, required this.index}) : super(key: key);

  @override
  _Indicator createState() => _Indicator();
}

class _Indicator extends State<Indicator> {
  var id = 0.obs;
  // bool _visible = true;
  RxBool _visible = true.obs;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _setTimer();

    id.listen((p0) {
      timer!.cancel();
      // setState(() => _visible = true);
      _visible.value = true;
      timer = Timer(Duration(seconds: 3), () {
        if (mounted) { 
          _visible.value = false;
          // setState(() {
          //   _visible=false; 
          // });
        }
      });
    });
  }

  _setTimer() {
    timer = Timer(Duration(seconds: 3), () {
      print("TIMER CALLED");
      if (mounted) { 
        _visible.value = false;
        // setState(() {
        //   _visible=false; 
        // });
      }
    });
  }

  _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 5,
      width: isActive ? 50 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade500,
        borderRadius: BorderRadius.circular(5)
      ),
    );
  }

  List<Widget> buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i<widget.length; i++) {
      if (widget.index == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    id.value = widget.index;
    // VisibilityDetectorController.instance.updateInterval = Duration.zero;
    return VisibilityDetector(
      key: UniqueKey(), 
      onVisibilityChanged: (d) {
        if(d.visibleFraction > 0.0) {
          timer!.cancel();
          _visible.value = true;
          timer = Timer(Duration(seconds: 3), () {
            if (mounted) { 
              _visible.value = false;
            }
          });
        }
      },
      child: Container(
        child: Obx(() => AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        opacity: _visible.value ? 1 : 0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Row(
            children: buildIndicator(),
          ),
        )
      ))),
    );
  }
}