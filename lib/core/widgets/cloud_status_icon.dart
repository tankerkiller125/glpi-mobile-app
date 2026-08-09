import 'package:flutter/material.dart';

import '../sync/connectivity.dart';

/// Renders the sync cloud for a [CloudState]:
/// connected (cloud done), syncing (cloud sync), offline (cloud off), or
/// error (a cloud with an error badge).
class CloudStatusIcon extends StatelessWidget {
  const CloudStatusIcon({super.key, required this.state, this.size = 24});

  final CloudState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (state) {
      case CloudState.connected:
        return Icon(Icons.cloud_done, size: size, color: scheme.primary);
      case CloudState.syncing:
        return Icon(Icons.cloud_sync, size: size, color: scheme.primary);
      case CloudState.offline:
        return Icon(Icons.cloud_off, size: size, color: scheme.outline);
      case CloudState.error:
        // A cloud with an error badge.
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.cloud, size: size, color: scheme.error),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error,
                    size: size * 0.55,
                    color: scheme.error,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

String cloudStateLabel(CloudState state) => switch (state) {
  CloudState.connected => 'Connected',
  CloudState.syncing => 'Syncing…',
  CloudState.offline => 'Offline',
  CloudState.error => 'Sync issue',
};
