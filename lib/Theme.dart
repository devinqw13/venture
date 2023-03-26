import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venture/Constants.dart';

class Themes {
  static ThemeData lightTheme = ThemeData(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    fontFamily: 'SegoeUI',
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backwardsCompatibility: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.grey.shade50,
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 0
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ColorConstants.gray400,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10)
      ),
      hintStyle: TextStyle(
        fontSize: 14,
      )
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        letterSpacing: -1.5,
        fontSize: 48,
        color: Colors.black,
        fontWeight: FontWeight.bold
      ),
      headline2: TextStyle(
        letterSpacing: -1.0,
        fontSize: 40,
        color: Colors.black,
        fontWeight: FontWeight.bold
      ),
      headline3: TextStyle(
        letterSpacing: -1.0,
        fontSize: 32,
        color: Colors.black,
        fontWeight: FontWeight.bold
      ),
      headline4: TextStyle(
        letterSpacing: -1.0,
        color: Colors.black,
        fontSize: 28,
        fontWeight: FontWeight.w600
      ),
      headline5: TextStyle(
        letterSpacing: -1.0,
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.w500
      ),
      headline6: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w500
      ),
      subtitle1: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500
      ),
      subtitle2: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500
      ),
      bodyText1: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 16,
        fontWeight: FontWeight.w400
      ),
      bodyText2: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 14,
        fontWeight: FontWeight.w400
      ),
      button: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600
      ),
      caption: TextStyle(
        color: Colors.grey.shade800,
        fontSize: 12,
        fontWeight: FontWeight.w400
      ),
      overline: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5
      )
    ).apply(
      bodyColor: Colors.black,
      displayColor: Colors.black
    )
  );

  static ThemeData darkTheme = ThemeData(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    fontFamily: 'SegoeUI',
    primaryColor: Colors.blue,
    brightness: Brightness.dark,
    // scaffoldBackgroundColor: ColorConstants.gray900,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backwardsCompatibility: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      // backgroundColor: ColorConstants.gray900,
      backgroundColor: Colors.black,
      elevation: 0
    ),
    // bottomAppBarColor: ColorConstants.gray800,
    bottomAppBarColor: Colors.black,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ColorConstants.gray100,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: ColorConstants.gray600,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10)
      ),
      hintStyle: TextStyle(
        fontSize: 14,
      )
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        letterSpacing: -1.5,
        fontSize: 48,
        color: Colors.grey.shade50,
        fontWeight: FontWeight.bold
      ),
      headline2: TextStyle(
        letterSpacing: -1.0,
        fontSize: 40,
        color: Colors.grey.shade50,
        fontWeight: FontWeight.bold
      ),
      headline3: TextStyle(
        letterSpacing: -1.0,
        fontSize: 32,
        color: Colors.grey.shade50,
        fontWeight: FontWeight.bold
      ),
      headline4: TextStyle(
        letterSpacing: -1.0,
        color: Colors.grey.shade50,
        fontSize: 28,
        fontWeight: FontWeight.w600
      ),
      headline5: TextStyle(
        letterSpacing: -1.0,
        color: Colors.grey.shade50,
        fontSize: 24,
        fontWeight: FontWeight.w500
      ),
      headline6: TextStyle(
        color: Colors.grey.shade50,
        fontSize: 18,
        fontWeight: FontWeight.w500
      ),
      subtitle1: TextStyle(
        color: Colors.grey.shade50,
        fontSize: 16,
        fontWeight: FontWeight.w500
      ),
      subtitle2: TextStyle(
        color: Colors.grey.shade50,
        fontSize: 14,
        fontWeight: FontWeight.w500
      ),
      bodyText1: TextStyle(
        color: Colors.grey.shade50,
        fontSize: 16,
        fontWeight: FontWeight.w400
      ),
      bodyText2: TextStyle(
        color: Colors.grey.shade50,
        fontSize: 14,
        fontWeight: FontWeight.w400
      ),
      button: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600
      ),
      caption: TextStyle(
        color: Colors.grey.shade50,
        fontSize: 12,
        fontWeight: FontWeight.w500
      ),
      overline: TextStyle(
        color: Colors.grey.shade50,
        fontSize: 10,
        fontWeight: FontWeight.w400
      )
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white
    ),
  );
}