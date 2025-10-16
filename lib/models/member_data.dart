/// Member data model
/// Contains information about a gym member returned from the API
class MemberData {
  final String memberId;
  final String memberName;
  final String planName;
  final String expiresAt;
  final String membershipStatus;
  final String? avatarUrl;
  // Additional member details
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? address;
  final String? city;
  final String? county;
  final String? gender;

  const MemberData({
    required this.memberId,
    required this.memberName,
    required this.planName,
    required this.expiresAt,
    required this.membershipStatus,
    this.avatarUrl,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.city,
    this.county,
    this.gender,
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
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      county: json['county'] as String?,
      gender: json['gender'] as String?,
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
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'address': address,
      'city': city,
      'county': county,
      'gender': gender,
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

  /// Get formatted birth date
  String? get formattedBirthDate {
    if (dateOfBirth == null) return null;
    try {
      final date = DateTime.parse(dateOfBirth!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateOfBirth;
    }
  }

  /// Get full address
  String? get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (county != null && county!.isNotEmpty) parts.add(county!);
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Check if member has contact details
  bool get hasContactDetails => email != null || phone != null;

  /// Check if member has address details
  bool get hasAddressDetails => address != null || city != null || county != null;

  @override
  String toString() {
    return 'MemberData(memberId: $memberId, memberName: $memberName, planName: $planName, status: $membershipStatus)';
  }
}

