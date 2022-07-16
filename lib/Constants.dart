import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

// const Color kPrimaryColor = const Color.fromARGB(255, 0, 32, 92);
// const kPrimaryColor = Color(0xFF018786);
// const kTextColor = Color(0xFF757575);
const kTextColor = Color(0xff121212);
const kLightGreyText = Color.fromARGB(255, 119, 119, 119);
const Color backgroundGrey = Color.fromARGB(255, 238, 238, 243);
const Color darkBackgroundGrey = Color(0xff121212);
const Color primaryOrange = Color.fromRGBO(255, 85, 0, 1);
const Color primaryBlue = Color.fromARGB(255, 0, 32, 92);
const Color accentBlue = Color.fromARGB(255, 0, 92, 160);
const Color primaryGrey = Color.fromARGB(255, 138, 139, 138);


final headingStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

final RegExp emailValidatorRegExp = RegExp(r"^[a-zA-Z0-9.+]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNameNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

Function unorderedEq = const DeepCollectionEquality.unordered().equals;

class ColorConstants {
  static Color gray50 = hexToColor('#e9e9e9');
  static Color gray100 = hexToColor('#bdbebe');
  static Color gray200 = hexToColor('#929293');
  static Color gray300 = hexToColor('#666667');
  static Color gray400 = hexToColor('#505151');
  static Color gray500 = hexToColor('#242526');
  static Color gray600 = hexToColor('#202122');
  static Color gray700 = hexToColor('#191a1b');
  static Color gray800 = hexToColor('#121313');
  static Color gray900 = hexToColor('#0e0f0f');
}

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex));

  return Color(int.parse(hex.substring(1), radix: 16) + (hex.length == 7 ? 0xFF000000 : 0x00000000));
}