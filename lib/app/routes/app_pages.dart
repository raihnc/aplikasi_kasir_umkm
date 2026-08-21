import 'package:aplikasi_kasir_umkm/app/modules/home/bindings/home_binding.dart';
import 'package:aplikasi_kasir_umkm/app/modules/main/view/main_view.dart';
import 'package:get/get.dart';

class AppPages {
  static final INITIAL = Routes.MAIN;

  static final routes = [
    GetPage(
      name: Routes.MAIN,
      page: () => MainView(),
      bindings: [
        // Load semua controller yang dibutuhkan untuk IndexedStack
        MainBinding(),
        HomeBinding(),
        ProductsBinding(),
        CustomersBinding(),
        ReportsBinding(),
      ],
    ),
  ];
}
