import 'package:get/get.dart';

import '../../home/bindings/home_binding.dart';
import '../../inventory/bindings/inventory_binding.dart';
import '../../pos/bindings/pos_binding.dart';
import '../../product/bindings/product_binding.dart';
import '../../reports/bindings/reports_binding.dart';
import '../../settings/bindings/settings_binding.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(MainController.new);
    HomeBinding().dependencies();
    ProductBinding().dependencies();
    InventoryBinding().dependencies();
    PosBinding().dependencies();
    ReportsBinding().dependencies();
    SettingsBinding().dependencies();
  }
}
