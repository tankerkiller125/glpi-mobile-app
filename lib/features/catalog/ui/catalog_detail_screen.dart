import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/catalog_item.dart';
import '../../../core/models/rights.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/due_badge.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../core/widgets/rights_gate.dart';
import '../../../core/widgets/section_heading.dart';
import '../../ticket/ui/attachments_section.dart';
import '../../ticket/ui/compose_sheet.dart';
import '../../ticket/ui/option_sheet.dart';
import '../../ticket/ui/user_picker.dart';
import '../../tools/ui/reservation_booking.dart';
import 'catalog_tile.dart';

/// One asset or management record. GLPI's schemas differ per itemtype, so the
/// screen renders the fields it knows explicitly and everything else generically
/// from the stored payload — a custom asset definition looks like any other.
class CatalogDetailScreen extends ConsumerStatefulWidget {
  const CatalogDetailScreen({
    super.key,
    required this.domain,
    required this.itemtype,
    required this.localId,
  });

  final String domain;
  final String itemtype;
  final String localId;

  @override
  ConsumerState<CatalogDetailScreen> createState() =>
      _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends ConsumerState<CatalogDetailScreen> {
  bool _loadedOnce = false;

  bool get _isAsset => widget.domain == 'Assets';

  @override
  Widget build(BuildContext context) {
    // Watched (not read) so the dropdown streams stay subscribed — a `read` on
    // a StreamProvider nothing is listening to has no value yet.
    ref
      ..watch(assetStatusesProvider)
      ..watch(locationsProvider);
    final item = ref.watch(catalogItemProvider(widget.localId)).value;
    // Raising a ticket about the asset is a ticket right, not an asset one.
    final canOpenTicket = (ref.watch(rightsProvider).value ?? Rights.empty)
        .canCreateItil('Ticket');
    if (item == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading'),
        ),
      );
    }
    if (!_loadedOnce) {
      _loadedOnce = true;
      // Pull the full payload (+ Infocom) once; the row above stays reactive.
      ref.read(
        catalogDetailLoadProvider((
          domain: widget.domain,
          itemtype: widget.itemtype,
          serverId: item.serverId,
        )),
      );
      unawaited(_refreshAttachments(item));
    }

    return RightsGate(
      allows: (r) => r.canReadItemtype(widget.itemtype),
      title: widget.itemtype,
      child: Scaffold(
        appBar: AppBar(
          title: Text(item.displayName, overflow: TextOverflow.ellipsis),
          actions: [
            if (item.pending)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: AccessibleRefresh(
          onRefresh: () async {
            ref.invalidate(
              catalogDetailLoadProvider((
                domain: widget.domain,
                itemtype: widget.itemtype,
                serverId: item.serverId,
              )),
            );
            if (_isAsset) {
              final ref_ = (itemtype: widget.itemtype, serverId: item.serverId);
              ref
                ..invalidate(assetPortsProvider(ref_))
                ..invalidate(assetSoftwareProvider(ref_))
                ..invalidate(assetItilProvider(ref_));
            }
            await _refreshAttachments(item);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _identity(item),
              _reserve(item),
              const Divider(height: 24),
              if (_isAsset) ...[
                _InfocomSection(item: item),
                _PortsSection(
                  itemtype: widget.itemtype,
                  serverId: item.serverId,
                ),
                if (widget.itemtype == 'Computer')
                  _SoftwareSection(
                    itemtype: widget.itemtype,
                    serverId: item.serverId,
                  ),
                _ItilSection(item: item),
              ] else ...[
                if (widget.itemtype == 'Document') _DocumentSection(item: item),
                _ValiditySection(item: item),
                _ContactSection(item: item),
              ],
              const SizedBox(height: 8),
              AttachmentsSection(
                ownerLocalId: item.localId,
                ownerServerId: item.serverId,
                itemtype: item.itemtype,
              ),
              const SizedBox(height: 16),
              _OtherFieldsSection(item: item),
            ],
          ),
        ),
        floatingActionButton: _isAsset && canOpenTicket
            ? FloatingActionButton.extended(
                onPressed: () => _createTicket(item),
                icon: const Icon(Icons.add_task),
                label: const Text('New ticket'),
              )
            : null,
      ),
    );
  }

