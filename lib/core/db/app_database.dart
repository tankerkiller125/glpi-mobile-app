import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Tickets,
    TicketTeam,
    TimelineItems,
    DropdownItems,
    PendingOps,
    ActiveTimers,
    AppConfig,
    SyncState,
    Attachments,
    ItilLinks,
    ItilExtras,
    PlanningEvents,
    Projects,
    ProjectTasks,
    Reminders,
    KbCategories,
    KbArticles,
    CatalogItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'glpi_mobile'));

  // v1: Tickets, TicketTeam, SyncState. v2: TimelineItems + DropdownItems.
  // v3: PendingOps + ActiveTimers. v4: ticket location + recipient columns.
  // v5: AppConfig (cached instance config). v6: validation approver + comments.
  // v7: Attachments (ticket documents + pending uploads).
  // v8: ITIL itemtype discriminator + object links/analysis extras.
  // v9: PlanningEvents (calendar feed cache + offline-created events).
  // v10: Projects + ProjectTasks. v11: Reminders + knowledge base.
  // v12: CatalogItems (generic assets + management browser).
  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(timelineItems);
        await m.createTable(dropdownItems);
      }
      if (from < 3) {
        await m.createTable(pendingOps);
        await m.createTable(activeTimers);
      }
      if (from < 4) {
        await m.addColumn(tickets, tickets.locationId);
        await m.addColumn(tickets, tickets.locationName);
        await m.addColumn(tickets, tickets.recipientName);
      }
      if (from < 5) {
        await m.createTable(appConfig);
      }
      if (from < 6) {
        await m.addColumn(timelineItems, timelineItems.approverId);
        await m.addColumn(timelineItems, timelineItems.approverType);
        await m.addColumn(timelineItems, timelineItems.approvalComment);
      }
      if (from < 7) {
        await m.createTable(attachments);
      }
      if (from < 8) {
        await m.addColumn(tickets, tickets.itemtype);
        await m.addColumn(pendingOps, pendingOps.itemtype);
        await m.createTable(itilLinks);
        await m.createTable(itilExtras);
      }
      if (from < 9) {
        await m.createTable(planningEvents);
      }
      if (from < 10) {
        await m.createTable(projects);
        await m.createTable(projectTasks);
      }
      if (from < 11) {
        await m.createTable(reminders);
        await m.createTable(kbCategories);
        await m.createTable(kbArticles);
      }
      if (from < 12) {
        await m.createTable(catalogItems);
      }
      if (from < 13) {
        await m.addColumn(pendingOps, pendingOps.entityId);
        await m.addColumn(pendingOps, pendingOps.entityRecursive);
      }
    },
  );
}
