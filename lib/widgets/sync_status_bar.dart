import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/providers/sync_status_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(syncState),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatusIcon(syncState),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStatusText(syncState),
                  style: TextStyle(
                    color: _getTextColor(syncState),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (syncState.lastSyncTime != null)
                  Text(
                    'Last sync: ${timeago.format(syncState.lastSyncTime!)}',
                    style: TextStyle(
                      color: _getTextColor(syncState).withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (syncState.status == SyncStatus.error && syncState.isOnline)
            TextButton(
              onPressed: () {
                // TODO: Implement manual sync
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(SyncState state) {
    IconData icon;
    Color color;

    if (!state.isOnline) {
      icon = Icons.cloud_off;
      color = Colors.red;
    } else {
      switch (state.status) {
        case SyncStatus.syncing:
          icon = Icons.sync;
          color = Colors.orange;
          break;
        case SyncStatus.error:
          icon = Icons.error_outline;
          color = Colors.red;
          break;
        case SyncStatus.success:
          icon = Icons.check_circle;
          color = Colors.green;
          break;
        case SyncStatus.idle:
          icon = Icons.cloud_done;
          color = Colors.green;
          break;
      }
    }

    return Icon(icon, color: color);
  }

  String _getStatusText(SyncState state) {
    if (!state.isOnline) {
      return 'Offline Mode';
    }

    switch (state.status) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return state.errorMessage ?? 'Sync Error';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.idle:
        return 'Online';
    }
  }

  Color _getBackgroundColor(SyncState state) {
    if (!state.isOnline) {
      return Colors.red.withOpacity(0.1);
    }

    switch (state.status) {
      case SyncStatus.syncing:
        return Colors.orange.withOpacity(0.1);
      case SyncStatus.error:
        return Colors.red.withOpacity(0.1);
      case SyncStatus.success:
        return Colors.green.withOpacity(0.1);
      case SyncStatus.idle:
        return Colors.green.withOpacity(0.1);
    }
  }

  Color _getTextColor(SyncState state) {
    if (!state.isOnline) {
      return Colors.red;
    }

    switch (state.status) {
      case SyncStatus.syncing:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.idle:
        return Colors.green;
    }
  }
} 