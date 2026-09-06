import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/dto/catalog_dto.dart';
import 'api/dto/dropdown_dto.dart';
import 'api/dto/form_dto.dart';
import 'api/dto/tools_dto.dart';
import 'api/dto/user_ref.dart';
import 'api/errors.dart';
import 'api/glpi_api.dart';
import 'api/itil_type.dart';
import 'api/rsql.dart';
import 'auth/auth_controller.dart';
import 'auth/context_switcher.dart';
import 'db/app_database.dart';
import 'models/attachment.dart';
import 'models/capabilities.dart';
import 'models/catalog_item.dart';
import 'models/entity_node.dart';
import 'models/itil_link.dart';
import 'models/planning_event.dart';
import 'models/project.dart';
import 'models/reminder.dart';
import 'models/session_info.dart';
import 'models/ticket_detail.dart';
import 'models/ticket_list_item.dart';
import 'models/timeline_entry.dart';
import 'repositories/attachment_repository.dart';
import 'repositories/catalog_repository.dart';
import 'repositories/itil_link_repository.dart';
import 'repositories/planning_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/reference_repository.dart';
import 'repositories/ticket_repository.dart';
import 'repositories/timeline_repository.dart';
import 'repositories/tools_repository.dart';
import 'sync/outbox_drainer.dart';
import 'sync/outbox_writer.dart';
import 'sync/sync_service.dart';
import 'sync/sync_status.dart';
import 'sync/ticket_actions.dart';
import 'sync/timer_service.dart';

/// Single app-wide database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The HL API bound to the signed-in account's dio, or null when signed out.
final glpiApiProvider = Provider<GlpiApi?>((ref) {
  ref.watch(authControllerProvider); // rebuild on sign-in/out
  final dio = ref.watch(authControllerProvider.notifier).dio;
  return dio == null ? null : HlGlpiApi(dio);
});

final ticketRepositoryProvider = Provider<TicketRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return TicketRepository(ref.watch(databaseProvider), api);
});

final timelineRepositoryProvider = Provider<TimelineRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return TimelineRepository(ref.watch(databaseProvider), api);
});

final referenceRepositoryProvider = Provider<ReferenceRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return ReferenceRepository(ref.watch(databaseProvider), api);
});

final itilLinkRepositoryProvider = Provider<ItilLinkRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return ItilLinkRepository(ref.watch(databaseProvider), api);
});

/// An object's relationships to other ITIL objects (reactive, offline-first).
final itilLinksProvider = StreamProvider.family<List<ItilLink>, String>((
  ref,
  ownerLocalId,
) {
  final repo = ref.watch(itilLinkRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchLinks(ownerLocalId);
});

/// Cached Change/Problem analysis fields (reactive, offline-first).
final itilExtraProvider = StreamProvider.family<Map<String, String>, String>((
  ref,
  ownerLocalId,
) {
  final repo = ref.watch(itilLinkRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchExtra(ownerLocalId);
});

final catalogRepositoryProvider = Provider<CatalogRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return CatalogRepository(ref.watch(databaseProvider), api);
});

/// Itemtype directory for a domain ('Assets' or 'Management').
final itemtypesProvider = FutureProvider.family<List<ItemtypeInfo>, String>((
  ref,
  domain,
) async {
  final repo = ref.watch(catalogRepositoryProvider);
  if (repo == null) return const [];
  return repo.itemtypes(domain);
});

/// Record count per itemtype, for the hub badges.
typedef CatalogScope = ({String domain, String itemtype});

final catalogCountProvider = FutureProvider.family<int, CatalogScope>((
  ref,
  scope,
) async {
  final repo = ref.watch(catalogRepositoryProvider);
  if (repo == null) return -1;
  return repo.countOf(scope.domain, scope.itemtype);
});

final catalogListProvider =
    StreamProvider.family<List<CatalogItem>, CatalogScope>((ref, scope) {
      final repo = ref.watch(catalogRepositoryProvider);
      if (repo == null) return const Stream.empty();
      return repo.watchList(scope.domain, scope.itemtype);
    });

