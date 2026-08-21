import 'package:get/get.dart';

class SettingsController extends GetxController {
  final storeName = 'Toko Ritel Nusantara'.obs;
  final address = 'Jl. Merdeka No. 24, Makassar'.obs;
  final phone = '+62 812 3456 7890'.obs;
  final qrisImageName = 'QRIS Merchant Statis.png'.obs;

  void saveBusinessProfile({
    required String name,
    required String address,
    required String phone,
  }) {
    if (name.trim().isEmpty) {
      Get.snackbar('Gagal menyimpan', 'Nama toko wajib diisi.');
      return;
    }

    storeName.value = name.trim();
    this.address.value = address.trim();
    this.phone.value = phone.trim();
    Get.snackbar('Profil disimpan', 'Data toko berhasil diperbarui.');
  }
}
