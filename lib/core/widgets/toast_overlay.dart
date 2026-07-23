import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Toast types
enum ToastType { success, error, warning, info }

// Toast data model
class ToastMessage {
  final String id;
  final String message;
  final ToastType type;
  final Duration duration;

  ToastMessage({
    required this.id,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
  });
}

// Toast notifier
class ToastNotifier extends Notifier<List<ToastMessage>> {
  @override
  List<ToastMessage> build() {
    return [];
  }

  void showToast({
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final toast = ToastMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      type: type,
      duration: duration,
    );

    state = [...state, toast];

    // Auto-remove after duration
    Future.delayed(duration, () {
      removeToast(toast.id);
    });
  }

  void removeToast(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void showSuccess(String message) {
    showToast(message: message, type: ToastType.success);
  }

  void showError(String message) {
    showToast(message: message, type: ToastType.error, duration: const Duration(seconds: 5));
  }

  void showWarning(String message) {
    showToast(message: message, type: ToastType.warning);
  }

  void showInfo(String message) {
    showToast(message: message, type: ToastType.info);
  }
}

final toastProvider = NotifierProvider<ToastNotifier, List<ToastMessage>>(() {
  return ToastNotifier();
});

// Toast overlay widget
class ToastOverlay extends ConsumerWidget {
  final Widget child;

  const ToastOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);

    return Stack(
      children: [
        child,
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: toasts.map((toast) => _ToastCard(toast: toast)).toList(),
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  final ToastMessage toast;

  const _ToastCard({required this.toast});

  Color get _backgroundColor {
    switch (toast.type) {
      case ToastType.success:
        return const Color(0xFF10B981);
      case ToastType.error:
        return const Color(0xFFEF4444);
      case ToastType.warning:
        return const Color(0xFFF59E0B);
      case ToastType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData get _icon {
    switch (toast.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              toast.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper extension for easy toast access
extension ToastExtension on WidgetRef {
  void showSuccessToast(String message) {
    read(toastProvider.notifier).showSuccess(message);
  }

  void showErrorToast(String message) {
    read(toastProvider.notifier).showError(message);
  }

  void showWarningToast(String message) {
    read(toastProvider.notifier).showWarning(message);
  }

  void showInfoToast(String message) {
    read(toastProvider.notifier).showInfo(message);
  }
}