  /// GLPI attaches Documents to any itemtype, but only the ITIL screens sync
  /// them automatically — pull this record's own set too.
  Future<void> _refreshAttachments(CatalogItem item) async {
    try {
      await ref
          .read(attachmentRepositoryProvider)
          ?.refresh(item.localId, item.serverId, itemtype: item.itemtype);
    } on Exception {
      // Offline: whatever is cached keeps showing.
    }
  }

  /// GLPI only allows booking assets someone made reservable; show the button
  /// only when a matching ReservationItem exists.
  Widget _reserve(CatalogItem item) {
    if (!_isAsset) return const SizedBox.shrink();
    final reservable = ref.watch(reservationItemsProvider).value ?? const [];
    final match = reservable
        .where(
          (r) =>
              r.isActive &&
              r.itemtype == item.itemtype &&
              r.itemsId == item.serverId,
        )
        .firstOrNull;
    if (match == null) return const SizedBox.shrink();
    final canBook =
        (ref.watch(rightsProvider).value ?? Rights.empty).canBookReservations;
    if (!canBook) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.tonalIcon(
          onPressed: () => bookReservation(context, ref, match),
          icon: const Icon(Icons.event_available_outlined),
          label: const Text('Reserve'),
        ),
      ),
    );
  }

  Widget _identity(CatalogItem item) {
    // Editing in the field needs UPDATE on the itemtype; a read-only profile
    // gets the same rows without the tap target.
    final canEdit = (ref.watch(rightsProvider).value ?? Rights.empty)
        .canUpdateItemtype(item.itemtype);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoTile(
          icon: catalogIcon(item.itemtype),
          label: 'Type',
          value: item.typeName ?? item.itemtype,
        ),
        if ((item.serial ?? '').isNotEmpty)
          InfoTile(icon: Icons.tag, label: 'Serial', value: item.serial!),
        if ((item.otherserial ?? '').isNotEmpty)
          InfoTile(
            icon: Icons.qr_code_2,
            label: 'Asset tag',
            value: item.otherserial!,
          ),
        if ((item.manufacturerName ?? '').isNotEmpty)
          InfoTile(
            icon: Icons.factory_outlined,
            label: 'Maker',
            value: item.manufacturerName!,
          ),
        if ((item.modelName ?? '').isNotEmpty)
          InfoTile(
            icon: Icons.devices_other,
            label: 'Model',
            value: item.modelName!,
          ),
        // Editable in the field: what a technician actually changes on site.
        // Only offered when the itemtype really has the field — a Supplier has
        // no status or location, and PATCHing one would be a silent no-op.
        if (item.fields.containsKey('status'))
          InfoTile(
            icon: Icons.flag_outlined,
            label: 'Status',
            value: item.statusName ?? 'Not set',
            onTap: canEdit ? () => _editStatus(item) : null,
          ),
        if (item.fields.containsKey('location'))
          InfoTile(
            icon: Icons.place_outlined,
            label: 'Location',
            value: item.locationName ?? 'Not set',
            onTap: canEdit ? () => _editLocation(item) : null,
          ),
        if (item.fields.containsKey('user'))
          InfoTile(
            icon: Icons.person_outline,
            label: 'User',
            value: item.userName ?? 'Not set',
            onTap: canEdit ? () => _editUser(item) : null,
          ),
        if ((item.groupName ?? '').isNotEmpty)
          InfoTile(
            icon: Icons.group_outlined,
            label: 'Group',
            value: item.groupName!,
          ),
        if ((item.entityName ?? '').isNotEmpty)
          InfoTile(
            icon: Icons.account_tree_outlined,
            label: 'Entity',
            value: item.entityName!,
          ),
        InfoTile(
          icon: Icons.notes_outlined,
          label: 'Comment',
          value: (item.comment ?? '').isEmpty
              ? (canEdit ? 'Add a note' : 'Not set')
              : item.comment!,
          onTap: canEdit ? () => _editComment(item) : null,
        ),
      ],
    );
  }

  Future<void> _editStatus(CatalogItem item) async {
    // Statuses come from the synced dropdown cache, so this works offline.
    final states = ref.read(assetStatusesProvider).value ?? const [];
    if (states.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statuses are still syncing')),
      );
      return;
    }
    final chosen = await OptionSheet.show(
      context,
      title: 'Status',
      options: [
        for (final s in states) OptionItem(value: s.serverId, label: s.name),
      ],
      current: 0,
    );
    if (chosen == null) return;
    await ref
        .read(ticketActionsProvider)
        ?.patchCatalogItem(
          item,
          statusId: chosen,
          statusName: states.firstWhere((s) => s.serverId == chosen).name,
        );
  }

  Future<void> _editLocation(CatalogItem item) async {
    final locations = ref.read(locationsProvider).value ?? const [];
    if (locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Locations are still syncing')),
      );
      return;
    }
    final chosen = await OptionSheet.show(
      context,
      title: 'Location',
      options: [
        for (final l in locations) OptionItem(value: l.serverId, label: l.name),
      ],
      current: 0,
    );
    if (chosen == null) return;
    await ref
        .read(ticketActionsProvider)
        ?.patchCatalogItem(
          item,
          locationId: chosen,
          locationName: locations.firstWhere((l) => l.serverId == chosen).name,
        );
  }

  Future<void> _editUser(CatalogItem item) async {
    final user = await UserPicker.show(context, title: 'Assign user');
    if (user == null) return;
    await ref
        .read(ticketActionsProvider)
        ?.patchCatalogItem(item, userId: user.id, userName: user.displayName);
  }

  Future<void> _editComment(CatalogItem item) async {
    final text = await ComposeSheet.show(
      context,
      title: 'Comment',
      hint: 'Notes about this record',
      initialText: item.comment ?? '',
      submitLabel: 'Save',
    );
    if (text == null) return;
    await ref
        .read(ticketActionsProvider)
        ?.patchCatalogItem(item, comment: text);
  }

  /// Log a ticket about this asset: create it, then queue the asset link
  /// against the (possibly still-unsynced) ticket.
  Future<void> _createTicket(CatalogItem item) async {
    final actions = ref.read(ticketActionsProvider);
    if (actions == null) return;
    final text = await ComposeSheet.show(
      context,
      title: 'New ticket for ${item.displayName}',
      hint: 'What is wrong with this asset?',
      submitLabel: 'Create',
      rich: true,
    );
    if (text == null || text.trim().isEmpty) return;

    final localId = await actions.createTicket(
      name: htmlToPlainText(text).split('\n').first,
      content: text.trim(),
      type: 1,
      urgency: 3,
      impact: 3,
      assignToMe: true,
    );
    // 0 is the sentinel: the drainer resolves the real ticket id once the
    // create op lands, so this works offline too.
    await actions.linkAssetToItil(
      ownerLocalId: localId,
      ownerServerId: 0,
      itemtype: 'Ticket',
      assetItemtype: item.itemtype,
      assetId: item.serverId,
    );
    if (!mounted) return;
    await context.push(Routes.ticket(localId));
  }
}

