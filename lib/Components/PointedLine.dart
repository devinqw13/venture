import 'package:flutter/material.dart';

class PointedLine extends StatelessWidget {
  final Color color;
  final double height;

  PointedLine({Key? key,
    this.color = Colors.grey,
    this.height = 1.0
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter:
        PointedLinePainter(color),
    );
  }
}

class PointedLinePainter extends CustomPainter {
  final Color color;

  PointedLinePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height / 2, size.width, 0);
    path.quadraticBezierTo(size.width / 2, -size.height / 2, 0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}