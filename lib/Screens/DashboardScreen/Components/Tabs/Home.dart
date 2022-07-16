import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';

class HomeTab extends GetView<HomeController> {
  HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        color: Colors.yellow,
        child: Center(
          child: Text('Home'),
        ),
      ),
    );
  }
}