/// Purchase / warranty block. Read-only: these are finance's fields, but a
/// technician on site needs to know whether a repair is covered.
class _InfocomSection extends StatelessWidget {
  const _InfocomSection({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final infocom = item.infocom;
    if (infocom == null || infocom.isEmpty) return const SizedBox.shrink();

    final buy = parseGlpiDateTime(infocom['date_buy'] as String?);
    final warrantyStart = parseGlpiDateTime(
      (infocom['date_warranty'] ?? infocom['date_buy']) as String?,
    );
    final months = (infocom['warranty_duration'] as num?)?.toInt() ?? 0;
    // GLPI stores the duration in months; -1 is its "lifetime" sentinel.
    final warrantyEnd = (warrantyStart != null && months > 0)
        ? DateTime(
            warrantyStart.year,
            warrantyStart.month + months,
            warrantyStart.day,
          )
        : null;

    return _Expansion(
      icon: Icons.receipt_long_outlined,
      title: 'Purchase & warranty',
      trailing: warrantyEnd == null
          ? null
          : DueBadge(
              text: formatDueRelative(warrantyEnd),
              color: expiryColor(context, warrantyEnd),
            ),
      children: [
        if (buy != null)
          InfoTile(
            icon: Icons.shopping_cart_outlined,
            label: 'Purchased',
            value: formatDate(buy),
          ),
        if (warrantyEnd != null)
          InfoTile(
            icon: Icons.verified_user_outlined,
            label: 'Warranty',
            value: '${formatDate(warrantyEnd)} ($months months)',
          )
        else if (months == -1)
          const InfoTile(
            icon: Icons.verified_user_outlined,
            label: 'Warranty',
            value: 'Lifetime',
          ),
        for (final field in _financeFields)
          if (_text(infocom[field.key]) != null)
            InfoTile(
              icon: field.icon,
              label: field.label,
              value: _text(infocom[field.key])!,
            ),
      ],
    );
  }

  /// Finance rows rendered only when GLPI actually holds a value.
  static const _financeFields = <({String key, IconData icon, String label})>[
    (key: 'supplier', icon: Icons.local_shipping_outlined, label: 'Supplier'),
    (key: 'order_number', icon: Icons.numbers, label: 'Order no.'),
    (key: 'invoice_number', icon: Icons.description_outlined, label: 'Invoice'),
    (key: 'value', icon: Icons.payments_outlined, label: 'Value'),
  ];

  static String? _text(Object? v) {
    if (v == null) return null;
    if (v is Map) {
      final n = v['completename'] ?? v['name'];
      return n is String && n.isNotEmpty ? n : null;
    }
    final s = '$v'.trim();
    return s.isEmpty || s == '0' || s == '0.0000' ? null : s;
  }
}

class _PortsSection extends ConsumerWidget {
  const _PortsSection({required this.itemtype, required this.serverId});

