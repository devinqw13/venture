import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:mime/mime.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/DottedBorder.dart';
import 'package:venture/Components/FadeOverlay.dart';
import 'package:venture/Components/PhotoBuilder.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/DeleteContent.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/LocationHandler.dart';
import 'package:venture/Helpers/MapPreview.dart';
import 'package:venture/Helpers/PinCategorySelector.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/PinCategory.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/Screens/ContentSelectionScreen/ContentSelectionScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CreatePinScreen extends StatefulWidget {
  final LatLng location;
  final PinCategory? pinCategory;
  CreatePinScreen({Key? key, required this.location, this.pinCategory}) : super(key: key);

  @override
  _CreatePinScreenState createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final ThemesController _themesController = Get.find();
  bool isLoading = false;
  bool isLoadingLoc = false;
  final TextEditingController nameTxtController = TextEditingController();
  final TextEditingController descTxtController = TextEditingController();
  final TextEditingController locTxtController = TextEditingController();
  List<int> circleKeys = [];
  List<File?> content = [];
  PinCategory? category;

  @override
  void initState() {
    super.initState();

    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() {
    fetchAddress();
    setState(() => category = widget.pinCategory);
  }

  fetchAddress() async {
    setState(() => isLoadingLoc = true);
    var location = await LocationHandler.addressFromCoords(context, widget.location.latitude, widget.location.longitude);
    setState(() => isLoadingLoc = false);

    var loc = location.first;

    locTxtController.text = "${loc.street} ${loc.subAdministrativeArea} ${loc.administrativeArea} ${loc.postalCode}";
  }

  openPhotoSelector() async {
    var result = await Navigator.of(context).push(
      FadeOverlay(
        backgroundColor: _themesController.getContainerBgColor(),
        child: ContentSelectionScreen(
          allowMultiSelect: true,
          photoOnly: false,
        )
      )
    );
    
    if(result != null) {
      setState(() => content = result);
    }
  }

  openCategorySelector() async {
    var response = await showPinCategorySelectorSheet(context: context, initCategory: category);
    setState(() => category = response);
  }

  removeContent() {
    // remove any content stored in local files
    for(var item in content) {
      deleteFile(item!);
    }

    if(mounted) {
      setState(() => content.clear());
    }
  }

  viewContent() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: CarouselSlider(
          items: List<Widget>.generate(content.length, (index) {
            return Image.file(content[index]!);
          }),
          options: CarouselOptions(),
        )
      ),
    );
  }

  // _showCircleModal(ThemeData theme) {
  //   Get.bottomSheet(
  //     Container(
  //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
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
  //           Text("Select circle", style: theme.textTheme.subtitle1),
  //           SizedBox(height: 32),
  //           Center(
  //             child: Text(
  //               "You are not in any circles", 
  //               style: TextStyle(
  //                 fontSize: 15,
  //                 color: Colors.grey.shade700,
  //                 fontStyle: FontStyle.italic
  //               )
  //             )
  //           ),
  //           SizedBox(height: 32),
  //           // ListTile(
  //           //   leading: Icon(Icons.brightness_5, color: Colors.blue,),
  //           //   title: Text("Light", style: theme.textTheme.bodyText1),
  //           //   onTap: () {
  //           //     _themesController.setTheme('light');
  //           //     Get.back();
  //           //   },
  //           //   trailing: Icon(Icons.check, color: current == 'light' ? Colors.blue : Colors.transparent,),
  //           // ),
  //           // SizedBox(height: 16),
  //           // ListTile(
  //           //   leading: Icon(Icons.brightness_2, color: Colors.orange,),
  //           //   title: Text("Dark", style: theme.textTheme.bodyText1),
  //           //   onTap: () {
  //           //     _themesController.setTheme('dark');
  //           //     Get.back();
  //           //   },
  //           //   trailing: Icon(Icons.check, color: current == 'dark' ? Colors.orange : Colors.transparent,),
  //           // ),
  //           // SizedBox(height: 16),
  //           // ListTile(
  //           //   leading: Icon(Icons.brightness_6, color: Colors.blueGrey,),
  //           //   title: Text("System", style: theme.textTheme.bodyText1),
  //           //   onTap: () {
  //           //     _themesController.setTheme('system');
  //           //     Get.back();
  //           //   },
  //           //   trailing: Icon(Icons.check, color: current == 'system' ? Colors.blueGrey : Colors.transparent,),
  //           // ),
  //         ],
  //       ),
  //     )
  //   );
  // }

  _handleSubmit() async {
    if(isLoading) return;

    if(nameTxtController.text.isEmpty) {
      showToastV2(context: context, msg: "Pin must have a name.");
      return;
    }

    String location = "${widget.location.latitude},${widget.location.longitude}";

    setState(() => isLoading = true);
    Pin? pin = await createPin(
      context,
      nameTxtController.text,
      descTxtController.text,
      location,
      VenUser().userKey.value,
      category != null ? category!.name : null,
      circleKeys: circleKeys.isNotEmpty ? circleKeys : null);
      
    if(content.isNotEmpty) {
      var _ = await handleContentUploadV2(context, content, VenUser().userKey.value, "post", pinKey: pin?.pinKey);
    }
    setState(() => isLoading = false);

    if(pin != null) {
      Navigator.pop(context, pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close, size: 28),
            onPressed: () {
              removeContent();
              Navigator.of(context).pop();
            },
          ),
          centerTitle: false,
          title: Text(
            'Create Pin',
            style: theme.textTheme.headline6,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MapPreview(latitude: widget.location.latitude, longitude: widget.location.longitude),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextField(
                          readOnly: isLoading,
                          controller: nameTxtController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            hintText: "Name",
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text("Give the place or location a name. Typically, the name of the place that it is better known as. Ex. Kings Island, Cosmosphere, etc.", 
                          style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic))
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextField(
                          readOnly: isLoading,
                          controller: descTxtController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            hintText: "Tell us about this place",
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ZoomTapAnimation(
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            leading: category != null ? Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withAlpha(30)
                              ),
                              child: Center(
                                child: CustomIcon(
                                  icon: category!.iconPath,
                                  color: Get.isDarkMode ? Colors.white : Colors.black,
                                  size: 27
                                ),
                              ),
                            ) : null,
                            title: Text(category != null ? category!.name : "Select a category", style: theme.textTheme.subtitle1),
                            trailing: Container(
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Text(trailing, style: theme.textTheme.bodyText1?.copyWith(color: Colors.grey.shade600)),
                                  Icon(Icons.arrow_forward_ios, size: 16,),
                                ],
                              ),
                            ),
                            onTap: () => openCategorySelector()
                          )
                        )
                      ),
                      SizedBox(height: 15),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                      //     borderRadius: BorderRadius.circular(10)
                      //   ),
                      //   child: TextField(
                      //     readOnly: true,
                      //     controller: locTxtController,
                      //     style: TextStyle(
                      //       color: ColorConstants.gray400
                      //     ),
                      //     decoration: InputDecoration(
                      //       contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      //       hintText: "Address or coordinates",
                      //       prefixIcon: isLoadingLoc ? Padding(
                      //         padding: const EdgeInsets.all(5.0),
                      //         child: Container(
                      //           width: 40,
                      //           child: Center(
                      //             child: CupertinoActivityIndicator(
                      //               radius: 10,
                      //             ),
                      //           ),
                      //         )
                      //       ) : null
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 15),
                      // GestureDetector(
                      //   onTap: () => !isLoading ? _showCircleModal(theme) : null,
                      //   child: Container(
                      //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      //     decoration: BoxDecoration(
                      //       color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                      //       borderRadius: BorderRadius.circular(10)
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         Text(
                      //           "Choose circle",
                      //           style: TextStyle(
                      //             color: ColorConstants.gray400
                      //           ),
                      //         ),
                      //         Icon(IconlyLight.arrow_down_2, color: ColorConstants.gray400)
                      //       ],
                      //     ),
                      //   )
                      // ),

                      content.isEmpty ? ZoomTapAnimation(
                        onTap: () => openPhotoSelector(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(10),
                            dashPattern: [10, 4],
                            strokeCap: StrokeCap.round,
                            color: Colors.blue.shade400,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                // color: Colors.blue.shade50.withOpacity(.3),
                                color: Get.isDarkMode ? Colors.blue.shade50.withOpacity(.15) :  Colors.blue.shade50.withOpacity(.3),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(IconlyLight.folder, color: Colors.blue, size: 40),
                                  SizedBox(height: 15),
                                  Text('upload photos or videos', style: TextStyle(fontSize: 15, color: Colors.grey.shade400),),
                                ],
                              ),
                            ),
                          )
                        ),
                      ) :
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(10),
                          dashPattern: [10, 4],
                          strokeCap: StrokeCap.round,
                          color: Colors.blue.shade400,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Get.isDarkMode ? Colors.blue.shade50.withOpacity(.15) :  Colors.blue.shade50.withOpacity(.3),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: ZoomTapAnimation(
                                    onTap: () => viewContent(),
                                    child: OverlapPhotos(
                                      files: content,
                                      radius: 30,
                                      overlap: 30,
                                    )
                                  )
                                ),
                                ElevatedButton(
                                  onPressed: () => removeContent(),
                                  child: CustomIcon(
                                    icon: 'assets/icons/trash.svg',
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(8),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    backgroundColor: Colors.black.withOpacity(0.4),
                                    shape: CircleBorder(),
                                  ),
                                )
                                // ZoomTapAnimation(
                                //   onTap: () => removeContent,
                                //   child: CustomIcon(
                                //     icon: 'assets/icons/trash.svg',
                                //     color: Colors.red,
                                //   )
                                // )
                              ],
                            ),
                          ),
                        )
                      ),
                      // Row(
                      //   mainAxisSize: MainAxisSize.max,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     ZoomTapAnimation(
                      //       child: IconButton(
                      //         onPressed: () => removeContent(),
                      //         icon: Icon(
                      //           Icons.close,
                      //           color: Get.isDarkMode ? ColorConstants.gray400 : Colors.grey,
                      //         )
                      //       )
                      //     ),

                      //     Expanded(
                      //       child: Container(
                      //       decoration: BoxDecoration(
                      //           color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                      //           borderRadius: BorderRadius.circular(10)
                      //         ),
                      //         child: Row(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Padding(
                      //               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      //               child: ZoomTapAnimation(
                      //                 onTap: () => viewContent(),
                      //                 child: OverlapPhotos(
                      //                   files: content,
                      //                   radius: 20,
                      //                 )
                      //               )
                      //             ),
                      //             Expanded(
                      //               child: TextField(
                      //                 maxLines: 5,
                      //                 decoration: InputDecoration(
                      //                   contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                      //                   hintText: "Write a caption...",
                      //                 )
                      //               )
                      //             )
                      //           ],
                      //         ),
                      //       )
                      //     )
                      //   ],
                      // ),
                    ],
                  )
                )
              )
            ),

            
            Container(
              decoration: BoxDecoration(
                color: _themesController.getContainerBgColor(),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 0.5,
                    offset: Offset(0.0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      child: ElevatedButton(
                        onPressed: () => _handleSubmit(),
                        child: !isLoading ? Text("Continue") :
                        SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(360, 40),
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.6),
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          )
                        ),
                      )
                    )
                  )
                ]
              ),
            )
          ],
        )
      )
    );
  }

}