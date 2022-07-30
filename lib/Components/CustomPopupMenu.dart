import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/NeumorphContainer.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:get/get.dart';

class CustomPopupMenu extends StatefulWidget {
  const CustomPopupMenu({
    Key? key,
  })  :
        super(key: key);
  @override
  _CustomPopupMenu createState() => _CustomPopupMenu();
}

class _CustomPopupMenu extends State<CustomPopupMenu> with TickerProviderStateMixin {
  GlobalKey _key = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _animateIcon;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, IconData iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 5.0,
            ),
            child: Icon(
              iconData,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            )
          ),
          Text(title),
        ],
      ),
    );
  }

  RelativeRect _getRelativeRect(GlobalKey key, Offset ofst) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;

    final RenderBox overlay = Navigator.of(key.currentState!.context).overlay!.context.findRenderObject()! as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(ofst, ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero) + ofst, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    return position;
  }

  _showPopupMenu() {
    showMenu(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      items: <PopupMenuEntry>[
        _buildPopupMenuItem('Add Pin', IconlyLight.location, 0),
        _buildPopupMenuItem('Create Meet', IconlyLight.chat, 1),
      ],
      context: context,
      position: _getRelativeRect(_key, Offset(0.0, 48.0)),
    ).then((value) {
      _animationController.reverse();
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      key: _key,
      onTap: () {
        if (_animationController.isDismissed) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }

        _showPopupMenu();
      },
      child: NeumorphContainer.convex(
        borderRadius: 10.0,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: AnimatedIcon(
              color: Get.isDarkMode ? Colors.white : Colors.black,
              icon: AnimatedIcons.menu_close,
              progress: _animateIcon
            )
          )
        ),
      )
    );
  }
}