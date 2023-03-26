import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:get/get.dart';

class CustomOptionPopupMenuItem {
  Text text;
  Widget? icon;
  VoidCallback? onTap;

  CustomOptionPopupMenuItem({required this.text, this.icon, this.onTap});
}

class CustomOptionsPopupMenu extends StatefulWidget {
  final List<CustomOptionPopupMenuItem>? popupItems;
  const CustomOptionsPopupMenu({
    Key? key,
    required this.popupItems
  })  :
        super(key: key);
  @override
  _CustomOptionsPopupMenu createState() => _CustomOptionsPopupMenu();
}

class _CustomOptionsPopupMenu extends State<CustomOptionsPopupMenu> with TickerProviderStateMixin {
  GlobalKey _key = GlobalKey();
  Color color = Get.isDarkMode ? Colors.white : Colors.black;

  @override
  void initState() {
    super.initState();

  }

  PopupMenuItem _buildPopupMenuItem(
      Widget title, Widget? icon, Function? onTap) {
    return PopupMenuItem(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      value: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          icon != null ? Padding(
            padding: EdgeInsets.only(left: 10),
            child: icon
          ) : Container(padding: EdgeInsets.only(left: 10)),
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
      color: Get.isDarkMode ?
      ColorConstants.gray500.withOpacity(0.9)
      : Colors.grey.shade200.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      items: widget.popupItems!.map<PopupMenuEntry<dynamic>>((s) =>
        _buildPopupMenuItem(s.text, s.icon, s.onTap)
      ).toList(),
      context: context,
      position: _getRelativeRect(_key, Offset(0.0, 48.0)),
    ).then((value) {
      if(value != null) value();

      setState(() {
        color = Get.isDarkMode ? Colors.white : Colors.black;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      key: _key,
      onTap: () {
        setState(() {
          color = primaryOrange;
        });

        _showPopupMenu();
      },
      child: Center(
        child:Icon(
          Icons.more_horiz,
          color: color,
        )
      ),
    );
  }
}