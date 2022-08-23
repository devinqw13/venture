import 'package:venture/Controllers/Dashboard/DashboardBinding.dart';
import 'package:venture/Screens/DashboardScreen/DashboardScreen.dart';
import 'package:get/route_manager.dart';
import 'package:venture/Screens/UploadContentScreen/UploadContentScreen.dart';

class Routes {
  static const INITIAL = '/home';

  static final routes = [
    GetPage(
      name: '/home',
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
      arguments: <dynamic, dynamic>{}
    ),
  ];
}