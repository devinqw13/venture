import 'dart:async';
// import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Theme.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Routes.dart';
import 'package:venture/Globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  Future<void> getKeys() async {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    // await remoteConfig.fetch(expiration: Duration(hours: 12));
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 12),
    ));
    await remoteConfig.fetchAndActivate();

     globals.apiBaseUrl = remoteConfig.getString('api_base_url');
     globals.googleMapsApi = remoteConfig.getString('google_maps_api');

     return;
  }

  // Future<void> checkAppleSignIn() async {
  //   globals.appleSignInAvailable = Platform.isIOS;
  // }

  // Future<void> checkUserLoginStatus() async {
  //   globals.auth!.idTokenChanges().listen((User? user) async {
  //     if (user == null) {
  //       VenUser().clear();
  //     } else {
  //       print(user.uid);
  //       // VenUser().userKey.value = userKey ?? 0;
  //       // if (user.displayName != null) {
  //       //   VenUser().displayName = user.displayName!;
  //       // }
  //       // VenUser().email = user.email!;
  //       // if (!alreadyCalled) {
  //       //   alreadyCalled = true;
  //       //   await getUserInfo(user.email);
  //       //   createUserDevice(user.email!);
  //       // }
  //     }
  //   });
  // }

  _initializeAsyncDependencies() async {
    // globals.auth = FirebaseAuth.instance;
    // await checkAppleSignIn();
    // await checkUserLoginStatus();
    await getKeys();
    // var box = storage.read('user');
    // User().fromJson(box);
    var userKey = storage.read('user_key');
    print(userKey);
    VenUser().userKey.value = userKey ?? 0;

    setState(() {
      future = Future.value(true);
    });
  }

  String getInitialRoute() {
    return '/home';
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
            color: primaryBlue,
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

