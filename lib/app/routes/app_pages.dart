import 'package:get/get.dart';

import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.main;

  static final routes = [
    GetPage(name: AppRoutes.main, page: MainView.new, binding: MainBinding()),
  ];
}
