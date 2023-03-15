import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Globals.dart' as globals;
import 'package:venture/Calls.dart';
import 'package:venture/Helpers/CustomPin.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Helpers/LocationHandler.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Screens/CreatePinScreen/CreatePinScreen.dart';
import 'package:venture/Screens/PinScreen/PinScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Components/CreatePin.dart';
import 'package:venture/Components/CustomMapPopupMenu.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/VenUser.dart';

class MapTab extends StatefulWidget {
  MapTab({Key? key}) : super(key: key);

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin<MapTab>, TickerProviderStateMixin {
  final TextEditingController textController = TextEditingController();
  final ThemesController _themesController = Get.find();
  ValueNotifier<bool> displayCreatePin = ValueNotifier<bool>(false);
  ValueNotifier<bool> canRemovePin = ValueNotifier<bool>(false);
  late AnimationController controller;
  late Animation<Offset> offset;
  // MapType mapType = MapType.satellite;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? createdMarker;
  LatLng? createdMarkerPos;
  Timer? mapFetchTimer;
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    offset = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, -1.0))
        .animate(controller);

    displayCreatePin.addListener(() {
      if (!displayCreatePin.value) {
        controller.reverse();
      } else {
        controller.forward();
      }
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  createPinAction(String action) async {
    if(action.contains('goto')) {
      final start = action.indexOf(':');
      String location = action.substring(start + 1);

      LatLng latLng = await mapNavigate(location);

      generateInitMarker(latLng);
      return;
    }

    switch (action) {
      case "close":
        setState(() => displayCreatePin.value = false);
        if(createdMarker != null) _remove(createdMarker!);
        break;
      case "currentlocation":
        var results = await LocationHandler.determineDeviceLocation();

        if(results != null) {
          final _kLoc = CameraPosition(
            target: LatLng(results.latitude, results.longitude),
            zoom: 15,
          );

          _themesController.googleMapController!.animateCamera(CameraUpdate.newCameraPosition(_kLoc));
        }
        break;
      case "dragdrop":
        final devicePixelRatio =
          Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;

        final location = await _themesController.googleMapController!.getLatLng(
          ScreenCoordinate(
            x: (MediaQuery.of(context).size.width * devicePixelRatio) ~/
                2.0,
            y: (MediaQuery.of(context).size.height * devicePixelRatio) ~/
                2.0,
          )
        );

        generateInitMarker(location);

        break;
      case "removemarker":
        _remove(createdMarker!);
        break;
      case "togglesatellite":
        if (_themesController.mapType == MapType.normal) {
          setState(() => _themesController.mapType = MapType.satellite);
        } else {
          setState(() => _themesController.mapType = MapType.normal);
        }
        break;
      case "continue":
        if(createdMarker == null || createdMarkerPos == null) {
          showToast(context: context, type: ToastType.INFO, msg: 'Place a marker to continue');
          break;
        }

        final CreatePinScreen screen = CreatePinScreen(location: createdMarkerPos!);
        var result = await Navigator.of(context).push(SlideUpDownPageRoute(page: screen, closeDuration: 400));

        if(result != null) {
          setState(() => displayCreatePin.value = false);
          _remove(createdMarker!);

          final MarkerId markerKey = MarkerId(result.pinKey.toString());
          List loc = result.latLng.split(',');
          
          BitmapDescriptor mkr = await bitmapDescriptorFromSvgAsset(context, 'assets/icons/pin-2.svg', color: Colors.green, size: Size(45, 45));

          final Marker marker = Marker(
            markerId: markerKey,
            position: LatLng(double.parse(loc[0]), double.parse(loc[1])),
            draggable: false,
            icon: mkr,
            // onTap: () => _onMarkerTapped(markerKey),
          );

          setState(() {
            markers[markerKey] = marker;
          });
        }

        break;
      default:
        break;
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

  generateInitMarker(LatLng coords) async {
    if(createdMarker != null) _remove(createdMarker!);

    final String key = '0';
    final MarkerId markerKey = MarkerId(key);
    
    BitmapDescriptor mkr = await bitmapDescriptorFromSvgAsset(context, 'assets/icons/pin-2.svg', color: primaryOrange, size: Size(45, 45));

    final Marker marker = Marker(
      markerId: markerKey,
      position: coords,
      draggable: true,
      icon: mkr,
      // onTap: () => _onMarkerTapped(markerKey),
      // onDragEnd: (LatLng position) => _onMarkerDragEnd(markerKey, position),
      onDrag: (LatLng position) => _onMarkerDrag(markerKey, position),
    );

    setState(() {
      markers[markerKey] = marker;
      createdMarker = markerKey;
      createdMarkerPos = coords;
      canRemovePin.value = true;
    });
  }

  displayGatheredPins(List<Pin> pins) async {
    List<Pin> newPins = pins.where((e) => !markers.keys.map((f) => int.parse(f.value)).toList().contains(e.pinKey)).toList();

    setState(() {
      markers.removeWhere((k, v) => !pins.map((e) => e.pinKey).toList().contains(int.parse(k.value)) && k.value != '0');
    });

    for(Pin item in newPins) {
      final MarkerId markerKey = MarkerId(item.pinKey.toString());
      List loc = item.latLng.split(',');

      BitmapDescriptor mkr = await bitmapDescriptorFromSvgAsset(context, 'assets/icons/pin-2.svg', color: Colors.green, size: Size(45, 45));

      final Marker marker = Marker(
        markerId: markerKey,
        position: LatLng(double.parse(loc[0]), double.parse(loc[1])),
        draggable: false,
        icon: mkr,
        onTap: () => _onMarkerTapped(markerKey),
      );

      setState(() {
        markers[markerKey] = marker;
      });
    }

    print("MARKERS DISPLAYED: ${markers.length}");
  }

  void _onMarkerTapped(MarkerId key) {
    final Marker? tappedMarker = markers[key];
    if (tappedMarker != null) {
      PinScreen screen = PinScreen(pinKey: int.parse(tappedMarker.markerId.value));
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
    }
  }

  Future<void> _onMarkerDrag(MarkerId key, LatLng newPosition) async {
    setState(() {
      createdMarkerPos = newPosition;
    });
  }

  // Future<void> _onMarkerDragEnd(MarkerId key, LatLng newPosition) async {
  //   final Marker? tappedMarker = markers[key];
  //   if (tappedMarker != null) {
  //     setState(() {
  //       initMarkerPosition = null;
  //     });
  //     await showDialog<void>(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //               actions: <Widget>[
  //                 TextButton(
  //                   child: const Text('OK'),
  //                   onPressed: () => Navigator.of(context).pop(),
  //                 )
  //               ],
  //               content: Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 66),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: <Widget>[
  //                       Text('Old position: ${tappedMarker.position}'),
  //                       Text('New position: $newPosition'),
  //                     ],
  //                   )));
  //         });
  //   }
  // }

  void _remove(MarkerId key) {
    setState(() {
      if (markers.containsKey(key)) {
        markers.remove(key);

        if(key.value == '0') {
          canRemovePin.value = false;
          createdMarker = null;
          createdMarkerPos = null;
        }
      }
    });
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
    final theme = Theme.of(context);
    return DismissKeyboard(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: _themesController.mapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) async {
              _themesController.googleMapController = controller;
              _themesController.setMapStyle();
              
              var results = await LocationHandler.determineDeviceLocation();
              if(results != null) {
                final _kLoc = CameraPosition(
                  target: LatLng(results.latitude, results.longitude),
                  zoom: 15,
                );

                _themesController.googleMapController!.animateCamera(CameraUpdate.newCameraPosition(_kLoc));
              }
              // _customInfoWindowController.googleMapController = controller;
            },
            markers: Set<Marker>.of(markers.values),
            onCameraMove: (position) {
              KeyboardUtil.hideKeyboard(context);
              if(mapFetchTimer != null) mapFetchTimer!.cancel();

              // setState(() {
              //   markers.removeWhere((key, value) => key.value != '0');
              // });
            },
            onCameraIdle: () async {
              LatLngBounds visibleRegion = await _themesController.googleMapController!.getVisibleRegion();

              LatLng centerLatLng = LatLng(
                (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
                (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
              );

              String latlng = "${centerLatLng.latitude},${centerLatLng.longitude}";

              mapFetchTimer = Timer(Duration(seconds: 1), () async {
                setState(() => isLoading = true);
                var results = await getMapPins(context, latlng: latlng);
                setState(() => isLoading = false);

                displayGatheredPins(results);
              });

            },
            onTap: (latlng) {
              KeyboardUtil.hideKeyboard(context);
              if(displayCreatePin.value) {
                generateInitMarker(latlng);
              }
            },
            onLongPress: (latlng) {
              KeyboardUtil.hideKeyboard(context);
            },
          ),
          ValueListenableBuilder(
            valueListenable: VenUser().userKey, 
            builder: (context, value, _) {
              if (value != 0) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: SlideTransition(
                    position: offset,
                    child: Padding(
                      padding: EdgeInsets.only(top: 60, right: 15, left: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(0,3),
                                    blurRadius: 1
                                    ),
                                  ]
                                ),
                                child: TextField(
                                  onChanged: (v) => autocomplete(v),
                                  controller: textController,
                                  keyboardType: TextInputType.streetAddress,
                                  textInputAction: TextInputAction.go,
                                  onSubmitted: (text) {
                                    KeyboardUtil.hideKeyboard(context);
                                    if (textController.text.isNotEmpty) {
                                      mapNavigate(textController.text);
                                      textController.clear();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                    hintText: "Enter location address",
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: ZoomTapAnimation(
                                        onTap: () {
                                          KeyboardUtil.hideKeyboard(context);
                                          if (textController.text.isNotEmpty) {
                                            mapNavigate(textController.text);
                                            textController.clear();
                                          }
                                        },
                                        child: Container(
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: Get.isDarkMode ? ColorConstants.gray800 : Colors.grey.shade300,
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
                              )
                            ),
                          ),
                          CustomMapPopupMenu(
                            popupItems: [
                              CustomMapPopupMenuItem(
                                text: Text(
                                  "Create Pin",
                                  style: theme.textTheme.subtitle1!,
                                ),
                                icon: Icon(
                                  IconlyLight.location,
                                  color: Get.isDarkMode ? Colors.white : Colors.black
                                ),
                                onTap: () {
                                  if (!displayCreatePin.value) {
                                    setState(() => displayCreatePin.value = true);
                                  } else {
                                    setState(() => displayCreatePin.value = false);
                                  }
                                }
                              )
                            ],
                          )
                        ]
                      )
                    )
                  )
                );
              } else {
                return Container();
              }
            }
          ),
          CreatePin(
            display: displayCreatePin,
            onAction: (v) => createPinAction(v),
            canRemovePin: canRemovePin
          ),
          // Positioned(
          //   top: 120,
          //   right: MediaQuery.of(context).size.width * .05,
          //   child: ZoomTapAnimation(
          //     onTap: () => _showMapThemeModal(theme),
          //     child: NeumorphContainer.convex(
          //       borderRadius: 10.0,
          //       child: Center(
          //         child: Padding(
          //           padding: EdgeInsets.all(10),
          //           child: Icon(IconlyBroken.more_square, size: 25)
          //         )
          //       )
          //     )
          //   )
          // ),
          // Positioned(
          //   top: 70,
          //   right: 15,
          //   child: Container(
          //     width: 35,
          //     height: 50,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(10),
          //       color: Colors.white
          //     ),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       children: [
          //         MaterialButton(
          //           padding: EdgeInsets.all(0),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           child: Icon(IconlyBroken.more_square, size: 25),
          //           onPressed: () {
          //             _showMapThemeModal(theme);
          //           }
          //         )
          //       ]
          //     )
          //   )
          // )
          // Positioned(
          //   right: 100,
          //   bottom: 100,
          //   child: FloatingActionButton(
          //     onPressed: () {},
          //     child: Icon(Icons.add),
          //   )
          // ),
          isLoading ? Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * .0798),
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