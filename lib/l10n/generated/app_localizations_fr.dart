// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GLPI Mobile';

  @override
  String get serverTitle => 'Connexion à votre serveur GLPI';

  @override
  String get serverUrlLabel => 'URL du serveur';

  @override
  String get serverUrlHint => 'https://glpi.exemple.fr';

  @override
  String get serverInvalid =>
      'Aucune API haut niveau GLPI trouvée à cette adresse';

  @override
  String get serverHelp =>
      'L\'adresse de votre serveur GLPI 11+. L\'API haut niveau doit être activée (Configuration > Générale > API).';

  @override
  String get next => 'Suivant';

  @override
  String get scanTitle => 'Scanner pour se connecter';

  @override
  String get scanInstructions =>
      'Dans un navigateur web, ouvrez GLPI, puis allez dans Mes préférences → Application mobile et scannez le QR code affiché.';

  @override
  String get scanManualToggle => 'Saisir le code manuellement';

  @override
  String get pairCodeLabel => 'Code d\'appairage';

  @override
  String get pairAction => 'Se connecter';

  @override
  String get pairFailed =>
      'Échec de l\'appairage. Le code est peut-être expiré ou déjà utilisé — rouvrez l\'onglet Application mobile pour en générer un nouveau.';

  @override
  String get contextTitle => 'Choisissez votre contexte';

  @override
  String get profileLabel => 'Profil';

  @override
  String get entityLabel => 'Entité';

  @override
  String get entityRecursive => 'Inclure les sous-entités';

  @override
  String get confirm => 'Valider';

  @override
  String get queueTitle => 'File';

  @override
  String get queueTabMine => 'Moi';

  @override
  String get queueTabGroups => 'Groupes';

  @override
  String get queueTabUnassigned => 'Non attribués';

  @override
  String get queueEmpty => 'Aucun ticket ici pour l\'instant';

  @override
  String get syncTitle => 'Synchro';

  @override
  String get syncEmpty => 'Rien ne requiert votre attention';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsContext => 'Profil et entité';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutConfirmTitle => 'Se déconnecter ?';

  @override
  String get logoutConfirmBody =>
      'Vos données en cache restent sur cet appareil. Vous devrez vous reconnecter.';

  @override
  String get cancel => 'Annuler';

  @override
  String get offlineBanner =>
      'Hors ligne — les modifications seront synchronisées au retour du réseau';

  @override
  String get genericError => 'Une erreur est survenue';

  @override
  String get retry => 'Réessayer';

  @override
  String signedInAs(String user, String server) {
    return 'Connecté en tant que $user sur $server';
  }
}
