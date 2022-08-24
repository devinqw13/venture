import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/CustomOptionsPopupMenu.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Components/ExpandableText.dart';
import 'package:venture/Helpers/TimeFormat.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/User.dart';

class PostSkeleton extends StatefulWidget{
  final Content content;
  PostSkeleton({Key? key, required this.content}) : super(key: key);

  @override
  _PostSkeleton createState() => _PostSkeleton();
}

class _PostSkeleton extends State<PostSkeleton> {

  _showOptions(ThemeData theme) {
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
            ListTile(
              title: Text("Delete", style: theme.textTheme.bodyText1!.copyWith(color: Colors.red)),
              onTap: () {
                // _showDeleteConfirmation();
                Get.back();
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      )
    );
  }

  deletePost() {
    print("DELETE POST");
  }

  Widget _buildHeaderDetails(ThemeData theme, Content content) {
    return Row(
      children: [
        ZoomTapAnimation(
          onTap: () => print("GO TO PROFILE"),
          child: MyAvatar(
            size: 25,
            photo: content.user!.userAvatar!
          )
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content.user!.displayName != null ?
              Text(content.user!.displayName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ) :
              Text('@'+content.user!.userName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Row(
                children: [
                  content.contentLocation != null ? Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      content.contentLocation!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        decoration: TextDecoration.underline
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  ) : Container(),
                  content.contentLocation != null ? Text(
                    " ${String.fromCharCode(0x00B7)} ",
                    style: TextStyle(
                      // fontSize: 25
                    ),
                  ) : Container(),
                  TimeFormat().withDate(
                    content.timestamp,
                    numericDates: false,
                    style: TextStyle(
                      color: Colors.grey
                    )
                  )
                ],
              )
            ],
          )
        ),
        ValueListenableBuilder(
          valueListenable: User().userKey, 
          builder: (context, value, _) {
            return value == 0 ? Container() : CustomOptionsPopupMenu(
              popupItems: [
                if(value == content.user!.userKey)
                  CustomOptionPopupMenuItem(
                    text: Text(
                      "Delete Post",
                      style: theme.textTheme.subtitle1!.copyWith(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    icon: Icon(IconlyLight.delete, color: Colors.red),
                    onTap: () => print("DELETE POST")
                  ),
                if(value == content.user!.userKey)
                  CustomOptionPopupMenuItem(
                    text: Text(
                      "Edit",
                      style: theme.textTheme.subtitle1!,
                    ),
                    onTap: () => print("EDIT")
                  )
              ],
            );
          }
        )
        // ElevatedButton(
        //   onPressed: () => _showOptions(theme),
        //   child: Icon(Icons.more_horiz),
        //   style: ElevatedButton.styleFrom(
        //     padding: EdgeInsets.all(0),
        //     // elevation: 0,
        //     // shadowColor: primaryOrange,
        //     primary: Colors.transparent,
        //     // shape: RoundedRectangleBorder(
        //     //   borderRadius: BorderRadius.circular(20.0),
        //     // )
        //     shape: CircleBorder(),
        //   ),
        // )
      ],
    );
  }

  _buildCaption(ThemeData theme, Content content) {
    if (content.contentCaption != null) {
      return ExpandableText(
        content.contentCaption,
        trimLines: 2,
        // style: theme.textTheme.bodyText1
      );
    } else {
      return Container();
    }
  }

  _buildContent(Content content) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: CachedNetworkImage(
        width: double.infinity,
        fit: BoxFit.contain,
        imageUrl: content.contentUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Skeleton.rectangular(
            height: 250,
            borderRadius: 20.0
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.1)
        )
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderDetails(theme, widget.content),
            SizedBox(height: 10),
            _buildCaption(theme, widget.content),
            SizedBox(height: 10),
            _buildContent(widget.content)
          ],
        )
      )
    );
  }
}

class PostSkeletonShimmer extends StatelessWidget {
  PostSkeletonShimmer({Key? key}) : super(key: key);

  Widget _buildHeaderDetails(BuildContext context) {
    return Row(
      children: [
        Skeleton.circular(
          width: 60,
          height: 60
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton.rectangular(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.6
            ),
            SizedBox(height: 5),
            Skeleton.rectangular(
              height: 15,
              width: MediaQuery.of(context).size.width * 0.3
            )
          ],
        )
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Skeleton.rectangular(
      height: 250,
      borderRadius: 20.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.1)
        )
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderDetails(context),
            SizedBox(height: 10),
            _buildContent(context)
          ],
        )
      )
    );
  }
}