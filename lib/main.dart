import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(const AplikasiKasirUmkmApp());
}

class AplikasiKasirUmkmApp extends StatelessWidget {
  const AplikasiKasirUmkmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aplikasi Kasir UMKM',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: AppTheme.light(),
    );
  }
}
