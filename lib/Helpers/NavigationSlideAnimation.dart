import 'package:flutter/material.dart';

class SlideUpDownPageRoute extends PageRouteBuilder {
  final Widget? page;
  SlideUpDownPageRoute({@required this.page}) : super(pageBuilder: (BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) => page!);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
  
  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: 200);

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