import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class LocationHandler {

  static Future<List<Location>> coordsFromAddress(BuildContext context, String address) async {
    List<Location> locations = await locationFromAddress(address);

    return locations;
  }
}