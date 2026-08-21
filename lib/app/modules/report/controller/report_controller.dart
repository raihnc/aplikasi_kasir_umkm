import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsController extends GetxController {
  // Observables untuk ringkasan
  final omzet = 2500000.0.obs;
  final labaKotor = 750000.0.obs;
  final totalTransaksi = 42.obs;

  final recentTransactions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRecentTransactions();
  }

  void _loadRecentTransactions() {
    recentTransactions.assignAll([
      {
        'id': 'TRX-001',
        'date': '2026-08-21 10:30',
        'total': 125000,
        'profit': 25000,
        'method': 'Tunai',
      },
      {
        'id': 'TRX-002',
        'date': '2026-08-21 11:15',
        'total': 65000,
        'profit': 5000,
        'method': 'Piutang',
      },
    ]);
  }

  void exportToExcel() {
    // Implementasi package 'excel' akan diletakkan di sini
    Get.snackbar(
      'Ekspor Berhasil',
      'Laporan berhasil diekspor ke format .xlsx',
      backgroundColor: const Color(0xFF064E3B), // AppTheme.primary
      colorText: const Color(0xFFFFFFFF),
    );
  }
}
