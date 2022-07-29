import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/ExpandableFab.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Models/MapThemes.dart';
import 'package:venture/Components/Test.dart';

class MapTab extends StatefulWidget {
  MapTab({Key? key}) : super(key: key);

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with AutomaticKeepAliveClientMixin<MapTab>{
  final ThemesController _themesController = Get.find();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
  }

  // GoogleMapController? _controller;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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

  PopupMenuItem _buildPopupMenuItem(
      String title, IconData iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            iconData,
            color: Colors.black,
          ),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Stack(
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
        Positioned(
          top: 50.0,
          right: 16.0,
          child: SimpleAccountMenu(
            icons: [
              Icon(Icons.person),
              Icon(Icons.settings),
              Icon(Icons.credit_card),
            ],
            iconColor: Colors.white,
            onChange: (index) {
              print(index);
            },
          )
          // child: ExpandableFab(
          //   actions: [
          //     TabAction(
          //       icon: Icons.star,
          //       onTap: () {

          //       }
          //     )
          //   ],
          // ),
        )
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
    );
  }
}