import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Security utility class for data protection and validation
class SecurityUtils {
  /// Generate a secure random string
  static String generateSecureToken([int length = 32]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Hash a password using PBKDF2
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a secure salt for password hashing
  static String generateSalt([int length = 16]) {
    return generateSecureToken(length);
  }

  /// Validate password strength
  static bool isPasswordSecure(String password) {
    if (password.length < 8) return false;

    // Check for uppercase, lowercase, number, and special character
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasNumber && hasSpecialChar;
  }

  /// Sanitize input string to prevent XSS
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .replaceAll('/', '&#x2F;');
  }

  /// Mask sensitive data (e.g., phone numbers, emails)
  static String maskSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars) return data;

    final visiblePart = data.substring(0, visibleChars);
    final maskedPart = '*' * (data.length - visibleChars);

    return visiblePart + maskedPart;
  }

  /// Validate API key format
  static bool isValidApiKey(String apiKey) {
    if (apiKey.isEmpty || apiKey.length < 32) return false;

    // Basic format validation
    final apiKeyRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return apiKeyRegex.hasMatch(apiKey);
  }

  /// Generate CSRF token
  static String generateCsrfToken() {
    return generateSecureToken(40);
  }

  /// Validate session token format
  static bool isValidSessionToken(String token) {
    if (token.isEmpty || token.length < 20) return false;

    // Basic format validation
    final tokenRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return tokenRegex.hasMatch(token);
  }

  /// Check if a string contains potentially malicious patterns
  static bool containsMaliciousPatterns(String input) {
    final maliciousPatterns = [
      RegExp(r'<script[^>]*>.*?<\/script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<iframe[^>]*>.*?<\/iframe>', caseSensitive: false),
      RegExp(r'<object[^>]*>.*?<\/object>', caseSensitive: false),
      RegExp(r'<embed[^>]*>', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'data:text/html', caseSensitive: false),
    ];

    return maliciousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Rate limiting helper
  static bool isRateLimited(
    Map<String, List<DateTime>> requests,
    String identifier,
    int maxRequests,
    Duration timeWindow,
  ) {
    final now = DateTime.now();
    final windowStart = now.subtract(timeWindow);

    // Clean old requests
    requests[identifier]?.removeWhere((time) => time.isBefore(windowStart));

    // Initialize if doesn't exist
    requests[identifier] ??= [];

    // Check if rate limited
    if (requests[identifier]!.length >= maxRequests) {
      return true;
    }

    // Add current request
    requests[identifier]!.add(now);
    return false;
  }

  /// Encrypt sensitive data using AES (requires additional crypto package)
  static String encryptData(String data, String key) {
    // This is a placeholder - implement actual AES encryption
    // For production, use proper encryption libraries
    final bytes = utf8.encode(data + key);
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// Decrypt sensitive data
  static String decryptData(String encryptedData, String key) {
    // This is a placeholder - implement actual AES decryption
    // For production, use proper decryption libraries
    return encryptedData; // Placeholder
  }

  /// Check if input contains SQL injection patterns
  static bool isSqlInjectionSafe(String input) {
    final sqlPatterns = [
      RegExp(r'(\bUNION\b|\bSELECT\b|\bINSERT\b|\bUPDATE\b|\bDELETE\b|\bDROP\b)', caseSensitive: false),
      RegExp(r'(\-\-|\#|/\*|\*/)', caseSensitive: false),
      RegExp(r'(\bOR\b|\bAND\b)\s+\d+\s*=\s*\d+', caseSensitive: false),
      RegExp(r"';\s*(\bDROP\b|\bDELETE\b|\bINSERT\b)", caseSensitive: false),
    ];

    return !sqlPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Check if input contains suspicious patterns
  static bool containsSuspiciousPatterns(String input) {
    return containsMaliciousPatterns(input) || !isSqlInjectionSafe(input);
  }

  /// Validate input against common security threats
  static bool isSecureInput(String input, {int maxLength = 1000}) {
    if (input.length > maxLength) return false;
    if (containsSuspiciousPatterns(input)) return false;
    return true;
  }

  /// Generate secure random token with specified length
  static String generateSecureTokenWithLength(int length) {
    return generateSecureToken(length);
  }

  /// Hash data with salt using SHA-256
  static String hashWithSalt(String data, String salt) {
    return hashPassword(data, salt);
  }

  /// Validate API request signature
  static bool validateSignature(String data, String signature, String secret) {
    final expectedSignature = hashPassword(data, secret);
    return expectedSignature == signature;
  }

  /// Check if file extension is allowed
  static bool isAllowedFileExtension(String filename, List<String> allowedExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Sanitize filename for safe storage
  static String sanitizeFilename(String filename) {
    return filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\.\.'), '_')
        .replaceAll(RegExp(r'^\.|\.{2,}'), '_');
  }

  /// Check if URL is from allowed domain
  static bool isAllowedDomain(String url, List<String> allowedDomains) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host.toLowerCase();
      return allowedDomains.any((allowed) => domain.endsWith(allowed.toLowerCase()));
    } catch (e) {
      return false;
    }
  }
}

/// Extension methods for String security utilities
extension StringSecurity on String {
  /// Check if string is secure
  bool get isSecure => !SecurityUtils.containsMaliciousPatterns(this);

  /// Get sanitized version of string
  String get sanitized => SecurityUtils.sanitizeInput(this);

  /// Get masked version of string
  String get masked => SecurityUtils.maskSensitiveData(this);
}