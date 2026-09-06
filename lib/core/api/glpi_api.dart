import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/capabilities.dart';
import 'dto/ai_dto.dart';
import 'dto/attachment_dto.dart';
import 'dto/catalog_dto.dart';
import 'dto/change_dto.dart';
import 'dto/dropdown_dto.dart';
import 'dto/entitle_dto.dart';
import 'dto/form_dto.dart';
import 'dto/itil_link_dto.dart';
import 'dto/kedb_dto.dart';
import 'dto/major_dto.dart';
import 'dto/planning_dto.dart';
import 'dto/presence_dto.dart';
import 'dto/project_dto.dart';
import 'dto/signal_dto.dart';
import 'dto/sop_dto.dart';
import 'dto/ticket_dto.dart';
import 'dto/timeline_dto.dart';
import 'dto/tools_dto.dart';
import 'dto/user_ref.dart';
import 'errors.dart';
import 'itil_type.dart';
import 'rsql.dart';
import 'sse.dart';

/// A page of results plus the total count parsed from `Content-Range`.
class Page<T> {
  const Page(this.items, this.total);
  final List<T> items;
  final int total;
}

/// Firebase client config the app uses to initialise FCM at runtime, so a
/// single published app works against each self-hosted instance's own Firebase
/// project (no baked-in google-services.json). These values are not secret.
class FcmOptions {
  const FcmOptions({
    required this.projectId,
    required this.appId,
    required this.apiKey,
    required this.senderId,
  });
  final String projectId;
  final String appId;
  final String apiKey;
  final String senderId;

  static FcmOptions? fromJson(Object? json) {
    if (json is! Map) return null;
    final projectId = json['project_id'] as String?;
    final appId = json['app_id'] as String?;
    final apiKey = json['api_key'] as String?;
    final senderId = json['sender_id'] as String?;
    if (projectId == null ||
        appId == null ||
        apiKey == null ||
        senderId == null) {
      return null;
    }
    return FcmOptions(
      projectId: projectId,
      appId: appId,
      apiKey: apiKey,
      senderId: senderId,
    );
  }
}

/// Push configuration from the companion plugin: the server VAPID public key
/// (for UnifiedPush registration), which transports are enabled server-side,
/// and the FCM client config (when configured).
class PushConfig {
  const PushConfig({
    required this.vapidPublicKey,
    required this.transports,
    this.fcm,
  });
  final String vapidPublicKey;
  final Map<String, bool> transports;
  final FcmOptions? fcm;
}

/// The seam the UI/sync layers depend on; faked in tests, HL-backed in prod.
abstract class GlpiApi {
  Future<Page<TicketDto>> searchTickets({
    Rsql? filter,
    String sort = 'date_mod:desc',
    int start = 0,
    int limit = 100,
    String itemtype = itilTicket,
  });

  Future<TicketDto> getTicket(int id, {String itemtype = itilTicket});

  /// Find a ticket we previously created by its idempotency marker (embedded in
  /// the content) — for duplicate-POST recovery. Returns the id or null.
  Future<int?> findTicketByMarker(
    String opUuid, {
    String itemtype = itilTicket,
  });

  Future<List<TimelineEntryDto>> getTimeline(
    int ticketId, {
    String itemtype = itilTicket,
  });

  /// A ticket's attached documents.
  Future<List<AttachmentDto>> listAttachments(
    int ticketId, {
    String itemtype = itilTicket,
  });

  /// Upload a file as a ticket attachment (multipart, via the plugin). [marker]
  /// makes the upload idempotent across retries. Returns the created document.
  Future<AttachmentDto> uploadAttachment(
    int ticketId, {
    required String filePath,
    required String name,
    required String marker,
    String itemtype = itilTicket,
  });

  /// Raw bytes of a document (for image preview / open).
  Future<List<int>> downloadDocument(int documentId);

  // --- ITIL extras + relationships (companion plugin) ---

  /// Change/Problem analysis fields (impact, cause, symptom, plans, checklists).
  Future<ItilExtraDto> getItilExtra(String itemtype, int id);

  /// Update one or more analysis fields.
  Future<void> patchItilExtra(
    String itemtype,
    int id,
    Map<String, Object?> fields,
  );

  /// Objects linked to this one, in both directions.
  Future<List<ItilLinkDto>> listItilLinks(String itemtype, int id);

