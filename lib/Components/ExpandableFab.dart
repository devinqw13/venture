import 'package:flutter/material.dart';

class ExpandableFab extends StatefulWidget {
  final List<TabAction>? actions;
  final Icon? icon;
  final Icon? closeIcon;
  ExpandableFab({Key? key, this.actions, this.icon, this.closeIcon}) : super(key: key);

  @override
  _ExpandableFab createState() => _ExpandableFab();
}

class _ExpandableFab extends State<ExpandableFab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animateIcon;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.actions!.length, (int index) {
        TabAction thisAppAction = widget.actions![index];
        // IconData thisAppActionIcon = matchIconToName(thisAppAction.icon);
        Widget child = Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.0,
                  1.0 - index / widget.actions!.length / 2.0,
                  curve: Curves.easeInOut
                ),
              ),
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.orange,
                mini: false,
                child: Icon(thisAppAction.icon, color: Colors.white),
                onPressed: () {
                  _animationController.reverse();
                  thisAppAction.onTap;
                },
              ),
            ),
          ),
        );
        return child;
      }).toList()
      ..add(
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            heroTag: null,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              color: Colors.white,
              progress: _animateIcon,
            ),
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        ),
      ),
    );
  }
}

class TabAction {
  String? title;
  IconData? icon;
  GestureTapCallback? onTap;

  TabAction({this.title, this.icon, this.onTap});
}