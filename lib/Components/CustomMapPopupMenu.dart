import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/NeumorphContainer.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:get/get.dart';

class CustomMapPopupMenuItem {
  Text text;
  Icon? icon;
  VoidCallback? onTap;

  CustomMapPopupMenuItem({required this.text, this.icon, this.onTap});
}

class CustomMapPopupMenu extends StatefulWidget {
  final List<CustomMapPopupMenuItem> popupItems;
  const CustomMapPopupMenu({
    Key? key,
    required this.popupItems
  })  :
        super(key: key);
  @override
  _CustomMapPopupMenu createState() => _CustomMapPopupMenu();
}

class _CustomMapPopupMenu extends State<CustomMapPopupMenu> with TickerProviderStateMixin {
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
      Widget title, Icon? icon, Function? onTap) {
    return PopupMenuItem(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      value: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: icon
          ),
          title,
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
      items: widget.popupItems.map<PopupMenuEntry<dynamic>>((s) =>
        _buildPopupMenuItem(s.text, s.icon, s.onTap)
      ).toList(),
      context: context,
      position: _getRelativeRect(_key, Offset(0.0, 52.0)),
    ).then((value) {
      if(value != null) value();

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
        height: 45,
        width: 45,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(0,2),
          blurRadius: 1
          ),
        ],
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