  /// Link another ITIL object to this one.
  Future<void> addItilLink(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
    int linkType = ItilLinkType.linkTo,
  });

  /// Remove a link (either direction).
  Future<void> removeItilLink(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  });

  // --- Planning (calendar) ---

  /// Every planned item for the signed-in user in the window (plugin feed).
  Future<List<PlanningEventDto>> fetchPlanning(String start, String end);

  /// Reschedule / re-state an ITIL task (`planned_begin`/`planned_end`/`state`).
  Future<void> planItilTask(
    int parentId,
    int taskId, {
    required String itemtype,
    String? plannedBegin,
    String? plannedEnd,
    int? state,
  });

  /// Reschedule / update a project task.
  Future<void> patchProjectTask(int taskId, Map<String, Object?> fields);

  /// Standalone calendar events (`/Assistance/ExternalEvent`).
  Future<int> createExternalEvent(Map<String, Object?> body);
  Future<void> patchExternalEvent(int id, Map<String, Object?> fields);
  Future<void> deleteExternalEvent(int id);

  /// Reminders (`/Tools/Reminder`).
  Future<List<Map<String, Object?>>> listReminders();
  Future<int> createReminder(Map<String, Object?> body);
  Future<void> patchReminder(int id, Map<String, Object?> fields);
  Future<void> deleteReminder(int id);

  // --- Projects ---

  Future<Page<ProjectDto>> listProjects({int start = 0, int limit = 100});
  Future<ProjectDto> getProject(int id);
  Future<List<ProjectTaskDto>> listProjectTasks(int projectId);
  Future<int> createProjectTask(int projectId, Map<String, Object?> body);

  // --- Generic catalog (assets + management) ---

  /// The itemtype directory for a domain: `Assets` or `Management`.
  Future<List<ItemtypeInfo>> listItemtypes(String domain);

  Future<Page<CatalogItemDto>> listCatalogItems(
    String domain,
    String itemtype, {
    String? search,
    int? statusId,
    int start = 0,
    int limit = 50,
  });

  Future<CatalogItemDto> getCatalogItem(String domain, String itemtype, int id);

  Future<void> patchCatalogItem(
    String domain,
    String itemtype,
    int id,
    Map<String, Object?> fields,
  );

  /// Warranty / financial info for an asset.
  Future<Map<String, Object?>?> getInfocom(String itemtype, int id);

  // --- Knowledge base ---

  Future<List<KbArticleDto>> searchKbArticles({
    String query = '',
    bool faqOnly = false,
    int? categoryId,
    int limit = 40,
  });
  Future<KbArticleDto> getKbArticle(int id);
  Future<List<KbCategoryDto>> listKbCategories();
  Future<List<KbCommentDto>> listKbComments(int articleId);
  Future<int> createKbComment(int articleId, String comment);

  // --- RSS feeds ---

  Future<List<RssFeedDto>> listRssFeeds();
  Future<int> createRssFeed(Map<String, Object?> body);
  Future<void> patchRssFeed(int id, Map<String, Object?> fields);
  Future<void> deleteRssFeed(int id);

  // --- Reservations ---

  Future<List<ReservationItemDto>> listReservationItems();
  Future<List<ReservationDto>> listReservations();
  Future<int> createReservation(Map<String, Object?> body);
  Future<void> deleteReservation(int id);

  // --- Service catalog (forms) ---

  /// Forms this user may answer, flat. Kept for servers whose companion
  /// plugin predates [fetchServiceCatalog].
  Future<List<FormSummaryDto>> listForms();

  /// GLPI's own catalog artwork for [ids], as standalone SVG markup keyed by
  /// id. Ids the server cannot draw are simply absent from the map.
  Future<Map<String, String>> fetchIllustrations(List<String> ids);

  /// One level of GLPI's service catalog: the categories and forms at
  /// [category] (0 = root), with the entity's own display settings — including
  /// whether categories are expanded into sections. A non-empty [filter]
  /// searches across every category, as the web catalog does.
  Future<ServiceCatalogPageDto> fetchServiceCatalog({
    int category = 0,
    String filter = '',
    int perPage = 100,
  });

  /// A form's full definition (sections, questions, resolved options).
  Future<FormDefinitionDto> getForm(int formId);

  /// Submit answers keyed by question id. [marker] makes it idempotent.
  Future<FormSubmitResult> submitForm(
    int formId, {
    required Map<int, Object?> answers,
    required String marker,
  });

  Future<List<DropdownDto>> listDropdown(String kind, {int limit = 200});

  /// The record's raw database row (plugin) — the HL schemas omit contact
  /// details, contract dates and most custom columns.
  Future<Map<String, Object?>> getRawRecord(String itemtype, int id);

  /// Network ports of an asset (plugin: the HL API doesn't publish them).
  Future<List<NetworkPortDto>> listAssetPorts(String itemtype, int id);

  /// Software installed on a computer: `(total, first 50 titles)`.
  Future<SoftwareListDto> listAssetSoftware(String itemtype, int id);

  /// ITIL objects linked to an asset.
  Future<List<AssetItilLinkDto>> listAssetItil(String itemtype, int id);

  /// Assets linked to an ITIL object.
  Future<List<LinkedAssetDto>> listItilItems(String itemtype, int id);

  /// Link an asset to an ITIL object (idempotent server-side).
  Future<void> addItilItem(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  });

  Future<void> removeItilItem(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  });

  Future<List<UserRef>> searchUsers(String query, {int limit = 20});

  /// Raw value of a GLPI config entry, e.g. context 'core' name
  /// 'priority_matrix'. Null if absent.
  Future<String?> getConfig(String context, String name);

  // --- Writes. Each returns the new sub-item's server id where relevant.

  /// Create a ticket; returns the new server id. Body carries name, content,
  /// type, urgency, impact and optional `category:{id}`. The entity comes from
  /// the request's GLPI-Entity context header.
  Future<int> createTicket(
    Map<String, Object?> body, {
    String itemtype = itilTicket,
  });

  Future<int> createFollowup(
    int ticketId, {
    required String content,
    required bool isPrivate,
    String itemtype = itilTicket,
  });

  Future<int> createTask(
    int ticketId, {
    required String content,
    required bool isPrivate,
    int? durationSeconds,
    int state = 1,
    String itemtype = itilTicket,
  });

  Future<void> setTaskState(
    int ticketId,
    int taskId,
    int state, {
    String itemtype = itilTicket,
  });

  /// Add a solution (sets the ticket to Solved server-side). Returns its id.
  Future<int> createSolution(
    int ticketId, {
    required String content,
    String itemtype = itilTicket,
  });

  /// Answer a solution: status 3 accepted, 4 refused.
  Future<void> setSolutionStatus(
    int ticketId,
    int solutionId,
    int status, {
    String itemtype = itilTicket,
  });

  /// Request an approval (validation). Returns its id.
  Future<int> createValidation(
    int ticketId, {
    required String approverType,
    required int approverId,
    required String comment,
    String itemtype = itilTicket,
  });

  /// Answer a validation: status 3 accepted, 4 refused, with a comment.
  Future<void> answerValidation(
    int ticketId,
    int validationId, {
    required int status,
    String? comment,
    String itemtype = itilTicket,
  });

  /// Generic scalar-field PATCH (status, priority, urgency, type, category…).
  Future<void> patchTicket(
    int ticketId,
    Map<String, Object?> fields, {
    String itemtype = itilTicket,
  });

  Future<void> addTeamMember(
    int ticketId, {
    required String type,
    required String role,
    required int memberId,
    String itemtype = itilTicket,
  });

  Future<void> removeTeamMember(
    int ticketId, {
    required String type,
    required String role,
    required int memberId,
    String itemtype = itilTicket,
  });

  // --- Optional-feature capabilities (companion plugins) ---

  /// What the server's companion plugins can do (`/GlpiMobile/capabilities`).
  /// Callers treat a 404 (older server plugin) or any failure as
  /// [Capabilities.empty] — the method itself throws like every other call.
  Future<Capabilities> fetchCapabilities();

  // --- Alerts + on-call (glpi-signal plugin) ---

  /// Alerts, newest first. [state] is a comma-list (`open,acked`);
  /// [severity] filters to one severity when set.
  Future<List<AlertDto>> listAlerts({
    String state = 'open,acked',
    String? severity,
    int start = 0,
    int limit = 50,
  });

  /// One alert with its page log.
  Future<AlertDetailDto> getAlert(int id);

  /// Acknowledge an alert; returns the updated row.
  Future<AlertDto> ackAlert(int id);

  /// Close an alert; returns the updated row.
  Future<AlertDto> closeAlert(int id);

  /// Every on-call rota visible to this user.
  Future<List<OncallRotaDto>> listOncallRotas();

  // --- Major incidents (glpi-major plugin) ---

  Future<List<MajorIncidentDto>> listMajorIncidents({String state = 'open'});

  /// One incident with its comms log.
  Future<MajorIncidentDetailDto> getMajorIncident(int id);

  /// A ticket's major-incident binding + the open incidents it could attach to.
  Future<MajorTicketInfoDto> getMajorForTicket(int ticketsId);

  /// Declare a major incident on a ticket; returns the created incident.
  Future<MajorIncidentDto> declareMajorIncident({
    required int ticketsId,
    required String title,
    required int commanderId,
    int commsId = 0,
  });

  /// Attach a ticket to an existing incident.
  Future<void> attachTicketToMajor(int incidentId, int ticketsId);

  /// Post a comms update. [audience] is `internal` or `customer`.
  Future<void> postMajorUpdate(
    int incidentId, {
    required String audience,
    required String content,
  });

  /// Update incident fields (`state`, `next_update_at`, `title`).
  Future<void> patchMajorIncident(int incidentId, Map<String, Object?> fields);

  // --- Known errors (glpi-kedb plugin) ---

  /// The KE offers for a ticket. The server records a `shown` hit per
  /// returned match, so call this once per ticket view, not per rebuild.
  Future<List<KedbMatchDto>> kedbMatchesForTicket(int ticketsId);

  /// Record a `used` / `dismissed` hit. `used` also returns the followup
  /// snippet the technician can paste into a reply.
  Future<KedbHitResultDto> kedbRecordHit({
    required int keId,
    required int ticketsId,
    required String action,
  });

  /// Entity-scoped KE search over title and symptom.
  Future<List<KedbRowDto>> searchKnownErrors({
    String query = '',
    int start = 0,
    int limit = 50,
  });

  /// One KE in full: symptom, workaround, root cause, lifecycle, links.
  Future<KedbDetailDto> getKnownError(int id);

  // --- Entitlement (glpi-entitle plugin) ---

  /// The entitlement answer for an entity — the `{state, payload, age,
  /// error}` envelope, same cache and degrade rules as the web Billing tab.
  Future<EntitlementDto> getEntitlement(int entitiesId);

  // --- Change calendar (glpi-change plugin) ---

  /// The combined change/release/freeze feed. Both bounds are required ISO
  /// dates and the span must stay within 92 days.
  Future<List<ChangeCalendarEventDto>> fetchChangeCalendar({
    required String from,
    required String to,
  });

  /// One change's scheduling picture: window, warnings, crossed freezes.
  Future<ChangeScheduleDto> getChangeSchedule(int changeId);

  /// The freezes in force between now and now + 14 days.
  Future<List<FreezeDto>> listActiveFreezes();

  // --- AI (glpi-ai plugin) ---

  /// What the AI plugin will answer for this caller in the entity the request
  /// is made in. Asked per screen rather than per session: the capability map
  /// cannot know which entity the technician has switched to.
  Future<AiStatusDto> getAiStatus();

  /// This technician's recent conversations, newest first.
  Future<List<AiThreadDto>> listAiThreads();

  /// Open or resume the conversation for a context — a ticket, an asset, or
  /// nothing at all for the general one.
  Future<AiThreadDetailDto> openAiThread({String? itemtype, int? itemsId});

  /// One conversation with its transcript.
  Future<AiThreadDetailDto> getAiThread(int threadId);

  /// Ask, and wait for the finished answer. The fallback for when streaming is
  /// not available; [streamAiAnswer] is what the assistant screen uses.
  Future<AiAnswerDto> askAi(int threadId, String question);

  /// Ask, and watch the run happen: turns, tools, and the answer as it
  /// arrives. The stream ends after `done` or `failed`; cancelling the
  /// subscription abandons the connection, which the server notices and stops.
  Stream<AiStreamEvent> streamAiAnswer(int threadId, String question);

  /// Forget a conversation's transcript.
  Future<void> clearAiThread(int threadId);

  /// The drafted solution (or article) a ticket already has.
  Future<AiDraftStateDto> getAiDraft(int ticketsId, {String kind = 'solution'});

  /// Draft one now. Synchronous at the server, so this waits on a provider.
  Future<AiDraftStateDto> makeAiDraft(
    int ticketsId, {
    String kind = 'solution',
  });

  /// Record what became of a draft: `used` or `discard`. Bookkeeping, and the
  /// entire measurement of whether the feature is any good.
  Future<void> decideAiDraft(int draftId, String decision);

  /// The triage suggestion for a ticket.
  Future<AiTriageStateDto> getAiTriage(int ticketsId);

  /// Run triage now (costs a provider call, so it needs update rights).
  Future<AiTriageStateDto> runAiTriage(int ticketsId);

  /// Apply or dismiss one proposed field.
  Future<AiTriageStateDto> decideAiTriage(
    int suggestionId,
    String decision,
    String field,
  );

  /// Read a drafted reply before it is sent. Writes nothing.
  Future<ReplyReviewDto> reviewReply({
    required String itemtype,
    required int itemsId,
    required String text,
  });

  // --- Procedures (glpi-sop plugin) ---

  /// The procedures attached to one ITIL object.
  Future<List<SopRunDto>> listSopRuns(String itemtype, int itemsId);

  /// One run, with its steps and what has been answered.
  Future<SopRunDetailDto> getSopRun(int runId);

  /// Answer a step. [value] is the typed value; assets and documents send
  /// their references instead.
  Future<SopRunDetailDto> answerSopStep(
    int runId,
    int stepId, {
    Object? value,
    String? valueItemtype,
    int? valueItemsId,
    int? documentsId,
  });

  /// Un-answer a step.
  Future<SopRunDetailDto> clearSopStep(int runId, int stepId);

  /// Skip a step (or un-skip it, if it was already skipped).
  Future<SopRunDetailDto> skipSopStep(int runId, int stepId, String reason);

  /// Write or erase the note on a step.
  Future<SopRunDetailDto> noteSopStep(int runId, int stepId, String note);

  /// Raise the ticket a ticket-step asks for. Refused (409) when one has
  /// already been raised — a duplicate request costs somebody real work.
  Future<SopRunDetailDto> spawnSopStep(int runId, int stepId);

  /// The run's history.
  Future<List<SopLogEntryDto>> getSopRunLog(int runId);

  // --- Presence (glpi-presence plugin) ---

  /// Who is on this item, and who holds the claim. A read: it does not
  /// announce the caller.
  Future<PresenceStateDto> getPresence(String itemtype, int itemsId);

  /// "I am here", and optionally "I am typing". [sessionKey] identifies this
  /// device's participation and must be stable while the screen is open.
  Future<PresenceStateDto> presenceHeartbeat(
    String itemtype,
    int itemsId, {
    required String sessionKey,
    bool typing = false,
    String? typingKind,
  });

  /// Stop being here. Worth calling, never worth waiting for — the server's
  /// TTL covers a phone that simply vanishes.
  Future<void> presenceLeave(
    String itemtype,
    int itemsId, {
    required String sessionKey,
  });

  /// Claim the work, take it over, or hand it back. `claim` on an item
  /// somebody else holds fails rather than stealing it.
  Future<PresenceStateDto> presenceClaim(
    String itemtype,
    int itemsId, {
    required String action,
  });

  // --- Push notifications (companion plugin) ---

  /// The plugin's VAPID public key + which transports are enabled.
  Future<PushConfig> fetchPushConfig();

  /// Register (or refresh) this device for push. `endpoint` is the UnifiedPush
  /// URL or the APNs/FCM token; `p256dh`/`auth` are the UnifiedPush keys.
  Future<void> registerDevice({
    required String transport,
    required String endpoint,
    String? p256dh,
    String? auth,
    required String platform,
  });

  /// Unregister a device by its endpoint (on sign-out).
  Future<void> unregisterDevice(String endpoint);
}

