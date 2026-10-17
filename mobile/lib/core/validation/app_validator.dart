class AppValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your email address.';
    }
    final trimmed = value.trim();
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password.';
    }
    if (value.length < 8) {
      return 'Use a password with at least 8 characters.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().length < 9) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your full name.';
    }
    return null;
  }
}
