import 'package:flutter_test/flutter_test.dart';
import 'package:mitugym_scanner_flutter/models/auth_session.dart';
import 'package:mitugym_scanner_flutter/models/pending_action.dart';

void main() {
  group('AuthSession Tests', () {
    test('should serialize and deserialize correctly', () {
      final now = DateTime.now();
      final session = AuthSession(
        email: 'test@example.com',
        apiKey: 'test-api-key-12345',
        userName: 'Test User',
        locationName: 'Test Gym',
        loginTime: now,
        lastValidated: now,
      );

      // Test toJson
      final json = session.toJson();
      expect(json['email'], 'test@example.com');
      expect(json['api_key'], 'test-api-key-12345');
      expect(json['user_name'], 'Test User');
      expect(json['location_name'], 'Test Gym');

      // Test fromJson
      final restored = AuthSession.fromJson(json);
      expect(restored.email, session.email);
      expect(restored.apiKey, session.apiKey);
      expect(restored.userName, session.userName);
      expect(restored.locationName, session.locationName);
    });

    test('should handle copyWith correctly', () {
      final session = AuthSession(
        email: 'test@example.com',
        apiKey: 'old-key',
        userName: 'Test User',
        locationName: 'Test Gym',
        loginTime: DateTime.now(),
      );

      final updated = session.copyWith(apiKey: 'new-key');
      expect(updated.apiKey, 'new-key');
      expect(updated.email, session.email); // unchanged
    });

    test('should detect when revalidation is needed', () {
      // Recent validation
      final recentSession = AuthSession(
        email: 'test@example.com',
        apiKey: 'test-key',
        userName: 'Test',
        locationName: 'Gym',
        loginTime: DateTime.now(),
        lastValidated: DateTime.now().subtract(const Duration(hours: 12)),
      );
      expect(recentSession.needsRevalidation(), false);

      // Old validation (over 24 hours)
      final oldSession = AuthSession(
        email: 'test@example.com',
        apiKey: 'test-key',
        userName: 'Test',
        locationName: 'Gym',
        loginTime: DateTime.now(),
        lastValidated: DateTime.now().subtract(const Duration(hours: 25)),
      );
      expect(oldSession.needsRevalidation(), true);

      // Never validated
      final neverValidated = AuthSession(
        email: 'test@example.com',
        apiKey: 'test-key',
        userName: 'Test',
        locationName: 'Gym',
        loginTime: DateTime.now(),
      );
      expect(neverValidated.needsRevalidation(), true);
    });
  });

  group('PendingAction Tests', () {
    test('should create with UUID', () {
      final action = PendingAction.create(
        qrCode: 'test-qr-12345',
        apiKey: 'test-api-key',
      );

      expect(action.id, isNotEmpty);
      expect(action.qrCode, 'test-qr-12345');
      expect(action.apiKey, 'test-api-key');
      expect(action.synced, false);
      expect(action.retryCount, 0);
      expect(action.type, 'auto');
    });

    test('should convert to and from map', () {
      final action = PendingAction.create(
        qrCode: 'test-qr',
        apiKey: 'test-key',
      );

      final map = action.toMap();
      expect(map['qr_code'], 'test-qr');
      expect(map['synced'], 0);

      final restored = PendingAction.fromMap(map);
      expect(restored.id, action.id);
      expect(restored.qrCode, action.qrCode);
      expect(restored.synced, action.synced);
    });

    test('should track retry logic correctly', () {
      final action = PendingAction.create(
        qrCode: 'test-qr',
        apiKey: 'test-key',
      );

      // Can retry initially
      expect(action.canRetry(), true);
      expect(action.retryCount, 0);

      // After incrementing
      final retried = action.incrementRetry(errorMessage: 'Network error');
      expect(retried.retryCount, 1);
      expect(retried.error, 'Network error');
      expect(retried.canRetry(), true);

      // After max retries (5)
      var maxRetried = action;
      for (int i = 0; i < 5; i++) {
        maxRetried = maxRetried.incrementRetry();
      }
      expect(maxRetried.canRetry(), false);
      expect(maxRetried.retryCount, 5);
    });

    test('should mark as synced', () {
      final action = PendingAction.create(
        qrCode: 'test-qr',
        apiKey: 'test-key',
      );

      final synced = action.markSynced();
      expect(synced.synced, true);
      expect(synced.error, null);
    });

    test('should handle copyWith', () {
      final action = PendingAction.create(
        qrCode: 'test-qr',
        apiKey: 'test-key',
      );

      final updated = action.copyWith(
        synced: true,
        retryCount: 3,
        error: 'Test error',
      );

      expect(updated.synced, true);
      expect(updated.retryCount, 3);
      expect(updated.error, 'Test error');
      expect(updated.id, action.id); // unchanged
    });
  });
}

