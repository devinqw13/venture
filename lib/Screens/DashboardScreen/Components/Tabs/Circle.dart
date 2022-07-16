import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';

class CircleTab extends GetView<HomeController> {
  CircleTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        color: Colors.green,
        child: Center(
          child: Text('Circle'),
        ),
      ),
    );
  }
}