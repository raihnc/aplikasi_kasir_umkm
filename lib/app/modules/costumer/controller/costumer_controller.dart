import 'package:aplikasi_kasir_umkm/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomersController extends GetxController {
  final customers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomers();
  }

  void _loadCustomers() {
    customers.assignAll([
      {'id': 'c1', 'name': 'Bapak Budi', 'phone': '08123456789', 'debt_balance': 150000},
      {'id': 'c2', 'name': 'Ibu Siti', 'phone': '08987654321', 'debt_balance': 0},
    ]);
  }

  void receivePayment(String customerName) {
    Get.snackbar('Pelunasan Piutang', 'Membuka dialog pelunasan untuk $customerName...',
      backgroundColor: AppTheme.primary,
      colorText: Colors.white,
    );
  }
}