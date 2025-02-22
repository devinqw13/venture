import 'package:flutter/material.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/PinScreen/Components/PinSkeleton.dart';

class PinScreen extends StatefulWidget {
  final int? pinKey;
  final Pin? pin;
  PinScreen({Key? key, this.pinKey, this.pin}) : super(key: key);

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
          widget.pin == null ? FutureBuilder<List<Pin>>(
            future: getMapPins(context, pinKey: widget.pinKey.toString(), ventureCurrentUser: VenUser().userKey.value),
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return CircularProgressIndicator(color: primaryOrange);
              }else {
                return PinSkeleton(pin: snapshot.data![0], enableBackButton: true);
              }
            }
          ) : PinSkeleton(pin: widget.pin!, enableBackButton: true)
        ]
      )
    );
  }
}