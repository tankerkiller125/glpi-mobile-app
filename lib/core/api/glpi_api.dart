import 'package:dio/dio.dart';

import 'dto/attachment_dto.dart';
import 'dto/catalog_dto.dart';
import 'dto/dropdown_dto.dart';
import 'dto/form_dto.dart';
import 'dto/itil_link_dto.dart';
import 'dto/planning_dto.dart';
import 'dto/project_dto.dart';
import 'dto/ticket_dto.dart';
import 'dto/timeline_dto.dart';
import 'dto/tools_dto.dart';
import 'dto/user_ref.dart';
import 'errors.dart';
import 'itil_type.dart';
import 'rsql.dart';

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

  /// Forms this user may answer.
  Future<List<FormSummaryDto>> listForms();

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
