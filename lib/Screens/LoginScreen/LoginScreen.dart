import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:venture/Components/FadeOverlay.dart';
import 'package:venture/Components/PointedLine.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Screens/CreateUserScreen/CreateUserScreen.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Screens/ForgotPasswordScreen/ForgotPasswordScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {

  showLogin() async {
    var result = await Navigator.of(context).push(
      FadeOverlay(
        backgroundColor: Colors.transparent,
        child: LoginPopup()
      )
    );
    
    if(result != null && result) showSignup();

    if(FirebaseAPI().firebaseId() != null) {
      Get.toNamed('/home');
    }
  }

  showSignup() async {
    final CreateUserScreen screen = CreateUserScreen();
    await Navigator.of(context).push(SlideUpDownPageRoute(page: screen, closeDuration: 300));

    if(FirebaseAPI().firebaseId() != null) {
      Get.toNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login-background-2.png"),
              fit: BoxFit.cover,
            ) 
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70.0, horizontal: 16.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Venture",
                        style: TextStyle(
                          fontFamily: "Coolvetica",
                          fontSize: 55,
                        ),
                      ),
                      Text(
                        "Explore more",
                        style: TextStyle(
                          fontSize: 18
                        ),
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ZoomTapAnimation(
                              child: ElevatedButton(
                                onPressed: () => showLogin(),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: primaryOrange,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  primary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                  )
                                ),
                              )
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          ZoomTapAnimation(
                            onTap: () => showSignup(),
                            child: Text(
                              "Sign up!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            )
                          )
                        ],
                      )
                    ]
                  )
                )
              ],
            )
          ),
        ),
      )
    );
  }
}

class LoginPopup extends StatefulWidget {
  LoginPopup({Key? key}) : super(key: key);

  @override
  _LoginPopup createState() => _LoginPopup();
}

class _LoginPopup extends State<LoginPopup> {
  TextEditingController userTextController = TextEditingController();
  TextEditingController pwdTextController = TextEditingController();
  bool isLoading = false;
  bool obsecure = true;

  _postLogin() async {
    KeyboardUtil.hideKeyboard(context);
    if (isLoading) return;
    if (userTextController.text.isEmpty || pwdTextController.text.isEmpty) {
      showToast(context: context, msg: "User/password must not be empty.");
      return;
    }
    setState(() => isLoading = true);
    // bool? _ = await postLogin(context, userTextController.text, pwdTextController.text);
    var userCreds = await FirebaseAPI().login(
      context,
      userTextController.text.trim(),
      pwdTextController.text
    );

    setState(() => isLoading = false);
    if(userCreds != null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Stack(
        children: [
          ClipRRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: ColorConstants.gray900.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color:ColorConstants.gray700.withOpacity(0.9) ,
                    //     spreadRadius: 1,
                    //     blurRadius: 1,
                    //     offset: Offset(0, 1), // changes position of shadow
                    //   ),
                    // ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            color: ColorConstants.gray600,
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
                            color: ColorConstants.gray600,
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
                                      color: ColorConstants.gray800,
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
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: ZoomTapAnimation(
                            onTap: () async {
                              final ForgetPasswordScreen screen = ForgetPasswordScreen();
                              await Navigator.of(context).push(SlideUpDownPageRoute(page: screen, closeDuration: 300));
                            },
                            child: Text("Forgot password?",
                              style: TextStyle(
                                color: primaryOrange
                              )
                            )
                          )
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
                                Navigator.pop(context, true);

                                // final CreateUserScreen screen = CreateUserScreen();
                                // Navigator.of(context).push(SlideUpDownPageRoute(page: screen, closeDuration: 300));
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

          Positioned(
            left: 0,
            top: 0,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Icon(Icons.close),
                style: ElevatedButton.styleFrom(
                  elevation: 1,
                  shadowColor: primaryOrange,
                  primary: primaryOrange,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(20.0),
                  // )
                  shape: CircleBorder(),
                ),
              ),
            )
          ),

          Container()
        ]
      )
    );
  }
}