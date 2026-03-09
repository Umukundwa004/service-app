class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^[+]?[\d\s-]{7,15}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validateCoordinate(String? value, String type) {
    if (value == null || value.isEmpty) {
      return '$type is required';
    }

    final coordinate = double.tryParse(value);
    if (coordinate == null) {
      return 'Please enter a valid $type';
    }

    if (type == 'Latitude' && (coordinate < -90 || coordinate > 90)) {
      return 'Latitude must be between -90 and 90';
    }

    if (type == 'Longitude' && (coordinate < -180 || coordinate > 180)) {
      return 'Longitude must be between -180 and 180';
    }

    return null;
  }

  static String? validateDisplayName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }

    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }
}
