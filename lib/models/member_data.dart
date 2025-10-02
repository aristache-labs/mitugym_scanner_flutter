/// Member data model
/// Contains information about a gym member returned from the API
class MemberData {
  final String memberId;
  final String memberName;
  final String planName;
  final String expiresAt;
  final String membershipStatus;
  final String? avatarUrl;

  const MemberData({
    required this.memberId,
    required this.memberName,
    required this.planName,
    required this.expiresAt,
    required this.membershipStatus,
    this.avatarUrl,
  });

  /// Create MemberData from JSON response
  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(
      memberId: json['member_id'] as String? ?? '',
      memberName: json['member_name'] as String? ?? 'Unknown',
      planName: json['plan_name'] as String? ?? 'No Plan',
      expiresAt: json['expires_at'] as String? ?? '',
      membershipStatus: json['membership_status'] as String? ?? 'unknown',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member_name': memberName,
      'plan_name': planName,
      'expires_at': expiresAt,
      'membership_status': membershipStatus,
      'avatar_url': avatarUrl,
    };
  }

  /// Check if membership is active
  bool get isActive => membershipStatus.toLowerCase() == 'active';

  /// Check if member has an avatar
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Get member initials for avatar fallback
  String get initials {
    final names = memberName.split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  /// Get formatted expiry date
  String get formattedExpiryDate {
    try {
      final date = DateTime.parse(expiresAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return expiresAt;
    }
  }

  @override
  String toString() {
    return 'MemberData(memberId: $memberId, memberName: $memberName, planName: $planName, status: $membershipStatus)';
  }
}

