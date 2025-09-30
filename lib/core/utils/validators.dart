/// Utility class for input validation
class Validators {
  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegex.hasMatch(email)) return false;

    // Additional checks for suspicious patterns
    if (email.contains('..') || email.startsWith('.') || email.contains('.@') || email.contains('@.')) {
      return false;
    }

    return true;
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    if (password.isEmpty || password.length < 8) return false;

    // Must contain at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasLetter && hasNumber;
  }

  /// Validate phone number (Cameroon format)
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;

    // Remove all non-digit characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Check for Cameroon phone number formats
    // +237XXXXXXXXX, 237XXXXXXXXX, 6XXXXXXXX, 2XXXXXXXX, 9XXXXXXXX
    if (cleanPhone.startsWith('237') && cleanPhone.length == 12) {
      // Check if the number after 237 starts with valid prefix (6, 2, or 9)
      final numberPart = cleanPhone.substring(3);
      return numberPart.startsWith('6') || numberPart.startsWith('2') || numberPart.startsWith('9');
    } else if (cleanPhone.length == 9 &&
        (cleanPhone.startsWith('6') || cleanPhone.startsWith('2') || cleanPhone.startsWith('9'))) {
      return true;
    }

    return false;
  }

  /// Validate name (letters, spaces, hyphens only)
  static bool isValidName(String name) {
    if (name.isEmpty || name.trim().length < 2) return false;

    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(name.trim())) return false;

    // Additional security check for dangerous patterns
    return validateTextInput(name, minLength: 2, maxLength: 50);
  }

  /// Validate required field (not empty)
  static bool isRequired(String value) {
    return value.trim().isNotEmpty;
  }

  /// Validate minimum length
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  /// Validate maximum length
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }

  /// Validate numeric string
  static bool isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  /// Validate amount (positive number with max 2 decimal places)
  static bool isValidAmount(String amount) {
    if (amount.isEmpty) return false;

    final amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!amountRegex.hasMatch(amount)) return false;

    final numericValue = double.tryParse(amount);
    return numericValue != null && numericValue > 0;
  }

  /// Get email validation error message
  static String? getEmailError(String email) {
    if (email.isEmpty) return 'Email requis';
    if (!isValidEmail(email)) return 'Format d\'email invalide';
    return null;
  }

  /// Get password validation error message
  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Mot de passe requis';
    if (password.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères';
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) return 'Le mot de passe doit contenir au moins une lettre';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Le mot de passe doit contenir au moins un chiffre';
    return null;
  }

  /// Get phone number validation error message
  static String? getPhoneError(String phone) {
    if (phone.isEmpty) return 'Phone number is required';
    if (!isValidPhoneNumber(phone)) return 'Invalid phone number format';
    return null;
  }

  /// Get name validation error message
  static String? getNameError(String name) {
    if (name.trim().isEmpty) return 'Nom requis';
    if (name.trim().length < 2) return 'Le nom doit contenir au moins 2 caractères';
    if (name.trim().length > 50) return 'Le nom ne peut pas dépasser 50 caractères';
    if (!isValidName(name)) return 'Le nom ne peut contenir que des lettres, espaces et tirets';
    return null;
  }

  /// Validate email (alias for backward compatibility)
  static bool validateEmail(String email) {
    return isValidEmail(email);
  }

  /// Validate password (alias for backward compatibility)
  static bool validatePassword(String password) {
    return isValidPassword(password);
  }

  /// Validate name (alias for backward compatibility)
  static bool validateName(String name) {
    return isValidName(name);
  }

  /// Validate phone (alias for backward compatibility)
  static bool validatePhone(String phone) {
    return isValidPhoneNumber(phone);
  }

  /// Validate text input for security and length
  static bool validateTextInput(String text, {int minLength = 1, int maxLength = 1000}) {
    if (text.length < minLength || text.length > maxLength) return false;

    // Check for malicious patterns
    final maliciousPatterns = [
      RegExp(r'<script[^>]*>.*?<\/script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<iframe[^>]*>.*?<\/iframe>', caseSensitive: false),
    ];

    return !maliciousPatterns.any((pattern) => pattern.hasMatch(text));
  }

  /// Validate URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Validate date format (YYYY-MM-DD)
  static bool isValidDate(String date) {
    try {
      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!dateRegex.hasMatch(date)) return false;

      final parts = date.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final dateTime = DateTime(year, month, day);
      return dateTime.year == year && dateTime.month == month && dateTime.day == day;
    } catch (e) {
      return false;
    }
  }

  /// Validate credit card number using Luhn algorithm
  static bool isValidCreditCard(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cleanNumber[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    return (sum % 10) == 0;
  }

  /// Validate age (minimum age requirement)
  static bool isValidAge(String birthDate, {int minAge = 13}) {
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      final age = now.year - birth.year;

      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        return age - 1 >= minAge;
      }

      return age >= minAge;
    } catch (e) {
      return false;
    }
  }

  /// Validate postal code (generic format)
  static bool isValidPostalCode(String postalCode) {
    // Basic postal code validation - can be customized per country
    final cleanCode = postalCode.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return cleanCode.length >= 3 && cleanCode.length <= 10;
  }

  /// Validate file size (in bytes)
  static bool isValidFileSize(int fileSizeBytes, {int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSizeBytes <= maxSizeBytes;
  }
}