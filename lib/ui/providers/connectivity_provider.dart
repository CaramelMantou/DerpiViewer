import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

/// Monitors device connectivity and exposes [isOnline].
///
/// Registered in main.dart via [ChangeNotifierProvider] so UI elements
/// (HomePage offline banner, search FAB) can react to connectivity changes.
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  void _init() {
    _connectivity.checkConnectivity().then(_updateStatus).catchError((_) {
      // Silently keep default state on platform error
    });
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateStatus,
      onError: (_) { /* Silently ignore stream errors */ },
    );
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online = !results.contains(ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
