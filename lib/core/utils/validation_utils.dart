import 'package:flutter/material.dart';

class ValidationUtils {
  // Email validation with regex
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.([a-zA-Z]{2,6})$');
    final match = emailRegex.firstMatch(trimmed);
    if (match == null) {
      return 'Please enter a valid email address';
    }

    final tld = match.group(1)?.toLowerCase() ?? '';
    if (tld == 'co') {
      return 'Please enter a complete domain (e.g. .com, .in, .ac.in)';
    }
    
    return null;
  }

  // Password validation with strength requirements
  static String? validatePassword(String? value, {bool requireCurrent = false}) {
    if (value == null || value.isEmpty) {
      return requireCurrent ? 'Please enter your password' : 'Please enter a password';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    final nameRegex = RegExp(r'^[a-zA-Z\s\-\.]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and dots';
    }
    
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (min != null && amount < min) {
      return 'Amount must be at least \$${min.toStringAsFixed(2)}';
    }
    
    if (max != null && amount > max) {
      return 'Amount must be less than \$${max.toStringAsFixed(2)}';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please enter a description';
    }
    
    if (value != null && value.isNotEmpty) {
      if (value.length < 3) {
        return 'Description must be at least 3 characters';
      }
      
      if (value.length > 200) {
        return 'Description must be less than 200 characters';
      }
    }
    
    return null;
  }

  // Category validation
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    final phoneRegex = RegExp(r'^[\d\+\-\(\)\s]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }
    
    final urlRegex = RegExp(r'^https?:\/\/[\w\-\.]+(\.[\w\-]+)+[\w\-\.,@?^=%&:/~\+#]*$');
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Date validation (future date check)
  static String? validateDate(DateTime? date, {bool allowFuture = false}) {
    if (date == null) {
      return 'Please select a date';
    }
    
    if (!allowFuture && date.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    
    if (date.isBefore(DateTime(2000))) {
      return 'Date cannot be before year 2000';
    }
    
    return null;
  }

  // Get password strength indicator
  static PasswordStrength getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  // Get password strength color
  static Color getPasswordStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  // Get password strength text
  static String getPasswordStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
}

// Safe double conversion helper for Firebase Realtime DB dynamic types
double safeDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) {
    return value.toDouble();
  }
  if (value is double) {
    return value;
  }
  return double.tryParse(value.toString()) ?? 0.0;
}
