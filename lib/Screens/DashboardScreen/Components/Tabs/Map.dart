import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Globals.dart' as globals;
import 'package:venture/Calls.dart';
import 'package:venture/Controllers/MapController.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/CustomPin.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/PinCategorySelector.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Helpers/LocationHandler.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Models/PinCategory.dart';
import 'package:venture/Models/Place.dart';
import 'package:venture/Screens/CreatePinScreen/CreatePinScreen.dart';
import 'package:venture/Screens/PinScreen/PinScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Models/Pin.dart';

class MapTab extends StatefulWidget {
  MapTab({Key? key}) : super(key: key);

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin<MapTab>, TickerProviderStateMixin {
  final TextEditingController textController = TextEditingController();
  final ThemesController _themesController = Get.find();
  final MapController _mapController = Get.put(MapController(), tag: "home_map_controller");
  // final MapController = Get.put(MapController());
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // MarkerId? createdMarker;
  // LatLng? createdMarkerPos;
  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<MarkerId, Marker> nonClusteringMarkers = <MarkerId, Marker>{}.obs;
  Rxn<MarkerId> createdMarker = Rxn<MarkerId>();
  Rxn<LatLng?> createdMarkerPos = Rxn<LatLng>();
  Timer? mapFetchTimer;
  bool isLoading = false;
  bool isCreatingPin = false;
  PinCategory? pinCategory;
  late ClusterManager _manager;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _manager = _initClusterManager();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(
      Iterable<Place>.empty(),
      _updateMarkers,
      markerBuilder: _markerBuilder,
      extraPercent: 0.2,
      levels: [1, 4.25, 6.75, 8.25, 11.5],
      stopClusteringZoom: 14.0 // Does not cluster higher than this zoom
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    var result = { for (var v in markers) v.markerId: v};
    setState(() {
      this.markers.value = result;
    });
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
    (cluster) async {
      String? iconPath = getIconPath(cluster.items.first.pinCategory);
      String? text = getMarkerText(cluster);

      BitmapDescriptor mkr = await getMarkerIconV2(
        context,
        iconPath,
        cluster: cluster.count,
        clusterTextColor: primaryOrange,
        pinColor: ColorConstants.gray25,
        text: text,
        textStyle: TextStyle(
          fontSize: 30,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        )
      );

      return Marker(
        markerId: cluster.isMultiple ? MarkerId(cluster.getId()) : cluster.items.first.markerId,
        position: cluster.location,
        draggable: cluster.isMultiple ? false : cluster.items.first.draggable,
        onTap: () async {
          if(!isCreatingPin) {
            if(!cluster.isMultiple) {
              _onMarkerTapped(cluster.items.first.markerId);
            }else {
              // create points for the bounds
              double north = cluster.location.latitude;
              double south = cluster.location.latitude;
              double east = cluster.location.longitude;
              double west = cluster.location.longitude;
            
              // extend the bound points with the markers in the cluster
              for (var clusterMarker in cluster.items) {
                south = min(south, clusterMarker.location.latitude);
                north = max(north, clusterMarker.location.latitude);
                west = min(west, clusterMarker.location.longitude);
                east = max(east, clusterMarker.location.longitude);
              }
              
              // create the CameraUpdate with LatLngBounds
              CameraUpdate clusterView = CameraUpdate.newLatLngBounds(
                  LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)),
                  100 // this is the padding to add on top of the bounds
              );
              
              // set the new view
              _themesController.googleMapController!.animateCamera(clusterView);
            }
          }
        },
        icon: mkr,
      );
    };

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  performAction(MapOverlayAction action, dynamic value) {
    switch(action) {
      case MapOverlayAction.initializeCreatePin:
        setState(() => isCreatingPin = true);
        if(createdMarkerPos.value != null) {
          // generateInitMarker(createdMarkerPos.value!);
          generateInitMarkerV2(createdMarkerPos.value!);
        }
        break;
      case MapOverlayAction.cancelCreatePin:
        setState(() => isCreatingPin = false);
        if(createdMarker.value != null) _remove(createdMarker.value!, nonCluster: true);
        _mapController.isPlaced.value = false;
        break;
      case MapOverlayAction.positionPin:
        // generateInitMarker(value);
        generateInitMarkerV2(value);
        break;
      case MapOverlayAction.continueCreation: 
        handleContinueCreation();
        break;
      case MapOverlayAction.updatePinCategory:
        setState(() => pinCategory = value);
    }
  }

