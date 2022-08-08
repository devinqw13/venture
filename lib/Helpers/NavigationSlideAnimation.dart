import 'package:flutter/material.dart';

class SlideUpDownPageRoute extends PageRouteBuilder {
  final Widget? page;
  final int openDuration;
  final int closeDuration;
  SlideUpDownPageRoute({
    @required this.page, 
    this.openDuration = 200,
    this.closeDuration = 200
  }) : super(pageBuilder: (BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) => page!);

  @override
  Duration get transitionDuration => Duration(milliseconds: openDuration);
  
  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: closeDuration);

  // OPTIONAL IF YOU WISH TO HAVE SOME EXTRA ANIMATION WHILE ROUTING
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 1), end: Offset(0.0, 0.0))
          .animate(controller!),
      child: page,
    );
  }
}