/// GLPI 11 high-level API implementation over a configured dio instance.
class HlGlpiApi implements GlpiApi {
  HlGlpiApi(this._dio);
  final Dio _dio;

  @override
  Future<Page<TicketDto>> searchTickets({
    Rsql? filter,
    String sort = 'date_mod:desc',
    int start = 0,
    int limit = 100,
    String itemtype = itilTicket,
  }) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Assistance/$itemtype',
        queryParameters: {
          if (filter != null) 'filter': filter.toString(),
          'sort': sort,
          'start': start,
          'limit': limit,
        },
      );
      final items = (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(TicketDto.fromJson)
          .toList();
      return Page(items, _totalFrom(response, items.length, start));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<TicketDto> getTicket(int id, {String itemtype = itilTicket}) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/Assistance/$itemtype/$id',
      );
      return TicketDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<int?> findTicketByMarker(
    String opUuid, {
    String itemtype = itilTicket,
  }) async {
    // The marker is an HTML comment GLPI preserves in the content; match it
    // case-insensitively with wildcards. Newest first, take one.
    final page = await searchTickets(
      filter: Rsql.raw('content=ilike="*op:$opUuid*"'),
      sort: 'id:desc',
      limit: 1,
      itemtype: itemtype,
    );
    return page.items.isEmpty ? null : page.items.first.id;
  }

  @override
  Future<int> createTicket(
    Map<String, Object?> body, {
    String itemtype = itilTicket,
  }) => _create('/Assistance/$itemtype', body);

  @override
  Future<List<TimelineEntryDto>> getTimeline(
    int ticketId, {
    String itemtype = itilTicket,
  }) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Assistance/$itemtype/$ticketId/Timeline',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(TimelineEntryDto.fromJson)
          .where((e) => e.type != 'document' || e.content.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<AttachmentDto>> listAttachments(
    int ticketId, {
    String itemtype = itilTicket,
  }) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiMobile/items/$itemtype/$ticketId/documents',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(AttachmentDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AttachmentDto> uploadAttachment(
    int ticketId, {
    required String filePath,
    required String name,
    required String marker,
    String itemtype = itilTicket,
  }) async {
    try {
      final form = FormData.fromMap({
        'name': name,
        'marker': marker,
        'file': await MultipartFile.fromFile(filePath, filename: name),
      });
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiMobile/items/$itemtype/$ticketId/documents',
        data: form,
      );
      return AttachmentDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Map<String, Object?>> getRawRecord(String itemtype, int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMobile/record/$itemtype/$id/raw',
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<NetworkPortDto>> listAssetPorts(String itemtype, int id) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiMobile/asset/$itemtype/$id/ports',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(NetworkPortDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<SoftwareListDto> listAssetSoftware(String itemtype, int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMobile/asset/$itemtype/$id/software',
      );
      return SoftwareListDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<AssetItilLinkDto>> listAssetItil(String itemtype, int id) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiMobile/asset/$itemtype/$id/itil',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(AssetItilLinkDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<LinkedAssetDto>> listItilItems(String itemtype, int id) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiMobile/itil/$itemtype/$id/items',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(LinkedAssetDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> addItilItem(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {
    try {
      await _dio.post<Map<String, Object?>>(
        '/GlpiMobile/itil/$itemtype/$id/items',
        data: {'target_itemtype': targetItemtype, 'target_id': targetId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> removeItilItem(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {
    try {
      await _dio.delete<Map<String, Object?>>(
        '/GlpiMobile/itil/$itemtype/$id/items',
        data: {'target_itemtype': targetItemtype, 'target_id': targetId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<int>> downloadDocument(int documentId) async {
    try {
      final response = await _dio.get<List<int>>(
        '/Management/Document/$documentId/Download',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? const [];
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<ItilExtraDto> getItilExtra(String itemtype, int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMobile/itil/$itemtype/$id/extra',
      );
      return ItilExtraDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> patchItilExtra(
    String itemtype,
    int id,
    Map<String, Object?> fields,
  ) async {
    try {
      await _dio.patch<Object?>(
        '/GlpiMobile/itil/$itemtype/$id/extra',
        data: fields,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<ItilLinkDto>> listItilLinks(String itemtype, int id) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiMobile/itil/$itemtype/$id/links',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(ItilLinkDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> addItilLink(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
    int linkType = ItilLinkType.linkTo,
  }) async {
    try {
      await _dio.post<Object?>(
        '/GlpiMobile/itil/$itemtype/$id/links',
        data: {
          'target_itemtype': targetItemtype,
          'target_id': targetId,
          'link_type': linkType,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> removeItilLink(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {
    try {
      await _dio.delete<Object?>(
        '/GlpiMobile/itil/$itemtype/$id/links',
        data: {'target_itemtype': targetItemtype, 'target_id': targetId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Page<ProjectDto>> listProjects({
    int start = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Project',
        queryParameters: {
          'start': start,
          'limit': limit,
          'sort': 'date_mod:desc',
        },
      );
      final items = (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(ProjectDto.fromJson)
          .toList();
      return Page(items, _totalFrom(response, items.length, start));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<ProjectDto> getProject(int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>('/Project/$id');
      return ProjectDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<ProjectTaskDto>> listProjectTasks(int projectId) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Project/$projectId/Task',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(ProjectTaskDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<int> createProjectTask(int projectId, Map<String, Object?> body) =>
      _create('/Project/$projectId/Task', body);

  @override
  Future<List<PlanningEventDto>> fetchPlanning(String start, String end) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiMobile/planning',
        queryParameters: {'start': start, 'end': end},
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(PlanningEventDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> planItilTask(
    int parentId,
    int taskId, {
    required String itemtype,
    String? plannedBegin,
    String? plannedEnd,
    int? state,
  }) => _patch('/Assistance/$itemtype/$parentId/Timeline/Task/$taskId', {
    'planned_begin': ?plannedBegin,
    'planned_end': ?plannedEnd,
    'state': ?state,
  });

  @override
  Future<void> patchProjectTask(int taskId, Map<String, Object?> fields) =>
      _patch('/Project/Task/$taskId', fields);

  @override
  Future<int> createExternalEvent(Map<String, Object?> body) =>
      _createThenSchedule('/Assistance/ExternalEvent', body);

  @override
  Future<void> patchExternalEvent(int id, Map<String, Object?> fields) =>
      _patch('/Assistance/ExternalEvent/$id', fields);

  @override
  Future<void> deleteExternalEvent(int id) =>
      _delete('/Assistance/ExternalEvent/$id');

  @override
  Future<List<Map<String, Object?>>> listReminders() async {
    try {
      final response = await _dio.get<List<Object?>>('/Tools/Reminder');
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<int> createReminder(Map<String, Object?> body) =>
      _createThenSchedule('/Tools/Reminder', body);

  @override
  Future<void> patchReminder(int id, Map<String, Object?> fields) =>
      _patch('/Tools/Reminder/$id', fields);

  @override
  Future<void> deleteReminder(int id) => _delete('/Tools/Reminder/$id');

  @override
  Future<List<ItemtypeInfo>> listItemtypes(String domain) async {
    try {
      final response = await _dio.get<List<Object?>>('/$domain');
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(ItemtypeInfo.fromJson)
          .where((i) => i.itemtype.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Page<CatalogItemDto>> listCatalogItems(
    String domain,
    String itemtype, {
    String? search,
    int? statusId,
    int start = 0,
    int limit = 50,
  }) async {
    final q = (search ?? '').trim();
    // Match on the fields a technician would type: name, serial, asset tag.
    final clauses = [
      if (q.isNotEmpty)
        '(name=ilike="*$q*",serial=ilike="*$q*",otherserial=ilike="*$q*")',
      if (statusId != null) 'status.id==$statusId',
    ];
    final filter = clauses.isEmpty ? null : clauses.join(';');
    try {
      final response = await _dio.get<List<Object?>>(
        '/$domain/$itemtype',
        queryParameters: {'filter': ?filter, 'start': start, 'limit': limit},
      );
      final items = (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map((j) => CatalogItemDto.fromJson(itemtype, j))
          .toList();
      return Page(items, _totalFrom(response, items.length, start));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<CatalogItemDto> getCatalogItem(
    String domain,
    String itemtype,
    int id,
  ) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/$domain/$itemtype/$id',
      );
      return CatalogItemDto.fromJson(itemtype, response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> patchCatalogItem(
    String domain,
    String itemtype,
    int id,
    Map<String, Object?> fields,
  ) => _patch('/$domain/$itemtype/$id', fields);

  @override
  Future<Map<String, Object?>?> getInfocom(String itemtype, int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/Assets/$itemtype/$id/Infocom',
      );
      return response.data;
    } on DioException catch (e) {
      // Most assets simply have no financial record.
      final mapped = mapDioError(e);
      if (mapped is GlpiNotFoundError) return null;
      throw mapped;
    }
  }

  @override
  Future<List<KbArticleDto>> searchKbArticles({
    String query = '',
    bool faqOnly = false,
    int? categoryId,
    int limit = 40,
  }) async {
    // Title OR body match; RSQL ',' is OR and ';' is AND.
    final filters = <String>[];
    final q = query.trim();
    if (q.isNotEmpty) {
      final escaped = q.replaceAll('"', r'\"');
      filters.add('(name=ilike="*$escaped*",content=ilike="*$escaped*")');
    }
    if (faqOnly) filters.add('is_faq==true');
    try {
      final response = await _dio.get<List<Object?>>(
        '/Knowledgebase/Article',
        queryParameters: {
          if (filters.isNotEmpty) 'filter': filters.join(';'),
          'sort': 'date_mod:desc',
          'limit': limit,
        },
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(KbArticleDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<KbArticleDto> getKbArticle(int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/Knowledgebase/Article/$id',
      );
      return KbArticleDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<KbCategoryDto>> listKbCategories() async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Knowledgebase/Category',
        queryParameters: {'limit': 200},
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(KbCategoryDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<KbCommentDto>> listKbComments(int articleId) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Knowledgebase/Article/$articleId/Comment',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(KbCommentDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<int> createKbComment(int articleId, String comment) => _create(
    '/Knowledgebase/Article/$articleId/Comment',
    {'comment': comment},
  );

  @override
  Future<List<RssFeedDto>> listRssFeeds() async {
    try {
      final response = await _dio.get<List<Object?>>('/Tools/RSSFeed');
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(RssFeedDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<int> createRssFeed(Map<String, Object?> body) =>
      _create('/Tools/RSSFeed', body);

  @override
  Future<void> patchRssFeed(int id, Map<String, Object?> fields) =>
      _patch('/Tools/RSSFeed/$id', fields);

  @override
  Future<void> deleteRssFeed(int id) => _delete('/Tools/RSSFeed/$id');

  @override
  Future<List<ReservationItemDto>> listReservationItems() async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Tools/ReservationItem',
        queryParameters: {'limit': 200},
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(ReservationItemDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<ReservationDto>> listReservations() async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Tools/Reservation',
        queryParameters: {'limit': 200},
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(ReservationDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<int> createReservation(Map<String, Object?> body) =>
      _create('/Tools/Reservation', body);

  @override
  Future<void> deleteReservation(int id) => _delete('/Tools/Reservation/$id');

  @override
  Future<List<FormSummaryDto>> listForms() async {
    try {
      final response = await _dio.get<List<Object?>>('/GlpiMobile/forms');
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(FormSummaryDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<ServiceCatalogPageDto> fetchServiceCatalog({
    int category = 0,
    String filter = '',
    int perPage = 100,
  }) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMobile/catalog',
        queryParameters: {
          'category': category,
          if (filter.isNotEmpty) 'filter': filter,
          'per_page': perPage,
        },
      );
      return ServiceCatalogPageDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      final mapped = mapDioError(e);
      // A companion plugin from before the catalog route. Fall back to the
      // flat list rather than showing nothing: an un-categorised catalog is
      // what that server has always served, and it still files tickets.
      if (mapped is GlpiNotFoundError) {
        return ServiceCatalogPageDto.flat(await listForms());
      }
      throw mapped;
    }
  }

  @override
  Future<Map<String, String>> fetchIllustrations(List<String> ids) async {
    if (ids.isEmpty) return const {};
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMobile/illustrations',
        queryParameters: {'ids': ids.join(',')},
      );
      return {
        for (final entry in (response.data ?? const {}).entries)
          if (entry.value is String) entry.key: entry.value! as String,
      };
    } on DioException {
      // Artwork is decoration: a server too old to have the route, or one that
      // could not be reached, costs the catalog its illustrations and nothing
      // else. The icons the app draws instead were the whole story until now.
      return const {};
    }
  }

  @override
  Future<FormDefinitionDto> getForm(int formId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMobile/forms/$formId',
      );
      return FormDefinitionDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<FormSubmitResult> submitForm(
    int formId, {
    required Map<int, Object?> answers,
    required String marker,
  }) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiMobile/forms/$formId/submit',
        data: {
          'marker': marker,
          // JSON object keys must be strings; the plugin casts them back.
          'answers': answers.map((k, v) => MapEntry('$k', v)),
        },
      );
      return FormSubmitResult.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<DropdownDto>> listDropdown(String kind, {int limit = 200}) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Dropdowns/$kind',
        queryParameters: {'limit': limit},
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(DropdownDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<int> createFollowup(
    int ticketId, {
    required String content,
    required bool isPrivate,
    String itemtype = itilTicket,
  }) async {
    return _create('/Assistance/$itemtype/$ticketId/Timeline/Followup', {
      'content': content,
      'is_private': isPrivate,
    });
  }

  @override
  Future<int> createTask(
    int ticketId, {
    required String content,
    required bool isPrivate,
    int? durationSeconds,
    int state = 1,
    String itemtype = itilTicket,
  }) async {
    return _create('/Assistance/$itemtype/$ticketId/Timeline/Task', {
      'content': content,
      'is_private': isPrivate,
      'duration': ?durationSeconds,
      'state': state,
    });
  }

  @override
  Future<void> setTaskState(
    int ticketId,
    int taskId,
    int state, {
    String itemtype = itilTicket,
  }) => _patch('/Assistance/$itemtype/$ticketId/Timeline/Task/$taskId', {
    'state': state,
  });

  @override
  Future<int> createSolution(
    int ticketId, {
    required String content,
    String itemtype = itilTicket,
  }) => _create('/Assistance/$itemtype/$ticketId/Timeline/Solution', {
    'content': content,
  });

  @override
  Future<void> setSolutionStatus(
    int ticketId,
    int solutionId,
    int status, {
    String itemtype = itilTicket,
  }) => _patch(
    '/Assistance/$itemtype/$ticketId/Timeline/Solution/$solutionId',
    {'status': status},
  );

  @override
  Future<int> createValidation(
    int ticketId, {
    required String approverType,
    required int approverId,
    required String comment,
    String itemtype = itilTicket,
  }) => _create('/Assistance/$itemtype/$ticketId/Timeline/Validation', {
    'requested_approver_type': approverType,
    'requested_approver_id': approverId,
    'submission_comment': comment,
  });

  @override
  Future<void> answerValidation(
    int ticketId,
    int validationId, {
    required int status,
    String? comment,
    String itemtype = itilTicket,
  }) => _patch(
    '/Assistance/$itemtype/$ticketId/Timeline/Validation/$validationId',
    {'status': status, 'approval_comment': ?comment},
  );

  @override
  Future<void> patchTicket(
    int ticketId,
    Map<String, Object?> fields, {
    String itemtype = itilTicket,
  }) => _patch('/Assistance/$itemtype/$ticketId', fields);

  @override
  Future<String?> getConfig(String context, String name) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/Setup/Config/$context/$name',
      );
      return response.data?['value'] as String?;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<UserRef>> searchUsers(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/Administration/User',
        queryParameters: {
          if (query.trim().isNotEmpty)
            'filter': Rsql.raw(
              'username=ilike="*${_escape(query)}*"',
            ).toString(),
          'limit': limit,
        },
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(UserRef.fromJson)
          .where((u) => u.id > 0)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> addTeamMember(
    int ticketId, {
    required String type,
    required String role,
    required int memberId,
    String itemtype = itilTicket,
  }) async {
    try {
      await _dio.post<Object?>(
        '/Assistance/$itemtype/$ticketId/TeamMember',
        data: {'type': type, 'role': role, 'id': memberId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> removeTeamMember(
    int ticketId, {
    required String type,
    required String role,
    required int memberId,
    String itemtype = itilTicket,
  }) async {
    try {
      await _dio.delete<Object?>(
        '/Assistance/$itemtype/$ticketId/TeamMember',
        data: {'type': type, 'role': role, 'id': memberId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Capabilities> fetchCapabilities() async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMobile/capabilities',
      );
      return Capabilities.fromJson(response.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<AlertDto>> listAlerts({
    String state = 'open,acked',
    String? severity,
    int start = 0,
    int limit = 50,
  }) async {
    try {
      // The plugin wraps the rows in `{total, start, limit, <rows>: [...]}`;
      // the DTO layer digs the list out tolerantly (and accepts a bare array).
      final response = await _dio.get<Object?>(
        '/GlpiSignal/alerts',
        queryParameters: {
          'state': state,
          'severity': ?severity,
          'start': start,
          'limit': limit,
        },
      );
      return alertRowsFromJson(response.data).map(AlertDto.fromJson).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AlertDetailDto> getAlert(int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiSignal/alerts/$id',
      );
      return AlertDetailDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AlertDto> ackAlert(int id) => _alertAction(id, 'ack');

  @override
  Future<AlertDto> closeAlert(int id) => _alertAction(id, 'close');

  Future<AlertDto> _alertAction(int id, String action) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiSignal/alerts/$id/$action',
      );
      return AlertDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<OncallRotaDto>> listOncallRotas() async {
    try {
      // The live route wraps the rows: `{"rotas": [...]}`.
      final response = await _dio.get<Object?>('/GlpiSignal/oncall');
      return oncallRowsFromJson(
        response.data,
      ).map(OncallRotaDto.fromJson).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<MajorIncidentDto>> listMajorIncidents({
    String state = 'open',
  }) async {
    try {
      // The live route wraps the rows: `{"incidents": [...]}`.
      final response = await _dio.get<Object?>(
        '/GlpiMajor/incidents',
        queryParameters: {'state': state},
      );
      return majorRowsFromJson(
        response.data,
      ).map(MajorIncidentDto.fromJson).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<MajorIncidentDetailDto> getMajorIncident(int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMajor/incidents/$id',
      );
      return MajorIncidentDetailDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<MajorTicketInfoDto> getMajorForTicket(int ticketsId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMajor/ticket/$ticketsId',
      );
      return MajorTicketInfoDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<MajorIncidentDto> declareMajorIncident({
    required int ticketsId,
    required String title,
    required int commanderId,
    int commsId = 0,
  }) async {
    try {
      // `commander` and `comms` are user ids — the server casts them to int.
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiMajor/incidents',
        data: {
          'tickets_id': ticketsId,
          'title': title,
          'commander': commanderId,
          'comms': commsId,
        },
      );
      return MajorIncidentDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> attachTicketToMajor(int incidentId, int ticketsId) async {
    try {
      await _dio.post<Object?>(
        '/GlpiMajor/incidents/$incidentId/tickets',
        data: {'tickets_id': ticketsId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> postMajorUpdate(
    int incidentId, {
    required String audience,
    required String content,
  }) async {
    try {
      await _dio.post<Object?>(
        '/GlpiMajor/incidents/$incidentId/updates',
        data: {'audience': audience, 'content': content},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> patchMajorIncident(
    int incidentId,
    Map<String, Object?> fields,
  ) => _patch('/GlpiMajor/incidents/$incidentId', fields);

  @override
  Future<List<KedbMatchDto>> kedbMatchesForTicket(int ticketsId) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiKedb/match/ticket/$ticketsId',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(KedbMatchDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<KedbHitResultDto> kedbRecordHit({
    required int keId,
    required int ticketsId,
    required String action,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/GlpiKedb/hits',
        data: {'ke_id': keId, 'tickets_id': ticketsId, 'action': action},
      );
      return KedbHitResultDto.fromJson(response.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<KedbRowDto>> searchKnownErrors({
    String query = '',
    int start = 0,
    int limit = 50,
  }) async {
    try {
      // Wrapped in `{total, start, limit, rows}`; the DTO layer digs the
      // list out tolerantly (and accepts a bare array).
      final response = await _dio.get<Object?>(
        '/GlpiKedb/knownerrors',
        queryParameters: {
          if (query.trim().isNotEmpty) 'q': query.trim(),
          'start': start,
          'limit': limit,
        },
      );
      return kedbRowsFromJson(response.data).map(KedbRowDto.fromJson).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<KedbDetailDto> getKnownError(int id) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiKedb/knownerrors/$id',
      );
      return KedbDetailDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<EntitlementDto> getEntitlement(int entitiesId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiEntitle/entitlement/$entitiesId',
      );
      return EntitlementDto.fromJson(response.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<ChangeCalendarEventDto>> fetchChangeCalendar({
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiChange/calendar',
        queryParameters: {'from': from, 'to': to},
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(ChangeCalendarEventDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<ChangeScheduleDto> getChangeSchedule(int changeId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiChange/changes/$changeId/schedule',
      );
      return ChangeScheduleDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<FreezeDto>> listActiveFreezes() async {
    try {
      final response = await _dio.get<List<Object?>>(
        '/GlpiChange/freezes/active',
      );
      return (response.data ?? const [])
          .whereType<Map<String, Object?>>()
          .map(FreezeDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AiStatusDto> getAiStatus() async {
    try {
      final response = await _dio.get<Map<String, Object?>>('/GlpiAi/status');
      return AiStatusDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<AiThreadDto>> listAiThreads() async {
    try {
      final response = await _dio.get<Map<String, Object?>>('/GlpiAi/threads');
      final rows = response.data?['threads'];
      return rows is List
          ? [
              for (final r in rows)
                if (r is Map) AiThreadDto.fromJson(r.cast<String, Object?>()),
            ]
          : const [];
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AiThreadDetailDto> openAiThread({
    String? itemtype,
    int? itemsId,
  }) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiAi/threads',
        // Both omitted opens the general conversation. Sending an item the
        // server cannot resolve is not an error there either — it degrades to
        // no context, exactly as the web panel does.
        data: {'itemtype': ?itemtype, 'items_id': ?itemsId},
      );
      return AiThreadDetailDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AiThreadDetailDto> getAiThread(int threadId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiAi/threads/$threadId',
      );
      return AiThreadDetailDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AiAnswerDto> askAi(int threadId, String question) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiAi/threads/$threadId/ask',
        data: {'question': question},
        // An agent run is four to eight vendor round trips. The default
        // 30-second receive timeout cancels most of them halfway.
        options: Options(receiveTimeout: const Duration(minutes: 5)),
      );
      return AiAnswerDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Stream<AiStreamEvent> streamAiAnswer(int threadId, String question) async* {
    final Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '/GlpiAi/threads/$threadId/stream',
        data: {'question': question},
        options: Options(
          responseType: ResponseType.stream,
          // The gap between events, not the length of the run: the server
          // narrates every turn and every tool, so a minute of silence really
          // does mean the connection is dead.
          receiveTimeout: const Duration(minutes: 2),
          headers: {'Accept': 'text/event-stream'},
        ),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }

    final body = response.data;
    if (body == null) return;

    final frames = decodeSse(
      utf8.decoder
          .bind(body.stream.cast<List<int>>())
          .transform(const LineSplitter()),
    );

    try {
      await for (final frame in frames) {
        final event = AiStreamEvent(
          kind: AiEventKind.parse(frame.event),
          data: frame.data,
        );
        yield event;
        // `done` and `failed` are both terminal — the server closes after
        // either, and waiting for the close costs a dead connection's timeout.
        if (event.kind == AiEventKind.done ||
            event.kind == AiEventKind.failed) {
          return;
        }
      }
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> clearAiThread(int threadId) =>
      _delete('/GlpiAi/threads/$threadId');

  @override
  Future<AiDraftStateDto> getAiDraft(
    int ticketsId, {
    String kind = 'solution',
  }) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiAi/tickets/$ticketsId/draft',
        queryParameters: {'kind': kind},
      );
      return AiDraftStateDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AiDraftStateDto> makeAiDraft(
    int ticketsId, {
    String kind = 'solution',
  }) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiAi/tickets/$ticketsId/draft',
        data: {'kind': kind},
        options: Options(receiveTimeout: const Duration(minutes: 3)),
      );
      return AiDraftStateDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> decideAiDraft(int draftId, String decision) async {
    try {
      await _dio.post<Object?>('/GlpiAi/drafts/$draftId/$decision');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AiTriageStateDto> getAiTriage(int ticketsId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiAi/tickets/$ticketsId/triage',
      );
      return AiTriageStateDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AiTriageStateDto> runAiTriage(int ticketsId) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiAi/tickets/$ticketsId/triage',
        options: Options(receiveTimeout: const Duration(minutes: 3)),
      );
      return AiTriageStateDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<AiTriageStateDto> decideAiTriage(
    int suggestionId,
    String decision,
    String field,
  ) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiAi/triage/$suggestionId/$decision',
        data: {'field': field},
      );
      return AiTriageStateDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<ReplyReviewDto> reviewReply({
    required String itemtype,
    required int itemsId,
    required String text,
  }) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiAi/reply/review',
        data: {'itemtype': itemtype, 'items_id': itemsId, 'text': text},
        options: Options(receiveTimeout: const Duration(minutes: 2)),
      );
      return ReplyReviewDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<SopRunDto>> listSopRuns(String itemtype, int itemsId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiSop/item/$itemtype/$itemsId/runs',
      );
      final rows = response.data?['runs'];
      return rows is List
          ? [
              for (final r in rows)
                if (r is Map) SopRunDto.fromJson(r.cast<String, Object?>()),
            ]
          : const [];
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<SopRunDetailDto> getSopRun(int runId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiSop/runs/$runId',
      );
      return SopRunDetailDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<SopRunDetailDto> answerSopStep(
    int runId,
    int stepId, {
    Object? value,
    String? valueItemtype,
    int? valueItemsId,
    int? documentsId,
  }) => _sopStep(runId, stepId, 'answer', {
    'value': ?value,
    'value_itemtype': ?valueItemtype,
    'value_items_id': ?valueItemsId,
    'documents_id': ?documentsId,
  });

  @override
  Future<SopRunDetailDto> clearSopStep(int runId, int stepId) =>
      _sopStep(runId, stepId, 'clear', const {});

  @override
  Future<SopRunDetailDto> skipSopStep(int runId, int stepId, String reason) =>
      _sopStep(runId, stepId, 'skip', {'reason': reason});

  @override
  Future<SopRunDetailDto> noteSopStep(int runId, int stepId, String note) =>
      _sopStep(runId, stepId, 'note', {'note': note});

  /// Every step write answers with the whole run, recomputed — which is the
  /// point: one answer can open a branch, close another, and change the
  /// counters, and none of that is derivable on the client.
  Future<SopRunDetailDto> _sopStep(
    int runId,
    int stepId,
    String action,
    Map<String, Object?> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiSop/runs/$runId/steps/$stepId/$action',
        data: body,
      );
      return SopRunDetailDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<SopRunDetailDto> spawnSopStep(int runId, int stepId) =>
      _sopStep(runId, stepId, 'spawn', const {});

  @override
  Future<List<SopLogEntryDto>> getSopRunLog(int runId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiSop/runs/$runId/log',
      );
      final rows = response.data?['entries'];
      return rows is List
          ? [
              for (final r in rows)
                if (r is Map)
                  SopLogEntryDto.fromJson(r.cast<String, Object?>()),
            ]
          : const [];
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PresenceStateDto> getPresence(String itemtype, int itemsId) async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiPresence/item/$itemtype/$itemsId',
      );
      return PresenceStateDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PresenceStateDto> presenceHeartbeat(
    String itemtype,
    int itemsId, {
    required String sessionKey,
    bool typing = false,
    String? typingKind,
  }) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiPresence/item/$itemtype/$itemsId/heartbeat',
        data: {
          'session_key': sessionKey,
          'typing': typing,
          'typing_kind': ?typingKind,
        },
      );
      return PresenceStateDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> presenceLeave(
    String itemtype,
    int itemsId, {
    required String sessionKey,
  }) async {
    try {
      await _dio.post<Object?>(
        '/GlpiPresence/item/$itemtype/$itemsId/leave',
        data: {'session_key': sessionKey},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PresenceStateDto> presenceClaim(
    String itemtype,
    int itemsId, {
    required String action,
  }) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/GlpiPresence/item/$itemtype/$itemsId/$action',
      );
      return PresenceStateDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<PushConfig> fetchPushConfig() async {
    try {
      final response = await _dio.get<Map<String, Object?>>(
        '/GlpiMobile/config',
      );
      final data = response.data ?? const {};
      final transports = <String, bool>{};
      final raw = data['transports'];
      if (raw is Map) {
        raw.forEach((k, v) => transports[k.toString()] = v == true);
      }
      return PushConfig(
        vapidPublicKey: data['vapid_public_key'] as String? ?? '',
        transports: transports,
        fcm: FcmOptions.fromJson(data['fcm']),
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> registerDevice({
    required String transport,
    required String endpoint,
    String? p256dh,
    String? auth,
    required String platform,
  }) async {
    try {
      await _dio.post<Object?>(
        '/GlpiMobile/devices',
        data: {
          'transport': transport,
          'endpoint': endpoint,
          'p256dh': ?p256dh,
          'auth': ?auth,
          'platform': platform,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> unregisterDevice(String endpoint) async {
    try {
      await _dio.delete<Object?>(
        '/GlpiMobile/devices',
        queryParameters: {'endpoint': endpoint},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  String _escape(String s) => s.replaceAll('"', '').replaceAll('*', '');

  /// POSTs a create and returns the new server id, parsed from the `Location`
  /// header (`.../{id}`) or the response body.
  Future<int> _create(String path, Map<String, Object?> body) async {
    try {
      final response = await _dio.post<Object?>(path, data: body);
      final location = response.headers.value('location');
      if (location != null) {
        final id = int.tryParse(location.split('/').last);
        if (id != null) return id;
      }
      final data = response.data;
      if (data is Map && data['id'] is num) return (data['id'] as num).toInt();
      return 0;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GLPI's HL API silently drops `date_begin`/`date_end` on POST for
  /// PlanningExternalEvent and Reminder — they only stick on PATCH. So create
  /// first, then send the window as an update.
  Future<int> _createThenSchedule(
    String path,
    Map<String, Object?> body,
  ) async {
    final schedule = <String, Object?>{
      'date_begin': ?body['date_begin'],
      'date_end': ?body['date_end'],
      'is_planned': ?body['is_planned'],
    };
    final id = await _create(path, body);
    if (id > 0 && schedule.isNotEmpty) {
      await _patch('$path/$id', schedule);
    }
    return id;
  }

  Future<void> _delete(String path) async {
    try {
      await _dio.delete<Object?>(path);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> _patch(String path, Map<String, Object?> body) async {
    try {
      await _dio.patch<Object?>(path, data: body);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GLPI sends `Content-Range: start-end/total` on 206 responses.
  int _totalFrom(Response<Object?> response, int pageLen, int start) {
    final header = response.headers.value('content-range');
    if (header != null) {
      final slash = header.lastIndexOf('/');
      if (slash != -1) {
        final total = int.tryParse(header.substring(slash + 1));
        if (total != null) return total;
      }
    }
    return start + pageLen; // 200 = single complete page
  }
}