  handleContinueCreation() async {
    if(createdMarker.value == null || createdMarkerPos.value == null) {
      showToast(context: context, type: ToastType.INFO, msg: 'Place a marker to continue');
      return;
    }

    final CreatePinScreen screen = CreatePinScreen(location: createdMarkerPos.value!, pinCategory: pinCategory);
    var result = await Navigator.of(context).push(SlideUpDownPageRoute(page: screen, closeDuration: 400));

    setState(() => isCreatingPin = false);
    _remove(createdMarker.value!, nonCluster: true);
    _mapController.isPlaced.value = false;

    if(result != null) {
      Pin newPin = result;
      final MarkerId markerKey = MarkerId(newPin.pinKey.toString());
      var item = Place(
        markerId: markerKey,
        name: newPin.title!,
        latLng: LatLng(double.parse(newPin.latLng.split(',')[0]), double.parse(newPin.latLng.split(',')[1])),
        pinCategory: newPin.category
      );

      _manager.addItem(item);
      // final MarkerId markerKey = MarkerId(result.pinKey.toString());
      // List loc = result.latLng.split(',');

      // String? iconPath = getIconPath(result.category);
      
      // BitmapDescriptor mkr = await getMarkerIconV2(
      //   context,
      //   iconPath,
      //   pinColor: ColorConstants.gray25,
      //   text: result.title,
      //   textStyle: TextStyle(
      //     fontSize: 30,
      //     color: Colors.black,
      //     fontWeight: FontWeight.bold,
      //   )
      // );

      // final Marker marker = Marker(
      //   markerId: markerKey,
      //   position: LatLng(double.parse(loc[0]), double.parse(loc[1])),
      //   draggable: false,
      //   icon: mkr,
      //   onTap: () => _onMarkerTapped(markerKey),
      // );

      // markers[markerKey] = marker;
    }
  }

  Future<LatLng> mapNavigate(String location) async {
    final loc = await LocationHandler.coordsFromAddress(context, location);

    final _kLoc = CameraPosition(
      target: LatLng(loc.first.latitude, loc.first.longitude),
      zoom: 15,
    );

    _themesController.googleMapController!.animateCamera(CameraUpdate.newCameraPosition(_kLoc));

    return LatLng(loc.first.latitude, loc.first.longitude);
  }

  generateInitMarkerV2(LatLng coords) async {
    if(createdMarker.value != null) _remove(createdMarker.value!, nonCluster: true);

    final String key = '0';
    final MarkerId markerKey = MarkerId(key);
    
    BitmapDescriptor mkr;
    if(isCreatingPin) {
      mkr = await getMarkerIconV2(context, 'assets/icons/bold-plus.svg', imageColor: Colors.white, pinColor: primaryOrange);
    }else {
      mkr = await bitmapDescriptorFromSvgAsset(context, 'assets/icons/map-pin.svg');
    }

    final Marker marker = Marker(
      zIndex: 99,
      markerId: markerKey,
      position: coords,
      draggable: isCreatingPin ? true : false,
      icon: mkr,
      // onTap: () => _onMarkerTapped(markerKey),
      // onDragEnd: (LatLng position) => _onMarkerDragEnd(markerKey, position),
      onDrag: (LatLng position) => _onMarkerDrag(markerKey, position),
    );

    nonClusteringMarkers[markerKey] = marker;
    createdMarker.value = markerKey;
    createdMarkerPos.value = coords;
    _mapController.isPlaced.value = true;
  }

  // generateInitMarker(LatLng coords) async {
  //   if(createdMarker.value != null) _remove(createdMarker.value!);

  //   final String key = '0';
  //   final MarkerId markerKey = MarkerId(key);
    
  //   BitmapDescriptor mkr;
  //   if(isCreatingPin) {
  //     mkr = await getMarkerIconV2(context, 'assets/icons/bold-plus.svg', imageColor: Colors.white, pinColor: primaryOrange);
  //   }else {
  //     mkr = await bitmapDescriptorFromSvgAsset(context, 'assets/icons/map-pin.svg');
  //   }

