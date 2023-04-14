import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(BuildContext context, String svgAssetLink, {Size size = const Size(30, 30), Color color = const Color(0xFF000000)}) async {
  String svgString = await DefaultAssetBundle.of(context).loadString(
    svgAssetLink,
  );

  final PictureInfo pictureInfo = await vg.loadPicture(
    SvgStringLoader(
      svgString,
      theme: SvgTheme(currentColor: color)
    ),
    context
  );
  final ratio = ui.window.devicePixelRatio.ceil();
  final width = size.width.ceil() * ratio;
  final height = size.height.ceil() * ratio;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  canvas.scale(width / pictureInfo.size.width, height / pictureInfo.size.height);
  canvas.drawPicture(pictureInfo.picture);
  final ui.Picture scaledPicture = recorder.endRecording();
  final image = await scaledPicture.toImage(width, height);

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final uInt8List = byteData!.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(uInt8List);
}

Future<BitmapDescriptor> getMarkerIconV2(
  BuildContext context,
  String? imagePath,
  {
    Size size = const Size(130, 130),
    Color pinColor = const Color(0xFF000000),
    Color imageColor = const Color(0xFF000000)
  }
) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Radius radius = Radius.circular(size.width / 2);

  final Paint paint = Paint()
    ..color = pinColor
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;
  final double triangleH = 20;
  final double triangleW = 25.0;
  // Multiply by double < 1.0 to account any other widgets such as pin title 
  final double width = size.width - triangleH;
  final double height = size.height - triangleH;

  // Add Shadow
  var shadowPath = Path();
  shadowPath.addOval(
    Rect.fromLTWH(0, 0, width, height)
  );
  canvas.drawShadow(shadowPath, Color(0xff000000), 3, true);

  // Add tag text
  // TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  // textPainter.text = TextSpan(
  //   text: 'TEST PIN',
  //   style: TextStyle(fontSize: 15, color: Colors.red),
  // );

  // textPainter.layout();
  // textPainter.paint(
  //     canvas,
  //     Offset(
  //       (width - textPainter.width) * 0.5,
  //       height + triangleH
  //     )
  // );

  // Add circle w/ triangle arrow
  final Path trianglePath = Path()
    ..moveTo(width / 2 - triangleW / 2, height)
    ..lineTo(width / 2, triangleH + height)
    ..lineTo(width / 2 + triangleW / 2, height)
    ..lineTo(width / 2 - triangleW / 2, height);
  canvas.drawPath(trianglePath, paint);
  final Rect rect = Rect.fromLTRB(0, 0, width, height);
  final RRect outer = RRect.fromRectAndCorners(
    rect,
    topLeft: radius,
    topRight: radius,
    bottomLeft: radius,
    bottomRight: radius,
  );
  canvas.drawRRect(outer, paint);

  if(imagePath != null) {
    // Oval for the image
    Rect oval = Rect.fromLTWH(
        (width * 0.4) * 0.5,
        (height * 0.4) * 0.5,
        (width * 0.6),
        (height * 0.6)
    );

    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    // ui.Image image = await getImageFromPath(imagePath);
    ui.Image image = await getImageFromAsset(context, imagePath, color: imageColor);

    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);
  }

  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size.width.toInt() - triangleH.toInt(),
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

Future<ui.Image> getImageFromAsset(BuildContext context, String svgAssetLink, {Size size = const Size(30, 30), Color color = const Color(0xFF000000)}) async {
  final PictureInfo pictureInfo = await vg.loadPicture(
    SvgAssetLoader(
      svgAssetLink,
      theme: SvgTheme(currentColor: Colors.red)
    ),
    null
  );

  final ratio = ui.window.devicePixelRatio.ceil();
  final width = size.width.ceil() * ratio;
  final height = size.height.ceil() * ratio;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  final colorFilter = ui.ColorFilter.mode(color, BlendMode.srcATop);

  canvas.scale(width / pictureInfo.size.width, height / pictureInfo.size.height);
  canvas.saveLayer(Offset.zero & Size(width.toDouble(), height.toDouble()), Paint()..colorFilter = colorFilter);
  canvas.drawPicture(pictureInfo.picture);
  final ui.Picture scaledPicture = recorder.endRecording();
  final image = await scaledPicture.toImage(width, height);

  // final ui.Image image = await pictureInfo.picture.toImage(
  //   width,
  //   height
  // );
  
  return image;
}