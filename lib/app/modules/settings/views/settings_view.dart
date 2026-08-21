import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsController controller;
  late final TextEditingController nameController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SettingsController>();
    nameController = TextEditingController(text: controller.storeName.value);
    addressController = TextEditingController(text: controller.address.value);
    phoneController = TextEditingController(text: controller.phone.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Pengaturan',
            subtitle: 'Kelola profil toko dan QRIS statis',
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PROFIL TOKO', style: AppTheme.labelCaps),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama toko'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Alamat'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor telepon',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.qr_code_2),
                        title: const Text('QRIS statis merchant'),
                        subtitle: Text(controller.qrisImageName.value),
                        trailing: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Ganti'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => controller.saveBusinessProfile(
                        name: nameController.text,
                        address: addressController.text,
                        phone: phoneController.text,
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Simpan Profil'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
