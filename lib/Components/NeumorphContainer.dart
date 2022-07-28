import 'package:flutter/material.dart';

class NeumorphContainer extends StatelessWidget {
  // NeumorphContainer({Key? key, this.width, this.height, this.child}) : super(key: key);

  final double? width, height;
  final Widget? child;
  final List<Color> colors;
  final bool isFlat;

  const NeumorphContainer.concave({Key? key,
    this.width,
    this.height,
    this.child
  }): colors = const [Color(0xffe6e6e6), Color(0xffffffff)],
      isFlat = false,
      super(key: key);

  const NeumorphContainer.convex({Key? key,
    this.width,
    this.height,
    this.child
  }): colors = const [Color(0xffffffff),Color(0xffe6e6e6)],
      isFlat = false,
      super(key: key);

  const NeumorphContainer.flat({Key? key,
    this.width,
    this.height,
    this.child
  }): colors = const [],
      isFlat = true,
      super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isFlat ? Colors.white : null,
        gradient: isFlat ? null : LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: colors
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