import 'dart:convert';

import '../../../app/data/local/app_database.dart';

abstract class BaseRepository {
  const BaseRepository(this.database);

  final AppDatabase database;

  String get businessId {
    final row = database.database
        .select('SELECT id FROM businesses LIMIT 1')
        .first;
    return row['id'] as String;
  }

  String get currentUserId {
    final row = database.database.select('''
        SELECT uid FROM app_users
        WHERE business_id = ? AND is_active = 1
        ORDER BY CASE role WHEN 'owner' THEN 0 ELSE 1 END
        LIMIT 1
      ''').first;
    return row['uid'] as String;
  }

  void audit({
    required String action,
    required String entityType,
    required String entityId,
    Map<String, Object?> before = const {},
    Map<String, Object?> after = const {},
    DateTime? occurredAt,
  }) {
    final now = AppDatabase.timestamp(occurredAt);
    final id = database.newId();
    final business = businessId;
    database.database.execute(
      '''INSERT INTO audit_logs
         (id, business_id, actor_id, action, entity_type, entity_id,
          before_json, after_json, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        id,
        business,
        currentUserId,
        action,
        entityType,
        entityId,
        jsonEncode(before),
        jsonEncode(after),
        now,
      ],
    );
    database.enqueueSync(
      businessId: business,
      entityType: 'audit_logs',
      entityId: id,
      payload: {
        'actor_id': currentUserId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'before': before,
        'after': after,
        'created_at': now,
      },
    );
  }
}
