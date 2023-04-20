import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:get/get.dart';

class ForgetPasswordScreen extends StatefulWidget {
  ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgetPasswordScreen createState() => _ForgetPasswordScreen();
}

class _ForgetPasswordScreen extends State<ForgetPasswordScreen> {
  TextEditingController emailTextController = TextEditingController();
  bool isLoading = false;
  bool enableSubmit = false;

  bool checkEmail(String v) {
    var regExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if(v.isNotEmpty && regExp.hasMatch(v)) {
      setState(() => enableSubmit = true);
      return true;
    }else {
      setState(() => enableSubmit = false);
      return false;
    }
  }

  submitForgotPassword() {
    FirebaseAuth auth = FirebaseAuth.instance;
    setState(() => isLoading = true);
    auth.sendPasswordResetEmail(email: emailTextController.text).then((_) {
      Navigator.pop(context);
      showToastV2(
        context: context,
        msg: 'Reset instructions has been sent to your email.',
      );
    });
    setState(() => isLoading = false);
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
            icon: Icon(Icons.close, size: 28),
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
            'Forgot password',
            style: theme.textTheme.headline6,
          )
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 15),
                    Text("Enter your email address to reset your password.",
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade600)),
                    SizedBox(height: 10),
                    TextField(
                      onChanged: (v) => checkEmail(v),
                      keyboardType: TextInputType.emailAddress,
                      controller: emailTextController,
                      readOnly: isLoading,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
                        ),
                        hintText: "Email",
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 5 : 20),
                child: ElevatedButton(
                  onPressed: () => checkEmail(emailTextController.text) ? submitForgotPassword() : null, // _createUser(),
                  child: isLoading ? 
                  SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(
                    "Submit",
                    style: TextStyle(
                      color: enableSubmit ? Colors.white : Colors.grey
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 1,
                    foregroundColor: Colors.transparent,
                    // shadowColor: Colors.transparent,
                    backgroundColor: enableSubmit ? primaryOrange : Get.isDarkMode ? ColorConstants.gray500 : Colors.grey,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    splashFactory: NoSplash.splashFactory,
                  ),
                )
              ),
            ],
          ),
        )
        // body: CustomScrollView(
        //   slivers: [
        //     SliverAppBar(
        //       leading: ZoomTapAnimation(
        //         child: Icon(Icons.close, size: 28),
        //         onTap: () => Navigator.of(context).pop(),
        //       ),
        //       floating: false,
        //       pinned: true,
        //       flexibleSpace: FlexibleSpaceBar(
        //         centerTitle: true,
        //         // titlePadding: EdgeInsets.symmetric(horizontal: 16),
        //         title: Text(
        //           'Forgot password',
        //           style: theme.textTheme.headline6,
        //         ),
        //       ),
        //     ),

        //     SliverToBoxAdapter(
        //       child: Container(
        //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text("Username & email", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        //             SizedBox(height: 10),
        //             Text("Please set a unique username and email that can be used to identify you.", 
        //               style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade600)),
        //             SizedBox(height: 30),
        //             TextField(
        //               controller: emailTextController,
        //               readOnly: isLoading,
        //               decoration: InputDecoration(
        //                 border: OutlineInputBorder(
        //                   borderRadius: BorderRadius.circular(10),
        //                   borderSide: BorderSide(color: Colors.black)
        //                 ),
        //                 focusedBorder: OutlineInputBorder(
        //                   borderRadius: BorderRadius.circular(10),
        //                   borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
        //                 ),
        //                 hintText: "Username",
        //                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        //               ),
        //             ),

        //             SizedBox(height: 30),

        //             ElevatedButton(
        //               onPressed: () => submitForgotPassword(), // _createUser(),
        //               child: isLoading ? 
        //               SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
        //               : Text("Create Account"),
        //               style: ElevatedButton.styleFrom(
        //                 elevation: 1,
        //                 shadowColor: primaryOrange,
        //                 primary: primaryOrange,
        //                 minimumSize: const Size.fromHeight(40),
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(10.0),
        //                 )
        //               ),
        //             ),
        //           ],
        //         ),
        //       )
        //     )

        //   ],
        // ),
      )
    );
  }
}