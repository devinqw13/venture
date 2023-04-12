import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final int itemCount;
  final bool hideZero;
  final Color badgeColor;
  final Color itemColor;
  final double top;
  final double right;
  final int maxCount;

  const NotificationBadge({
    Key? key,
    this.onTap,
    required this.icon,
    this.itemCount = 0,
    this.hideZero = false,
    this.badgeColor = Colors.blue,
    this.itemColor = Colors.white,
    this.maxCount = 99,
    this.top = 4.0,
    this.right = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        IconButton(
          icon: icon,
          onPressed: onTap
        ),
        itemCount == 0 && hideZero ? Container() : Positioned(
          right: right,
          top: top,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 14,
              minHeight: 14,
            ),
            child: itemCount > maxCount
                ? Text(
                    '$maxCount+',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 10.0,
                    ),
                  )
                : Text(
                    '$itemCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 10.0,
                    ),
                  ),
            // child: Text(
            //   '2',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 10,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
          ),
        )
      ],
    );
    // return itemCount == 0 && hideZero
    //     ? GestureDetector(
    //         onTap: onTap,
    //         child: Container(
    //           width: 72,
    //           padding: const EdgeInsets.symmetric(horizontal: 8),
    //           child: Stack(
    //             alignment: Alignment.center,
    //             children: [
    //               Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: <Widget>[
    //                   icon,
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       )
    //     : GestureDetector(
    //         onTap: onTap,
    //         child: Container(
    //           width: 72,
    //           padding: const EdgeInsets.symmetric(horizontal: 8),
    //           child: Stack(
    //             alignment: Alignment.center,
    //             children: [
    //               Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: <Widget>[
    //                   icon,
    //                 ],
    //               ),
    //               Positioned(
    //                 top: top,
    //                 right: right,
    //                 child: Container(
    //                   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    //                   decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.circular(50.0),
    //                     color: badgeColor,
    //                   ),
    //                   alignment: Alignment.center,
    //                   child: itemCount > maxCount
    //                       ? Text(
    //                           '$maxCount+',
    //                           style: TextStyle(
    //                             color: itemColor,
    //                             fontSize: 12.0,
    //                           ),
    //                         )
    //                       : Text(
    //                           '$itemCount',
    //                           style: TextStyle(
    //                             color: itemColor,
    //                             fontSize: 12.0,
    //                           ),
    //                         ),
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //       );
  }
}