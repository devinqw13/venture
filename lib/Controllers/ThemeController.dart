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
  MapType mapType = MapType.satellite;
  String theme = 'dark';
  String mapStyle = 'orange';
  String lightModeMapStyle = 'orange';
  String darkModeMapStyle = 'orange';

  @override
  void onInit() {
    super.onInit();

    getThemeState();
    getMapState();
  }

  getThemeState() {
    if (storage.read('theme') != null) {
      return setTheme(storage.read('theme'));
    }
    
    setTheme(theme);
  }

  getMapState() {
    if (storage.read('maptype') != null) {
      mapType = storage.read('maptype') == "normal" ? MapType.normal : MapType.satellite;
    }

    if (storage.read('mapstyle') != null) {
      return setMapStyle(storage.read('mapstyle'));
    }

    setMapStyle();
  }

  Color getContainerBgColor() {
    if (Get.isDarkMode) {
      // return ColorConstants.gray900;
      return Colors.black;
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

    update();
  }

  void setMapStyle([String? value]) {
    if(value != null) {
      mapStyle = value;

      googleMapController?.setMapStyle(MapThemes().themes.firstWhere((e) => e['name'] == value)['style']);

      return;
    }

    if (theme == 'light') googleMapController?.setMapStyle(MapThemes().themes.firstWhere((e) => e['name'] == lightModeMapStyle)['style']);

    if (theme == 'dark') googleMapController?.setMapStyle(MapThemes().themes.firstWhere((e) => e['name'] == darkModeMapStyle)['style']);

    update();
  }

  Future<LatLng> navigateMap(List<String> coords) async {
    final _kLoc = CameraPosition(
      target: LatLng(double.parse(coords[0]), double.parse(coords[1])),
      zoom: 15,
    );

    await googleMapController!.animateCamera(CameraUpdate.newCameraPosition(_kLoc));

    return LatLng(double.parse(coords[0]), double.parse(coords[1]));
  }
}