// lib/core/network/connectivity_controller.dart
// WHY: Provides a single, app-wide source of truth for online/offline state.
//      Repositories consult [isOnline] before making network calls so that
//      the UI shows "you're offline" proactively instead of failing
//      mid-request. The Riverpod layer caches the stream so we never spawn
//      multiple platform listeners.
//
//      Implementation note: We intentionally avoid pulling in
//      `connectivity_plus` because (a) it adds a native dependency and (b)
//      Firestore already fails fast when offline + persistence is disabled.
//      Instead we hook Firestore's metadata server snapshot, which gives us
//      the real "can I reach the backend" signal the app cares about.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';

/// Snapshot of network reachability as the app sees it.
@immutable
class ConnectivityState {
  final bool isOnline;
  final DateTime? lastChecked;

  const ConnectivityState({required this.isOnline, this.lastChecked});

  static const unknown = ConnectivityState(isOnline: true, lastChecked: null);

  @override
  String toString() => 'ConnectivityState(online=$isOnline, '
      'checked=${lastChecked?.toIso8601String() ?? 'never'})';
}

/// Controller that exposes a stream of connectivity snapshots. We piggy-back
/// on Firestore's reachability — a single lightweight document fetch is the
/// cheapest reachability check we can make without adding a native plugin.
class ConnectivityController extends Notifier<ConnectivityState> {
  Timer? _heartbeat;

  static const _probePath = 'system/health';
  static const _heartbeatInterval = Duration(seconds: 30);

  @override
  ConnectivityState build() {
    _start();
    ref.onDispose(_stop);
    return ConnectivityState.unknown;
  }

  void _start() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(_heartbeatInterval, (_) => _probeOnce());
    _probeOnce();
  }

  void _stop() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  Future<void> _probeOnce() async {
    try {
      await FirebaseFirestore.instance
          .doc(_probePath)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 5));
      state = ConnectivityState(isOnline: true, lastChecked: DateTime.now());
    } catch (e) {
      state = ConnectivityState(isOnline: false, lastChecked: DateTime.now());
      logWarning('connectivity probe failed', error: e, tag: 'net');
    }
  }

  /// Force a refresh from a UI button ("retry").
  Future<void> refresh() => _probeOnce();
}

final connectivityProvider =
    NotifierProvider<ConnectivityController, ConnectivityState>(
  ConnectivityController.new,
);
