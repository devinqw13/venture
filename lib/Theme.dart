import 'package:flutter/material.dart';
import 'package:venture/Constants.dart';

// ThemeData theme() {
//   return ThemeData(
//     scaffoldBackgroundColor: Colors.white,
//     textTheme: textTheme(),
//     appBarTheme: appBarTheme(),
//     inputDecorationTheme: inputDecorationTheme(),
//     visualDensity: VisualDensity.adaptivePlatformDensity
//   );
// }

// InputDecorationTheme inputDecorationTheme() {
//   OutlineInputBorder outlineInputBorder = OutlineInputBorder(
//     borderRadius: BorderRadius.circular(28),
//     borderSide: BorderSide(color: kTextColor),
//     gapPadding: 10
//   );
//   return InputDecorationTheme(
//     errorStyle: TextStyle(height: 0),
//     floatingLabelBehavior: FloatingLabelBehavior.never,
//     contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
//     enabledBorder: outlineInputBorder,
//     focusedBorder: outlineInputBorder,
//     border: outlineInputBorder
//   );
// }

// TextTheme textTheme() {
//   return TextTheme(
//     bodyText1: TextStyle(color: kTextColor),
//     bodyText2: TextStyle(color: kTextColor)
//   );
// }

// AppBarTheme appBarTheme() {
//   return AppBarTheme(
//     color: Colors.white,
//     elevation: 0,
//     brightness: Brightness.light,
//     iconTheme: IconThemeData(color: Colors.black),
//     textTheme: TextTheme(
//       headline6: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
//     ),
//   );
// }

class Themes {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade50,
      elevation: 0
    ),
    inputDecorationTheme: InputDecorationTheme(
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
    )
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.blue,
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorConstants.gray900,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorConstants.gray900,
      elevation: 0
    ),
    bottomAppBarColor: ColorConstants.gray800,
    inputDecorationTheme: InputDecorationTheme(
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
    ),
  );
}