import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:venture/Screens/DashboardScreen/Components/Tabs/Home.dart';
import 'package:venture/Screens/DashboardScreen/Components/Tabs/Notification.dart';
import 'package:venture/Screens/DashboardScreen/Components/Tabs/Profile.dart';
import 'package:venture/Screens/DashboardScreen/Components/Tabs/Search.dart';
import 'package:venture/Screens/DashboardScreen/Components/Tabs/Map.dart';
import 'package:venture/Screens/DashboardScreen/Components/Tabs/SearchV2.dart';
// import 'package:venture/Screens/DashboardScreen/Components/Tabs/Circle.dart';
// import 'package:venture/Screens/DashboardScreen/Components/Tabs/Account.dart';

class HomeController extends GetxController {
  HomeController();

  late PageController pageController;
  late CarouselController carouselController;
  PageController? homeFeedController;

  var currentPage = 2.obs;
  var currentBanner = 0.obs;

  RxMap<dynamic, dynamic> messageTracker = {}.obs;
  RxList notificationTracker = [].obs;

  List<Widget> pages = [
   HomeTab(),
  //  SearchTab(),
   SearchTabV2(),
   MapTab(),
   NotificationTab(),
  //  CircleTab(),
   ProfileTab()
  //  AccountTab()
  ];

  @override
  void onInit() {
    pageController = PageController(initialPage: 2);
    carouselController = CarouselController();

    // getOffers();
    // getCategories();
    // getDiscountedProducts();
    super.onInit();
  }

  // void getOffers() {
  //   _offerProvider.getOffers().then((offers) {
  //     activeOffers.value = offers;
  //   });
  // }

  // void getCategories() {
  //   _categoryProvider.getCategories().then((categories) {
  //     this.categories.value = categories;
  //   });
  // }

  // void getDiscountedProducts() {
  //   _productProvider.getDiscountedProducts().then((products) {
  //     discountedProducts(products);
  //     print(products);
  //   });
  // }

  void goToTab(int page) {
    currentPage.value = page;
    pageController.jumpToPage(page);
  }

  void changeBanner(int index) {
    currentBanner.value = index;
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }
}