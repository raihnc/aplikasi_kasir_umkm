import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase akan masuk di sini (Firebase.initializeApp)

  runApp(
    GetMaterialApp(
      title: "Aplikasi Kasir UMKM",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppTheme.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
