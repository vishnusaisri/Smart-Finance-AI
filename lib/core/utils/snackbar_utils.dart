import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class SnackbarUtils {
  static void showSuccess(String message) {
    _showSnackbar(message, AppColors.success, Icons.check_circle_outline);
  }

  static void showError(String message) {
    _showSnackbar(message, AppColors.danger, Icons.error_outline);
  }

  static void showInfo(String message) {
    _showSnackbar(message, AppColors.primary, Icons.info_outline);
  }

  static void showWarning(String message) {
    _showSnackbar(message, AppColors.warning, Icons.warning_amber_outlined);
  }

  static void _showSnackbar(String message, Color backgroundColor, IconData icon) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
