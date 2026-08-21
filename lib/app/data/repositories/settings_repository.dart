import '../local/app_database.dart';
import 'base_repository.dart';

class BusinessProfile {
  const BusinessProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.qrisImageUrl,
  });

  final String name;
  final String address;
  final String phone;
  final String qrisImageUrl;
}

class SettingsRepository extends BaseRepository {
  const SettingsRepository(super.database);

  BusinessProfile load() {
    final row = database.database
        .select('SELECT * FROM businesses LIMIT 1')
        .first;
    return BusinessProfile(
      name: row['name'] as String,
      address: row['address'] as String,
      phone: row['phone'] as String,
      qrisImageUrl: row['qris_image_url'] as String,
    );
  }

  void saveProfile({
    required String name,
    required String address,
    required String phone,
    String? qrisImageUrl,
  }) {
    final id = businessId;
    final now = AppDatabase.timestamp();
    final before = _rawBusiness();
    database.database.execute(
      '''UPDATE businesses
         SET name = ?, address = ?, phone = ?,
             qris_image_url = COALESCE(?, qris_image_url), updated_at = ?
         WHERE id = ?''',
      [name, address, phone, qrisImageUrl, now, id],
    );
    final after = _rawBusiness();
    database.enqueueSync(
      businessId: id,
      entityType: 'businesses',
      entityId: id,
      payload: after,
    );
    audit(
      action: 'update',
      entityType: 'business',
      entityId: id,
      before: before,
      after: after,
    );
  }

  Map<String, Object?> _rawBusiness() {
    return Map<String, Object?>.from(
      database.database.select('SELECT * FROM businesses LIMIT 1').first,
    );
  }
}
