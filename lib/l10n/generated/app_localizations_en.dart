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

  @override
  String get assistantTitle => 'Assistant';

  @override
  String get assistantAsk => 'Ask';

  @override
  String get assistantStop => 'Stop';

  @override
  String get assistantHint => 'Ask about this problem…';

  @override
  String get assistantThinking => 'Thinking…';

  @override
  String get assistantWorking => 'Working…';

  @override
  String assistantTurn(int n) {
    return 'Turn $n…';
  }

  @override
  String assistantRunningTool(String tool) {
    return 'Looking: $tool';
  }

  @override
  String get assistantHistory => 'Past conversations';

  @override
  String get assistantNoHistory => 'No conversations yet';

  @override
  String get assistantUntitled => 'Untitled conversation';

  @override
  String get assistantClear => 'Clear this conversation';

  @override
  String get assistantCleared => 'Conversation cleared';

  @override
  String get assistantEmpty =>
      'Ask about a machine, a ticket, or what you are seeing. The assistant can look things up before answering.';

  @override
  String assistantEmptyOn(String context) {
    return 'Ask about $context. The assistant already knows what you have open.';
  }

  @override
  String get assistantOnTicket => 'Ask the assistant';

  @override
  String get aiTitle => 'AI';

  @override
  String get aiDraftSolution => 'Draft a solution';

  @override
  String get aiDraftRedo => 'Draft again';

  @override
  String get aiDrafting => 'Drafting…';

  @override
  String get aiDraftTitle => 'Drafted solution';

  @override
  String get aiDraftUse => 'Use it';

  @override
  String get aiDraftDiscard => 'Discard';

  @override
  String get aiDraftInserted => 'Draft moved into the reply box';

  @override
  String get aiDraftDiscarded => 'Draft discarded';

  @override
  String get aiDraftUnread =>
      'Read it before you send it — it is a draft, not an answer.';

  @override
  String aiConfidence(String level) {
    return 'Confidence: $level';
  }

  @override
  String get aiTriageTitle => 'Suggested triage';

  @override
  String get aiTriageRun => 'Run triage';

  @override
  String get aiTriageRunning => 'Triaging…';

  @override
  String get aiTriageApply => 'Apply';

  @override
  String get aiTriageDismiss => 'Dismiss';

  @override
  String get aiTriageApplied => 'Applied';

  @override
  String get aiFieldCategory => 'Category';

  @override
  String get aiFieldUrgency => 'Urgency';

  @override
  String get aiFieldImpact => 'Impact';

  @override
  String get aiFieldProcedure => 'Procedure';

  @override
  String get aiReplyReview => 'Check this reply';

  @override
  String get aiReplyReviewing => 'Reading it…';

  @override
  String get aiReplyClean => 'Nothing to flag — it reads fine.';

  @override
  String get aiReplyTitle => 'Before you send';

  @override
  String get aiReplySendAnyway => 'Send anyway';

  @override
  String get aiReplyKeepEditing => 'Keep editing';

  @override
  String get sopTitle => 'Procedure';

  @override
  String get sopSectionTitle => 'Procedures';

  @override
  String sopOutstanding(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n steps outstanding',
      one: '1 step outstanding',
      zero: 'all steps done',
    );
    return '$_temp0';
  }

  @override
  String sopProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get sopBlocking =>
      'This procedure must be finished before the ticket can be solved';

  @override
  String get sopReadOnly =>
      'Read-only — this run is locked, or you cannot edit this ticket';

  @override
  String get sopSkip => 'Skip';

  @override
  String get sopUnskip => 'Un-skip';

  @override
  String get sopSkipped => 'Skipped';

  @override
  String get sopSkipReason => 'Why is this being skipped?';

  @override
  String get sopSkipReasonRequired => 'Say why this step is being skipped';

  @override
  String get sopNote => 'Note';

  @override
  String get sopNoteHint => 'Anything worth recording about this step…';

  @override
  String get sopClear => 'Clear answer';

  @override
  String get sopSave => 'Save';

  @override
  String get sopAnswerElsewhere =>
      'This step is answered elsewhere — from the ticket itself.';

  @override
  String get sopRaiseTicket => 'Raise the ticket';

  @override
  String sopRaisedTicket(int id) {
    return 'Raised ticket #$id';
  }

  @override
  String get sopLog => 'History';

  @override
  String get sopLogEmpty => 'Nothing recorded yet';

  @override
  String get sopEmpty => 'No procedure is attached to this ticket';

  @override
  String get presenceTitle => 'Who is on this';

  @override
  String get presenceOnlyYou => 'Only you';

  @override
  String presenceTyping(String name) {
    return '$name is typing…';
  }

  @override
  String get presenceClaim => 'I am working this';

  @override
  String get presenceRelease => 'Hand it back';

  @override
  String get presenceTakeover => 'Take it over';

  @override
  String get presenceClaimedByYou => 'You have this';

  @override
  String presenceClaimedBy(String name) {
    return '$name is working this';
  }

  @override
  String get presenceClaimTaken => 'Somebody else claimed it first';

  @override
  String get capabilityUnavailableTitle => 'Not available';

  @override
  String get capabilityUnavailableBody =>
      'This module is not available on this server. It may need a newer companion plugin.';

  @override
  String get actionNeedsConnection => 'This action needs a connection';

  @override
  String get close => 'Close';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsEmpty => 'No alerts';

  @override
  String get alertsNeedConnection =>
      'No connection — alerts are always live, never cached';

  @override
  String alertNumber(int id) {
    return 'Alert #$id';
  }

  @override
  String get alertStateOpen => 'Open';

  @override
  String get alertStateAcked => 'Acknowledged';

  @override
  String get alertStateTicketed => 'Ticketed';

  @override
  String get alertStateSuppressed => 'Suppressed';

  @override
  String get alertStateClosed => 'Closed';

  @override
  String get alertAck => 'Acknowledge';

  @override
  String get alertAcked => 'Alert acknowledged';

  @override
  String alertAckedBy(String name) {
    return 'acknowledged by $name';
  }

  @override
  String get alertClose => 'Close alert';

  @override
  String get alertClosed => 'Alert closed';

  @override
  String get alertHost => 'Host';

  @override
  String get alertItem => 'Asset';

  @override
  String get alertEvents => 'Events';

  @override
  String alertEventCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get alertFirstSeen => 'First seen';

  @override
  String get alertLastSeen => 'Last seen';

  @override
  String get alertOpenTicket => 'Open the ticket raised for this alert';

  @override
  String get alertPageLog => 'Paging log';

  @override
  String get alertPageLogEmpty => 'Nobody has been paged';

  @override
  String get severityCritical => 'Critical';

  @override
  String get severityHigh => 'High';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityLow => 'Low';

  @override
  String get severityInfo => 'Info';

  @override
  String get oncallTitle => 'On call';

  @override
  String get oncallYou => 'You';

  @override
  String get oncallNobody => 'Nobody';

  @override
  String oncallHandoff(String name, String when) {
    return '$name takes over $when';
  }

  @override
  String get majorTitle => 'Major incidents';

  @override
  String get majorEmpty => 'No open major incidents';

  @override
  String majorNumber(int id) {
    return 'Major incident #$id';
  }

  @override
  String get majorBanner => 'Major incident';

  @override
  String get majorDeclare => 'Declare major incident';

  @override
  String get majorAttach => 'Attach to major incident';

  @override
  String get majorAttached => 'Attached to major incident';

  @override
  String get majorDeclared => 'Major incident declared';

  @override
  String get majorCommander => 'Commander';

  @override
  String get majorDeclaredAt => 'Declared';

  @override
  String get majorNextUpdate => 'Next update';

  @override
  String get majorUpdates => 'Updates';

  @override
  String get majorUpdatesEmpty => 'No updates posted yet';

  @override
  String get majorPostUpdate => 'Post update';

  @override
  String get majorAudienceInternal => 'Internal';

  @override
  String get majorAudienceCustomer => 'Public';

  @override
  String get majorUpdatePosted => 'Update posted';

  @override
  String get majorUpdateHint => 'What changed? What happens next?…';

  @override
  String get majorTicket => 'Ticket';

  @override
  String get majorTitleLabel => 'Title';

  @override
  String get majorFirstUpdateHint => 'First status update (optional)…';

  @override
  String get majorOutcomeNeeded =>
      'Describe the outcome before resolving — this incident requires a post-incident review.';

  @override
  String get majorStateOpen => 'Open';

  @override
  String get majorStateInvestigating => 'Investigating';

  @override
  String get majorStateIdentified => 'Identified';

  @override
  String get majorStateMonitoring => 'Monitoring';

  @override
  String get majorStateResolved => 'Resolved';

  @override
  String get majorStateClosed => 'Closed';

  @override
  String get majorResolve => 'Mark resolved';

  @override
  String get majorResolved => 'Incident resolved';

  @override
  String get kedbTitle => 'Known errors';

  @override
  String get kedbEmpty => 'No known errors recorded';

  @override
  String get kedbNoMatches => 'Nothing matches that';

  @override
  String get kedbSearchHint => 'Search known errors…';

  @override
  String get kedbClearSearch => 'Clear the search';

  @override
  String get kedbNeedsConnection =>
      'No connection — the known-error database is server-side only';

  @override
  String get kedbBanner => 'Known error';

  @override
  String get kedbUseWorkaround => 'Use workaround';

  @override
  String get kedbWorkaroundInserted => 'Workaround moved into the reply box';

  @override
  String get kedbDismiss => 'Dismiss';

  @override
  String get kedbDismissed => 'Dismissed';

  @override
  String get kedbHasWorkaround => 'Workaround available';

  @override
  String get kedbStatusKnown => 'Known';

  @override
  String get kedbStatusFixInProgress => 'Fix in progress';

  @override
  String get kedbStatusRetired => 'Retired';

  @override
  String get kedbIdentified => 'Identified';

  @override
  String get kedbSymptom => 'Symptom';

  @override
  String get kedbRootCause => 'Root cause';

  @override
  String get kedbWorkaround => 'Workaround';

  @override
  String get kedbProblem => 'Problem';

  @override
  String get kedbSoftware => 'Software';

  @override
  String kedbUseCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'used $n times',
      one: 'used once',
    );
    return '$_temp0';
  }

  @override
  String get changeCalendarTitle => 'Change calendar';

  @override
  String get changeCalendarEmpty => 'Nothing scheduled';

  @override
  String get changeScheduleTitle => 'Schedule';

  @override
  String get changeWindowNone => 'No window planned';

  @override
  String get changeNoConflicts => 'No conflicts';

  @override
  String get changeFreeze => 'Freeze';

  @override
  String get changeRelease => 'Release';

  @override
  String get changeTypeChange => 'Change';

  @override
  String get changeCollisionSharedCi => 'Shares an asset with another change';

  @override
  String get changeCollisionImpactCi =>
      'Touches an asset another change impacts';

  @override
  String changeCollisionDismissed(String reason) {
    return 'dismissed: $reason';
  }

  @override
  String changeFreezeWarning(String title) {
    return 'Inside the $title freeze';
  }

  @override
  String get entitleTitle => 'Cover';

  @override
  String get entitleNoContract => 'No contract covers this entity';

  @override
  String get entitleNoLabor => 'No contract covers labour on this ticket';

  @override
  String get entitleNoRate => 'No rate is set, so this work cannot be priced';

  @override
  String get entitleBlocked => 'This work is not covered';

  @override
  String get entitleApprovalNeeded =>
      'This work needs approval before it is done';

  @override
  String get entitleUncontractedBillable => 'Billable — no contract covers it';

  @override
  String get entitleBillsTicket => 'Bills this ticket';

  @override
  String entitleEndsSoon(String date) {
    return 'Ends $date';
  }

  @override
  String entitleLapsed(String contract, String model, String ended) {
    return '$contract ($model) ran out on $ended';
  }

  @override
  String entitleBlockHours(String used, String pool) {
    return '$used of $pool hours used';
  }

  @override
  String entitleStale(String age) {
    return 'Answered $age ago';
  }

  @override
  String get assistantOffline =>
      'The assistant needs a connection — it asks the model on your server, and nothing about it works offline.';

  @override
  String get rightsUnavailableTitle => 'Not available to you';

  @override
  String get rightsUnavailableBody =>
      'Your GLPI profile doesn\'t include this. An administrator can grant it, or you can switch to another profile if you have one.';

  @override
  String get rightsReadOnly => 'Read-only with your profile';
}