  //   final Marker marker = Marker(
  //     markerId: markerKey,
  //     position: coords,
  //     draggable: isCreatingPin ? true : false,
  //     icon: mkr,
  //     // onTap: () => _onMarkerTapped(markerKey),
  //     // onDragEnd: (LatLng position) => _onMarkerDragEnd(markerKey, position),
  //     onDrag: (LatLng position) => _onMarkerDrag(markerKey, position),
  //   );

  //   markers[markerKey] = marker;
  //   createdMarker.value = markerKey;
  //   createdMarkerPos.value = coords;
  //   _mapController.isPlaced.value = true;
  // }

  String? getIconPath(String? pinCategory) {
    String? path;

    if(pinCategory == null) {
      path = 'assets/icons/venture-colored.svg';
    }else {
      var c = globals.defaultPinCategories.firstWhereOrNull((e) => e.name == pinCategory);

      if(c != null) {
        path = c.iconPath;
      }else {
        path = 'assets/icons/venture-colored.svg';
      }
    }

    return path;
  }

  String? getMarkerText(Cluster<Place> cluster) {
    String? string;

    if(cluster.isMultiple) {
      string = "${cluster.items.first.name} \n+${(cluster.count - 1)} more";
    }else {
      string = cluster.items.first.name;
    }

    return string;
  }

  displayGatheredPinsV2(List<Pin> gatheredPins) async {
    // // List<Pin> newPins = gatheredPins.where((e) => !markers.keys.map((f) => int.parse(f.value)).toList().contains(e.pinKey)).toList();

    // // markers.removeWhere((k, v) => !pins.map((e) => e.pinKey).toList().contains(int.parse(k.value)) && k.value != '0');
    // var firstList = [2, 2, 2, 3];
    // var secondList = [1, 2, 3];
    // // print(firstList.toSet().intersection(secondList.toSet()));
    // print(secondList.any((item) => item == 2));


    List<Place> p = gatheredPins.map((e) {
      final MarkerId markerKey = MarkerId(e.pinKey.toString());
      var item = Place(
        markerId: markerKey,
        name: e.title!,
        latLng: LatLng(double.parse(e.latLng.split(',')[0]), double.parse(e.latLng.split(',')[1])),
        pinCategory: e.category
      );
      return item;
    }).toList();

    _manager.setItems(p);
  }

  // displayGatheredPins(List<Pin> pins) async {
  //   List<Pin> newPins = pins.where((e) => !markers.keys.map((f) => int.parse(f.value)).toList().contains(e.pinKey)).toList();

  //   setState(() {
  //     markers.removeWhere((k, v) => !pins.map((e) => e.pinKey).toList().contains(int.parse(k.value)) && k.value != '0');
  //   });

  //   for(Pin item in newPins) {
  //     final MarkerId markerKey = MarkerId(item.pinKey.toString());
  //     List loc = item.latLng.split(',');

  //     String? iconPath = getIconPath(item);

  //     BitmapDescriptor mkr = await getMarkerIconV2(
  //       context,
  //       iconPath,
  //       pinColor: ColorConstants.gray25,
  //       text: item.title,
  //       textStyle: TextStyle(
  //         fontSize: 30,
  //         color: Colors.black,
  //         fontWeight: FontWeight.bold,
  //       )
  //     );

  //     final Marker marker = Marker(
  //       markerId: markerKey,
  //       position: LatLng(double.parse(loc[0]), double.parse(loc[1])),
  //       draggable: false,
  //       icon: mkr,
  //       onTap: () => _onMarkerTapped(markerKey),
  //     );

  //     setState(() {
  //       markers[markerKey] = marker;
  //     });
  //   }

  //   print("MARKERS DISPLAYED: ${markers.length}");
  // }

  void _onMarkerTapped(MarkerId key) {
    final Marker? tappedMarker = markers[key];
    if (tappedMarker != null) {
      PinScreen screen = PinScreen(pinKey: int.parse(tappedMarker.markerId.value));
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
    }
  }

  Future<void> _onMarkerDrag(MarkerId key, LatLng newPosition) async {
    createdMarkerPos.value = newPosition;
  }

  void _remove(MarkerId key, {bool nonCluster = false}) {
    if(nonCluster) {
      if (nonClusteringMarkers.containsKey(key)) {
        nonClusteringMarkers.remove(key);

        if(key.value == '0') {
          createdMarker.value = null;
          createdMarkerPos.value = null;
          pinCategory = null;
        }
      }
    }else {
      if (markers.containsKey(key)) {
        markers.remove(key);
      }
    }
  }

