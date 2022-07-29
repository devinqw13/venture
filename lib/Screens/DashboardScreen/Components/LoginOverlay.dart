import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

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
                                  color: Get.isDarkMode ? ColorConstants.gray900 : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Center(
                                  child: Icon(obsecure ? IconlyLight.show : IconlyLight.hide, color: Colors.grey,),
                                ),
                              )
                            )
                          )
                        ),
                      ),
                    )
                    // TextField(
                    //   decoration: InputDecoration(
                    //     contentPadding: const EdgeInsets.all(16.0),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                    //     ),
                    //     hintText: "Username",
                    //     hintStyle: TextStyle(
                    //       color: Color(0xFF2D3243).withOpacity(0.5),
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //     prefixIcon: Icon(
                    //       IconlyBroken.profile,
                    //       color: Color(0xFF2D3243).withOpacity(0.5),
                    //     ),
                    //   ),
                    //   obscureText: false,
                    // )
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