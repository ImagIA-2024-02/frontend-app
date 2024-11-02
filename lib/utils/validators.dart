class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!(hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters)) {
      return 'Password must include uppercase, lowercase, digit, and special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < 2) {
      return 'First name must be at least 2 characters long';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'First name can only contain alphabets';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters long';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'Last name can only contain alphabets';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age <= 0) {
      return 'Enter a valid age';
    }
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    return null;
  }
}
