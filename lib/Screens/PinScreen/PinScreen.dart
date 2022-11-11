import 'package:flutter/material.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Screens/PinScreen/Components/PinSkeleton.dart';

class PinScreen extends StatefulWidget {
  final int pinKey;
  PinScreen({Key? key, required this.pinKey}) : super(key: key);

  @override
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<Pin>>(
            future: getMapPins(context, pinKey: widget.pinKey.toString()),
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return CircularProgressIndicator(color: primaryOrange);
              }else {
                return PinSkeleton(pin: snapshot.data![0], enableBackButton: true);
              }
            }
          )
        ]
      )
    );
  }
}