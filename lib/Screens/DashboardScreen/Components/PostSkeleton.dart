import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Helpers/TimeFormat.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Helpers/SizeConfig.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostSkeleton extends StatefulWidget{
  final Content content;
  PostSkeleton({Key? key, required this.content}) : super(key: key);

  @override
  _PostSkeleton createState() => _PostSkeleton();
}

class _PostSkeleton extends State<PostSkeleton> {

  Widget _buildHeaderDetails(Content content) {
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
        ElevatedButton(
          onPressed: () => print("MORE OPTIONS"),
          child: Icon(Icons.more_horiz),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0),
            // elevation: 0,
            // shadowColor: primaryOrange,
            primary: Colors.transparent,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(20.0),
            // )
            shape: CircleBorder(),
          ),
        )
      ],
    );
  }

  // _buildCaption(Content content) {
  //   return Flexible(
  //     child: Text(content.contentCaption!)
  //   );
  // }

  _buildContent(Content content) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      // child: Image.network(
      //     content.contentUrl,
      //     // height: 150.0,
      //     // width: 100.0,
      // ),
      child: CachedNetworkImage(
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
          children: [
            _buildHeaderDetails(widget.content),
            // _buildCaption(widget.content),
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