import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GLPI Mobile'**
  String get appTitle;

  /// No description provided for @serverTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to your GLPI server'**
  String get serverTitle;

  /// No description provided for @serverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrlLabel;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://glpi.example.com'**
  String get serverUrlHint;

  /// No description provided for @serverInvalid.
  ///
  /// In en, this message translates to:
  /// **'No GLPI high-level API found at this address'**
  String get serverInvalid;

  /// No description provided for @serverHelp.
  ///
  /// In en, this message translates to:
  /// **'Your GLPI 11+ server address. The high-level API must be enabled (Setup > General > API).'**
  String get serverHelp;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to sign in'**
  String get scanTitle;

  /// No description provided for @scanInstructions.
  ///
  /// In en, this message translates to:
  /// **'In a web browser, open GLPI, then go to My Settings → Mobile app and scan the QR code shown there.'**
  String get scanInstructions;

  /// No description provided for @scanManualToggle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code manually'**
  String get scanManualToggle;

  /// No description provided for @pairCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pairing code'**
  String get pairCodeLabel;

  /// No description provided for @pairAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get pairAction;

  /// No description provided for @pairFailed.
  ///
  /// In en, this message translates to:
  /// **'Pairing failed. The code may be expired or already used — open the Mobile app tab again for a fresh code.'**
  String get pairFailed;

  /// No description provided for @contextTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your context'**
  String get contextTitle;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @entityLabel.
  ///
  /// In en, this message translates to:
  /// **'Entity'**
  String get entityLabel;

  /// No description provided for @entityRecursive.
  ///
  /// In en, this message translates to:
  /// **'Include sub-entities'**
  String get entityRecursive;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueTitle;

  /// No description provided for @queueTabMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get queueTabMine;

  /// No description provided for @queueTabGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get queueTabGroups;

  /// No description provided for @queueTabUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get queueTabUnassigned;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tickets here yet'**
  String get queueEmpty;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncTitle;

  /// No description provided for @syncEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs your attention'**
  String get syncEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsContext.
  ///
  /// In en, this message translates to:
  /// **'Profile & entity'**
  String get settingsContext;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your cached data stays on this device. You will need to sign in again.'**
  String get logoutConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — changes will sync when back online'**
  String get offlineBanner;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get genericError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {user} on {server}'**
  String signedInAs(String user, String server);

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistantTitle;

  /// No description provided for @assistantAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get assistantAsk;

  /// No description provided for @assistantStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get assistantStop;

  /// No description provided for @assistantHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about this problem…'**
  String get assistantHint;

  /// No description provided for @assistantThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get assistantThinking;

  /// No description provided for @assistantWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get assistantWorking;

  /// No description provided for @assistantTurn.
  ///
  /// In en, this message translates to:
  /// **'Turn {n}…'**
  String assistantTurn(int n);

  /// No description provided for @assistantRunningTool.
  ///
  /// In en, this message translates to:
  /// **'Looking: {tool}'**
  String assistantRunningTool(String tool);

  /// No description provided for @assistantHistory.
  ///
  /// In en, this message translates to:
  /// **'Past conversations'**
  String get assistantHistory;

  /// No description provided for @assistantNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get assistantNoHistory;

  /// No description provided for @assistantUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled conversation'**
  String get assistantUntitled;

  /// No description provided for @assistantClear.
  ///
  /// In en, this message translates to:
  /// **'Clear this conversation'**
  String get assistantClear;

  /// No description provided for @assistantCleared.
  ///
  /// In en, this message translates to:
  /// **'Conversation cleared'**
  String get assistantCleared;

  /// No description provided for @assistantEmpty.
  ///
  /// In en, this message translates to:
  /// **'Ask about a machine, a ticket, or what you are seeing. The assistant can look things up before answering.'**
  String get assistantEmpty;

  /// No description provided for @assistantEmptyOn.
  ///
  /// In en, this message translates to:
  /// **'Ask about {context}. The assistant already knows what you have open.'**
  String assistantEmptyOn(String context);

  /// No description provided for @assistantOnTicket.
  ///
  /// In en, this message translates to:
  /// **'Ask the assistant'**
  String get assistantOnTicket;

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiTitle;

  /// No description provided for @aiDraftSolution.
  ///
  /// In en, this message translates to:
  /// **'Draft a solution'**
  String get aiDraftSolution;

  /// No description provided for @aiDraftRedo.
  ///
  /// In en, this message translates to:
  /// **'Draft again'**
  String get aiDraftRedo;

  /// No description provided for @aiDrafting.
  ///
  /// In en, this message translates to:
  /// **'Drafting…'**
  String get aiDrafting;

  /// No description provided for @aiDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafted solution'**
  String get aiDraftTitle;

  /// No description provided for @aiDraftUse.
  ///
  /// In en, this message translates to:
  /// **'Use it'**
  String get aiDraftUse;

  /// No description provided for @aiDraftDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get aiDraftDiscard;

  /// No description provided for @aiDraftInserted.
  ///
  /// In en, this message translates to:
  /// **'Draft moved into the reply box'**
  String get aiDraftInserted;

  /// No description provided for @aiDraftDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Draft discarded'**
  String get aiDraftDiscarded;

  /// No description provided for @aiDraftUnread.
  ///
  /// In en, this message translates to:
  /// **'Read it before you send it — it is a draft, not an answer.'**
  String get aiDraftUnread;

  /// No description provided for @aiConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {level}'**
  String aiConfidence(String level);

  /// No description provided for @aiTriageTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested triage'**
  String get aiTriageTitle;

  /// No description provided for @aiTriageRun.
  ///
  /// In en, this message translates to:
  /// **'Run triage'**
  String get aiTriageRun;

  /// No description provided for @aiTriageRunning.
  ///
  /// In en, this message translates to:
  /// **'Triaging…'**
  String get aiTriageRunning;

  /// No description provided for @aiTriageApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get aiTriageApply;

  /// No description provided for @aiTriageDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get aiTriageDismiss;

  /// No description provided for @aiTriageApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get aiTriageApplied;

  /// No description provided for @aiFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get aiFieldCategory;

  /// No description provided for @aiFieldUrgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get aiFieldUrgency;

  /// No description provided for @aiFieldImpact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get aiFieldImpact;

  /// No description provided for @aiFieldProcedure.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get aiFieldProcedure;

  /// No description provided for @aiReplyReview.
  ///
  /// In en, this message translates to:
  /// **'Check this reply'**
  String get aiReplyReview;

  /// No description provided for @aiReplyReviewing.
  ///
  /// In en, this message translates to:
  /// **'Reading it…'**
  String get aiReplyReviewing;

  /// No description provided for @aiReplyClean.
  ///
  /// In en, this message translates to:
  /// **'Nothing to flag — it reads fine.'**
  String get aiReplyClean;

  /// No description provided for @aiReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you send'**
  String get aiReplyTitle;

  /// No description provided for @aiReplySendAnyway.
  ///
  /// In en, this message translates to:
  /// **'Send anyway'**
  String get aiReplySendAnyway;

  /// No description provided for @aiReplyKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get aiReplyKeepEditing;

  /// No description provided for @sopTitle.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get sopTitle;

  /// No description provided for @sopSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Procedures'**
  String get sopSectionTitle;

  /// No description provided for @sopOutstanding.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{all steps done} =1{1 step outstanding} other{{n} steps outstanding}}'**
  String sopOutstanding(int n);

  /// No description provided for @sopProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String sopProgress(int done, int total);

  /// No description provided for @sopBlocking.
  ///
  /// In en, this message translates to:
  /// **'This procedure must be finished before the ticket can be solved'**
  String get sopBlocking;

  /// No description provided for @sopReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only — this run is locked, or you cannot edit this ticket'**
  String get sopReadOnly;

  /// No description provided for @sopSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get sopSkip;

  /// No description provided for @sopUnskip.
  ///
  /// In en, this message translates to:
  /// **'Un-skip'**
  String get sopUnskip;

  /// No description provided for @sopSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get sopSkipped;

  /// No description provided for @sopSkipReason.
  ///
  /// In en, this message translates to:
  /// **'Why is this being skipped?'**
  String get sopSkipReason;

  /// No description provided for @sopSkipReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Say why this step is being skipped'**
  String get sopSkipReasonRequired;

  /// No description provided for @sopNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get sopNote;

  /// No description provided for @sopNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything worth recording about this step…'**
  String get sopNoteHint;

  /// No description provided for @sopClear.
  ///
  /// In en, this message translates to:
  /// **'Clear answer'**
  String get sopClear;

  /// No description provided for @sopSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get sopSave;

  /// No description provided for @sopAnswerElsewhere.
  ///
  /// In en, this message translates to:
  /// **'This step is answered elsewhere — from the ticket itself.'**
  String get sopAnswerElsewhere;

  /// No description provided for @sopRaiseTicket.
  ///
  /// In en, this message translates to:
  /// **'Raise the ticket'**
  String get sopRaiseTicket;

  /// No description provided for @sopRaisedTicket.
  ///
  /// In en, this message translates to:
  /// **'Raised ticket #{id}'**
  String sopRaisedTicket(int id);

  /// No description provided for @sopLog.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get sopLog;

  /// No description provided for @sopLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet'**
  String get sopLogEmpty;

  /// No description provided for @sopEmpty.
  ///
  /// In en, this message translates to:
  /// **'No procedure is attached to this ticket'**
  String get sopEmpty;

  /// No description provided for @presenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is on this'**
  String get presenceTitle;

  /// No description provided for @presenceOnlyYou.
  ///
  /// In en, this message translates to:
  /// **'Only you'**
  String get presenceOnlyYou;

  /// No description provided for @presenceTyping.
  ///
  /// In en, this message translates to:
  /// **'{name} is typing…'**
  String presenceTyping(String name);

  /// No description provided for @presenceClaim.
  ///
  /// In en, this message translates to:
  /// **'I am working this'**
  String get presenceClaim;

  /// No description provided for @presenceRelease.
  ///
  /// In en, this message translates to:
  /// **'Hand it back'**
  String get presenceRelease;

  /// No description provided for @presenceTakeover.
  ///
  /// In en, this message translates to:
  /// **'Take it over'**
  String get presenceTakeover;

  /// No description provided for @presenceClaimedByYou.
  ///
  /// In en, this message translates to:
  /// **'You have this'**
  String get presenceClaimedByYou;

  /// No description provided for @presenceClaimedBy.
  ///
  /// In en, this message translates to:
  /// **'{name} is working this'**
  String presenceClaimedBy(String name);

  /// No description provided for @presenceClaimTaken.
  ///
  /// In en, this message translates to:
  /// **'Somebody else claimed it first'**
  String get presenceClaimTaken;

  /// No description provided for @capabilityUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get capabilityUnavailableTitle;

  /// No description provided for @capabilityUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This module is not available on this server. It may need a newer companion plugin.'**
  String get capabilityUnavailableBody;

  /// No description provided for @actionNeedsConnection.
  ///
  /// In en, this message translates to:
  /// **'This action needs a connection'**
  String get actionNeedsConnection;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @alertsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alerts'**
  String get alertsEmpty;

  /// No description provided for @alertsNeedConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection — alerts are always live, never cached'**
  String get alertsNeedConnection;

  /// No description provided for @alertNumber.
  ///
  /// In en, this message translates to:
  /// **'Alert #{id}'**
  String alertNumber(int id);

  /// No description provided for @alertStateOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get alertStateOpen;

  /// No description provided for @alertStateAcked.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get alertStateAcked;

  /// No description provided for @alertStateTicketed.
  ///
  /// In en, this message translates to:
  /// **'Ticketed'**
  String get alertStateTicketed;

  /// No description provided for @alertStateSuppressed.
  ///
  /// In en, this message translates to:
  /// **'Suppressed'**
  String get alertStateSuppressed;

  /// No description provided for @alertStateClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get alertStateClosed;

  /// No description provided for @alertAck.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get alertAck;

  /// No description provided for @alertAcked.
  ///
  /// In en, this message translates to:
  /// **'Alert acknowledged'**
  String get alertAcked;

  /// No description provided for @alertAckedBy.
  ///
  /// In en, this message translates to:
  /// **'acknowledged by {name}'**
  String alertAckedBy(String name);

  /// No description provided for @alertClose.
  ///
  /// In en, this message translates to:
  /// **'Close alert'**
  String get alertClose;

  /// No description provided for @alertClosed.
  ///
  /// In en, this message translates to:
  /// **'Alert closed'**
  String get alertClosed;

  /// No description provided for @alertHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get alertHost;

  /// No description provided for @alertItem.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get alertItem;

  /// No description provided for @alertEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get alertEvents;

  /// No description provided for @alertEventCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 event} other{{n} events}}'**
  String alertEventCount(int n);

  /// No description provided for @alertFirstSeen.
  ///
  /// In en, this message translates to:
  /// **'First seen'**
  String get alertFirstSeen;

  /// No description provided for @alertLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get alertLastSeen;

  /// No description provided for @alertOpenTicket.
  ///
  /// In en, this message translates to:
  /// **'Open the ticket raised for this alert'**
  String get alertOpenTicket;

  /// No description provided for @alertPageLog.
  ///
  /// In en, this message translates to:
  /// **'Paging log'**
  String get alertPageLog;

  /// No description provided for @alertPageLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody has been paged'**
  String get alertPageLogEmpty;

  /// No description provided for @severityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityCritical;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityHigh;

  /// No description provided for @severityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get severityMedium;

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get severityLow;

  /// No description provided for @severityInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get severityInfo;

  /// No description provided for @oncallTitle.
  ///
  /// In en, this message translates to:
  /// **'On call'**
  String get oncallTitle;

  /// No description provided for @oncallYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get oncallYou;

  /// No description provided for @oncallNobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get oncallNobody;

  /// No description provided for @oncallHandoff.
  ///
  /// In en, this message translates to:
  /// **'{name} takes over {when}'**
  String oncallHandoff(String name, String when);

  /// No description provided for @majorTitle.
  ///
  /// In en, this message translates to:
  /// **'Major incidents'**
  String get majorTitle;

  /// No description provided for @majorEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open major incidents'**
  String get majorEmpty;

  /// No description provided for @majorNumber.
  ///
  /// In en, this message translates to:
  /// **'Major incident #{id}'**
  String majorNumber(int id);

  /// No description provided for @majorBanner.
  ///
  /// In en, this message translates to:
  /// **'Major incident'**
  String get majorBanner;

  /// No description provided for @majorDeclare.
  ///
  /// In en, this message translates to:
  /// **'Declare major incident'**
  String get majorDeclare;

  /// No description provided for @majorAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach to major incident'**
  String get majorAttach;

  /// No description provided for @majorAttached.
  ///
  /// In en, this message translates to:
  /// **'Attached to major incident'**
  String get majorAttached;

  /// No description provided for @majorDeclared.
  ///
  /// In en, this message translates to:
  /// **'Major incident declared'**
  String get majorDeclared;

  /// No description provided for @majorCommander.
  ///
  /// In en, this message translates to:
  /// **'Commander'**
  String get majorCommander;

  /// No description provided for @majorDeclaredAt.
  ///
  /// In en, this message translates to:
  /// **'Declared'**
  String get majorDeclaredAt;

  /// No description provided for @majorNextUpdate.
  ///
  /// In en, this message translates to:
  /// **'Next update'**
  String get majorNextUpdate;

  /// No description provided for @majorUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get majorUpdates;

  /// No description provided for @majorUpdatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No updates posted yet'**
  String get majorUpdatesEmpty;

  /// No description provided for @majorPostUpdate.
  ///
  /// In en, this message translates to:
  /// **'Post update'**
  String get majorPostUpdate;

  /// No description provided for @majorAudienceInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal'**
  String get majorAudienceInternal;

  /// No description provided for @majorAudienceCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get majorAudienceCustomer;

  /// No description provided for @majorUpdatePosted.
  ///
  /// In en, this message translates to:
  /// **'Update posted'**
  String get majorUpdatePosted;

  /// No description provided for @majorUpdateHint.
  ///
  /// In en, this message translates to:
  /// **'What changed? What happens next?…'**
  String get majorUpdateHint;

  /// No description provided for @majorTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get majorTicket;

  /// No description provided for @majorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get majorTitleLabel;

  /// No description provided for @majorFirstUpdateHint.
  ///
  /// In en, this message translates to:
  /// **'First status update (optional)…'**
  String get majorFirstUpdateHint;

  /// No description provided for @majorOutcomeNeeded.
  ///
  /// In en, this message translates to:
  /// **'Describe the outcome before resolving — this incident requires a post-incident review.'**
  String get majorOutcomeNeeded;

  /// No description provided for @majorStateOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get majorStateOpen;

  /// No description provided for @majorStateInvestigating.
  ///
  /// In en, this message translates to:
  /// **'Investigating'**
  String get majorStateInvestigating;

  /// No description provided for @majorStateIdentified.
  ///
  /// In en, this message translates to:
  /// **'Identified'**
  String get majorStateIdentified;

  /// No description provided for @majorStateMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get majorStateMonitoring;

  /// No description provided for @majorStateResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get majorStateResolved;

  /// No description provided for @majorStateClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get majorStateClosed;

  /// No description provided for @majorResolve.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get majorResolve;

  /// No description provided for @majorResolved.
  ///
  /// In en, this message translates to:
  /// **'Incident resolved'**
  String get majorResolved;

  /// No description provided for @kedbTitle.
  ///
  /// In en, this message translates to:
  /// **'Known errors'**
  String get kedbTitle;

  /// No description provided for @kedbEmpty.
  ///
  /// In en, this message translates to:
  /// **'No known errors recorded'**
  String get kedbEmpty;

  /// No description provided for @kedbNoMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that'**
  String get kedbNoMatches;

  /// No description provided for @kedbSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search known errors…'**
  String get kedbSearchHint;

  /// No description provided for @kedbClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear the search'**
  String get kedbClearSearch;

  /// No description provided for @kedbNeedsConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection — the known-error database is server-side only'**
  String get kedbNeedsConnection;

  /// No description provided for @kedbBanner.
  ///
  /// In en, this message translates to:
  /// **'Known error'**
  String get kedbBanner;

  /// No description provided for @kedbUseWorkaround.
  ///
  /// In en, this message translates to:
  /// **'Use workaround'**
  String get kedbUseWorkaround;

  /// No description provided for @kedbWorkaroundInserted.
  ///
  /// In en, this message translates to:
  /// **'Workaround moved into the reply box'**
  String get kedbWorkaroundInserted;

  /// No description provided for @kedbDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get kedbDismiss;

  /// No description provided for @kedbDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get kedbDismissed;

  /// No description provided for @kedbHasWorkaround.
  ///
  /// In en, this message translates to:
  /// **'Workaround available'**
  String get kedbHasWorkaround;

  /// No description provided for @kedbStatusKnown.
  ///
  /// In en, this message translates to:
  /// **'Known'**
  String get kedbStatusKnown;

  /// No description provided for @kedbStatusFixInProgress.
  ///
  /// In en, this message translates to:
  /// **'Fix in progress'**
  String get kedbStatusFixInProgress;

  /// No description provided for @kedbStatusRetired.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get kedbStatusRetired;

  /// No description provided for @kedbIdentified.
  ///
  /// In en, this message translates to:
  /// **'Identified'**
  String get kedbIdentified;

  /// No description provided for @kedbSymptom.
  ///
  /// In en, this message translates to:
  /// **'Symptom'**
  String get kedbSymptom;

  /// No description provided for @kedbRootCause.
  ///
  /// In en, this message translates to:
  /// **'Root cause'**
  String get kedbRootCause;

  /// No description provided for @kedbWorkaround.
  ///
  /// In en, this message translates to:
  /// **'Workaround'**
  String get kedbWorkaround;

  /// No description provided for @kedbProblem.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get kedbProblem;

  /// No description provided for @kedbSoftware.
  ///
  /// In en, this message translates to:
  /// **'Software'**
  String get kedbSoftware;

  /// No description provided for @kedbUseCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{used once} other{used {n} times}}'**
  String kedbUseCount(int n);

  /// No description provided for @changeCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Change calendar'**
  String get changeCalendarTitle;

  /// No description provided for @changeCalendarEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get changeCalendarEmpty;

  /// No description provided for @changeScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get changeScheduleTitle;

  /// No description provided for @changeWindowNone.
  ///
  /// In en, this message translates to:
  /// **'No window planned'**
  String get changeWindowNone;

  /// No description provided for @changeNoConflicts.
  ///
  /// In en, this message translates to:
  /// **'No conflicts'**
  String get changeNoConflicts;

  /// No description provided for @changeFreeze.
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get changeFreeze;

  /// No description provided for @changeRelease.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get changeRelease;

  /// No description provided for @changeTypeChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeTypeChange;

  /// No description provided for @changeCollisionSharedCi.
  ///
  /// In en, this message translates to:
  /// **'Shares an asset with another change'**
  String get changeCollisionSharedCi;

  /// No description provided for @changeCollisionImpactCi.
  ///
  /// In en, this message translates to:
  /// **'Touches an asset another change impacts'**
  String get changeCollisionImpactCi;

  /// No description provided for @changeCollisionDismissed.
  ///
  /// In en, this message translates to:
  /// **'dismissed: {reason}'**
  String changeCollisionDismissed(String reason);

  /// No description provided for @changeFreezeWarning.
  ///
  /// In en, this message translates to:
  /// **'Inside the {title} freeze'**
  String changeFreezeWarning(String title);

  /// No description provided for @entitleTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get entitleTitle;

  /// No description provided for @entitleNoContract.
  ///
  /// In en, this message translates to:
  /// **'No contract covers this customer'**
  String get entitleNoContract;

  /// No description provided for @entitleNoLabor.
  ///
  /// In en, this message translates to:
  /// **'No contract covers labour on this ticket'**
  String get entitleNoLabor;

  /// No description provided for @entitleNoRate.
  ///
  /// In en, this message translates to:
  /// **'No rate is set, so this work cannot be priced'**
  String get entitleNoRate;

  /// No description provided for @entitleBlocked.
  ///
  /// In en, this message translates to:
  /// **'This work is not covered'**
  String get entitleBlocked;

  /// No description provided for @entitleApprovalNeeded.
  ///
  /// In en, this message translates to:
  /// **'This work needs approval before it is done'**
  String get entitleApprovalNeeded;

  /// No description provided for @entitleUncontractedBillable.
  ///
  /// In en, this message translates to:
  /// **'Billable — no contract covers it'**
  String get entitleUncontractedBillable;

  /// No description provided for @entitleBillsTicket.
  ///
  /// In en, this message translates to:
  /// **'Bills this ticket'**
  String get entitleBillsTicket;

  /// No description provided for @entitleEndsSoon.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String entitleEndsSoon(String date);

  /// No description provided for @entitleLapsed.
  ///
  /// In en, this message translates to:
  /// **'{contract} ({model}) ran out on {ended}'**
  String entitleLapsed(String contract, String model, String ended);

  /// No description provided for @entitleBlockHours.
  ///
  /// In en, this message translates to:
  /// **'{used} of {pool} hours used'**
  String entitleBlockHours(String used, String pool);

  /// No description provided for @entitleStale.
  ///
  /// In en, this message translates to:
  /// **'Answered {age} ago'**
  String entitleStale(String age);

  /// No description provided for @assistantOffline.
  ///
  /// In en, this message translates to:
  /// **'The assistant needs a connection — it asks the model on your server, and nothing about it works offline.'**
  String get assistantOffline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
