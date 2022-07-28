import 'package:flutter/material.dart';

class ConcaveWidget extends StatelessWidget {
  ConcaveWidget({Key? key, this.width, this.height, this.child}) : super(key: key);

  final double? width, height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: [
            Color(0xffe6e6e6),
            Color(0xffffffff)
          ]
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Color(0xffcccccc),
            blurRadius: 40,
            offset: Offset(20, 20)
          ),
          BoxShadow(
            color: Color(0xffffffff),
            blurRadius: 40,
            offset: Offset(-20, -20)
          )
        ]
      ),
      child: child
    );
  }
}