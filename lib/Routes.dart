import 'package:venture/Controllers/Dashboard/DashboardBinding.dart';
import 'package:venture/Screens/DashboardScreen/DashboardScreen.dart';
import 'package:get/route_manager.dart';

class Routes {
  static const INITIAL = '/home';

  static final routes = [
    // GetPage(
    //   name: '/login', 
    //   page: () => LoginPage(),
    // ),
    GetPage(
      name: '/home', 
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
    )
  ];
}