  // _showMapThemeModal(ThemeData theme) {
  //   Get.bottomSheet(
  //     Container(
  //       padding: EdgeInsets.all(16),
  //       height: MediaQuery.of(context).size.height * 0.23,
  //       decoration: BoxDecoration(
  //         color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(16),
  //           topRight: Radius.circular(16),
  //         )
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Select a Theme", style: theme.textTheme.subtitle1,),
  //           SizedBox(height: 20),
  //           Container(
  //             width: double.infinity,
  //             height: 100,
  //             child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: MapThemes().themes.length,
  //               itemBuilder: (context, index) {
  //                 return GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       _themesController.googleMapController?.setMapStyle(MapThemes().themes[index]['style']);
  //                     });
  //                     Get.back();
  //                   },
  //                   child: Container(
  //                     width: 100,
  //                     margin: EdgeInsets.only(right: 10),
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(10),
  //                       image: DecorationImage(
  //                         fit: BoxFit.cover,
  //                         image: NetworkImage(MapThemes().themes[index]['image']),
  //                       )
  //                     ),
  //                   ),
  //                 );
  //               }
  //             ),
  //           )
  //         ],
  //       ),
  //     )
  //   );
  // }

  autocomplete(String v) async {
    // var list = await getPlaces(v);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DismissKeyboard(
      child: Stack(
        children: [
          Obx(() => GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: _themesController.mapType.value,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            // markers: Set<Marker>.of(markers.values),
            markers: {
              ...Set<Marker>.of(nonClusteringMarkers.values),
              ...Set<Marker>.of(markers.values)
            },
            onMapCreated: (GoogleMapController controller) async {
              _manager.setMapId(controller.mapId); // Used for clustering
              setState(() {
                _themesController.googleMapController = controller;
              });
              _themesController.setMapStyle();
              
              var results = await LocationHandler.determineDeviceLocation();
              if(results != null) {
                final _kLoc = CameraPosition(
                  target: LatLng(results.latitude, results.longitude),
                  zoom: 15,
                );

                _themesController.googleMapController!.animateCamera(CameraUpdate.newCameraPosition(_kLoc));
              }
            },
            onCameraMove: (position) {
              KeyboardUtil.hideKeyboard(context);
              _manager.onCameraMove(position, forceUpdate: true); // Used for clustering
              if(mapFetchTimer != null) mapFetchTimer!.cancel();
            },
            onCameraIdle: () async {
              LatLngBounds visibleRegion = await _themesController.googleMapController!.getVisibleRegion();

              LatLng centerLatLng = LatLng(
                (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
                (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
              );

              String latlng = "${centerLatLng.latitude},${centerLatLng.longitude}";

              mapFetchTimer = Timer(Duration(seconds: 1), () async {
                var screenCoord = await _themesController.googleMapController!.getScreenCoordinate(centerLatLng);

                double zoom = await _themesController.googleMapController!.getZoomLevel();

                var radiusInMiles = LocationHandler().calculateZoomRadius(zoom, centerLatLng.latitude, screenCoord.y);

                setState(() => isLoading = true);
                var results = await getMapPins(context, latlng: latlng, radius: double.parse(radiusInMiles.toString()));
                setState(() => isLoading = false);

                // displayGatheredPins(results);
                displayGatheredPinsV2(results);
              });

            },
            onTap: (latlng) {
              KeyboardUtil.hideKeyboard(context);
              if(isCreatingPin) {
                // generateInitMarker(latlng);
                generateInitMarkerV2(latlng);
              }
            },
            onLongPress: (latlng) {
              KeyboardUtil.hideKeyboard(context);
            },
          )),
          _themesController.googleMapController != null ?
          MapOverlay(
            controller: _themesController.googleMapController!,
            onAction: (action, value) => performAction(action, value),
          ) : Container(),
          isLoading ? Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: primaryOrange
              )
            ),
          ) : Container()
        ],
      )
    );
  }
}

enum MapOverlayAction {
  initializeCreatePin,
  cancelCreatePin,
  positionPin,
  continueCreation,
  updatePinCategory
}

class MapOverlay extends StatefulWidget {
  final GoogleMapController controller;
  final bool allowCreatePin;
  final Function(MapOverlayAction action, dynamic value)? onAction;
  MapOverlay({Key? key, required this.controller, this.onAction, this.allowCreatePin = false}) : super(key: key);

