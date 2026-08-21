import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_models.dart';

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
            subtitle: 'Kelola profil toko, pengguna, dan keamanan kasir',
          ),
          const SizedBox(height: 24),
          _BusinessProfileCard(
            controller: controller,
            nameController: nameController,
            addressController: addressController,
            phoneController: phoneController,
          ),
          const SizedBox(height: 16),
          const _SecurityCard(),
          const SizedBox(height: 16),
          _UsersCard(controller: controller),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTheme.labelCaps);
  }
}

class _BusinessProfileCard extends StatelessWidget {
  const _BusinessProfileCard({
    required this.controller,
    required this.nameController,
    required this.addressController,
    required this.phoneController,
  });

  final SettingsController controller;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: 'PROFIL TOKO'),
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
                decoration: const InputDecoration(labelText: 'Nomor telepon'),
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
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: 'KEAMANAN'),
            const SizedBox(height: 8),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.pinRequired.value,
                onChanged: (value) => controller.pinRequired.value = value,
                title: const Text('Wajib PIN kasir'),
                subtitle: const Text('PIN 4–6 digit setelah login'),
              ),
            ),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.biometricEnabled.value,
                onChanged: (value) => controller.biometricEnabled.value = value,
                title: const Text('Biometrik'),
                subtitle: const Text('Sidik jari atau wajah'),
              ),
            ),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.autoLockEnabled.value,
                onChanged: (value) => controller.autoLockEnabled.value = value,
                title: const Text('Kunci otomatis'),
                subtitle: const Text('Setelah 5 menit tidak aktif'),
              ),
            ),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Batas diskon kasir: ${controller.cashierDiscountLimit.value}%',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: controller.cashierDiscountLimit.value.toDouble(),
                    min: 0,
                    max: 50,
                    divisions: 50,
                    label: '${controller.cashierDiscountLimit.value}%',
                    onChanged: (value) =>
                        controller.setDiscountLimit(value.round()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersCard extends StatelessWidget {
  const _UsersCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: _SectionTitle(title: 'PENGGUNA')),
                FilledButton.tonalIcon(
                  onPressed: () => _showAddUserSheet(context),
                  icon: const Icon(Icons.person_add_alt_outlined),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => Column(
                children: controller.users.map((user) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(user.name.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(user.name),
                    subtitle: Text('${user.email} • ${user.roleLabel}'),
                    trailing: Switch(
                      value: user.isActive,
                      onChanged: (_) => controller.toggleUserActive(user),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserSheet(BuildContext context) {
    final name = TextEditingController();
    final email = TextEditingController();
    var role = UserRole.cashier;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tambah Pengguna',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Firebase Auth',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.cashier,
                        child: Text('Kasir'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.owner,
                        child: Text('Owner'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => role = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () =>
                        controller.addUser(name.text, email.text, role),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
