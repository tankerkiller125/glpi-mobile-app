// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GLPI Mobile';

  @override
  String get serverTitle => 'Connect to your GLPI server';

  @override
  String get serverUrlLabel => 'Server URL';

  @override
  String get serverUrlHint => 'https://glpi.example.com';

  @override
  String get serverInvalid => 'No GLPI high-level API found at this address';

  @override
  String get serverHelp =>
      'Your GLPI 11+ server address. The high-level API must be enabled (Setup > General > API).';

  @override
  String get next => 'Next';

  @override
  String get scanTitle => 'Scan to sign in';

  @override
  String get scanInstructions =>
      'In a web browser, open GLPI, then go to My Settings → Mobile app and scan the QR code shown there.';

  @override
  String get scanManualToggle => 'Enter the code manually';

  @override
  String get pairCodeLabel => 'Pairing code';

  @override
  String get pairAction => 'Sign in';

  @override
  String get pairFailed =>
      'Pairing failed. The code may be expired or already used — open the Mobile app tab again for a fresh code.';

  @override
  String get contextTitle => 'Choose your context';

  @override
  String get profileLabel => 'Profile';

  @override
  String get entityLabel => 'Entity';

  @override
  String get entityRecursive => 'Include sub-entities';

  @override
  String get confirm => 'Confirm';

  @override
  String get queueTitle => 'Queue';

  @override
  String get queueTabMine => 'Mine';

  @override
  String get queueTabGroups => 'Groups';

  @override
  String get queueTabUnassigned => 'Unassigned';

  @override
  String get queueEmpty => 'No tickets here yet';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncEmpty => 'Nothing needs your attention';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsContext => 'Profile & entity';

  @override
  String get settingsAbout => 'About';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirmTitle => 'Sign out?';

  @override
  String get logoutConfirmBody =>
      'Your cached data stays on this device. You will need to sign in again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get offlineBanner => 'Offline — changes will sync when back online';

  @override
  String get genericError => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String signedInAs(String user, String server) {
    return 'Signed in as $user on $server';
  }
}
