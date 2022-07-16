import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';

class MapTab extends GetView<HomeController> {
  MapTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        color: Colors.blue,
        child: Center(
          child: Text('Map'),
        ),
      ),
    );
  }
}