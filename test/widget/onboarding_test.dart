import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/features/auth/ui/server_screen.dart';
import 'package:glpi_mobile/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

void main() {
  testWidgets(
    'server screen renders just the URL field (no client id/secret)',
    (tester) async {
      await tester.pumpWidget(_wrap(const ServerScreen()));
      expect(find.text('Server URL'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      // Auth is by QR pairing now — no OAuth client credentials on this screen.
      expect(find.text('OAuth client'), findsNothing);
      expect(find.text('Client secret'), findsNothing);
    },
  );

  testWidgets('server screen renders in French', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: const ServerScreen(),
        ),
      ),
    );
    expect(find.text('URL du serveur'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });
}