  final String itemtype;
  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ports = ref
        .watch(assetPortsProvider((itemtype: itemtype, serverId: serverId)))
        .value;
    if (ports == null || ports.isEmpty) return const SizedBox.shrink();

    return _Expansion(
      icon: Icons.settings_ethernet,
      title: 'Network ports (${ports.length})',
      children: [
        for (final p in ports)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(p.name.isEmpty ? 'Port ${p.id}' : p.name),
            subtitle: Text(
              [
                if (p.type.isNotEmpty) p.type,
                if (p.mac.isNotEmpty) p.mac,
                ...p.ips,
              ].join(' · '),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
      ],
    );
  }
}

class _SoftwareSection extends ConsumerWidget {
  const _SoftwareSection({required this.itemtype, required this.serverId});

  final String itemtype;
  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final software = ref
        .watch(assetSoftwareProvider((itemtype: itemtype, serverId: serverId)))
        .value;
    if (software == null || software.total == 0) return const SizedBox.shrink();

    return _Expansion(
      icon: Icons.apps_outlined,
      title: 'Software (${software.total})',
      children: [
        for (final s in software.items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(s.name),
            trailing: s.version.isEmpty
                ? null
                : Text(s.version, style: Theme.of(context).textTheme.bodySmall),
          ),
        if (software.items.length < software.total)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Showing ${software.items.length} of ${software.total}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}

/// Tickets, changes and problems logged against this asset.
class _ItilSection extends ConsumerWidget {
  const _ItilSection({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links =
        ref
            .watch(
              assetItilProvider((
                itemtype: item.itemtype,
                serverId: item.serverId,
              )),
            )
            .value ??
        const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: const SectionHeading('Tickets'),
        ),
        if (links.isEmpty)
          Text(
            'None linked',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          )
        else
          for (final l in links)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(switch (l.itemtype) {
                'Change' => Icons.published_with_changes,
                'Problem' => Icons.report_problem_outlined,
                _ => Icons.confirmation_number_outlined,
              }, size: 20),
              title: Text(l.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${l.itemtype} #${l.id} · '
                '${statusLabel(l.status, itemtype: l.itemtype)}',
              ),
              onTap: () => _open(context, ref, l.itemtype, l.id),
            ),
      ],
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    String itemtype,
    int serverId,
  ) async {
    final localId = await ref
        .read(ticketRepositoryProvider)
        ?.openByServerId(serverId, itemtype: itemtype);
    if (localId == null || !context.mounted) return;
    await context.push(Routes.ticket(localId));
  }
}

/// The file behind a standalone Document record: images preview inline, other
/// types are downloaded and their path offered (the app deliberately carries no
/// viewer for arbitrary mime types).
class _DocumentSection extends ConsumerWidget {
  const _DocumentSection({required this.item});

