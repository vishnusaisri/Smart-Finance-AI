import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;

  const AppErrorBoundary({super.key, required this.child});

  @override
  ConsumerState<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends ConsumerState<AppErrorBoundary> {
  bool _hasError = false;
  String? _errorMessage;
  StackTrace? _stackTrace;

  @override
  void didUpdateWidget(AppErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _hasError = false;
      _errorMessage = null;
      _stackTrace = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _ErrorFallback(
        error: _errorMessage ?? 'An unexpected error occurred',
        stackTrace: _stackTrace,
        onRetry: () {
          setState(() {
            _hasError = false;
            _errorMessage = null;
            _stackTrace = null;
          });
        },
      );
    }

    return widget.child;
  }

  static void catchError(dynamic error, StackTrace? stackTrace) {
    // This would be called from global error handlers
    debugPrint('App Error: $error');
    debugPrint('Stack: $stackTrace');
  }
}

class _ErrorFallback extends StatelessWidget {
  final String error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _ErrorFallback({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              if (stackTrace != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    child: Text(
                      stackTrace.toString().split('\n').take(5).join('\n'),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
