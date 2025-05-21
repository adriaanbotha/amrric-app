import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
  success,
}

class SyncState {
  final bool isOnline;
  final SyncStatus status;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  SyncState({
    required this.isOnline,
    this.status = SyncStatus.idle,
    this.errorMessage,
    this.lastSyncTime,
  });

  SyncState copyWith({
    bool? isOnline,
    SyncStatus? status,
    String? errorMessage,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class SyncStatusNotifier extends StateNotifier<SyncState> {
  SyncStatusNotifier() : super(SyncState(isOnline: true)) {
    _init();
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((result) {
      state = state.copyWith(
        isOnline: result != ConnectivityResult.none,
        status: result == ConnectivityResult.none ? SyncStatus.error : SyncStatus.idle,
        errorMessage: result == ConnectivityResult.none ? 'Offline mode' : null,
      );
    });
  }

  void setSyncing() {
    state = state.copyWith(
      status: SyncStatus.syncing,
      errorMessage: null,
    );
  }

  void setSuccess() {
    state = state.copyWith(
      status: SyncStatus.success,
      errorMessage: null,
      lastSyncTime: DateTime.now(),
    );
  }

  void setError(String message) {
    state = state.copyWith(
      status: SyncStatus.error,
      errorMessage: message,
    );
  }

  void setIdle() {
    state = state.copyWith(
      status: SyncStatus.idle,
      errorMessage: null,
    );
  }
}

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncState>((ref) {
  return SyncStatusNotifier();
}); 