
class ValidatorManager {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter Email";
    }
    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return "Enter Valid Email";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password requierd";
    }
    if (value.length < 6) {
      return "Password Must be 8";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Pass must be uppercase ";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "pass must at least 1 num";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "pass special char";
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }
    if (value.trim().length < 2) {
      return "Name must be at least 2 characters";
    }
    // Allow letters, numbers, spaces, and basic punctuation for hospital/blood bank names
    if (!RegExp(r'^[\p{L}\p{N}\s.,-]+$', unicode: true).hasMatch(value)) {
      return "Name contains invalid characters";
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }
    final RegExp phoneRegex = RegExp(r'^\+?\d{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return "Enter a valid phone number";
    }
    return null;
  }


  static String? validateNationalId(String? value) {
    if (value == null || value.isEmpty) {
      return "National ID is required";
    }

    // Must be 14 digits
    if (!RegExp(r'^\d{14}$').hasMatch(value)) {
      return "National ID must be 14 digits";
    }

    // Extract parts
    int century = int.parse(value[0]);
    int year = int.parse(value.substring(1, 3));
    int month = int.parse(value.substring(3, 5));
    int day = int.parse(value.substring(5, 7));

    // Convert to full year
    int fullYear = (century == 2 ? 1900 : 2000) + year;

    // Validate date
    try {
      DateTime birthDate = DateTime(fullYear, month, day);

      // Check if date is realistic
      if (birthDate.year != fullYear ||
          birthDate.month != month ||
          birthDate.day != day) {
        return "Invalid birth date in ID";
      }

      if (birthDate.isAfter(DateTime.now())) {
        return "Birth date cannot be in the future";
      }
    } catch (e) {
      return "Invalid date in National ID";
    }

    return null; // valid
  }

  static String? validateFactoryNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Factory number is required";
    }

    // Regex: 2 uppercase letters + 7 digits
    final regex = RegExp(r'^[A-Z]{2}\d{7}$');

    if (!regex.hasMatch(value)) {
      return "Invalid factory number format (e.g., AB1234567)";
    }

    return null; // valid
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return "Address is required";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return "Confirm password is required";
    }
    if (value != originalPassword) {
      return "Passwords do not match";
    }
    return null;
  }
}
