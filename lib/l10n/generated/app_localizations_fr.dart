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

  @override
  String get assistantTitle => 'Assistant';

  @override
  String get assistantAsk => 'Demander';

  @override
  String get assistantStop => 'Arrêter';

  @override
  String get assistantHint => 'Posez votre question sur ce problème…';

  @override
  String get assistantThinking => 'Réflexion…';

  @override
  String get assistantWorking => 'Traitement…';

  @override
  String assistantTurn(int n) {
    return 'Tour $n…';
  }

  @override
  String assistantRunningTool(String tool) {
    return 'Consultation : $tool';
  }

  @override
  String get assistantHistory => 'Conversations précédentes';

  @override
  String get assistantNoHistory => 'Aucune conversation pour l\'instant';

  @override
  String get assistantUntitled => 'Conversation sans titre';

  @override
  String get assistantClear => 'Effacer cette conversation';

  @override
  String get assistantCleared => 'Conversation effacée';

  @override
  String get assistantEmpty =>
      'Posez une question sur une machine, un ticket ou ce que vous constatez. L\'assistant peut aller chercher l\'information avant de répondre.';

  @override
  String assistantEmptyOn(String context) {
    return 'Posez votre question sur $context. L\'assistant sait déjà ce que vous avez ouvert.';
  }

  @override
  String get assistantOnTicket => 'Interroger l\'assistant';

  @override
  String get aiTitle => 'IA';

  @override
  String get aiDraftSolution => 'Rédiger une solution';

  @override
  String get aiDraftRedo => 'Rédiger à nouveau';

  @override
  String get aiDrafting => 'Rédaction…';

  @override
  String get aiDraftTitle => 'Solution proposée';

  @override
  String get aiDraftUse => 'Utiliser';

  @override
  String get aiDraftDiscard => 'Écarter';

  @override
  String get aiDraftInserted => 'Brouillon inséré dans la réponse';

  @override
  String get aiDraftDiscarded => 'Brouillon écarté';

  @override
  String get aiDraftUnread =>
      'Relisez-le avant de l\'envoyer : c\'est un brouillon, pas une réponse.';

  @override
  String aiConfidence(String level) {
    return 'Confiance : $level';
  }

  @override
  String get aiTriageTitle => 'Tri suggéré';

  @override
  String get aiTriageRun => 'Lancer le tri';

  @override
  String get aiTriageRunning => 'Tri en cours…';

  @override
  String get aiTriageApply => 'Appliquer';

  @override
  String get aiTriageDismiss => 'Rejeter';

  @override
  String get aiTriageApplied => 'Appliqué';

  @override
  String get aiFieldCategory => 'Catégorie';

  @override
  String get aiFieldUrgency => 'Urgence';

  @override
  String get aiFieldImpact => 'Impact';

  @override
  String get aiFieldProcedure => 'Procédure';

  @override
  String get aiReplyReview => 'Relire cette réponse';

  @override
  String get aiReplyReviewing => 'Relecture…';

  @override
  String get aiReplyClean => 'Rien à signaler — la réponse se lit bien.';

  @override
  String get aiReplyTitle => 'Avant l\'envoi';

  @override
  String get aiReplySendAnyway => 'Envoyer quand même';

  @override
  String get aiReplyKeepEditing => 'Continuer à écrire';

  @override
  String get sopTitle => 'Procédure';

  @override
  String get sopSectionTitle => 'Procédures';

  @override
  String sopOutstanding(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n étapes en attente',
      one: '1 étape en attente',
      zero: 'toutes les étapes sont faites',
    );
    return '$_temp0';
  }

  @override
  String sopProgress(int done, int total) {
    return '$done sur $total';
  }

  @override
  String get sopBlocking =>
      'Cette procédure doit être terminée avant de pouvoir résoudre le ticket';

  @override
  String get sopReadOnly =>
      'Lecture seule — exécution verrouillée, ou vous ne pouvez pas modifier ce ticket';

  @override
  String get sopSkip => 'Ignorer';

  @override
  String get sopUnskip => 'Ne plus ignorer';

  @override
  String get sopSkipped => 'Ignorée';

  @override
  String get sopSkipReason => 'Pourquoi cette étape est-elle ignorée ?';

  @override
  String get sopSkipReasonRequired =>
      'Indiquez pourquoi cette étape est ignorée';

  @override
  String get sopNote => 'Note';

  @override
  String get sopNoteHint =>
      'Ce qu\'il vaut la peine de consigner sur cette étape…';

  @override
  String get sopClear => 'Effacer la réponse';

  @override
  String get sopSave => 'Enregistrer';

  @override
  String get sopAnswerElsewhere =>
      'Cette étape se répond ailleurs — depuis le ticket lui-même.';

  @override
  String get sopRaiseTicket => 'Créer le ticket';

  @override
  String sopRaisedTicket(int id) {
    return 'Ticket n°$id créé';
  }

  @override
  String get sopLog => 'Historique';

  @override
  String get sopLogEmpty => 'Rien d\'enregistré pour l\'instant';

  @override
  String get sopEmpty => 'Aucune procédure n\'est rattachée à ce ticket';

  @override
  String get presenceTitle => 'Qui est sur ce ticket';

  @override
  String get presenceOnlyYou => 'Vous seul';

  @override
  String presenceTyping(String name) {
    return '$name est en train d\'écrire…';
  }

  @override
  String get presenceClaim => 'Je m\'en occupe';

  @override
  String get presenceRelease => 'Rendre la main';

  @override
  String get presenceTakeover => 'Reprendre';

  @override
  String get presenceClaimedByYou => 'Vous vous en occupez';

  @override
  String presenceClaimedBy(String name) {
    return '$name s\'en occupe';
  }

  @override
  String get presenceClaimTaken =>
      'Quelqu\'un d\'autre l\'a réclamé avant vous';

  @override
  String get capabilityUnavailableTitle => 'Non disponible';

  @override
  String get capabilityUnavailableBody =>
      'Ce module n\'est pas disponible sur ce serveur. Un plugin compagnon plus récent est peut-être nécessaire.';

  @override
  String get actionNeedsConnection => 'Cette action nécessite une connexion';

  @override
  String get close => 'Fermer';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get alertsEmpty => 'Aucune alerte';

  @override
  String get alertsNeedConnection =>
      'Pas de connexion — les alertes sont toujours en direct, jamais mises en cache';

  @override
  String alertNumber(int id) {
    return 'Alerte n°$id';
  }

  @override
  String get alertStateOpen => 'Ouverte';

  @override
  String get alertStateAcked => 'Prise en compte';

  @override
  String get alertStateTicketed => 'Ticket créé';

  @override
  String get alertStateSuppressed => 'Masquée';

  @override
  String get alertStateClosed => 'Fermée';

  @override
  String get alertAck => 'Prendre en compte';

  @override
  String get alertAcked => 'Alerte prise en compte';

  @override
  String alertAckedBy(String name) {
    return 'prise en compte par $name';
  }

  @override
  String get alertClose => 'Fermer l\'alerte';

  @override
  String get alertClosed => 'Alerte fermée';

  @override
  String get alertHost => 'Hôte';

  @override
  String get alertItem => 'Matériel';

  @override
  String get alertEvents => 'Événements';

  @override
  String alertEventCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n événements',
      one: '1 événement',
    );
    return '$_temp0';
  }

  @override
  String get alertFirstSeen => 'Première occurrence';

  @override
  String get alertLastSeen => 'Dernière occurrence';

  @override
  String get alertOpenTicket => 'Ouvrir le ticket créé pour cette alerte';

  @override
  String get alertPageLog => 'Journal des notifications';

  @override
  String get alertPageLogEmpty => 'Personne n\'a été notifié';

  @override
  String get severityCritical => 'Critique';

  @override
  String get severityHigh => 'Élevée';

  @override
  String get severityMedium => 'Moyenne';

  @override
  String get severityLow => 'Faible';

  @override
  String get severityInfo => 'Information';

  @override
  String get oncallTitle => 'Astreinte';

  @override
  String get oncallYou => 'Vous';

  @override
  String get oncallNobody => 'Personne';

  @override
  String oncallHandoff(String name, String when) {
    return '$name prend le relais $when';
  }

  @override
  String get majorTitle => 'Incidents majeurs';

  @override
  String get majorEmpty => 'Aucun incident majeur en cours';

  @override
  String majorNumber(int id) {
    return 'Incident majeur n°$id';
  }

  @override
  String get majorBanner => 'Incident majeur';

  @override
  String get majorDeclare => 'Déclarer un incident majeur';

  @override
  String get majorAttach => 'Rattacher à un incident majeur';

  @override
  String get majorAttached => 'Rattaché à l\'incident majeur';

  @override
  String get majorDeclared => 'Incident majeur déclaré';

  @override
  String get majorCommander => 'Pilote de l\'incident';

  @override
  String get majorDeclaredAt => 'Déclaré';

  @override
  String get majorNextUpdate => 'Prochain point';

  @override
  String get majorUpdates => 'Points de situation';

  @override
  String get majorUpdatesEmpty => 'Aucun point publié';

  @override
  String get majorPostUpdate => 'Publier un point';

  @override
  String get majorAudienceInternal => 'Interne';

  @override
  String get majorAudienceCustomer => 'Client';

  @override
  String get majorUpdatePosted => 'Point publié';

  @override
  String get majorUpdateHint => 'Qu\'est-ce qui a changé ? Et ensuite ?…';

  @override
  String get majorTicket => 'Ticket';

  @override
  String get majorTitleLabel => 'Titre';

  @override
  String get majorFirstUpdateHint => 'Premier point de situation (facultatif)…';

  @override
  String get majorOutcomeNeeded =>
      'Décrivez l\'issue avant de résoudre — cet incident exige une revue post-incident.';

  @override
  String get majorStateOpen => 'Ouvert';

  @override
  String get majorStateInvestigating => 'Investigation';

  @override
  String get majorStateIdentified => 'Cause identifiée';

  @override
  String get majorStateMonitoring => 'Sous surveillance';

  @override
  String get majorStateResolved => 'Résolu';

  @override
  String get majorStateClosed => 'Clos';

  @override
  String get majorResolve => 'Marquer comme résolu';

  @override
  String get majorResolved => 'Incident résolu';

  @override
  String get kedbTitle => 'Erreurs connues';

  @override
  String get kedbEmpty => 'Aucune erreur connue enregistrée';

  @override
  String get kedbNoMatches => 'Aucun résultat';

  @override
  String get kedbSearchHint => 'Rechercher une erreur connue…';

  @override
  String get kedbClearSearch => 'Effacer la recherche';

  @override
  String get kedbNeedsConnection =>
      'Pas de connexion — la base des erreurs connues est uniquement côté serveur';

  @override
  String get kedbBanner => 'Erreur connue';

  @override
  String get kedbUseWorkaround => 'Utiliser le contournement';

  @override
  String get kedbWorkaroundInserted => 'Contournement inséré dans la réponse';

  @override
  String get kedbDismiss => 'Écarter';

  @override
  String get kedbDismissed => 'Écartée';

  @override
  String get kedbHasWorkaround => 'Contournement disponible';

  @override
  String get kedbStatusKnown => 'Connue';

  @override
  String get kedbStatusFixInProgress => 'Correctif en cours';

  @override
  String get kedbStatusRetired => 'Retirée';

  @override
  String get kedbIdentified => 'Identifiée';

  @override
  String get kedbSymptom => 'Symptôme';

  @override
  String get kedbRootCause => 'Cause racine';

  @override
  String get kedbWorkaround => 'Contournement';

  @override
  String get kedbProblem => 'Problème';

  @override
  String get kedbSoftware => 'Logiciel';

  @override
  String kedbUseCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'utilisée $n fois',
      one: 'utilisée une fois',
    );
    return '$_temp0';
  }

  @override
  String get changeCalendarTitle => 'Calendrier des changements';

  @override
  String get changeCalendarEmpty => 'Rien de planifié';

  @override
  String get changeScheduleTitle => 'Planification';

  @override
  String get changeWindowNone => 'Aucune fenêtre planifiée';

  @override
  String get changeNoConflicts => 'Aucun conflit';

  @override
  String get changeFreeze => 'Gel';

  @override
  String get changeRelease => 'Mise en production';

  @override
  String get changeTypeChange => 'Changement';

  @override
  String get changeCollisionSharedCi =>
      'Partage un élément avec un autre changement';

  @override
  String get changeCollisionImpactCi =>
      'Touche un élément impacté par un autre changement';

  @override
  String changeCollisionDismissed(String reason) {
    return 'écarté : $reason';
  }

  @override
  String changeFreezeWarning(String title) {
    return 'Dans la période de gel $title';
  }

  @override
  String get entitleTitle => 'Couverture';

  @override
  String get entitleNoContract => 'Aucun contrat ne couvre ce client';

  @override
  String get entitleNoLabor =>
      'Aucun contrat ne couvre la main-d\'œuvre sur ce ticket';

  @override
  String get entitleNoRate =>
      'Aucun tarif défini : ce travail ne peut pas être facturé';

  @override
  String get entitleBlocked => 'Ce travail n\'est pas couvert';

  @override
  String get entitleApprovalNeeded =>
      'Ce travail nécessite une validation avant d\'être réalisé';

  @override
  String get entitleUncontractedBillable =>
      'Facturable — aucun contrat ne le couvre';

  @override
  String get entitleBillsTicket => 'Facture ce ticket';

  @override
  String entitleEndsSoon(String date) {
    return 'Se termine le $date';
  }

  @override
  String entitleLapsed(String contract, String model, String ended) {
    return '$contract ($model) a expiré le $ended';
  }

  @override
  String entitleBlockHours(String used, String pool) {
    return '$used heures sur $pool consommées';
  }

  @override
  String entitleStale(String age) {
    return 'Réponse datant de $age';
  }

  @override
  String get assistantOffline =>
      'L\'assistant nécessite une connexion : il interroge le modèle sur votre serveur, et rien n\'en fonctionne hors ligne.';

  @override
  String get rightsUnavailableTitle => 'Indisponible pour vous';

  @override
  String get rightsUnavailableBody =>
      'Votre profil GLPI ne l\'inclut pas. Un administrateur peut vous l\'accorder, ou vous pouvez changer de profil si vous en avez un autre.';

  @override
  String get rightsReadOnly => 'Lecture seule avec votre profil';
}
