import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/DropShadow.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/rating.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Models/VenUser.dart';

Future<dynamic> showRatePinSheet({
  required BuildContext context,
  required String title,
  required int pinKey,
  required UserModel user,
  Content? content,
  Pin? pin
}) async {
  var response = await Get.bottomSheet(
    RatePin(title: title, pinKey: pinKey, user: user, content: content, pin: pin)
  );
  return response;
}

class RatePin extends StatefulWidget {
  final String title;
  final int pinKey;
  final UserModel user;
  final Content? content;
  final Pin? pin;
  RatePin({Key? key, required this.title, required this.pinKey, required this.user, this.content, this.pin}) : super(key: key);

  @override 
  _RatePin createState() => _RatePin();
}

class _RatePin extends State<RatePin> {
  RxDouble _rating = 0.0.obs;
  RxBool isLoading = false.obs;
  RxBool _visible = false.obs;

  submit() {
    if(isLoading.value) return;
    ratePin(
      context,
      widget.pinKey, 
      VenUser().userKey.value, 
      _rating.value.toInt(),
      data: {
        "pin_key": widget.pinKey,
        "rating": _rating.value.toInt(),
        "user_key": widget.pin != null ?
                              widget.pin!.user!.userKey.toString()
                            : widget.content!.user!.userKey.toString(),
        "content_image_url": widget.pin != null ?
                                widget.pin!.featuredPhoto!
                            : widget.content != null ?
                                widget.content!.contentUrls.first
                            : null
      }
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      // height: MediaQuery.of(context).size.height * 0.23,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        )
      ),
      child: Obx(() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 30,
                height: 8.0,
                decoration: BoxDecoration(
                  color: ColorConstants.gray100,
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.title,
                      style: TextStyle(
                        fontSize: 30
                      )
                    ),
                    TextSpan(
                      text: "\nby "
                    ),
                    TextSpan(
                      text: "${widget.user.userName} ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    if(widget.user.isVerified!)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: CustomIcon(
                          icon: 'assets/icons/verified-account.svg',
                          size: 14,
                          color: primaryOrange,
                        )
                      ),
                  ]
                ),
                textAlign: TextAlign.center,
              )
            ),
            if(widget.pin != null && !lookupMimeType(widget.pin!.featuredPhoto!)!.contains('video'))
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: DropShadow(
                  child: MyAvatar(
                    photo: widget.pin!.featuredPhoto!,
                    size: 50
                  )
                )
              ),
            if(widget.content != null && !lookupMimeType(widget.content!.contentUrls.first)!.contains('video'))
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: DropShadow(
                  child: MyAvatar(
                    photo: widget.content!.contentUrls.first,
                    size: 50
                  )
                )
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Rate "
                    ),
                    TextSpan(
                      text: widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                      )
                    ),
                    TextSpan(
                      text: "  based on overall experience if you've been here or by the information shared on this pin."
                    )
                  ]
                ),
                textAlign: TextAlign.center,
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: RatingBar(
                initialRating: 0,
                itemCount: 5,
                ratingWidget: RatingWidget(
                  full: CustomIcon(
                    icon: 'assets/icons/star.svg',
                    color: Colors.amber,
                  ),
                  half: CustomIcon(
                    icon: 'assets/icons/star.svg',
                    color: Colors.amber,
                  ),
                  empty: CustomIcon(
                    icon: 'assets/icons/star.svg',
                    color: Colors.grey,
                  ),
                ),
                onRatingUpdate: (rating) {
                  _rating.value = rating;
                  _visible.value = true;
                },
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: AnimatedOpacity(
                opacity: _visible.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: ElevatedButton(
                  onPressed: () => _visible.value ? submit() : null,
                  child: Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // padding: EdgeInsets.all(0),
                    // minimumSize: Size.zero,
                    minimumSize: Size(
                      150, 40
                    ),
                    elevation: 0,
                    backgroundColor: primaryOrange,
                    shadowColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                  ),
                ),
              ),
            )
          ],
        )
      ))
    );
  }
}