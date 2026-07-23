import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

class ConnectivityNotifier extends Notifier<bool> {
  late ConnectivityService _service;

  @override
  bool build() {
    _service = ref.watch(connectivityServiceProvider);
    _initConnectivity();
    return true; // Assume connected initially
  }

  Future<void> _initConnectivity() async {
    final isConnected = await _service.isConnected();
    state = isConnected;

    _service.connectivityStream.listen((results) {
      final connected = results.any((result) => result != ConnectivityResult.none);
      state = connected;
    });
  }
}

final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(() {
  return ConnectivityNotifier();
});
