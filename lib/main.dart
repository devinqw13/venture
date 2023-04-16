import 'dart:async';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Theme.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Routes.dart';
import 'package:venture/Globals.dart' as globals;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp();
  await GetStorage.init();

  runZonedGuarded(() {
    runApp(
      const MyApp()
    );
  }, (Object error, StackTrace stackTrace) async {

  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool>? future;
  final storage = GetStorage();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  final ThemesController themeController = Get.put(ThemesController());

  @override
  void initState() {
    super.initState();

    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    globals.auth = FirebaseAuth.instance;
    // await checkAppleSignIn();
    await getKeys();
    await checkUserLoginStatus();
    await saveUniqueIDToSecureStorage();
    // var box = storage.read('user');
    // User().fromJson(box);
    // var userKey = storage.read('user_key');
    // VenUser().userKey.value = userKey ?? 0;

    setState(() {
      future = Future.value(true);
    });
    FlutterNativeSplash.remove();
  }

  saveUniqueIDToSecureStorage() async {
    // Normally, UIDs can change if app is uninstalled and reinstalled. Store initial UID to secure storage and retrieve when app is loaded
    // in order to save between installations. 
    // Used for push notifications and solves the problem of recieving duplicate push notifications on the same device.
    final storage = FlutterSecureStorage();
    await storage.read(key: 'AppUID').then((uniqueID) async {
      if (uniqueID == null) {
        List<String> deviceDetails = await getDeviceDetails();
        await storage.write(key: 'AppUID', value: deviceDetails[2]);
      }
    });
  }

  Future<void> getKeys() async {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    // await remoteConfig.fetch(expiration: Duration(hours: 12));
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(seconds: 10),
    ));
    await remoteConfig.fetchAndActivate();

     globals.apiBaseUrl = remoteConfig.getString('api_base_url');
     globals.googleMapsApi = remoteConfig.getString('google_maps_api');
     globals.googleApi = remoteConfig.getString('google_api_key');
     return;
  }

  // Future<void> checkAppleSignIn() async {
  //   globals.appleSignInAvailable = Platform.isIOS;
  // }

  Future<void> checkUserLoginStatus() async {
    globals.auth!.idTokenChanges().listen((User? user) async {
      var userKey = storage.read('user_key');
      var userEmail = storage.read('user_email');
      if (user != null && userKey != null && userEmail != null) {
        VenUser().userKey.value = userKey;
        VenUser().email = userEmail;
        try {
          await FirebaseAuth.instance.currentUser!.reload();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-disabled') {
            print("USER DISABLED");
            setState(() =>  globals.userDisabled = true);
            showCustomDialog(
              context: context,
              title: 'Account restricted', 
              description: "Your account has been restricted from any activity. We restricted your account to prevent any action and to protect others. Contact customer service for assistance.",
              descAlignment: TextAlign.center,
              buttons: {
                "OK": {
                  "action": () => Navigator.of(context).pop(),
                  "textColor": Get.isDarkMode ? Colors.white : Colors.black,
                  "alignment": TextAlign.center
                },
              }
            );
          }
        }
      } else {
        VenUser().clear();
      }
    });
  }

  String getInitialRoute() {
    // Implemented force login screen if not signed in.
    // remove if statement to disable force login.
    // note: remove pushAndRemoveUntil in logout func if disabling force login.
    var userKey = storage.read('user_key');
    var userEmail = storage.read('user_email');
    if(FirebaseAuth.instance.currentUser != null && userKey != null && userEmail != null) {
      return '/home';
    } else {
      return '/login';
    }
    // return '/home';
  }

  ThemeMode getThemeMode(String type) {
    ThemeMode themeMode = ThemeMode.system;
    switch (type) {
      case "system":
        themeMode = ThemeMode.system;
        break;
      case "dark":
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.light;
        break;
    }

    return themeMode;
  }

  @override
  Widget build(BuildContext context) {
    // return GetMaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: "Venture",
    //   theme: Themes.lightTheme,
    //   darkTheme: Themes.darkTheme,
    //   themeMode: getThemeMode(themeController.theme),
    //   navigatorKey: navigatorKey,
    //   // initialRoute: '/',
    //   navigatorObservers: [routeObserver],
    //   getPages: Routes.routes,
    //   initialRoute: getInitialRoute(),
    //   // routes: <String, WidgetBuilder>{
    //   //   '/': (context) => getFirstScreen()
    //   // },
    // );
    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Venture",
            theme: Themes.lightTheme,
            darkTheme: Themes.darkTheme,
            themeMode: getThemeMode(themeController.theme),
            navigatorKey: navigatorKey,
            // initialRoute: '/',
            navigatorObservers: [routeObserver],
            getPages: Routes.routes,
            initialRoute: getInitialRoute(),
            // routes: <String, WidgetBuilder>{
            //   '/': (context) => getFirstScreen()
            // },
          );
        }
        else {
          return Container(
            // color: primaryBlue,
            child: Center(
              child: Container()
              // child: Image.asset('assets/images/ATS_HW_Vertical_FullColor_02.png',
              //   alignment: Alignment.center,
              //   fit: BoxFit.fill,
              // ),
            ),
          );
        }
      }
    );
  }
}

