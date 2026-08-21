import 'package:get/get.dart';

import '../models/settings_models.dart';

class SettingsController extends GetxController {
  final storeName = 'Toko Ritel Nusantara'.obs;
  final address = 'Jl. Merdeka No. 24, Makassar'.obs;
  final phone = '+62 812 3456 7890'.obs;
  final qrisImageName = 'QRIS Merchant Statis.png'.obs;
  final pinRequired = true.obs;
  final biometricEnabled = false.obs;
  final autoLockEnabled = true.obs;
  final cashierDiscountLimit = 10.obs;
  final users = <StoreUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    users.assignAll(const [
      StoreUser(
        id: 'u-01',
        name: 'Raih Owner',
        email: 'owner@toko.id',
        role: UserRole.owner,
        isActive: true,
      ),
      StoreUser(
        id: 'u-02',
        name: 'Sari Kasir',
        email: 'kasir@toko.id',
        role: UserRole.cashier,
        isActive: true,
      ),
      StoreUser(
        id: 'u-03',
        name: 'Budi Kasir',
        email: 'budi@toko.id',
        role: UserRole.cashier,
        isActive: false,
      ),
    ]);
  }

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

  void addUser(String name, String email, UserRole role) {
    if (name.isEmpty || email.isEmpty) return;

    users.add(
      StoreUser(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
        isActive: true,
      ),
    );
    Get.back<void>();
    Get.snackbar('Pengguna ditambahkan', name);
  }

  void toggleUserActive(StoreUser user) {
    final index = users.indexWhere((item) => item.id == user.id);
    if (index >= 0) users[index] = user.copyWith(isActive: !user.isActive);
  }

  void setDiscountLimit(int value) {
    cashierDiscountLimit.value = value.clamp(0, 50);
  }

  void logout() {
    Get.snackbar(
      'Keluar',
      'Autentikasi Firebase akan dihubungkan pada tahap berikutnya.',
    );
  }
}
