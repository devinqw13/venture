import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Components/NeumorphContainer.dart';
import 'package:venture/Constants.dart';

class CreatePin extends StatefulWidget {
  final ValueNotifier<bool> display;
  final ValueNotifier<bool> canRemovePin;
  final ValueChanged? onAction;
  const CreatePin({
    Key? key,
    required this.display,
    required this.canRemovePin,
    this.onAction
  })  : super(key: key);
  @override
  CreatePinState createState() => CreatePinState();
}

class CreatePinState extends State<CreatePin> with TickerProviderStateMixin {
  late AnimationController controller, controller2;
  late Animation<Offset> offset, offset2;
  final TextEditingController textController = TextEditingController();
  bool showRemovePin = false;

  @override
  void initState() {
    super.initState();
    
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    offset = Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset(0.0, 0.0))
        .animate(controller);

    controller2 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    offset2 = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, -1.0))
        .animate(controller2);

    widget.display.addListener(() {
      switch(widget.display.value) {
        case true:
          controller.forward();
          controller2.forward();
          break;
        case false:
          controller.reverse();
          controller2.reverse();
          break;
      }
    });

    widget.canRemovePin.addListener(() {
      switch(widget.canRemovePin.value) {
        case true:
          setState(() => showRemovePin = true);
          break;
        case false:
          setState(() => showRemovePin = false);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: offset,
            child: Stack(
              children: [
                // Positioned.fill(
                //   child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {                     
                //     return IgnorePointer(
                //       child: Container(
                //         decoration: BoxDecoration(
                //           gradient: LinearGradient(
                //             begin: Alignment(0, -1),
                //             end: Alignment(0, 0),
                //             colors: [
                //               Color.fromARGB(255, 255, 255, 255),
                //               Color.fromARGB(255, 255, 255, 255),
                //               Color.fromARGB(235, 255, 255, 255),
                //               Color.fromARGB(150, 255, 255, 255),
                //               Color.fromARGB(120, 255, 255, 255),
                //             ]
                //           )
                //         )
                //       )
                //     );
                //   }),
                // ),
                Container(
                  padding: EdgeInsets.only(top: 55.0, bottom: 5.0, left: 15.0, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ZoomTapAnimation(
                        onTap: () {
                          setState(() => textController.clear());
                          widget.onAction!('close');
                        },
                        child: NeumorphContainer.convex(
                          height: 45,
                          width: 45,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(0,1),
                            blurRadius: 1
                            ),
                          ],
                          borderRadius: 10.0,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.close)
                            )
                          ),
                        )
                      ),
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
                              controller: textController,
                              keyboardType: TextInputType.streetAddress,
                              textInputAction: TextInputAction.go,
                              onSubmitted: (text) {
                                if (textController.text.isNotEmpty) {
                                  widget.onAction!('goto:${textController.text}');
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
                                        widget.onAction!('goto:${textController.text}');
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZoomTapAnimation(
                            onTap: () {
                              KeyboardUtil.hideKeyboard(context);
                              widget.onAction!('dragdrop');
                            },
                            child: NeumorphContainer.convex(
                              height: 45,
                              width: 45,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(0,1),
                                blurRadius: 1
                                ),
                              ],
                              borderRadius: 10.0,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.person_pin_circle_outlined)
                                )
                              ),
                            )
                          ),
                          SizedBox(height: 15),
                          ZoomTapAnimation(
                            onTap: () {
                              // Navigate map to user location
                              // widget.onAction!('currentlocation');
                            },
                            child: NeumorphContainer.convex(
                              height: 45,
                              width: 45,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(0,1),
                                blurRadius: 1
                                ),
                              ],
                              borderRadius: 10.0,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.navigation_outlined)
                                )
                              ),
                            )
                          ),
                          SizedBox(height: 15),
                          ZoomTapAnimation(
                            onTap: () {
                              KeyboardUtil.hideKeyboard(context);
                              widget.onAction!('togglesatellite');
                            },
                            child: NeumorphContainer.convex(
                              height: 45,
                              width: 45,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(0,1),
                                blurRadius: 1
                                ),
                              ],
                              borderRadius: 10.0,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.map_outlined)
                                )
                              ),
                            )
                          ),
                          SizedBox(height: 25),
                          showRemovePin ? ZoomTapAnimation(
                            onTap: () {
                              // Remove init marker on map
                              widget.onAction!('removemarker');
                            },
                            child: NeumorphContainer.convex(
                              height: 45,
                              width: 45,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(0,1),
                                blurRadius: 1
                                ),
                              ],
                              borderRadius: 10.0,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(IconlyLight.delete)
                                )
                              ),
                            )
                          ) : Container()
                        ],
                      )
                    ],
                  )
                )
              ],
            ),
          )
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: offset2,
            child: Stack(
              children: [
                // Positioned.fill(
                //   child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {                       
                //     return IgnorePointer(
                //       child: Container(
                //         decoration: BoxDecoration(
                //           gradient: LinearGradient(
                //             begin: Alignment(0, 0),
                //             end: Alignment(0, -1),
                //             colors: [
                //               Color.fromARGB(255, 255, 255, 255),
                //               Color.fromARGB(150, 255, 255, 255),
                //               Color.fromARGB(120, 255, 255, 255),
                //             ]
                //           )
                //         )
                //       )
                //     );
                //   }),
                // ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 25, left: 10, right: 10, top: 5),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text("Continue"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(360, 40),
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.6),
                            primary: primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            )
                          ),
                        )
                      )
                    )
                  ]
                )
              ]
            )
          ),
        )
      ],
    );
  }
}