import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/CreatePin.dart';
import 'package:venture/Components/CustomMapPopupMenu.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:venture/Components/NeumorphContainer.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Models/MapThemes.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Models/User.dart';

class MapTab extends StatefulWidget {
  MapTab({Key? key}) : super(key: key);

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin<MapTab>, TickerProviderStateMixin {
  final ThemesController _themesController = Get.find();
  ValueNotifier<bool> displayCreatePin = ValueNotifier<bool>(false);
  late AnimationController controller;
  late Animation<Offset> offset;

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

  createPinAction(String action) {
    if(action.contains('goto')) {
      final start = action.indexOf(':');
      String location = action.substring(start + 1);
      print(location);
      // setState(() {
      //   _themesController.googleMapController.
      // });
      return;
    }

    switch (action) {
      case "close":
        setState(() => displayCreatePin.value = false);
        break;
      case "currentlocation":

        break;
      case "dragdrop":

        break;
      default:
        break;
    }
  }

  _showMapThemeModal(ThemeData theme) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.23,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select a Theme", style: theme.textTheme.subtitle1,),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: MapThemes().themes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _themesController.googleMapController?.setMapStyle(MapThemes().themes[index]['style']);
                      });
                      Get.back();
                    },
                    child: Container(
                      width: 100,
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(MapThemes().themes[index]['image']),
                        )
                      ),
                    ),
                  );
                }
              ),
            )
          ],
        ),
      )
    );
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
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _themesController.googleMapController = controller;
              _themesController.setMapStyle();
              // _customInfoWindowController.googleMapController = controller;
            }
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