final catalogItemProvider = StreamProvider.family<CatalogItem?, String>((
  ref,
  localId,
) {
  final repo = ref.watch(catalogRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchItem(localId);
});

/// Search across a domain's primary itemtypes (hub search + barcode lookup).
typedef CatalogSearch = ({String domain, String query});

final catalogSearchProvider =
    FutureProvider.family<List<CatalogItem>, CatalogSearch>((ref, s) async {
      final repo = ref.watch(catalogRepositoryProvider);
      if (repo == null) return const [];
      return repo.searchAcross(
        s.domain,
        s.domain == 'Assets' ? primaryAssetTypes : managementTier1,
        s.query,
      );
    });

/// Loads a record's full payload (+ Infocom) into the cache, then the
/// reactive [catalogItemProvider] renders it.
final catalogDetailLoadProvider =
    FutureProvider.family<CatalogItem?, CatalogRef>((ref, r) async {
      final repo = ref.watch(catalogRepositoryProvider);
      if (repo == null) return null;
      return repo.loadItem(r.domain, r.itemtype, r.serverId);
    });

typedef CatalogRef = ({String domain, String itemtype, int serverId});
typedef AssetRef = ({String itemtype, int serverId});

final assetPortsProvider =
    FutureProvider.family<List<NetworkPortDto>, AssetRef>((ref, r) async {
      final api = ref.watch(glpiApiProvider);
      if (api == null) return const [];
      return api.listAssetPorts(r.itemtype, r.serverId);
    });

final assetSoftwareProvider = FutureProvider.family<SoftwareListDto, AssetRef>((
  ref,
  r,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const SoftwareListDto(total: 0, items: []);
  return api.listAssetSoftware(r.itemtype, r.serverId);
});

/// ITIL objects linked to an asset.
final assetItilProvider =
    FutureProvider.family<List<AssetItilLinkDto>, AssetRef>((ref, r) async {
      final api = ref.watch(glpiApiProvider);
      if (api == null) return const [];
      return api.listAssetItil(r.itemtype, r.serverId);
    });

/// Assets linked to an ITIL object (ticket/change/problem detail).
final itilItemsProvider = FutureProvider.family<List<LinkedAssetDto>, AssetRef>(
  (ref, r) async {
    final api = ref.watch(glpiApiProvider);
    if (api == null) return const [];
    return api.listItilItems(r.itemtype, r.serverId);
  },
);

final toolsRepositoryProvider = Provider<ToolsRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  final account = switch (ref.watch(authControllerProvider)) {
    Ready(:final account) => account,
    _ => null,
  };
  return ToolsRepository(
    ref.watch(databaseProvider),
    api,
    myUserId: account?.userId,
  );
});

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchReminders();
});

/// KB search parameters the browse screen drives.
typedef KbQuery = ({String text, bool faqOnly, int? categoryId});

final kbSearchProvider = FutureProvider.family<List<KbArticleDto>, KbQuery>((
  ref,
  q,
) async {
  final repo = ref.watch(toolsRepositoryProvider);
  if (repo == null) return const [];
  return repo.searchArticles(
    query: q.text,
    faqOnly: q.faqOnly,
    categoryId: q.categoryId,
  );
});

/// Articles already cached on the device (the offline shelf).
final kbCachedProvider = StreamProvider<List<KbArticleDto>>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchCachedArticles();
});

final kbCategoriesProvider = StreamProvider<List<KbCategoryDto>>((ref) {
  final repo = ref.watch(toolsRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchCategories();
});

final kbArticleProvider = StreamProvider.family<KbArticleDto?, int>((ref, id) {
  final repo = ref.watch(toolsRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchArticle(id);
});

final kbCommentsProvider = FutureProvider.family<List<KbCommentDto>, int>((
  ref,
  id,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  try {
    return await api.listKbComments(id);
  } on Exception {
    return const []; // comments need a connection
  }
});

final rssFeedsProvider = FutureProvider<List<RssFeedDto>>((ref) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.listRssFeeds();
});

final reservationItemsProvider = FutureProvider<List<ReservationItemDto>>((
  ref,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.listReservationItems();
});

final reservationsProvider = FutureProvider<List<ReservationDto>>((ref) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.listReservations();
});

final projectRepositoryProvider = Provider<ProjectRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return ProjectRepository(ref.watch(databaseProvider), api);
});

/// All cached projects (reactive).
final projectsProvider = StreamProvider<List<Project>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchProjects();
});

final projectDetailProvider = StreamProvider.family<Project?, String>((
  ref,
  localId,
) {
  final repo = ref.watch(projectRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchProject(localId);
});

/// A project's tasks, flattened parent-then-child with depth.
final projectTasksProvider = StreamProvider.family<List<ProjectTask>, String>((
  ref,
  projectLocalId,
) {
  final repo = ref.watch(projectRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchTasks(projectLocalId);
});

final planningRepositoryProvider = Provider<PlanningRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return PlanningRepository(ref.watch(databaseProvider), api);
});

