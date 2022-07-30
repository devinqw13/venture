import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Components/PointedLine.dart';

class LoginOverlay extends StatefulWidget {
  LoginOverlay({Key? key}) : super(key: key);

  @override
  _LoginOverlay createState() => _LoginOverlay();
}

class _LoginOverlay extends State<LoginOverlay>  {
  bool obsecure = true;
  
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            alignment: Alignment.center,
            color: Get.isDarkMode ? ColorConstants.gray700.withOpacity(0.3) : Colors.white.withOpacity(0.1),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? ColorConstants.gray900 : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Get.isDarkMode ? ColorConstants.gray700.withOpacity(0.8) : Colors.grey.withOpacity(0.9),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Center(
                      child: Text("Venture",
                        style: TextStyle(
                          fontFamily: "GrandHotel",
                          fontSize: 60
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
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                          hintText: "Username",
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
                      onPressed: () => print("START LOGIN PROCESS"),
                      child: Text("Login"),
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
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
                      child: PointedLine()
                    )
                  ]
                )
              )
            ),
          )
        )
      )
    );
  }
}