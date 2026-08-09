import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../shell/entity_switcher_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final account = switch (auth) {
      Ready(:final account) => account,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          if (account != null)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(account.displayName),
              subtitle: Text(l.signedInAs(account.username, account.serverUrl)),
            ),
          if (account != null)
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(l.settingsContext),
              subtitle: Text(
                '${account.profileName ?? ''} · ${account.entityName ?? ''}'
                '${account.entityRecursive ? ' (+ sub-entities)' : ''}',
              ),
              trailing: const Icon(Icons.swap_horiz),
              onTap: () async {
                final changed = await EntitySwitcherSheet.show(context);
                if (changed && context.mounted) Navigator.pop(context);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l.logout),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l.logoutConfirmTitle),
                  content: Text(l.logoutConfirmBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l.logout),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authControllerProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
    );
  }
}