/// The day the Planning screen is showing.
class PlanningDay extends Notifier<DateTime> {
  @override
  DateTime build() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void set(DateTime day) => state = DateTime(day.year, day.month, day.day);
}

final planningDayProvider = NotifierProvider<PlanningDay, DateTime>(
  PlanningDay.new,
);

/// Events for the selected day (reactive, offline-first).
final planningDayEventsProvider = StreamProvider<List<PlanningEvent>>((ref) {
  final repo = ref.watch(planningRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchDay(ref.watch(planningDayProvider));
});

/// Events for the week containing the selected day (agenda view).
final planningWeekEventsProvider = StreamProvider<List<PlanningEvent>>((ref) {
  final repo = ref.watch(planningRepositoryProvider);
  if (repo == null) return const Stream.empty();
  final day = ref.watch(planningDayProvider);
  final monday = day.subtract(Duration(days: day.weekday - 1));
  return repo.watchRange(monday, monday.add(const Duration(days: 6)));
});

final attachmentRepositoryProvider = Provider<AttachmentRepository?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return AttachmentRepository(ref.watch(databaseProvider), api);
});

/// A ticket's attachments from the local DB (reactive).
final attachmentsProvider = StreamProvider.family<List<Attachment>, String>((
  ref,
  ticketLocalId,
) {
  final repo = ref.watch(attachmentRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watch(ticketLocalId);
});

/// The service catalog: forms this user may answer.
final formCatalogProvider = FutureProvider<List<FormSummaryDto>>((ref) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.listForms();
});

/// Which level of the service catalog is being looked at: a category (0 at the
/// root) and the search filter, which — as in the web catalog — searches across
/// every category rather than inside the current one.
typedef ServiceCatalogQuery = ({int category, String filter});

/// One level of the service catalog, with the entity's display settings.
///
/// A family rather than one provider because each level is its own screen: the
/// app pushes a route per category, so going back is GLPI's breadcrumb without
/// the app having to keep a stack of its own.
final serviceCatalogProvider =
    FutureProvider.family<ServiceCatalogPageDto, ServiceCatalogQuery>((
      ref,
      query,
    ) async {
      final api = ref.watch(glpiApiProvider);
      if (api == null) return ServiceCatalogPageDto.empty;
      return api.fetchServiceCatalog(
        category: query.category,
        filter: query.filter,
      );
    });

/// A single form's full definition (sections/questions/options).
final formDefinitionProvider = FutureProvider.family<FormDefinitionDto, int>((
  ref,
  formId,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) throw StateError('not signed in');
  return api.getForm(formId);
});

/// The on-device file path for an attachment (downloads + caches server docs on
/// first read), memoized per attachment id.
final attachmentFileProvider = FutureProvider.family<String?, String>((
  ref,
  attachmentLocalId,
) {
  final repo = ref.watch(attachmentRepositoryProvider);
  if (repo == null) return Future.value(null);
  return repo.localFileForId(attachmentLocalId);
});

