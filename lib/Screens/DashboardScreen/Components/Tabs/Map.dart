import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/CreatePin.dart';
import 'package:venture/Components/CustomMapPopupMenu.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Models/MapThemes.dart';
import 'package:venture/Models/User.dart';
import 'package:venture/Helpers/LocationHandler.dart';

class MapTab extends StatefulWidget {
  MapTab({Key? key}) : super(key: key);

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin<MapTab>, TickerProviderStateMixin {
  final ThemesController _themesController = Get.find();
  ValueNotifier<bool> displayCreatePin = ValueNotifier<bool>(false);
  ValueNotifier<bool> canRemovePin = ValueNotifier<bool>(false);
  late AnimationController controller;
  late Animation<Offset> offset;
  MapType mapType = MapType.normal;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? createdMarker;
  LatLng? createdMarkerPos;

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

  // GoogleMapController? _controller;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  createPinAction(String action) async {
    if(action.contains('goto')) {
      final start = action.indexOf(':');
      String location = action.substring(start + 1);

      final loc = await LocationHandler.coordsFromAddress(context, location);

      final _kLoc = CameraPosition(
        target: LatLng(loc.first.latitude, loc.first.longitude),
        zoom: 14.4746,
      );

      _themesController.googleMapController!.animateCamera(CameraUpdate.newCameraPosition(_kLoc));

      generateInitMarker(LatLng(loc.first.latitude, loc.first.longitude));
      return;
    }

    switch (action) {
      case "close":
        setState(() => displayCreatePin.value = false);
        break;
      case "currentlocation":

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
        if (mapType == MapType.normal) {
          setState(() => mapType = MapType.satellite);
        } else {
          setState(() => mapType = MapType.normal);
        }
        break;
      default:
        break;
    }
  }

  generateInitMarker(LatLng coords) {
    if(createdMarker != null) _remove(createdMarker!);

    final String key = '0';
    final MarkerId markerKey = MarkerId(key);

    final Marker marker = Marker(
      markerId: markerKey,
      position: coords,
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
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

  // void _onMarkerTapped(MarkerId key) {
  //   final Marker? tappedMarker = markers[key];
  //   if (tappedMarker != null) {
  //     setState(() {
  //       final MarkerId? previousMarkerId = selectedMarker;
  //       if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
  //         final Marker resetOld = markers[previousMarkerId]!
  //             .copyWith(iconParam: BitmapDescriptor.defaultMarker);
  //         markers[previousMarkerId] = resetOld;
  //       }
  //       selectedMarker = key;
  //       final Marker newMarker = tappedMarker.copyWith(
  //         iconParam: BitmapDescriptor.defaultMarkerWithHue(
  //           BitmapDescriptor.hueGreen,
  //         ),
  //       );
  //       markers[key] = newMarker;

  //       initMarkerPosition = null;

  //       canRemovePin.value = true;
  //     });
  //   }
  // }

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
        canRemovePin.value = false;
        createdMarker = null;
        createdMarkerPos = null;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return DismissKeyboard(
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: mapType,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _themesController.googleMapController = controller;
              _themesController.setMapStyle();
              // _customInfoWindowController.googleMapController = controller;
            },
            markers: Set<Marker>.of(markers.values),
            onCameraMove: (position) {
              KeyboardUtil.hideKeyboard(context);
            },
            onTap: (latlng) {
              KeyboardUtil.hideKeyboard(context);
            },
            onLongPress: (latlng) {
              KeyboardUtil.hideKeyboard(context);
            },
          ),
          ValueListenableBuilder(
            valueListenable: User().userKey, 
            builder: (context, value, _) {
              if (value != 0) {
                return Align(
                  alignment: Alignment.topRight,
                  child: SlideTransition(
                    position: offset,
                    child: Padding(
                      padding: EdgeInsets.only(top: 60, right: 15),
                      child: CustomMapPopupMenu(
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
          )
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
        ],
      )
    );
  }
}