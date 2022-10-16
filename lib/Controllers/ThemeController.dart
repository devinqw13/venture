import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Models/MapThemes.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';

class ThemesController extends GetxController {
  final storage = GetStorage();
  GoogleMapController? googleMapController;

  String theme = 'light';
  String mapStyle = 'standard';

  @override
  void onInit() {
    super.onInit();

    getThemeState();
  }

  getThemeState() {
    if (storage.read('theme') != null) {
      return setTheme(storage.read('theme'));
    } 
    
    setTheme('light');
  }

  Color getContainerBgColor() {
    if (Get.isDarkMode) {
      return ColorConstants.gray900;
    } else {
      return Colors.grey.shade50;
    }
  }

  void setTheme(String value) {
    theme = value;
    storage.write('theme', value);

    if (value == 'system') Get.changeThemeMode(ThemeMode.system);
    if (value == 'light') Get.changeThemeMode(ThemeMode.light);
    if (value == 'dark') Get.changeThemeMode(ThemeMode.dark);

    if (value == 'light') googleMapController?.setMapStyle(MapThemes().themes[0]['style']);
    if (value == 'dark') googleMapController?.setMapStyle(MapThemes().themes[1]['style']);

    update();
  }

  void setMapStyle() {
    if (theme == 'light') googleMapController?.setMapStyle(MapThemes().themes[0]['style']);
    if (theme == 'dark') googleMapController?.setMapStyle(MapThemes().themes[1]['style']);

    update();
  }

  Future<LatLng> navigateMap(List<String> coords) async {
    final _kLoc = CameraPosition(
      target: LatLng(double.parse(coords[0]), double.parse(coords[1])),
      zoom: 15,
    );

    googleMapController!.animateCamera(CameraUpdate.newCameraPosition(_kLoc));

    return LatLng(double.parse(coords[0]), double.parse(coords[1]));
  }
}