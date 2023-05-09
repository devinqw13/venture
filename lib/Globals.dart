import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Models/PinCategory.dart';
import 'package:venture/Screens/LoginScreen/LoginScreen.dart';

FirebaseAuth? auth;
bool userDisabled = false;
bool appleSignInAvailable = false;
String apiBaseUrl = '';
String googleMapsApi = '';
String googleMapPreviewPin = '';
String googleApi = '';
List<PinCategory> defaultPinCategories = [];

logout(BuildContext context) async {
  final storage = GetStorage();
  // storage.erase();
  storage.remove("user_key");
  storage.remove("user_email");
  VenUser().userKey.value = 0;
  VenUser().onChange();

  await FirebaseAPI().removeFirebaseTokens();
  await FirebaseAPI().logout();
  
  // Navigator.pop(context);
  // Implemented force login. This will remove all screens and navigate to login screen
  // remove statements below if disabling force login.
  LoginScreen loginController = LoginScreen();
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => loginController), (Route<dynamic> route) => false);
}