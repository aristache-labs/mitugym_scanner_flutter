import 'package:uuid/uuid.dart';

/// Pending action model for offline queue
/// Stores QR scan actions that need to be synced when online
class PendingAction {
  final String id;
  final String type; // 'auto' for check-in/out
  final String qrCode;
  final DateTime timestamp;
  final String apiKey;
  final bool synced;
  final int retryCount;
  final String? error;

  const PendingAction({
    required this.id,
    required this.type,
    required this.qrCode,
    required this.timestamp,
    required this.apiKey,
    this.synced = false,
    this.retryCount = 0,
    this.error,
  });

  /// Create a new pending action with generated UUID
  factory PendingAction.create({
    required String qrCode,
    required String apiKey,
    String type = 'auto',
  }) {
    return PendingAction(
      id: const Uuid().v4(),
      type: type,
      qrCode: qrCode,
      timestamp: DateTime.now(),
      apiKey: apiKey,
      synced: false,
      retryCount: 0,
    );
  }

  /// Create from database map
  factory PendingAction.fromMap(Map<String, dynamic> map) {
    return PendingAction(
      id: map['id'] as String,
      type: map['action'] as String,
      qrCode: map['qr_code'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      apiKey: map['api_key'] as String,
      synced: (map['synced'] as int) == 1,
      retryCount: map['retry_count'] as int? ?? 0,
      error: map['error'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'qr_code': qrCode,
      'action': type,
      'api_key': apiKey,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
      'retry_count': retryCount,
      'error': error,
    };
  }

  /// Create a copy with updated fields
  PendingAction copyWith({
    String? id,
    String? type,
    String? qrCode,
    DateTime? timestamp,
    String? apiKey,
    bool? synced,
    int? retryCount,
    String? error,
  }) {
    return PendingAction(
      id: id ?? this.id,
      type: type ?? this.type,
      qrCode: qrCode ?? this.qrCode,
      timestamp: timestamp ?? this.timestamp,
      apiKey: apiKey ?? this.apiKey,
      synced: synced ?? this.synced,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }

  /// Check if action can be retried (less than 5 attempts)
  bool canRetry() => retryCount < 5;

  /// Increment retry count
  PendingAction incrementRetry({String? errorMessage}) {
    return copyWith(
      retryCount: retryCount + 1,
      error: errorMessage,
    );
  }

  /// Mark as synced
  PendingAction markSynced() {
    return copyWith(synced: true, error: null);
  }
}

