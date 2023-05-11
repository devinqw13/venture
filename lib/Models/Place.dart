import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place with ClusterItem {
  final MarkerId markerId;
  final String name;
  final bool isClosed;
  final LatLng latLng;
  final String? pinCategory;
  final bool draggable;

  Place({required this.markerId, required this.name, required this.latLng, this.isClosed = false, this.pinCategory, this.draggable = false});

  @override
  String toString() {
    return 'Place $name (closed : $isClosed)';
  }

  @override
  LatLng get location => latLng;
}