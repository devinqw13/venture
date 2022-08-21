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
  Duration duration = const Duration(seconds: 3),
  @required String? msg,
  ToastGravity gravity = ToastGravity.TOP
}) async {
  IconData? icon;
  if(type == ToastType.ERROR) icon = Icons.close;
  if(type == ToastType.INFO) icon = Icons.info_outline;
  color == null ? 
    color = Get.isDarkMode ? 
      ColorConstants.gray800.withOpacity(0.8)
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