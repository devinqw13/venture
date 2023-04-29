import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Models/Pin.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class PinSettingsScreen extends StatefulWidget {
  final Pin pin;
  PinSettingsScreen({Key? key, required this.pin}) : super(key: key);

  @override
  _PinSettingsScreen createState() => _PinSettingsScreen();
}

class _PinSettingsScreen extends State<PinSettingsScreen> {
  late TextEditingController nameController;
  bool isLoading = false;
  bool enableButton = false;
  late Pin pin;

  @override
  void initState() {
    super.initState();
    pin = widget.pin;
    nameController = TextEditingController(text: pin.title!);
  }

  checkDoneButton() {
    if(
      pin.title != nameController.text
    ) {
      setState(() => enableButton = true);
    }else {
      setState(() => enableButton = false);
    }
  }

  _deletePin() async {
    var result = await showCustomDialog(
      context: context,
      barrierDismissible: false,
      title: 'Delete pin?', 
      description: "Are you sure you want to delete this pin? It will be permanently deleted.",
      descAlignment: TextAlign.center,
      buttonDirection: Axis.vertical,
      buttons: {
        "Delete": {
          "action": () => Navigator.of(context).pop(true),
          "fontWeight": FontWeight.bold,
          "textColor": Colors.red,
          "alignment": TextAlign.center
        },
        "Cancel": {
          "action": () => Navigator.of(context).pop(false),
          "textColor": Get.isDarkMode ? Colors.white : Colors.black,
          "alignment": TextAlign.center
        },
      }
    );

    if(result != null && result) {
      deletePins(context, [pin.pinKey], FirebaseAPI().firebaseId()!);
      Navigator.of(context)..pop()..pop({"action": "deleted"});
      // LoginScreen loginController = LoginScreen();
      // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => loginController), (Route<dynamic> route) => false);

      // Navigator.of(context).popUntil(ModalRoute.withName("/home"));

    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DismissKeyboard(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(IconlyLight.arrow_left, size: 25),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: Get.isDarkMode ? ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7) : ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Get.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          centerTitle: true,
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Settings',
                  style: theme.textTheme.headline6!.copyWith(
                    color: Colors.grey
                  )
                ),
                TextSpan(
                  text: "\n${pin.title}",
                  style: theme.textTheme.headline6!
                )
              ]
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: ListView(
          children: [
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey,
                  width: 0.3
                ),
                bottom: BorderSide(
                  color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey,
                  width: 0.3
                )
              ),
              children: [
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 20),
                      child: Text(
                        "Name",
                      )
                    ),
                    TextField(
                      controller: nameController,
                      readOnly: isLoading,
                      onChanged: (v) => checkDoneButton(),
                      decoration: InputDecoration(
                        hintText: "Pin name",
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      ),
                    )
                  ],
                ),
              ]
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ZoomTapAnimation(
                onTap: () => _deletePin(),
                child: Text("Delete pin",
                  style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                )
              )
            )
          ]
        )
      )
    );
  }
}