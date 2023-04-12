import 'dart:ui' as ui;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/FadeOverlay.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/ContentSelectionScreen.dart/ContentSelectionScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController usernameController;
  late TextEditingController nameController;
  late TextEditingController bioController;
  final ThemesController _themesController = Get.find();
  late UserModel user;
  bool isLoading = false;
  bool enableButton = false;
  File? newAvatar;

  @override
  initState() {
    super.initState();
    user = widget.user;
    usernameController = TextEditingController(text: user.userName);
    nameController = TextEditingController(text: user.displayName);
    bioController = TextEditingController(text: user.userBio);
  }

  checkDoneButton() {
    if(
      newAvatar != null ||
      usernameController.text != user.userName ||
      nameController.text != user.displayName ||
      bioController.text != (user.userBio ?? '')
    ) {
      setState(() => enableButton = true);
    }else {
      setState(() => enableButton = false);
    }
  }

  onSubmit() async {
    if(isLoading) return;
    KeyboardUtil.hideKeyboard(context);
    setState(() => isLoading = true);

    if(newAvatar != null) {
      var result = await handleContentUploadV2(context, [newAvatar], user.userKey!, 'update-avatar');

      bool res = await FirebaseAPI().updateUserData(context, user.fid, avatar: result);

      if(res) setState(() => user.userAvatar = result);

      setState(() {
        newAvatar = null;
      });
    }

    if(usernameController.text != user.userName) {
      bool result = await FirebaseAPI().updateUserData(context, user.fid, username: usernameController.text.toLowerCase());

      if(result) setState(() => user.userName = usernameController.text);
    }

    if(nameController.text != (user.displayName ?? '')) {
      bool result = await FirebaseAPI().updateUserData(context, user.fid, displayName: nameController.text);

      if(result) setState(() => user.displayName = nameController.text);
    }

    if(bioController.text != (user.userBio ?? '')) {
      bool result = await FirebaseAPI().updateUserData(context, user.fid, bio: bioController.text);

      if(result) setState(() => user.userBio = bioController.text);
    }

    setState(() => isLoading = false);

    checkDoneButton();
    Navigator.pop(context);
  }

  selectPhoto() async {
    var result = await Navigator.of(context).push(
      FadeOverlay(
        backgroundColor: _themesController.getContainerBgColor(),
        child: ContentSelectionScreen(
          allowMultiSelect: false,
          photoOnly: true,
          circleMask: true,
        )
      )
    );

    if(result != null) {
      setState(() {
        newAvatar = result.first;
        enableButton = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, user);
        return false;
      },
      child: DismissKeyboard(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(IconlyLight.arrow_left, size: 25),
            onPressed: () => Navigator.of(context).pop(user),
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
          centerTitle: true,
          title: Text(
            'Edit Profile',
            style: theme.textTheme.headline6,
          ),
          actions: [
            !isLoading ? enableButton ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: ZoomTapAnimation(
                  onTap: () => onSubmit(),
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Get.isDarkMode ? Colors.white : Colors.black
                    ),
                  )
                )
              )
            ) : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  "Done",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Get.isDarkMode ? ColorConstants.gray400 : Colors.grey
                  ),
                )
              )
            ) : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoActivityIndicator(
                radius: 13,
              )
            )
          ],
        ),
        body: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                image: newAvatar != null ?
                DecorationImage(
                  image: FileImage(
                    newAvatar!,
                  ),
                  fit: BoxFit.cover
                ) :
                DecorationImage(
                  image: CachedNetworkImageProvider(
                    user.userAvatar!,
                  ),
                  fit: BoxFit.cover
                )
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.3),
                    child: ZoomTapAnimation(
                      onTap: () => selectPhoto(),
                      child: Stack(
                        children: [
                          newAvatar != null ?
                          CircleAvatar(
                            radius: getProportionateScreenHeight(45),
                            backgroundImage: FileImage(newAvatar!),
                          ) :
                          CircleAvatar(
                            radius: getProportionateScreenHeight(45),
                            backgroundImage: CachedNetworkImageProvider(user.userAvatar!),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.5),
                            radius: getProportionateScreenHeight(45),
                            child: Center(
                              child: Icon(
                                IconlyLight.camera,
                                size: 40,
                                color: Colors.black,
                              )
                            ),
                          )
                        ]
                      )
                    ),
                  )
                )
              )
            ),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey,
                  width: 0.3
                ),
                bottom: BorderSide(
                  color: Get.isDarkMode ? ColorConstants.gray300 : Colors.grey,
                  width: 0.3
                )
              ),
              children: [
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 20),
                      child: Text(
                        "Username",
                      )
                    ),
                    TextField(
                      controller: usernameController,
                      readOnly: isLoading,
                      onChanged: (v) => checkDoneButton(),
                      decoration: InputDecoration(
                        hintText: "Username",
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      ),
                    )
                  ],
                ),

                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 20),
                      child: Text(
                        "Name",
                      )
                    ),
                    TextField(
                      controller: nameController,
                      readOnly: isLoading,
                      onChanged: (v) => checkDoneButton(),
                      decoration: InputDecoration(
                        hintText: "Name",
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      ),
                    )
                  ],
                ),

                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 20),
                      child: Text(
                        "Bio",
                      )
                    ),
                    TextField(
                      controller: bioController,
                      readOnly: isLoading,
                      onChanged: (v) => checkDoneButton(),
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Bio",
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        )
      )
    ));
  }
}