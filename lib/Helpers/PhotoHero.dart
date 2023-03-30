import 'package:flutter/material.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key? key, required this.tag, required this.photoUrl, this.onTap, this.size}) : super(key: key);

  final String tag;
  final String photoUrl;
  final VoidCallback? onTap;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            width: size?.width,
            height: size?.height,
            imageUrl: photoUrl,
            progressIndicatorBuilder: (context, url, downloadProgress) {
              return Skeleton.rectangular(
                height: size?.height ?? 130,
                // borderRadius: 20.0
              );
            }
          )
        )
      )
    );
  }
}