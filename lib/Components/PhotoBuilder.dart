import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/lru_map.dart';

class PhotoBuilder extends StatefulWidget {
  final AssetEntity entity;
  final double size;

  const PhotoBuilder({
    Key? key,
    this.size = 130,
    required this.entity,
  }) : super(key: key);
  @override
  _PhotoBuilder createState() => _PhotoBuilder();
}

class _PhotoBuilder extends State<PhotoBuilder> {
  @override
  Widget build(BuildContext context) {
    final item = widget.entity;
    final size = 130;
    final u8List = ImageLruCache.getData(item, widget.size.toInt());
    Widget image;

    if (u8List != null) {
      return Image.memory(
        u8List,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      );
    } else {
      image = FutureBuilder(
        future: item.thumbnailDataWithSize(ThumbnailSize(size, size)),
        builder: (context, snapshot) {
          Widget w;
          if (snapshot.hasError) {
            w = Center(
              child: Text("load error, error: ${snapshot.error}"),
            );
          }
          if (snapshot.hasData) {
            ImageLruCache.setData(item, size, snapshot.data as Uint8List);
            w = Image.memory(
              snapshot.data as Uint8List,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover
            );
          } else {
            w = Center(
              child: CircularProgressIndicator(
                color: primaryOrange,
              )
            );
          }
          return w;
        },
      );
    }

    return image;
  }

  @override
  void didUpdateWidget(PhotoBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entity.id != oldWidget.entity.id) {
      setState(() {});
    }
  }
}

// class PhotoBuilderV2 extends StatefulWidget {
//   final AssetEntity entity;

//   const PhotoBuilderV2({
//     Key? key,
//     required this.entity,
//   }) : super(key: key);
//   @override
//   _PhotoBuilderV2 createState() => _PhotoBuilderV2();
// }

// class _PhotoBuilderV2 extends State<PhotoBuilderV2> {
//   Uint8List? bytes;
//   final size = 130;
//   var bt;

//   @override
//   void initState() {
//     super.initState();

//     // _getBytes();
//     bt = widget.entity.originBytes;
//   }

//   _getBytes() async {
//     print(widget.entity);
//     print("GET BYTES CALLED");
//     Uint8List? bytes = await widget.entity.originBytes;
//     if (bytes != null) {
//       print("NOT NULL");
//     } else {
//       print("IS NULL");
//     }
//     return bytes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _getBytes(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return Image.memory(
//             bytes!,
//             width: size.toDouble(),
//             height: size.toDouble(),
//             fit: BoxFit.cover,
//           );
//         } else {
//           return Center(
//             child: CircularProgressIndicator(
//               color: primaryOrange,
//             )
//           );
//         }
//       }
//     );
//     // if (bytes != null) {
//     //   return Image.memory(
//     //     bytes!,
//     //     width: size.toDouble(),
//     //     height: size.toDouble(),
//     //     fit: BoxFit.cover,
//     //   );
//     // } else {
//     //   return Container();
//     // }
//   }

//   @override
//   void didUpdateWidget(PhotoBuilderV2 oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.entity.id != oldWidget.entity.id) {
//       setState(() {});
//     }
//   }
// }

class PhotoBuilderV2 extends StatefulWidget {
  final AssetEntity entity;

  const PhotoBuilderV2({
    Key? key,
    required this.entity,
  }) : super(key: key);
  @override
  _PhotoBuilderV2 createState() => _PhotoBuilderV2();
}

class _PhotoBuilderV2 extends State<PhotoBuilderV2> {
  Uint8List? bytes;
  final size = 130;
  var bt;

  @override
  void initState() {
    super.initState();
    bt = widget.entity.originBytes;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.entity;
    final size = 130;
    final u8List = widget.entity.originBytes;
    Widget image;

    if (bt != null) {
      return Image.memory(
        bt,
        width: size.toDouble(),
        height: size.toDouble(),
        fit: BoxFit.cover,
      );
    } else {
      image = FutureBuilder(
        future: item.thumbnailDataWithSize(ThumbnailSize(size, size)),
        builder: (context, snapshot) {
          Widget w;
          if (snapshot.hasError) {
            w = Center(
              child: Text("load error, error: ${snapshot.error}"),
            );
          }
          if (snapshot.hasData) {
            ImageLruCache.setData(item, size, snapshot.data as Uint8List);
            w = FittedBox(
              fit: BoxFit.cover,
              child: Image.memory(
                snapshot.data as Uint8List,
              ),
            );
          } else {
            w = Center(
              child: CircularProgressIndicator(
                color: primaryOrange,
              )
            );
          }
          return w;
        },
      );
    }

    return image;
  }

  @override
  void didUpdateWidget(PhotoBuilderV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entity.id != oldWidget.entity.id) {
      setState(() {});
    }
  }
}