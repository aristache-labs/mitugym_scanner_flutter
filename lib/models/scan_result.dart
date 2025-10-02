import 'member_data.dart';

/// Scan result model
/// Represents the response from a QR code scan attempt
class ScanResult {
  final bool success;
  final String message;
  final MemberData? data;
  final String? error;

  const ScanResult({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  /// Create ScanResult from API JSON response
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown response',
      data: json['data'] != null 
          ? MemberData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }

  /// Create an error result
  factory ScanResult.error(String errorMessage) {
    return ScanResult(
      success: false,
      message: 'Error',
      error: errorMessage,
    );
  }

  /// Create a success result
  factory ScanResult.successResult(String message, MemberData data) {
    return ScanResult(
      success: true,
      message: message,
      data: data,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'error': error,
    };
  }

  @override
  String toString() {
    return 'ScanResult(success: $success, message: $message, error: $error)';
  }
}

