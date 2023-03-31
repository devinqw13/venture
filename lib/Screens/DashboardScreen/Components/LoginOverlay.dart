import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Constants.dart';
import 'package:get/get.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Screens/CreateUserScreen.dart/CreateUserScreen.dart';
import 'package:venture/Screens/SettingsScreen/SettingsScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Components/PointedLine.dart';

class LoginOverlay extends StatefulWidget {
  final bool enableSettings;
  final bool enableBackButton;
  final String? message;
  LoginOverlay({Key? key, this.enableBackButton = false, this.enableSettings = false, this.message}) : super(key: key);

  @override
  _LoginOverlay createState() => _LoginOverlay();
}

class _LoginOverlay extends State<LoginOverlay>  {
  final TextEditingController userTextController = TextEditingController();
  final TextEditingController pwdTextController = TextEditingController();
  bool obsecure = true;
  bool isLoading = false;

  _postLogin() async {
    KeyboardUtil.hideKeyboard(context);
    if (isLoading) return;
    setState(() => isLoading = true);
    if (userTextController.text.isEmpty || pwdTextController.text.isEmpty) {
      showToast(context: context, msg: "User/password must not be empty.");
      return;
    }
    // bool? _ = await postLogin(context, userTextController.text, pwdTextController.text);
    var _ = await FirebaseAPI().login(
      context,
      userTextController.text,
      pwdTextController.text
    );

    setState(() => isLoading = false);
    if(widget.enableBackButton && FirebaseAPI().firebaseId() != null) Navigator.pop(context);
  }

  void goToSettings() {
    SettingsScreen settingsScreen = SettingsScreen();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => settingsScreen));
  }
  
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Stack(
        children: [
          ClipRRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                alignment: Alignment.center,
                color: Get.isDarkMode ? ColorConstants.gray800.withOpacity(0.95) : Colors.white.withOpacity(0.1),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? ColorConstants.gray900 : Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Get.isDarkMode ? ColorConstants.gray700.withOpacity(0.9) : Colors.grey.withOpacity(0.9),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.message != null ? Center(
                          child: Text(
                            widget.message!,
                            style: TextStyle(
                              color: primaryOrange
                            ),
                          )
                        ) : Container(),
                        SizedBox(height: 15),
                        Center(
                          child: Text("Venture",
                            style: TextStyle(
                              fontFamily: "Coolvetica",
                              fontSize: 55
                            ),
                          )
                        ),
                        SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextField(
                            readOnly: isLoading,
                            controller: userTextController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                              hintText: "Username or email",
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextField(
                            readOnly: isLoading,
                            controller: pwdTextController,
                            obscureText: obsecure,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                              hintText: "Password",
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ZoomTapAnimation(
                                  onTap: () => setState(() => obsecure = !obsecure),
                                  child: Container(
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Get.isDarkMode ? ColorConstants.gray800 : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Center(
                                      child: Icon(obsecure ? IconlyLight.show : IconlyLight.hide, color: Colors.grey),
                                    ),
                                  )
                                )
                              )
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: () => _postLogin(),
                          child: isLoading ? 
                          SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)): Text("Login"),
                          style: ElevatedButton.styleFrom(
                            elevation: 1,
                            shadowColor: primaryOrange,
                            primary: primaryOrange,
                            minimumSize: const Size.fromHeight(40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: PointedLine(height: 0.5)
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? "),
                            ZoomTapAnimation(
                              onTap: () async {
                                if(widget.enableBackButton) Navigator.pop(context);

                                final CreateUserScreen screen = CreateUserScreen();
                                Navigator.of(context).push(SlideUpDownPageRoute(page: screen, closeDuration: 400));
                              },
                              child: Text("Create",
                                style: TextStyle(
                                  color: primaryOrange
                                )
                              )
                            )
                          ],
                        )
                      ]
                    )
                  )
                ),
              )
            )
          ),

          widget.enableBackButton ? Positioned(
            left: 0,
            top: 0,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Icon(Icons.close),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  shadowColor: primaryOrange,
                  primary: primaryOrange,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(20.0),
                  // )
                  shape: CircleBorder(),
                ),
              ),
            )
          ) : Container(),

          widget.enableSettings ? Positioned(
            right: 0,
            top: 0,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
              child: ElevatedButton(
                onPressed: () => goToSettings(),
                child: Icon(IconlyLight.setting),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  shadowColor: primaryOrange,
                  primary: primaryOrange,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(20.0),
                  // )
                  shape: CircleBorder(),
                ),
              )
            )
          ) : Container()
        ]
      )
    );
  }
}