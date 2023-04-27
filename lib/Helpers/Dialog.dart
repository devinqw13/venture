import 'package:flutter/material.dart';
import 'package:venture/Components/CustomDialogBox.dart';

Future<dynamic> showCustomDialog({
  @required BuildContext? context, 
  @required String? title,
  @required String? description, 
  @required TextAlign? descAlignment, 
  Axis buttonDirection = Axis.horizontal,
  bool barrierDismissible = true,
  @required Map<String, dynamic>? buttons
}) async {
  var response = await showDialog(
    barrierDismissible: barrierDismissible,
    context: context!,
    builder: (BuildContext context) {
      return CustomDialogBox(
        title: title!,
        description: description!,
        descAlignment: descAlignment!,
        buttonDirection: buttonDirection,
        buttons: buttons!,
      );
    }
  );
  return response;
}