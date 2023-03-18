import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseServices.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController pwdTextController = TextEditingController();
  final TextEditingController pwdRepeatTextController = TextEditingController();
  bool isLoading = false;
  bool enableButton = false;

  onPasswordChanged() {
    if(pwdTextController.text.isNotEmpty && pwdRepeatTextController.text.isNotEmpty) {
      setState(() => enableButton = true);
    }else {
      setState(() => enableButton = false);
    }
  }

  _changePassword() async {
    if(isLoading) return;
    KeyboardUtil.hideKeyboard(context);

    if(pwdTextController.text.isEmpty || pwdRepeatTextController.text.isEmpty) {
      showToast(context: context, gravity: ToastGravity.BOTTOM, msg: "Password fields must not be empty.");
      return;
    }

    if(pwdTextController.text.length < 6) {
      showToast(context: context, gravity: ToastGravity.BOTTOM, msg: "Password must be atleast 6 characters long.");
      return;
    }

    if(!RegExp(r'[0-9]').hasMatch(pwdTextController.text)) {
      showToast(context: context, gravity: ToastGravity.BOTTOM, msg: "Password must contain atleast one number character.");
      return;
    }

    if(pwdTextController.text != pwdRepeatTextController.text) {
      showToast(context: context, gravity: ToastGravity.BOTTOM, msg: "Password fields does not match.");
      return;
    }

    setState(() => isLoading = true);
    await FirebaseServices().updatePassword(
      context,
      pwdTextController.text
    );
    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          !isLoading ? enableButton ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: ZoomTapAnimation(
                onTap: _changePassword,
                child: Text(
                  "Done",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Get.isDarkMode ? Colors.white : Colors.black
                  ),
                )
              )
            )
          ) : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "Done",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Get.isDarkMode ? ColorConstants.gray400 : Colors.grey
                ),
              )
            )
          ) : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoActivityIndicator(
              radius: 13,
            )
          )
        ],
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: Get.isDarkMode ? ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7) : ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Get.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        centerTitle: false,
        title: Text(
          'Change your password',
          style: theme.textTheme.headline6,
        )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            // Text("Set a password", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            // SizedBox(height: 10),
            Text("Create a new secure password.", 
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade600)),
            SizedBox(height: 30),
            TextField(
              controller: pwdTextController,
              readOnly: isLoading,
              obscureText: true,
              decoration: InputDecoration(
                // suffixIcon: Padding(
                //   padding: const EdgeInsets.all(5.0),
                //   child: ZoomTapAnimation(
                //     onTap: () => setState(() => obsecure = !obsecure),
                //     child: Container(
                //       width: 40,
                //       decoration: BoxDecoration(
                //         color: Get.isDarkMode ? ColorConstants.gray800 : Colors.grey.shade100,
                //         borderRadius: BorderRadius.circular(10)
                //       ),
                //       child: Center(
                //         child: Icon(obsecure ? IconlyLight.show : IconlyLight.hide, color: Colors.grey),
                //       ),
                //     )
                //   )
                // ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
                ),
                hintText: "New password",
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
            SizedBox(height: 10),
            // Row(
            //   children: [
            //     AnimatedContainer(
            //       duration: Duration(milliseconds: 300),
            //       width: 20,
            //       height: 20,
            //       decoration: BoxDecoration(
            //         color: _isPasswordLengthAccepted ?  Colors.green : Colors.transparent,
            //         border: _isPasswordLengthAccepted ? Border.all(color: Colors.transparent) :
            //           Border.all(color: Colors.grey.shade400),
            //         borderRadius: BorderRadius.circular(50)
            //       ),
            //       child: Center(child: Icon(Icons.check, color: Get.isDarkMode ? ColorConstants.gray900 : Colors.grey.shade50, size: 15)),
            //     ),
            //     SizedBox(width: 10),
            //     Text("Contains at least 6 characters")
            //   ],
            // ),
            // SizedBox(height: 10),
            // Row(
            //   children: [
            //     AnimatedContainer(
            //       duration: Duration(milliseconds: 300),
            //       width: 20,
            //       height: 20,
            //       decoration: BoxDecoration(
            //         color: _hasPasswordOneNumber ?  Colors.green : Colors.transparent,
            //         border: _hasPasswordOneNumber ? Border.all(color: Colors.transparent) :
            //           Border.all(color: Colors.grey.shade400),
            //         borderRadius: BorderRadius.circular(50)
            //       ),
            //       child: Center(child: Icon(Icons.check, color: Get.isDarkMode ? ColorConstants.gray900 : Colors.grey.shade50, size: 15)),
            //     ),
            //     SizedBox(width: 10,),
            //     Text("Contains at least 1 number")
            //   ],
            // ),
            // SizedBox(height: 30),
            TextField(
              controller: pwdRepeatTextController,
              readOnly: isLoading,
              onChanged: (password) => onPasswordChanged(),
              obscureText: true,
              decoration: InputDecoration(
                // suffixIcon: Padding(
                //   padding: const EdgeInsets.all(5.0),
                //   child: ZoomTapAnimation(
                //     onTap: () => setState(() => obsecure2 = !obsecure2),
                //     child: Container(
                //       width: 40,
                //       decoration: BoxDecoration(
                //         color: Get.isDarkMode ? ColorConstants.gray800 : Colors.grey.shade100,
                //         borderRadius: BorderRadius.circular(10)
                //       ),
                //       child: Center(
                //         child: Icon(obsecure2 ? IconlyLight.show : IconlyLight.hide, color: Colors.grey),
                //       ),
                //     )
                //   )
                // ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
                ),
                hintText: "Confirm password",
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

