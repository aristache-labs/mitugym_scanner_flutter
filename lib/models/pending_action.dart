import 'package:uuid/uuid.dart';

/// Pending action model for offline queue
/// Stores QR scan actions that need to be synced when online
class PendingAction {
  final String id;
  final String type; // 'auto' for check-in/out
  final String qrCode; // Full QR code (for online) or just member_id (for offline)
  final String memberId; // Extracted member ID
  final DateTime timestamp;
  final String apiKey;
  final bool synced;
  final int retryCount;
  final String? error;
  final bool isOfflineScan; // Flag to indicate this was scanned offline

  const PendingAction({
    required this.id,
    required this.type,
    required this.qrCode,
    required this.memberId,
    required this.timestamp,
    required this.apiKey,
    this.synced = false,
    this.retryCount = 0,
    this.error,
    this.isOfflineScan = false,
  });

  /// Create a new pending action with generated UUID
  factory PendingAction.create({
    required String qrCode,
    required String apiKey,
    String type = 'auto',
    bool isOfflineScan = false,
  }) {
    // Extract member ID from QR code (format: member_id:totp or just member_id)
    final memberId = qrCode.contains(':') ? qrCode.split(':')[0] : qrCode;
    
    return PendingAction(
      id: const Uuid().v4(),
      type: type,
      qrCode: isOfflineScan ? memberId : qrCode, // Store only member_id for offline scans
      memberId: memberId,
      timestamp: DateTime.now(),
      apiKey: apiKey,
      synced: false,
      retryCount: 0,
      isOfflineScan: isOfflineScan,
    );
  }

  /// Create from database map
  factory PendingAction.fromMap(Map<String, dynamic> map) {
    final qrCode = map['qr_code'] as String;
    final memberId = map['member_id'] as String? ?? (qrCode.contains(':') ? qrCode.split(':')[0] : qrCode);
    
    return PendingAction(
      id: map['id'] as String,
      type: map['action'] as String,
      qrCode: qrCode,
      memberId: memberId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      apiKey: map['api_key'] as String,
      synced: (map['synced'] as int) == 1,
      retryCount: map['retry_count'] as int? ?? 0,
      error: map['error'] as String?,
      isOfflineScan: (map['is_offline_scan'] as int?) == 1,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'qr_code': qrCode,
      'member_id': memberId,
      'action': type,
      'api_key': apiKey,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
      'retry_count': retryCount,
      'error': error,
      'is_offline_scan': isOfflineScan ? 1 : 0,
    };
  }

  /// Create a copy with updated fields
  PendingAction copyWith({
    String? id,
    String? type,
    String? qrCode,
    String? memberId,
    DateTime? timestamp,
    String? apiKey,
    bool? synced,
    int? retryCount,
    String? error,
    bool? isOfflineScan,
  }) {
    return PendingAction(
      id: id ?? this.id,
      type: type ?? this.type,
      qrCode: qrCode ?? this.qrCode,
      memberId: memberId ?? this.memberId,
      timestamp: timestamp ?? this.timestamp,
      apiKey: apiKey ?? this.apiKey,
      synced: synced ?? this.synced,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
      isOfflineScan: isOfflineScan ?? this.isOfflineScan,
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

