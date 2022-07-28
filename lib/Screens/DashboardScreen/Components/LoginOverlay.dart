import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:get/get.dart';

class LoginOverlay extends StatefulWidget {
  LoginOverlay({Key? key}) : super(key: key);

  @override
  _LoginOverlay createState() => _LoginOverlay();
}

class _LoginOverlay extends State<LoginOverlay>  {
  
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(
            alignment: Alignment.center,
            color: Get.isDarkMode ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? ColorConstants.gray900 : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Get.isDarkMode ? ui.Color.fromARGB(255, 54, 54, 54).withOpacity(0.8) : Colors.grey.withOpacity(0.8),
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
                    TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                        ),
                        hintText: "Username",
                        hintStyle: TextStyle(
                          color: Color(0xFF2D3243).withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          IconlyBroken.profile,
                          color: Color(0xFF2D3243).withOpacity(0.5),
                        ),
                      ),
                      obscureText: false,
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