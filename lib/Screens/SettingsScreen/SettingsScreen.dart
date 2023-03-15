import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/string_extension.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/SettingsScreen/AccountSettingsScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Models/MapThemes.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>  {
  final ThemesController _themesController = Get.find();
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              // expandedHeight: 100.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                // titlePadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Settings',
                  style: theme.textTheme.headline6,
                ),
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text("Account", style: theme.textTheme.headline6?.copyWith(fontWeight: FontWeight.w400)),
                  SizedBox(height: 16),
                  ZoomTapAnimation(
                    onTap: () {
                      if(VenUser().userKey.value == 0) {
                        Navigator.pop(context);
                      } else {
                        AccountSettingsScreen screen = AccountSettingsScreen();
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
                      }
                    },
                    child: Container(
                      height: 80,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Get.isDarkMode ? ColorConstants.gray700 : Colors.grey.shade200
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Get.isDarkMode ? ColorConstants.gray500 : Colors.grey.shade300
                            ),
                            child: Center(
                              child: Icon(Icons.person, size: 32, color: Colors.grey.shade500),
                            ),
                          ),
                          SizedBox(width: 16),
                          ValueListenableBuilder(
                            valueListenable: VenUser().userKey, 
                            builder: (context, value, _) {
                              return value == 0 ? Text("Login / Register", style: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w400, color: Colors.blue)) :
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Your account",
                                    style: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 3),
                                  Text("See information about your account",
                                    style: theme.textTheme.subtitle2?.copyWith(color: Colors.grey),
                                  )
                                ],
                              );
                            }
                          ),
                        ],
                      ),
                    )
                  ),
                  SizedBox(height: 32),
                  Text("Settings", style: theme.textTheme.headline6?.copyWith(fontWeight: FontWeight.w400)),
                  SizedBox(height: 16),
                  GetBuilder<ThemesController>(builder: (_) {
                    return _buildListTile('Appearance', Icons.dark_mode, _.theme.toCapitalized(), Colors.purple, theme, onTab: () => _showAppearanceModal(theme, _.theme));
                    // return Text(_.theme);
                  }),
                  GetBuilder<ThemesController>(builder: (_) {
                    return _buildToggleTile('Map Satelite', Icons.map_rounded, _.mapType == MapType.satellite, Colors.blue, theme, onTap: () => _toggleSatelite(_.mapType));
                    // return Text(_.theme);
                  }),
                  // GetBuilder<ThemesController>(builder: (_) {
                  //   return _buildListTile('Map Style', Icons.map_rounded, '', Colors.blue, theme, onTab: () => _showMapThemeModal(theme));
                  //   // return Text(_.theme);
                  // }),
                  // SizedBox(height: 8),
                  // _buildListTile('Language', Icons.language, 'English', Colors.orange, theme, onTab: () {}),
                  // SizedBox(height: 8),
                  // _buildListTile('Notifications', Icons.notifications_outlined, '', Colors.blue, theme, onTab: () {}),
                  // SizedBox(height: 8),
                  // _buildListTile('Help', Icons.help, '', Colors.green, theme, onTab: () {}),
                  // SizedBox(height: 8),
                  // _buildListTile('Logout', Icons.exit_to_app, '', Colors.red, theme, onTab: () {}),

                ],
              ),
              Text("Version 1.0.0", style: theme.textTheme.bodyText2?.copyWith(color: Colors.grey.shade500)),
            ],
          ),
        )
      )
    );
  }

  Widget _buildToggleTile(String title, IconData icon, bool value, Color color, theme, {onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(30)
        ),
        child: Center(
          child: Icon(icon, color: color,),
        ),
      ),
      title: Text(title, style: theme.textTheme.subtitle1),
      trailing: Platform.isAndroid ?
      Switch(
        onChanged: (v) => onTap(),
        value: value,
      ) : CupertinoSwitch(
        value: value,
        onChanged: (v) => onTap()
      ),
      onTap: onTap,
    );
  }

  Widget _buildListTile(String title, IconData icon, String trailing, Color color, theme, {onTab}) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(30)
        ),
        child: Center(
          child: Icon(icon, color: color,),
        ),
      ),
      title: Text(title, style: theme.textTheme.subtitle1),
      trailing: Container(
        width: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(trailing, style: theme.textTheme.bodyText1?.copyWith(color: Colors.grey.shade600)),
            Icon(Icons.arrow_forward_ios, size: 16,),
          ],
        ),
      ),
      onTap: onTab
    );
  }

  _showAppearanceModal(ThemeData theme, String current) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        height: 320,
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
            SizedBox(height: 32),
            ListTile(
              leading: Icon(Icons.brightness_5, color: Colors.blue,),
              title: Text("Light", style: theme.textTheme.bodyText1),
              onTap: () {
                _themesController.setTheme('light');
                Get.back();
              },
              trailing: Icon(Icons.check, color: current == 'light' ? Colors.blue : Colors.transparent,),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.brightness_2, color: Colors.orange,),
              title: Text("Dark", style: theme.textTheme.bodyText1),
              onTap: () {
                _themesController.setTheme('dark');
                Get.back();
              },
              trailing: Icon(Icons.check, color: current == 'dark' ? Colors.orange : Colors.transparent,),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.brightness_6, color: Colors.blueGrey,),
              title: Text("System", style: theme.textTheme.bodyText1),
              onTap: () {
                _themesController.setTheme('system');
                Get.back();
              },
              trailing: Icon(Icons.check, color: current == 'system' ? Colors.blueGrey : Colors.transparent,),
            ),
          ],
        ),
      )
    );
  }

  _toggleSatelite(MapType type) {

    if(type == MapType.satellite) {
      setState(() => _themesController.mapType = MapType.normal);

    }else {
      setState(() => _themesController.mapType = MapType.satellite);
    }

    storage.write('maptype', _themesController.mapType == MapType.satellite ? "satellite" : "normal");
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
  //                       border: Border.all(
  //                         color: MapThemes().themes[index]['name'] == _themesController.mapStyle ? Colors.blue : Colors.white.withOpacity(0),
  //                         width: 2
  //                       ),
  //                       boxShadow: [
  //                         MapThemes().themes[index]['name'] == _themesController.mapStyle ?
  //                         BoxShadow(
  //                           color: Colors.blue.shade100,
  //                           offset: Offset(0, 1),
  //                           blurRadius: 2
  //                         ) : BoxShadow(
  //                           color: Colors.grey.shade200,
  //                           offset: Offset(0, 1),
  //                           blurRadius: 2
  //                         )
  //                       ],
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
}