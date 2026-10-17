import 'package:dhahabu/l10n/l10n.dart';

class AppValidator {
  static String? validateEmail(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validatorEmailRequired;
    }
    final trimmed = value.trim();
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return l10n.validatorEmailValid;
    }
    return null;
  }

  static String? validatePassword(AppLocalizations l10n, String? value) {
    if (value == null || value.isEmpty) {
      return l10n.validatorPasswordRequired;
    }
    if (value.length < 8) {
      return l10n.validatorPasswordLength;
    }
    return null;
  }

  static String? validatePhone(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().length < 9) {
      return l10n.validatorPhoneValid;
    }
    return null;
  }

  static String? validateName(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validatorNameRequired;
    }
    return null;
  }
}
