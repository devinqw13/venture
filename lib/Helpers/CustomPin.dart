import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(BuildContext context, String svgAssetLink, {Size size = const Size(30, 30), Color? color}) async {
  String svgString = await DefaultAssetBundle.of(context).loadString(
    svgAssetLink,
  );
  final drawableRoot = await svg.fromSvgString(
    svgString,
    'debug: $svgAssetLink',
    theme: SvgTheme(currentColor: color)
  );
  final ratio = ui.window.devicePixelRatio.ceil();
  final width = size.width.ceil() * ratio;
  final height = size.height.ceil() * ratio;
  final picture = drawableRoot.toPicture(
    size: Size(
      width.toDouble(),
      height.toDouble(),
    ),
  );
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final uInt8List = byteData!.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(uInt8List);
}

Future<BitmapDescriptor> getMarkerIcon(BuildContext context, String imagePath, {Size size = const Size(150, 150), Color? color}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    // canvas.drawRRect(
    //     RRect.fromRectAndCorners(
    //       Rect.fromLTWH(
    //           0.0,
    //           0.0,
    //           size.width,
    //           size.height
    //       ),
    //       topLeft: radius,
    //       topRight: radius,
    //       bottomLeft: radius,
    //       bottomRight: radius,
    //     ),
    //     shadowPaint);

    // Add border circle
    // canvas.drawRRect(
    //     RRect.fromRectAndCorners(
    //       Rect.fromLTWH(
    //           shadowWidth,
    //           shadowWidth,
    //           size.width - (shadowWidth * 2),
    //           size.height - (shadowWidth * 2)
    //       ),
    //       topLeft: radius,
    //       topRight: radius,
    //       bottomLeft: radius,
    //       bottomRight: radius,
    //     ),
    //     borderPaint);

    // Add tag circle
    // canvas.drawRRect(
    //     RRect.fromRectAndCorners(
    //       Rect.fromLTWH(
    //           size.width - tagWidth,
    //           0.0,
    //           tagWidth,
    //           tagWidth
    //       ),
    //       topLeft: radius,
    //       topRight: radius,
    //       bottomLeft: radius,
    //       bottomRight: radius,
    //     ),
    //     tagPaint);

    canvas.drawPath(
       Path(),
        Paint() 
        ..color= Colors.black.withAlpha(255)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, (3 * 0.57735 + 0.5))
    );

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: '1',
      style: TextStyle(fontSize: 20.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            size.width - tagWidth / 2 - textPainter.width / 2,
            tagWidth / 2 - textPainter.height / 2
        )
    );

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        imageOffset,
        imageOffset,
        size.width - (imageOffset * 2),
        size.height - (imageOffset * 2)
    );

    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    // ui.Image image = await getImageFromPath(imagePath);
    ui.Image image = await getImageFromAsset(context, imagePath, color: color);

    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
    );

    // Convert image to bytes
    final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
}

Future<ui.Image> getImageFromPath(String imagePath) async {
    File imageFile = File(imagePath);

    Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
}

Future<ui.Image> getImageFromAsset(BuildContext context, String svgAssetLink, {Size size = const Size(30, 30), Color? color}) async {
  String svgString = await DefaultAssetBundle.of(context).loadString(
    svgAssetLink,
  );
  final drawableRoot = await svg.fromSvgString(
    svgString,
    'debug: $svgAssetLink',
    theme: SvgTheme(currentColor: color)
  );
  final ratio = ui.window.devicePixelRatio.ceil();
  final width = size.width.ceil() * ratio;
  final height = size.height.ceil() * ratio;
  final picture = drawableRoot.toPicture(
    size: Size(
      width.toDouble(),
      height.toDouble(),
    ),
  );
  final image = await picture.toImage(width, height);

  return image;
}