  final CatalogItem item;

  static const _imageExtensions = {
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.webp',
    '.bmp',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filename =
        (item.fields['filename'] ?? item.fields['filepath']) as String?;
    final mime = item.fields['mime'] as String?;
    final path = ref
        .watch(documentFileProvider((id: item.serverId, filename: filename)))
        .value;
    final isImage =
        (mime ?? '').startsWith('image/') ||
        _imageExtensions.contains(p.extension(filename ?? '').toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filename != null && filename.isNotEmpty)
          InfoTile(icon: Icons.attach_file, label: 'File', value: filename),
        if (mime != null && mime.isNotEmpty)
          InfoTile(
            icon: Icons.description_outlined,
            label: 'Type',
            value: mime,
          ),
        if (path == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (isImage)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                // Not every "image/*" decodes on device (TIFF, HEIC on old
                // Androids) — fall back to the file itself, not a dead end.
                errorBuilder: (context, _, _) => _downloadButton(context, path),
              ),
            ),
          )
        else
          _downloadButton(context, path),
      ],
    );
  }

  Widget _downloadButton(BuildContext context, String path) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: OutlinedButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: path));
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved — path copied')));
      },
      icon: const Icon(Icons.download_outlined),
      label: const Text('Download'),
    ),
  );
}

/// Term of a contract / licence: when it started, when it runs out, and how
/// much notice is needed to get out of it.
class _ValiditySection extends StatelessWidget {
  const _ValiditySection({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final f = item.fields;
    final begin = parseGlpiDateTime(
      (f['date_begin'] ?? f['begin_date']) as String?,
    );
    final end = parseGlpiDateTime(item.expiryDate);
    final months = (f['duration'] as num?)?.toInt() ?? 0;
    final notice = (f['notice_period'] ?? f['notice']) as num?;
    if (begin == null && end == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (begin != null)
          InfoTile(
            icon: Icons.play_arrow_outlined,
            label: 'Starts',
            value: formatDate(begin),
          ),
        if (end != null)
          InfoTile(
            icon: Icons.event_busy_outlined,
            label: 'Ends',
            value: months > 0
                ? '${formatDate(end)} ($months months)'
                : formatDate(end),
            trailing: DueBadge(
              text: formatDueRelative(end),
              color: expiryColor(context, end),
            ),
          ),
        if (notice != null && notice > 0)
          InfoTile(
            icon: Icons.notifications_active_outlined,
            label: 'Notice',
            value: '$notice days',
          ),
      ],
    );
  }
}

