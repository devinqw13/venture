import 'package:flutter/material.dart';
import 'package:venture/Components/CustomDialogBox.dart';

Future<dynamic> showCustomDialog({
  @required BuildContext? context, 
  @required String? title,
  @required String? description, 
  @required TextAlign? descAlignment, 
  @required Map<String, dynamic>? buttons
}) async {
  var response = await showDialog(
    context: context!,
    builder: (BuildContext context) {
      return CustomDialogBox(
        title: title!,
        description: description!,
        descAlignment: descAlignment!,
        buttons: buttons!,
      );
    }
  );
  return response;
}