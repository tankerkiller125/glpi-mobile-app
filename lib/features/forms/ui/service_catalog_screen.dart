import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/accessible_refresh.dart';

/// The GLPI Service Catalog: the forms a technician can file. Picking one opens
/// its dynamic form, so tickets are created through GLPI's own intake config
/// rather than an app-invented field set.
class ServiceCatalogScreen extends ConsumerWidget {
  const ServiceCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final forms = ref.watch(formCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New request')),
      body: switch (forms) {
        AsyncData(:final value) when value.isEmpty => _Empty(
          onRetry: () => ref.invalidate(formCatalogProvider),
          // Nothing published in the catalog — offer the plain ticket form so
          // the tech isn't stuck.
          onFallback: () => context.push(Routes.createTicket),
        ),
        AsyncData(:final value) => AccessibleRefresh(
          onRefresh: () async => ref.invalidate(formCatalogProvider),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: value.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final form = value[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    _iconFor(form.illustration),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(form.name),
                subtitle: form.description.isEmpty
                    ? null
                    : Text(
                        form.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.form(form.id)),
              );
            },
          ),
        ),
        AsyncError() => _Empty(
          message:
              'Could not load the service catalog. Check your connection and '
              'try again.',
          onRetry: () => ref.invalidate(formCatalogProvider),
        ),
        _ => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading'),
        ),
      },
    );
  }

  /// Map GLPI's illustration slug to a rough icon.
  IconData _iconFor(String illustration) {
    final s = illustration.toLowerCase();
    if (s.contains('issue') || s.contains('incident')) {
      return Icons.report_problem_outlined;
    }
    if (s.contains('service') || s.contains('request')) {
      return Icons.support_agent_outlined;
    }
    if (s.contains('hardware') || s.contains('device')) {
      return Icons.devices_outlined;
    }
    return Icons.assignment_outlined;
  }
}

class _Empty extends StatelessWidget {
  const _Empty({this.message, required this.onRetry, this.onFallback});

  final String? message;
  final VoidCallback onRetry;
  final VoidCallback? onFallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  'No forms are published in the service catalog for your '
                      'account.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            if (onFallback != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onFallback,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Create a ticket directly'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
