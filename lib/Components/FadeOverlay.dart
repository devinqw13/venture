import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FadeOverlay extends ModalRoute {
  final Widget? child;
  final Color? backgroundColor;
  final ui.ImageFilter? blur;
  FadeOverlay({this.child, this.backgroundColor, this.blur}) : super();

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => backgroundColor != null ? backgroundColor! : Get.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5);

  @override
  Null get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    // This makes sure that text and other content follows the material style
    return Material(
          type: MaterialType.transparency,
          // make sure that the overlay content is not cut off
          child: child != null ? child! : _buildOverlayContent(context),
        );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'This is a nice overlay',
            style: TextStyle(color: Colors.white, fontSize: 30.0),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Dismiss'),
          )
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}