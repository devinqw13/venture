import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/SettingsScreen/ChangePassword.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:get/get.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:get_storage/get_storage.dart';

class PrivacySettingsScreen extends StatefulWidget {
  PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen>  {

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, size: 25),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: Get.isDarkMode ? ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7) : ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Get.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        centerTitle: false,
        title: Text(
          'Your account',
          style: theme.textTheme.headline6,
        )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            _buildListTile('Change your password', Icons.key_rounded, "", Colors.grey, theme, onTab: () => print("")),

          ],
        )
      )
    );
  }
}