import 'package:venture/Controllers/Dashboard/DashboardBinding.dart';
import 'package:venture/Screens/DashboardScreen/DashboardScreen.dart';
import 'package:get/route_manager.dart';
import 'package:venture/Screens/LoginScreen/LoginScreen.dart';

class Routes {
  static const INITIAL = '/home';

  static final routes = [
    GetPage(
      name: '/home',
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
      arguments: <dynamic, dynamic>{}
    ),
    GetPage(
      name: '/login',
      page: () => LoginScreen(),
      binding: DashboardBinding(),
      arguments: <dynamic, dynamic>{}
    ),
  ];
}