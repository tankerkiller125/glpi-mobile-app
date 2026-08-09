import 'package:glpi_mobile/core/api/dto/attachment_dto.dart';
import 'package:glpi_mobile/core/api/dto/catalog_dto.dart';
import 'package:glpi_mobile/core/api/dto/dropdown_dto.dart';
import 'package:glpi_mobile/core/api/dto/form_dto.dart';
import 'package:glpi_mobile/core/api/dto/itil_link_dto.dart';
import 'package:glpi_mobile/core/api/dto/planning_dto.dart';
import 'package:glpi_mobile/core/api/dto/project_dto.dart';
import 'package:glpi_mobile/core/api/dto/ticket_dto.dart';
import 'package:glpi_mobile/core/api/dto/timeline_dto.dart';
import 'package:glpi_mobile/core/api/dto/tools_dto.dart';
import 'package:glpi_mobile/core/api/dto/user_ref.dart';
import 'package:glpi_mobile/core/api/glpi_api.dart';
import 'package:glpi_mobile/core/api/itil_type.dart';
import 'package:glpi_mobile/core/api/rsql.dart';

/// Default no-op / throwing implementations of every GlpiApi method, so a test
/// fake can override only the ones it exercises.
mixin FakeGlpiApiDefaults implements GlpiApi {
  @override
  Future<Page<TicketDto>> searchTickets({
    Rsql? filter,
    String sort = 'date_mod:desc',
    int start = 0,
    int limit = 100,
    String itemtype = itilTicket,
  }) async => const Page([], 0);

  @override
  Future<TicketDto> getTicket(int id, {String itemtype = itilTicket}) =>
      throw UnimplementedError();

  @override
  Future<int?> findTicketByMarker(
    String opUuid, {
    String itemtype = itilTicket,
  }) async => null;

  @override
  Future<int> createTicket(
    Map<String, Object?> body, {
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<List<TimelineEntryDto>> getTimeline(
    int ticketId, {
    String itemtype = itilTicket,
  }) async => const [];

  @override
  Future<List<AttachmentDto>> listAttachments(
    int ticketId, {
    String itemtype = itilTicket,
  }) async => const [];

  @override
  Future<AttachmentDto> uploadAttachment(
    int ticketId, {
    required String filePath,
    required String name,
    required String marker,
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<List<int>> downloadDocument(int documentId) async => const [];

  @override
  Future<List<FormSummaryDto>> listForms() async => const [];

  @override
  Future<FormDefinitionDto> getForm(int formId) => throw UnimplementedError();

  @override
  Future<FormSubmitResult> submitForm(
    int formId, {
    required Map<int, Object?> answers,
    required String marker,
  }) => throw UnimplementedError();

  @override
  Future<List<DropdownDto>> listDropdown(
    String kind, {
    int limit = 200,
  }) async => const [];

  @override
  Future<int> createFollowup(
    int ticketId, {
    required String content,
    required bool isPrivate,
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<int> createTask(
    int ticketId, {
    required String content,
    required bool isPrivate,
    int? durationSeconds,
    int state = 1,
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<void> setTaskState(
    int ticketId,
    int taskId,
    int state, {
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<int> createSolution(
    int ticketId, {
    required String content,
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<void> setSolutionStatus(
    int ticketId,
    int solutionId,
    int status, {
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<int> createValidation(
    int ticketId, {
    required String approverType,
    required int approverId,
    required String comment,
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<void> answerValidation(
    int ticketId,
    int validationId, {
    required int status,
    String? comment,
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<void> patchTicket(
    int ticketId,
    Map<String, Object?> fields, {
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<List<UserRef>> searchUsers(String query, {int limit = 20}) async =>
      const [];

  @override
  Future<String?> getConfig(String context, String name) async => null;

  @override
  Future<void> addTeamMember(
    int ticketId, {
    required String type,
    required String role,
    required int memberId,
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<void> removeTeamMember(
    int ticketId, {
    required String type,
    required String role,
    required int memberId,
    String itemtype = itilTicket,
  }) => throw UnimplementedError();

  @override
  Future<PushConfig> fetchPushConfig() async =>
      const PushConfig(vapidPublicKey: '', transports: {});

  @override
  Future<void> registerDevice({
    required String transport,
    required String endpoint,
    String? p256dh,
    String? auth,
    required String platform,
  }) async {}

  @override
  Future<ItilExtraDto> getItilExtra(String itemtype, int id) async =>
      const ItilExtraDto(fields: {});

  @override
  Future<void> patchItilExtra(
    String itemtype,
    int id,
    Map<String, Object?> fields,
  ) async {}

  @override
  Future<List<ItilLinkDto>> listItilLinks(String itemtype, int id) async =>
      const [];

  @override
  Future<void> addItilLink(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
    int linkType = ItilLinkType.linkTo,
  }) async {}

  @override
  Future<void> removeItilLink(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {}

  // --- Planning ---

  @override
  Future<List<PlanningEventDto>> fetchPlanning(
    String start,
    String end,
  ) async => const [];

  @override
  Future<void> planItilTask(
    int parentId,
    int taskId, {
    required String itemtype,
    String? plannedBegin,
    String? plannedEnd,
    int? state,
  }) async {}

  @override
  Future<void> patchProjectTask(
    int taskId,
    Map<String, Object?> fields,
  ) async {}

  @override
  Future<int> createExternalEvent(Map<String, Object?> body) =>
      throw UnimplementedError();

  @override
  Future<void> patchExternalEvent(int id, Map<String, Object?> fields) async {}

  @override
  Future<void> deleteExternalEvent(int id) async {}

  @override
  Future<List<Map<String, Object?>>> listReminders() async => const [];

  @override
  Future<int> createReminder(Map<String, Object?> body) =>
      throw UnimplementedError();

  @override
  Future<void> patchReminder(int id, Map<String, Object?> fields) async {}

  @override
  Future<void> deleteReminder(int id) async {}

  // --- Projects ---

  @override
  Future<Page<ProjectDto>> listProjects({
    int start = 0,
    int limit = 100,
  }) async => const Page([], 0);

  @override
  Future<ProjectDto> getProject(int id) => throw UnimplementedError();

  @override
  Future<List<ProjectTaskDto>> listProjectTasks(int projectId) async =>
      const [];

  @override
  Future<int> createProjectTask(int projectId, Map<String, Object?> body) =>
      throw UnimplementedError();

  // --- Knowledge base ---

  @override
  Future<List<KbArticleDto>> searchKbArticles({
    String query = '',
    bool faqOnly = false,
    int? categoryId,
    int limit = 40,
  }) async => const [];

  @override
  Future<KbArticleDto> getKbArticle(int id) => throw UnimplementedError();

  @override
  Future<List<KbCategoryDto>> listKbCategories() async => const [];

  @override
  Future<List<KbCommentDto>> listKbComments(int articleId) async => const [];

  @override
  Future<int> createKbComment(int articleId, String comment) =>
      throw UnimplementedError();

  // --- RSS ---

  @override
  Future<List<RssFeedDto>> listRssFeeds() async => const [];

  @override
  Future<int> createRssFeed(Map<String, Object?> body) =>
      throw UnimplementedError();

  @override
  Future<void> patchRssFeed(int id, Map<String, Object?> fields) async {}

  @override
  Future<void> deleteRssFeed(int id) async {}

  // --- Reservations ---

  @override
  Future<List<ReservationItemDto>> listReservationItems() async => const [];

  @override
  Future<List<ReservationDto>> listReservations() async => const [];

  @override
  Future<int> createReservation(Map<String, Object?> body) =>
      throw UnimplementedError();

  @override
  Future<void> deleteReservation(int id) async {}

  @override
  Future<void> unregisterDevice(String endpoint) async {}

  // --- Assets / Management ---

  @override
  Future<List<ItemtypeInfo>> listItemtypes(String domain) async => const [];

  @override
  Future<Page<CatalogItemDto>> listCatalogItems(
    String domain,
    String itemtype, {
    String? search,
    int? statusId,
    int start = 0,
    int limit = 50,
  }) async => const Page([], 0);

  @override
  Future<CatalogItemDto> getCatalogItem(
    String domain,
    String itemtype,
    int id,
  ) => throw UnimplementedError();

  @override
  Future<void> patchCatalogItem(
    String domain,
    String itemtype,
    int id,
    Map<String, Object?> fields,
  ) async {}

  @override
  Future<Map<String, Object?>?> getInfocom(String itemtype, int id) async =>
      null;

  @override
  Future<Map<String, Object?>> getRawRecord(String itemtype, int id) async =>
      const {};

  @override
  Future<List<NetworkPortDto>> listAssetPorts(String itemtype, int id) async =>
      const [];

  @override
  Future<SoftwareListDto> listAssetSoftware(String itemtype, int id) async =>
      const SoftwareListDto(total: 0, items: []);

  @override
  Future<List<AssetItilLinkDto>> listAssetItil(String itemtype, int id) async =>
      const [];

  @override
  Future<List<LinkedAssetDto>> listItilItems(String itemtype, int id) async =>
      const [];

  @override
  Future<void> addItilItem(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {}

  @override
  Future<void> removeItilItem(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {}
}
