import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';

enum WidgetStatus {
  // ignore: constant_identifier_names
  HIDDEN,
  // ignore: constant_identifier_names
  VISIBLE
}

class SlideOverlay extends StatefulWidget {
  final ValueNotifier<WidgetStatus> status;
  final Widget child;
  final double height;
  SlideOverlay({
    Key? key,
    required this.height,
    required this.status,
    required this.child
  }) : super(key: key);

  @override
  _SlideOverlay createState() => _SlideOverlay();
}

class _SlideOverlay extends State<SlideOverlay> with TickerProviderStateMixin {
  double height = 0.0;
  double opacity = 0.0;
  bool active = false;
  final duration = Duration(milliseconds: 200);
  late AnimationController animationController, opacityAnimationController;
  late Animation positionAnimation, opacityAnimation;
  VoidCallback? test;
  WidgetStatus wStatus = WidgetStatus.HIDDEN;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(duration: duration, vsync: this);
    opacityAnimationController = AnimationController(duration: duration, vsync: this);
    positionAnimation = Tween(begin: 0.0, end: widget.height).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut)
    );
    opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: opacityAnimationController, curve: Curves.easeInOut)
    );
    positionAnimation.addListener(() {
      setState(() {});
    });
    opacityAnimation.addListener(() {
      setState(() {});
    });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (active) {
          wStatus = WidgetStatus.HIDDEN;
        } else {
          wStatus = WidgetStatus.VISIBLE;
        }
      }
    });

    widget.status.addListener(() {
      switch(widget.status.value) {
        case WidgetStatus.VISIBLE:
          animationController.forward(from: 0.0);
          opacityAnimationController.forward(from: 0.0);
          wStatus = WidgetStatus.VISIBLE;
          break;
        case WidgetStatus.HIDDEN:
          animationController.reverse(from: widget.height); // 400.0
          opacityAnimationController.reverse(from: 1.0);
          wStatus = WidgetStatus.HIDDEN;
          break;
      }
    });
  }

  @override
  void dispose() {
    if(mounted) animationController.dispose();
    if(mounted) opacityAnimationController.dispose();
    super.dispose();
  }

  _buildOverlay() {
    switch(wStatus) {
      case WidgetStatus.HIDDEN:
        height = positionAnimation.value;
        opacity = opacityAnimation.value;
        active = false;
        break;
      case WidgetStatus.VISIBLE:
        height = positionAnimation.value;
        opacity = opacityAnimation.value;
        active = true;
        break;
    }
    return Opacity(
      opacity: opacity,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: height,
          child: widget.child,
          // child: Opacity(
          //   opacity: opacity,
          //   child: Column(
          //     mainAxisSize: MainAxisSize.max,
          //     children: <Widget>[
          //       Expanded(
          //         flex: 6,
          //         child: Container()
          //       ),
          //     ],
          //   )
          // ),
          color: Get.isDarkMode ? ColorConstants.gray500.withOpacity(0.8) : ui.Color.fromARGB(255, 220, 220, 220).withOpacity(0.8),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildOverlay();
  }

}