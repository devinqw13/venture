import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final int length;
  final int index;

  const Indicator({Key? key, required this.length, required this.index}) : super(key: key);

  _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 50 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade500,
        borderRadius: BorderRadius.circular(5)
      ),
    );
  }

  List<Widget> buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i<length; i++) {
      if (index == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: buildIndicator(),
      ),
    );
  }

}