class FormValidators {
  /// Validates a Gmail address according to strict requirements:
  /// - Must contain '@'
  /// - Must contain '.'
  /// - Must contain the keyword 'gmail'
  /// - Other than numbers and alphabets, no symbols can be used except '@' and '.'
  /// - Strictly disallows symbols such as '_', '-', '+', '!', '#', '$', '%', etc.
  static String? validateGmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Email address is required';
    }

    if (!email.contains('@')) {
      return 'Email must contain "@"';
    }

    if (!email.contains('.')) {
      return 'Email must contain "."';
    }

    if (!email.toLowerCase().contains('gmail')) {
      return 'Email must contain "gmail" (e.g. user@gmail.com)';
    }

    if (email.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    // Disallow any characters other than letters, numbers, '@', and '.'
    // (Explicitly rejects '_', '-', '+', '!', '#', etc.)
    final invalidCharRegex = RegExp(r'[^a-zA-Z0-9@.]');
    if (invalidCharRegex.hasMatch(email)) {
      return 'Only letters & numbers allowed (no symbols like _, -, +)';
    }

    // Gmail format: username@gmail.com (or username@gmail.<tld>)
    // Username must contain only alphanumeric characters or dot between alphanumerics
    final gmailRegex = RegExp(
      r'^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*@gmail\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    if (!gmailRegex.hasMatch(email)) {
      return 'Enter a valid Gmail address (e.g. user@gmail.com)';
    }

    return null;
  }

  /// Validates a password according to strict security rules:
  /// - Minimum 8 characters
  /// - At least one capital letter (A-Z)
  /// - At least one special symbol
  /// - Strictly NO underscore ('_') allowed
  /// - Other letters, numbers, and allowed symbols can be used as words
  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must include at least one capital letter (A-Z)';
    }

    if (password.contains('_')) {
      return 'Underscore (_) is not allowed in password';
    }

    // Must include at least one special symbol (excluding underscore)
    if (!RegExp(r'[^a-zA-Z0-9_]').hasMatch(password)) {
      return 'Password must include at least one symbol (e.g. @, #, \$, !)';
    }

    return null;
  }
}
