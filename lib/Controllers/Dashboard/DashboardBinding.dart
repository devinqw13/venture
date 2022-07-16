import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:get/get.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<OfferRepository>(() => OfferRepository(Get.find()));
    // Get.lazyPut<OfferProvider>(() => OfferProvider(Get.find()));

    // Get.lazyPut<CategoryRepository>(() => CategoryRepository(Get.find()));
    // Get.lazyPut<CategoryProvider>(() => CategoryProvider(Get.find()));
    
    // Get.lazyPut<ProductRepository>(() => ProductRepository(Get.find()));
    // Get.lazyPut<ProductProvider>(() => ProductProvider(Get.find()));
    
    Get.lazyPut<HomeController>(() => HomeController());
  }
}