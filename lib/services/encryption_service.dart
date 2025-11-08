import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Service for managing database encryption keys
/// Uses SharedPreferences to store encryption keys
/// Note: For production, consider using platform-specific secure storage
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final Logger _logger = Logger();
  
  static const String _keyStorageKey = 'mitugym_db_encryption_key';

  /// Get or create the database encryption key
  /// Returns a 256-bit (32-byte) encryption key
  Future<String> getOrCreateEncryptionKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to read existing key
      String? existingKey = prefs.getString(_keyStorageKey);
      
      if (existingKey != null && existingKey.isNotEmpty) {
        _logger.i('✅ Using existing encryption key');
        return existingKey;
      }
      
      // Generate new key if none exists
      _logger.i('🔑 Generating new encryption key...');
      final newKey = _generateSecureKey();
      
      // Store the key
      await prefs.setString(_keyStorageKey, newKey);
      
      _logger.i('✅ Encryption key generated and stored');
      return newKey;
    } catch (e) {
      _logger.e('❌ Failed to get/create encryption key: $e');
      rethrow;
    }
  }

  /// Generate a cryptographically secure 256-bit key
  String _generateSecureKey() {
    // Use cryptographically secure random number generator
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    
    // Convert to hex string for SQLCipher
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Derive a key from a user password (optional, for future use)
  /// Uses PBKDF2 with SHA-256
  String deriveKeyFromPassword(String password, String salt) {
    final saltBytes = utf8.encode(salt);
    final passwordBytes = utf8.encode(password);
    
    // Simple derivation for demonstration
    // In production, use a proper PBKDF2 implementation with high iteration count
    final hmac = Hmac(sha256, saltBytes);
    final digest = hmac.convert(passwordBytes);
    
    return digest.toString();
  }

  /// Delete the encryption key (use with caution!)
  /// This will make the encrypted database unreadable
  Future<void> deleteEncryptionKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStorageKey);
      _logger.w('⚠️ Encryption key deleted - database will be unreadable!');
    } catch (e) {
      _logger.e('Failed to delete encryption key: $e');
      rethrow;
    }
  }

  /// Check if an encryption key exists
  Future<bool> hasEncryptionKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_keyStorageKey);
      return key != null && key.isNotEmpty;
    } catch (e) {
      _logger.e('Failed to check for encryption key: $e');
      return false;
    }
  }
}