/// Phone / email / address rows for Suppliers and Contacts — tapping them
/// hands off to the dialer, mail client or maps app.
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if ((item.phone ?? '').isNotEmpty)
        _launchTile(
          context,
          Icons.phone_outlined,
          'Phone',
          item.phone!,
          Uri(scheme: 'tel', path: item.phone!),
        ),
      if ((item.mobile ?? '').isNotEmpty)
        _launchTile(
          context,
          Icons.smartphone,
          'Mobile',
          item.mobile!,
          Uri(scheme: 'tel', path: item.mobile!),
        ),
      if ((item.email ?? '').isNotEmpty)
        _launchTile(
          context,
          Icons.mail_outline,
          'Email',
          item.email!,
          Uri(scheme: 'mailto', path: item.email!),
        ),
      if ((item.website ?? '').isNotEmpty)
        _launchTile(
          context,
          Icons.language,
          'Website',
          item.website!,
          Uri.tryParse(
                item.website!.startsWith('http')
                    ? item.website!
                    : 'https://${item.website!}',
              ) ??
              Uri(),
        ),
      if ((item.address ?? '').isNotEmpty)
        _launchTile(
          context,
          Icons.map_outlined,
          'Address',
          item.address!,
          Uri(
            scheme: 'geo',
            path: '0,0',
            queryParameters: {'q': item.address!},
          ),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _launchTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Uri uri,
  ) => InfoTile(
    icon: icon,
    label: label,
    value: value,
    trailing: const Icon(Icons.open_in_new, size: 16),
    onTap: () async {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Nothing can open $value')));
      }
    },
  );
}

/// Everything the screen doesn't model explicitly, rendered label/value so a
/// custom asset definition's fields are still visible.
class _OtherFieldsSection extends StatelessWidget {
  const _OtherFieldsSection({required this.item});

  final CatalogItem item;

  /// Fields already shown above, plus GLPI plumbing no technician needs.
  static const _skip = {
    'id',
    'name',
    'comment',
    'serial',
    'otherserial',
    'status',
    'state',
    'location',
    'user',
    'group',
    'manufacturer',
    'model',
    'type',
    'entity',
    'is_deleted',
    'is_template',
    'is_dynamic',
    'is_recursive',
    'template_name',
    '_infocom',
    'links',
    'date_creation',
  };

  @override
  Widget build(BuildContext context) {
    final entries = <MapEntry<String, String>>[];
    for (final e in item.fields.entries) {
      if (_skip.contains(e.key) || e.key.startsWith('_')) continue;
      final text = _render(e.value);
      if (text == null) continue;
      entries.add(MapEntry(_humanize(e.key), text));
    }
    if (entries.isEmpty) return const SizedBox.shrink();

    return _Expansion(
      icon: Icons.more_horiz,
      title: 'Other fields (${entries.length})',
      children: [
        for (final e in entries)
          InfoTile(icon: Icons.chevron_right, label: e.key, value: e.value),
      ],
    );
  }

  static String? _render(Object? v) {
    if (v == null) return null;
    if (v is bool) return v ? 'Yes' : null;
    if (v is Map) {
      final n = v['completename'] ?? v['name'];
      return n is String && n.isNotEmpty ? n : null;
    }
    if (v is List) return v.isEmpty ? null : '${v.length} item(s)';
    final s = '$v'.trim();
    return s.isEmpty || s == '0' ? null : s;
  }

  /// `date_mod` → `Date mod`; good enough for fields the app doesn't know.
  static String _humanize(String key) {
    final words = key.replaceAll('_', ' ').trim();
    return words.isEmpty ? key : words[0].toUpperCase() + words.substring(1);
  }
}

/// Collapsed-by-default block, so the detail opens on identity, not plumbing.
class _Expansion extends StatelessWidget {
  const _Expansion({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Theme(
    // Hide the ExpansionTile's own dividers: the screen has its own rhythm.
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      trailing: trailing,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}
