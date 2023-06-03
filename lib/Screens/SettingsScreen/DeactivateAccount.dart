import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Globals.dart' as globals;
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Models/VenUser.dart';

class DeactivateAccount extends StatefulWidget {
  DeactivateAccount({Key? key}) : super(key: key);

  _DeactivateAccount createState() => _DeactivateAccount();
}

class _DeactivateAccount extends State<DeactivateAccount> {
  final TextEditingController pwdTextController = TextEditingController();
  bool isUserLoading = false;
  bool isDeactivateLoading = false;
  bool isDeleteLoading = false;
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    setState(() => isUserLoading = true);
    var result = await FirebaseAPI().getUserFromFirebaseId(FirebaseAPI().firebaseId()!);
    setState(() => isUserLoading = false);
    setState(() => user = result!);
  }

  startDeactivation() async {
    KeyboardUtil.hideKeyboard(context);
    if(isDeactivateLoading || isDeleteLoading) return;

    if(pwdTextController.text.isEmpty) {
      showToastV2(context: context, msg: 'Must enter your password.');
      return;
    }

    setState(() => isDeactivateLoading = true);
    bool didReauth = await FirebaseAPI().reauthenticate(
      context, 
      VenUser().email,
      pwdTextController.text
    );
    setState(() => isDeactivateLoading = false);

    if(didReauth) {
      var result = await showCustomDialog(
        context: context, 
        barrierDismissible: false,
        title: "Deactivate account", 
        description: "Are you sure you want to deactivate your Venture account?", 
        descAlignment: TextAlign.center,
        buttonDirection: Axis.vertical,
        buttons: {
          "Deactivate": {
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

      if(result) {
        setState(() => isDeactivateLoading = true);
        bool deactivated = await deactivateVentureAccount(context, VenUser().userKey.value, FirebaseAPI().firebaseId()!, isSelf: true);
        setState(() => isDeactivateLoading = false);

        if(deactivated) {
          globals.logout(context);
        }
      }
    }
  }

  startDeletion() async {
    KeyboardUtil.hideKeyboard(context);
    if(isDeactivateLoading || isDeleteLoading) return;

    if(pwdTextController.text.isEmpty) {
      showToastV2(context: context, msg: 'Must enter your password.');
      return;
    }

    setState(() => isDeleteLoading = true);
    bool didReauth = await FirebaseAPI().reauthenticate(
      context, 
      VenUser().email,
      pwdTextController.text
    );
    setState(() => isDeleteLoading = false);

    if(didReauth) {
      var result = await showCustomDialog(
        context: context, 
        barrierDismissible: false,
        title: "Delete account", 
        description: "This action cannot be undone. Are you sure you want to Delete your Venture account?", 
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

      if(result) {
        setState(() => isDeleteLoading = true);
        var _ = terminateVentureAccount(context, VenUser().userKey.value, FirebaseAPI().firebaseId()!);
        setState(() => isDeleteLoading = false);

        globals.logout(context);
      }
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
          title: Text(
            'Deactivate account',
            style: theme.textTheme.headline6,
          )
        ),
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 20,
            left: 16,
            right: 16
          ),
          children: [
            !isUserLoading ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyAvatar(
                  photo: user['photo_url']
                ),
                SizedBox(width: 10),
                user['display_name'] != null && user['display_name'] != '' ?
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${user['display_name']} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          )
                        ),
                        if(user['verified'])
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: CustomIcon(
                              icon: 'assets/icons/verified-account.svg',
                              size: 14,
                              color: primaryOrange,
                            )
                          ),
                        TextSpan(
                          text: "\n${user['username']}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16
                          )
                        ),
                      ]
                    )
                  )
                  : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${user['username']} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          )
                        ),
                        if(user['verified'])
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: CustomIcon(
                              icon: 'assets/icons/verified-account.svg',
                              size: 14,
                              color: primaryOrange,
                            )
                          ),
                      ]
                    )
                  )
              ],
            ) :
            CupertinoActivityIndicator(
              radius: 13,
            ),

            SizedBox(height: 20),
            Text(
              "Deactiving your account",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            SizedBox(height: 5),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Get.isDarkMode ? ColorConstants.gray25 : ColorConstants.gray900
                ),
                children: [
                  TextSpan(
                    text: "While deactiving your Venture account your profile, pins, content (photo & videos), comments and likes will be hidden until you "
                  ),
                  TextSpan(
                    text: "enable your account by logging back in. ",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  TextSpan(
                    text: "Deactivating your account is temporary."
                  )
                ]
              )
            ),
            // Text(
            //   "While deactiving your Venture account your profile, pins, content (photo & videos), comments and likes will be hidden until you enable your account by logging back in. Deactivating your account is temporary.",
            //   style: TextStyle(
            //     color: Get.isDarkMode ? ColorConstants.gray25 : ColorConstants.gray900
            //   ),
            // ),
            SizedBox(height: 20),
            Text(
              "Deleting your account",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            SizedBox(height: 5),
            Text(
              "While deleting your Venture account your profile, pins, content (photo & videos), comments, likes, and followers will be deleted. Deleting your account is permanent and cannot be undone.",
              style: TextStyle(
                color: Get.isDarkMode ? ColorConstants.gray25 : ColorConstants.gray900
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Verify account",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            SizedBox(height: 5),
            Text(
              "This is to verify that it is you performing this action.",
              style: TextStyle(
                color: Get.isDarkMode ? ColorConstants.gray25 : ColorConstants.gray900
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: pwdTextController,
              readOnly: (isDeactivateLoading || isDeleteLoading),
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
                ),
                hintText: "Current password",
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => startDeactivation(),
                    child: !isDeactivateLoading && !isDeleteLoading ? Text(
                      "Deactivate",
                      style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ) : CupertinoActivityIndicator(
                      radius: 13,
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: primaryOrange,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(20.0),
                      // )
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: ZoomTapAnimation(
                onTap: () => startDeletion(),
                child: Text("Delete account",
                  style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                )
              )
            )
          ],
        ),
      )
    );
  }
}