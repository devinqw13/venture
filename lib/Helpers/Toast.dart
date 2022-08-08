import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// class Toast extends StatelessWidget {

//   final BuildContext context;
//   final 

// }

void showToast({
  @required BuildContext? context, 
  @required String? msg,
  ToastGravity gravity = ToastGravity.TOP
}) async {
  FToast fToast = FToast().init(context!);
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.red,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(Icons.close),
        SizedBox(width: 12.0),
        Flexible(child: Text(msg!)),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: gravity,
    toastDuration: Duration(seconds: 3),
  );
}