import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationHandler {

  static Future<List<Location>> coordsFromAddress(BuildContext context, String address) async {
    List<Location> locations = await locationFromAddress(address);

    return locations;
  }

  static Future<List<Placemark>> addressFromCoords(BuildContext context, double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    return placemarks;
  }

  static Future<bool> requestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    return true;
  }

  static Future<Position?> determineDeviceLocation() async {
    bool results = await requestPermissions();
    if(!results) return null;

    Position? position;

    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    return position;
  }

  static Future<Position?> determineLastKnownDeviceLocation() async {
    bool results = await requestPermissions();
    if(!results) return null;
    
    Position? position;

    position = await Geolocator.getLastKnownPosition();

    return position;
  }

  static Future<num?> getDistanceFromCoords(String latlng) async {
    bool results = await requestPermissions();
    if(!results) return null;

    Position? position = await determineDeviceLocation();
    List locList = latlng.split(',');

    double distanceInMeters = Geolocator.distanceBetween(position!.latitude, position.longitude, double.parse(locList[0]), double.parse(locList[1]));

    double miles = double.parse((distanceInMeters * 0.000621371).toStringAsFixed(1));

    return miles % 1 == 0 ? miles.toInt() : miles;
  }
}