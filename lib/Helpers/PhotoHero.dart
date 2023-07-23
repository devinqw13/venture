import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PhotoHero extends StatefulWidget {
  final String tag;
  final String photoUrl;
  final VoidCallback? onTap;
  final Size? size;
  PhotoHero({Key? key, required this.tag, required this.photoUrl, this.onTap, this.size}) : super(key: key);

  @override
  _PhotoHero createState() => _PhotoHero();
}

class _PhotoHero extends State<PhotoHero> with AutomaticKeepAliveClientMixin<PhotoHero> {
  Uint8List? uint8list;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Hero(
      transitionOnUserGestures: true,
      tag: widget.tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: lookupMimeType(widget.photoUrl)!.contains("video") ?
          FutureBuilder(
            future: VideoThumbnail.thumbnailData(
              video: widget.photoUrl,
              imageFormat: ImageFormat.PNG,
              timeMs: 2000,
              maxWidth: widget.size?.height.toInt() ?? 130, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
              // quality: 1000,
            ),
            builder: (context, i) {
              if(i.hasData) {
                return Image.memory(
                  i.data!,
                  width: widget.size?.width,
                  height: widget.size?.height,
                  fit: BoxFit.cover,
                );
              }else {
                return Skeleton.rectangular(
                  height: widget.size?.height ?? 130,
                  // borderRadius: 20.0
                );
              }
            }
          )
          : CachedNetworkImage(
            fit: BoxFit.cover,
            width: widget.size?.width,
            height: widget.size?.height,
            imageUrl: widget.photoUrl,
            progressIndicatorBuilder: (context, url, downloadProgress) {
              return Skeleton.rectangular(
                height: widget.size?.height ?? 130,
                // borderRadius: 20.0
              );
            }
          )
        )
      )
    );
  }
}