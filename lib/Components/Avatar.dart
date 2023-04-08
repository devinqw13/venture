import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyAvatar extends StatelessWidget {
  final double? size;
  final String? photo;

  const MyAvatar({Key? key, this.size, @required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 0.1,
            ),
            shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: CircleAvatar(
            radius: size,
            // backgroundImage: NetworkImage(photo!),
            backgroundImage: CachedNetworkImageProvider(photo!),
          ),
        ),
      ),
    );
  }
}