  @override
  _MapOverlay createState() => _MapOverlay();
}

class _MapOverlay extends State<MapOverlay> with AutomaticKeepAliveClientMixin<MapOverlay>, TickerProviderStateMixin {
  final ThemesController _themesController = Get.find();
  final MapController _mapController = Get.find(tag: "home_map_controller");
  final TextEditingController textController = TextEditingController();
  bool isCreating = false;
  late AnimationController controller, controller2;
  late Animation<Offset> offset, offset2;
  PinCategory? category;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    offset = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.0))
        .animate(controller);

    offset2 = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
        .animate(controller);
  }

  Future<LatLng> goToLocation() async {
    var results = await LocationHandler.determineDeviceLocation();

    if(results != null) {
      final _kLoc = CameraPosition(
        target: LatLng(results.latitude, results.longitude),
        zoom: 15,
      );

      widget.controller.animateCamera(CameraUpdate.newCameraPosition(_kLoc));
    }

    return LatLng(results!.latitude, results.longitude);
  }

  toggleMapType() {
    final storage = GetStorage();
    if(_themesController.mapType.value == MapType.satellite) {
      _themesController.mapType.value = MapType.normal;
    }else {
      _themesController.mapType.value = MapType.satellite;
    }

    storage.write('maptype', _themesController.mapType.value == MapType.satellite ? "satellite" : "normal");
  }

  Future<LatLng> mapNavigate(String location) async {
    final loc = await LocationHandler.coordsFromAddress(context, location);

    final _kLoc = CameraPosition(
      target: LatLng(loc.first.latitude, loc.first.longitude),
      zoom: 15,
    );

    widget.controller.animateCamera(CameraUpdate.newCameraPosition(_kLoc));

    return LatLng(loc.first.latitude, loc.first.longitude);
  }

  startCreatePin() async {
    await showCustomDialog(
      context: context,
      title: 'Create a pin', 
      description: "You are creating a pin.\n\nSet the location of the pin on the map to continue.",
      descAlignment: TextAlign.center,
      buttons: {
        "OK": {
          "action": () => Navigator.of(context).pop(),
          "textColor": Get.isDarkMode ? Colors.white : Colors.black,
          "alignment": TextAlign.center
        },
      }
    );

    controller.forward();
    widget.onAction!(MapOverlayAction.initializeCreatePin, null);
    setState(() => isCreating = true);
  }

  openCategorySelector() async {
    var response = await showPinCategorySelectorSheet(context: context, initCategory: category);
    // print(response);
    widget.onAction!(MapOverlayAction.updatePinCategory, response);
    setState(() => category = response);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: MediaQuery.of(context).padding.bottom,
        left: 16.0,
        right: 16.0
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? ColorConstants.gray600 : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(0,3),
                            blurRadius: 2
                            ),
                          ]
                        ),
                        child: TextField(
                          // onChanged: (v) => autocomplete(v),
                          autocorrect: false,
                          enableSuggestions: false,
                          controller: textController,
                          keyboardType: TextInputType.streetAddress,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (text) async {
                            KeyboardUtil.hideKeyboard(context);
                            if (textController.text.isNotEmpty) {
                              // if(isCreating) {
                              //   var result = await mapNavigate(textController.text);
                              //   widget.onAction!(MapOverlayAction.positionPin, result);
                              // }else {
                              //   mapNavigate(textController.text);
                              // }
                              var result = await mapNavigate(textController.text);
                              widget.onAction!(MapOverlayAction.positionPin, result);
                              textController.clear();
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            hintText: "Enter location address",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: ZoomTapAnimation(
                                onTap: () async {
                                  KeyboardUtil.hideKeyboard(context);
                                  if (textController.text.isNotEmpty) {
                                    // if(isCreating) {
                                    //   var result = await mapNavigate(textController.text);
                                    //   widget.onAction!(MapOverlayAction.positionPin, result);
                                    // }else {
                                    //   mapNavigate(textController.text);
                                    // }
                                    var result = await mapNavigate(textController.text);
                                    widget.onAction!(MapOverlayAction.positionPin, result);
                                    textController.clear();
                                  }
                                },
                                child: Container(
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Get.isDarkMode ? ColorConstants.gray800 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Center(
                                    child: Icon(IconlyLight.arrow_right, color: Colors.grey),
                                  ),
                                )
                              ),
                            )
                          ),
                        )
                      ),
                    ),
                  ]
                ),
                SizedBox(height: 15),
                Obx(() => AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: _mapController.isPlaced.value ? Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: ElevatedButton(
                      onPressed: () => openCategorySelector(),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if(category != null)
                              WidgetSpan(
                                child: CustomIcon(
                                  icon: category!.iconPath,
                                  color: Get.isDarkMode ? Colors.white : Colors.black,
                                  size: 16
                                )
                              ),
                            TextSpan(
                              text: category != null ? "  ${category!.name}" : "Select a category"
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Get.isDarkMode ? Colors.white : Colors.black,
                                size: 16,
                              )
                            )
                          ]
                        ),
                        style: TextStyle(
                          color: Get.isDarkMode ? Colors.white : Colors.black
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        minimumSize: Size.zero,
                        padding: EdgeInsets.all(10),
                        backgroundColor: Get.isDarkMode ? ColorConstants.gray800 : Colors.white,
                        foregroundColor: Colors.transparent
                      ),
                    )
                  ) : Container()
                )),
                ElevatedButton(
                  onPressed: () async {
                    if(isCreating) {
                      var result = await goToLocation();
                      widget.onAction!(MapOverlayAction.positionPin, result);
                    }else {
                      goToLocation();
                    }
                  },
                  // child: Icon(Icons.navigation_rounded, color: Get.isDarkMode ? Colors.white : Colors.black),
                  child: CustomIcon(
                    icon: 'assets/icons/target.svg',
                    color: Get.isDarkMode ? Colors.white : Colors.black
                  ),
                  style: ElevatedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: CircleBorder(),
                    minimumSize: Size.zero,
                    padding: EdgeInsets.all(10),
                    backgroundColor: Get.isDarkMode ? ColorConstants.gray800 : Colors.white,
                    foregroundColor: Colors.transparent
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => toggleMapType(),
                  child: Icon(Icons.map_rounded, color: Get.isDarkMode ? Colors.white : Colors.black),
                  style: ElevatedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: CircleBorder(),
                    minimumSize: Size.zero,
                    padding: EdgeInsets.all(10),
                    backgroundColor: Get.isDarkMode ? ColorConstants.gray800 : Colors.white,
                    foregroundColor: Colors.transparent
                  ),
                )
              ]
            )
          ),
          SlideTransition(
            position: offset2,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 35,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AnimatedSize(
                        duration: Duration(milliseconds: 200),
                        child: ElevatedButton(
                        onPressed: () {
                          controller.reverse();
                          widget.onAction!(MapOverlayAction.cancelCreatePin, null);
                          setState(() {
                            isCreating = false;
                            category = null;
                          });
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Get.isDarkMode ? Colors.white : Colors.black
                          )
                        ),
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size.zero,
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.6),
                          backgroundColor: Get.isDarkMode ? ColorConstants.gray800 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          )
                        ),
                      )
                      )
                    ),
                    Obx(() => AnimatedSize(
                      duration: Duration(milliseconds: 200),
                      child: _mapController.isPlaced.value ? Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            controller.reverse();
                            widget.onAction!(MapOverlayAction.continueCreation, null);
                            setState(() {
                              isCreating = false;
                              category = null;
                            });
                          },
                          child: Icon(Icons.arrow_forward_ios_rounded, color: Get.isDarkMode ? Colors.white : Colors.black),
                          style: ElevatedButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: CircleBorder(),
                            minimumSize: Size.zero,
                            padding: EdgeInsets.all(13),
                            backgroundColor: Get.isDarkMode ? ColorConstants.gray800 : Colors.white,
                            foregroundColor: Colors.transparent
                          ),
                        )
                      ) : SizedBox()
                    ))
                  ],
                )
              ),
            )
          ),
          SlideTransition(
            position: offset,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 35,
                ),
                child: FloatingActionButton(
                  backgroundColor: Get.isDarkMode ? ColorConstants.gray800 : Colors.white,
                  heroTag: 'createPin',
                  onPressed: () => startCreatePin(),
                  child: Icon(Icons.add, color: Get.isDarkMode ? Colors.white : Colors.black)
                )
              ),
            )
          ),
        ]
      )
    );
  }
}