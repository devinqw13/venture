import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:venture/Components/DropShadow.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/lru_map.dart';
import 'package:video_player/video_player.dart';

class PhotoBuilder extends StatefulWidget {
  final AssetEntity entity;
  final double size;
  final bool selected;
  final bool multiSelect;
  final bool highlighted;
  final int index;

  const PhotoBuilder({
    Key? key,
    this.size = 130,
    required this.entity,
    this.selected = false,
    this.multiSelect = false,
    this.highlighted = false,
    this.index = 0
  }) : super(key: key);
  @override
  _PhotoBuilder createState() => _PhotoBuilder();
}

class _PhotoBuilder extends State<PhotoBuilder> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.entity;
    final size = 130;
    final u8List = ImageLruCache.getData(item, widget.size.toInt());
    Widget image;

    if (u8List != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              u8List,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
            )
          ),
          widget.highlighted ? Container(color: ColorConstants.gray50.withOpacity(0.4)) : Container(),

          widget.entity.type == AssetType.video ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${(widget.entity.duration ~/ 60).toString().padLeft(1, '0')}:${(widget.entity.duration % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            )
          ) : Container(),

          widget.multiSelect ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 22,
                width: 22,
                child: widget.selected ? 
                Text(widget.index.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white)) : Text(""),
                decoration: BoxDecoration(
                  color: widget.selected ? Colors.blue : ColorConstants.gray50.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.selected ? Colors.blue : Colors.white
                  )
                ),
              )
            ) 
          ): Container()
        ],
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
            w = Stack(
              children: [
                Image.memory(
                  snapshot.data as Uint8List,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.cover
                ),
                widget.multiSelect ? Container(
                  decoration: BoxDecoration(
                    color: widget.selected ? Colors.blue : ColorConstants.gray50.withOpacity(0.3)
                  ),
                ) : Container()
              ],
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

class OverlapPhotos extends StatefulWidget {
  final List<File?> files;
  final double overlap;
  final double radius;

  const OverlapPhotos({
    Key? key,
    this.overlap = 10.0,
    this.radius = 40.0,
    required this.files,
  }) : super(key: key);
  @override
  _OverlapPhotos createState() => _OverlapPhotos();
}

class _OverlapPhotos extends State<OverlapPhotos> {
  List items = [];

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackLayers = List<Widget>.generate(widget.files.length > 3 ? 3 : widget.files.length, (index) {

      String? fileType = lookupMimeType(widget.files[index]!.path);

      if(fileType != null && fileType.contains('video')) {
        return DropShadow(
          sigma: 5,
          offset: Offset(5, 5),
          child: Padding(
            padding: EdgeInsets.fromLTRB(index.toDouble() * widget.overlap, 0, 0, 0),
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                child: Icon(Icons.play_arrow_rounded),
                radius: widget.radius-0.5,
              )
            )
          )
        );
      }else {
        return DropShadow(
          sigma: 5,
          offset: Offset(5, 5),
          child: Padding(
            padding: EdgeInsets.fromLTRB(index.toDouble() * widget.overlap, 0, 0, 0),
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                backgroundImage: FileImage(
                  widget.files[index]!,
                ),
                radius: widget.radius-0.5,
              )
            )
          )
        );
      }
    });

    return Stack(
      children: stackLayers
    );
  }

  // @override
  // void didUpdateWidget(OverlapPhotos oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.files != oldWidget.files) {
  //     setState(() {});
  //   }
  // }
}