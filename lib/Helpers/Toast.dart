import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:venture/Constants.dart';
import 'package:get/get.dart';

enum ToastType {
  // ignore: constant_identifier_names
  ERROR,
  // ignore: constant_identifier_names
  INFO
}

void showToast({
  @required BuildContext? context, 
  Color? color,
  ToastType type = ToastType.ERROR,
  Duration duration = const Duration(seconds: 4),
  @required String? msg,
  ToastGravity gravity = ToastGravity.TOP
}) async {
  IconData? icon;
  if(type == ToastType.ERROR) icon = Icons.close;
  if(type == ToastType.INFO) icon = Icons.info_outline;
  color == null ? 
    color = Get.isDarkMode ? 
      ColorConstants.gray800.withOpacity(0.9)
      :Colors.grey.shade50.withOpacity(0.8)
  : null;
  FToast fToast = FToast().init(context!);
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: color,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon),
        SizedBox(width: 12.0),
        Flexible(child: Text(msg!)),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: gravity,
    toastDuration: duration,
  );
}

void showToastV2({
  required BuildContext? context, 
  Duration duration = const Duration(seconds: 4),
  Widget? icon,
  Brightness? forcedBrightness,
  required String msg,
  // ToastGravity gravity = ToastGravity.BOTTOM
}) async {
  Widget toast = ClipRRect(
    borderRadius: BorderRadius.circular(50.0),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        // alignment: Alignment.center,
        decoration: BoxDecoration(
          color: forcedBrightness != null ? forcedBrightness == Brightness.dark ? Colors.grey[350]!.withOpacity(0.5) : ColorConstants.gray600.withOpacity(0.8) : Get.isDarkMode ? ColorConstants.gray600.withOpacity(0.8) : Colors.grey[350]!.withOpacity(0.5),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: icon != null ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              icon != null ? Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: icon
              ) : Container(),
              Flexible(child: Text(msg)),
            ],
          )
        )
      )
    )
  );
  
  // FToast fToast = FToast().init(context!);
  FToast fToast = FToast().init(Get.key.currentContext!);
  fToast.showToast(
    child: toast,
    // gravity: gravity,
    toastDuration: duration,
    positionedToastBuilder: (ctx, child) {
      return Positioned(
        left: 10,
        right: 10,
        child: child,
        bottom: MediaQuery.of(ctx).padding.bottom + kBottomNavigationBarHeight,
      );
    }
  );
}

// class ToastWidget extends StatefulWidget {
//   ToastWidget({Key? key}) : super(key: key);

//   _ToastWidget createState() => _ToastWidget();
// }

// class _ToastWidget extends State<ToastWidget> {

//   FToast fToast;

//   @override
//   void initState() {
//       super.initState();
//       fToast = FToast();
//       // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
//       fToast.init(navigatorKey.currentContext!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     fToast.showToast(
//     child: toast,
//     // gravity: gravity,
//     toastDuration: duration,
//     positionedToastBuilder: (ctx, child) {
//       return Positioned(
//         left: 10,
//         right: 10,
//         child: child,
//         bottom: MediaQuery.of(ctx).padding.bottom + kBottomNavigationBarHeight,
//       );
//     }
//   );
//   }
// }