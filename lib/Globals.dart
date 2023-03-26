import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth? auth;
bool userDisabled = false;
bool appleSignInAvailable = false;
String apiBaseUrl = '';
String googleMapsApi = '';
String googleMapPreviewPin = '';
String googleApi = '';