/// Cached ITIL categories (for the category picker).
final categoriesProvider = StreamProvider<List<DropdownItem>>((ref) {
  final repo = ref.watch(referenceRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchDropdown(DropdownKinds.category);
});

/// On-device path for a standalone GLPI Document (downloads once, then caches).
typedef DocumentRef = ({int id, String? filename});

final documentFileProvider = FutureProvider.family<String?, DocumentRef>((
  ref,
  d,
) {
  final repo = ref.watch(attachmentRepositoryProvider);
  if (repo == null) return Future.value(null);
  return repo.cachedDocument(d.id, filename: d.filename);
});

/// Cached asset statuses (GLPI `State`) — available offline like the rest of
/// the reference data.
final assetStatusesProvider = StreamProvider<List<DropdownItem>>((ref) {
  final repo = ref.watch(referenceRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchDropdown(DropdownKinds.state);
});

/// Cached locations (asset + management edits, ticket location).
final locationsProvider = StreamProvider<List<DropdownItem>>((ref) {
  final repo = ref.watch(referenceRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchDropdown(DropdownKinds.location);
});

/// Live user search for the assignee picker (read-through, debounced by caller).
final userSearchProvider = FutureProvider.family<List<UserRef>, String>((
  ref,
  query,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.searchUsers(query);
});

/// Which ITIL module the shell is showing (Tickets / Changes / Problems).
class ItilModule extends Notifier<String> {
  @override
  String build() => itilTicket;

  void set(String itemtype) => state = itemtype;
}

final itilModuleProvider = NotifierProvider<ItilModule, String>(ItilModule.new);

/// The open queue for the active module, from the local DB (reactive).

final queueProvider = StreamProvider<List<TicketListItem>>((ref) {
  final repo = ref.watch(ticketRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchQueue(itemtype: ref.watch(itilModuleProvider));
});

/// Search ITIL objects for the link picker. Tries the server, and falls back to
/// the local cache so linking still works offline.
final itilSearchProvider =
    FutureProvider.family<
      List<({int id, String name, int status})>,
      ({String itemtype, String query})
    >((ref, args) async {
      final db = ref.watch(databaseProvider);
      final api = ref.watch(glpiApiProvider);
      final q = args.query.trim();

      Future<List<({int id, String name, int status})>> fromCache() async {
        final rows =
            await (db.select(db.tickets)
                  ..where((t) => t.itemtype.equals(args.itemtype))
                  ..limit(30))
                .get();
        return [
          for (final r in rows)
            if (r.serverId != null &&
                (q.isEmpty ||
                    r.name.toLowerCase().contains(q.toLowerCase()) ||
                    '${r.serverId}' == q.replaceAll('#', '')))
              (id: r.serverId!, name: r.name, status: r.status),
        ];
      }

      if (api == null) return fromCache();
      try {
        // A bare number searches by id; anything else matches the title.
        final byId = int.tryParse(q.replaceAll('#', ''));
        final page = await api.searchTickets(
          itemtype: args.itemtype,
          filter: q.isEmpty
              ? null
              : (byId != null
                    ? Rsql.eq('id', byId)
                    : Rsql.raw('name=ilike="*$q*"')),
          sort: 'date_mod:desc',
          limit: 30,
        );
        return [
          for (final t in page.items)
            (id: t.id, name: t.name, status: t.status),
        ];
      } on Exception {
        return fromCache();
      }
    });

final ticketDetailProvider = StreamProvider.family<TicketDetail?, String>((
  ref,
  localId,
) {
  final repo = ref.watch(ticketRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchTicket(localId);
});

final timelineProvider = StreamProvider.family<List<TimelineEntry>, String>((
  ref,
  ticketLocalId,
) {
  final repo = ref.watch(timelineRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchTimeline(ticketLocalId);
});

// --- Sync / outbox (M3) ---

final syncServiceProvider = Provider<SyncService?>((ref) {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  final db = ref.watch(databaseProvider);
  final account = switch (ref.watch(authControllerProvider)) {
    Ready(:final account) => account,
    _ => null,
  };
  return SyncService(db, OutboxDrainer(db, api, myUserId: account?.userId));
});

final outboxWriterProvider = Provider<OutboxWriter>((ref) {
  return OutboxWriter(
    ref.watch(databaseProvider),
    // Read at enqueue time: each op remembers the entity it was written in.
    entity: () {
      final account = switch (ref.read(authControllerProvider)) {
        Ready(:final account) => account,
        _ => null,
      };
      final id = account?.entityId;
      return id == null ? null : (id: id, recursive: account!.entityRecursive);
    },
  );
});

/// Switches the working profile/entity, resetting the caches that belonged to
/// the old context.
final contextSwitcherProvider = Provider<ContextSwitcher>((ref) {
  final account = switch (ref.watch(authControllerProvider)) {
    Ready(:final account) => account,
    _ => null,
  };
  return ContextSwitcher(
    ref.watch(databaseProvider),
    ref.read(authControllerProvider.notifier),
    account,
  );
});

/// The entity tree this account may work in (profile-dependent).
///
/// Cached, because switching entity is exactly the kind of thing a technician
/// does on a client site with no signal — and the tree changes rarely.
final entityTreeProvider = FutureProvider<List<EntityNode>>((ref) async {
  ref.watch(authControllerProvider); // refetch after a context change
  final db = ref.watch(databaseProvider);
  final dio = ref.read(authControllerProvider.notifier).dio;
  const key = 'entity_tree';
  if (dio != null) {
    try {
      final response = await dio.get<List<Object?>>('/Session/EntityTree');
      final raw = response.data ?? const [];
      await db
          .into(db.appConfig)
          .insertOnConflictUpdate(
            AppConfigCompanion.insert(key: key, value: jsonEncode(raw)),
          );
      return EntityNode.listFromJson(raw);
    } on Exception {
      // Fall through to the cache.
    }
  }
  final row = await (db.select(
    db.appConfig,
  )..where((c) => c.key.equals(key))).getSingleOrNull();
  if (row == null) return const [];
  return EntityNode.listFromJson(jsonDecode(row.value) as List<Object?>);
});

/// Which optional server-plugin features this server offers (drawer modules,
/// per-action gates). Fetched once the account is Ready and re-fetched on
/// login/context change; [SyncScope] also invalidates it on app resume.
///
/// The last-known map is cached in [AppConfig] so gating still works offline.
/// A 404 (an older companion plugin without the endpoint) means the server
/// affirmatively has no optional features — the cache is cleared. Any other
/// failure falls back to the cache, then to [Capabilities.empty]: features
/// hide, nothing crashes.
final capabilitiesProvider = FutureProvider<Capabilities>((ref) async {
  ref.watch(authControllerProvider); // refetch after login / context change
  final db = ref.watch(databaseProvider);
  final api = ref.watch(glpiApiProvider);
  const key = 'capabilities';
  if (api != null) {
    try {
      final caps = await api.fetchCapabilities();
      await db
          .into(db.appConfig)
          .insertOnConflictUpdate(
            AppConfigCompanion.insert(
              key: key,
              value: jsonEncode(caps.toJson()),
            ),
          );
      return caps;
    } on GlpiNotFoundError {
      await (db.delete(db.appConfig)..where((c) => c.key.equals(key))).go();
      return Capabilities.empty;
    } on Exception {
      // Fall through to the cache.
    }
  }
  final row = await (db.select(
    db.appConfig,
  )..where((c) => c.key.equals(key))).getSingleOrNull();
  if (row == null) return Capabilities.empty;
  try {
    return Capabilities.fromJson(jsonDecode(row.value));
  } on Exception {
    return Capabilities.empty;
  }
});

/// The current session as GLPI sees it — used for the profile list.
final sessionInfoProvider = FutureProvider<SessionInfo?>((ref) async {
  ref.watch(authControllerProvider);
  final dio = ref.read(authControllerProvider.notifier).dio;
  if (dio == null) return null;
  final response = await dio.get<Map<String, Object?>>('/session');
  return SessionInfo.fromJson(response.data!);
});

/// Facade the UI calls for offline writes: enqueue + optimistic change, then
/// kick the sync engine.
final ticketActionsProvider = Provider<TicketActions?>((ref) {
  final sync = ref.watch(syncServiceProvider);
  if (sync == null) return null;
  final account = switch (ref.watch(authControllerProvider)) {
    Ready(:final account) => account,
    _ => null,
  };
  if (account == null) return null;
  return TicketActions(
    writer: ref.watch(outboxWriterProvider),
    sync: sync,
    userId: account.userId,
    userName: account.displayName,
  );
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final sync = ref.watch(syncServiceProvider);
  if (sync == null) return Stream.value(const SyncStatus());
  return sync.watchStatus();
});

/// Failed (needs-attention) outbox ops for the Needs Attention screen.
final needsAttentionProvider = StreamProvider<List<PendingOp>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.pendingOps)
    ..where((o) => o.status.equals('needsAttention'))
    ..orderBy([(o) => OrderingTerm(expression: o.id)]);
  return query.watch();
});

// --- Task timer ---

final timerServiceProvider = Provider<TimerService>((ref) {
  return TimerService(ref.watch(databaseProvider));
});

final activeTimerProvider = StreamProvider<ActiveTimer?>((ref) {
  return ref.watch(timerServiceProvider).watchActive();
});

/// Set by "stop timer" to pre-fill the composer's task duration (minutes).
class PendingTaskMinutes extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? minutes) => state = minutes;
}

final pendingTaskMinutesProvider = NotifierProvider<PendingTaskMinutes, int?>(
  PendingTaskMinutes.new,
);

/// Set by the KEDB banner's "Use workaround" to pre-fill the reply composer
/// with the workaround snippet — the technician still reads it, still edits
/// it, and still presses Send. Consumed (and cleared) by the composer, the
/// same handshake as [pendingTaskMinutesProvider].
class PendingComposerText extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? text) => state = text;
}

final pendingComposerTextProvider =
    NotifierProvider<PendingComposerText, String?>(PendingComposerText.new);

/// Count of pending (not-done) ops for a ticket — drives the "sending" badge.
final ticketPendingCountProvider = StreamProvider.family<int, String>((
  ref,
  ticketLocalId,
) {
  final db = ref.watch(databaseProvider);
  final countExp = db.pendingOps.id.count();
  final query = db.selectOnly(db.pendingOps)
    ..addColumns([countExp])
    ..where(
      db.pendingOps.ticketLocalId.equals(ticketLocalId) &
          db.pendingOps.status.isNotValue('done'),
    );
  return query.watchSingle().map((row) => row.read(countExp) ?? 0);
});
