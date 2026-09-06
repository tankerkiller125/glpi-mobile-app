import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dto/entitle_dto.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatting.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../entitle_providers.dart';

/// The contract/entitlement card on a ticket, keyed by the ticket's entity:
/// which contract bills this work, the block-hours gauge, lapsed-contract and
/// uncontracted-policy warnings, and an honest age note when the data is
/// stale. `silent` — entity not enabled, or nothing usable cached — renders
/// nothing at all, exactly like the web card; so does a missing capability or
/// an unsynced ticket. The conditional-section pattern from [AnalysisSection].
class EntitlementCard extends ConsumerWidget {
  const EntitlementCard({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.itemtype != itilTicket) return const SizedBox.shrink();
    final entityId = item.entityId;
    if (entityId == null) return const SizedBox.shrink();
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    if (!caps.has(Cap.entitle, Cap.entitleEntitlement)) {
      return const SizedBox.shrink();
    }

    final ent = ref.watch(entitlementProvider(entityId)).value;
    if (ent == null || ent.isSilent) return const SizedBox.shrink();
    final payload = ent.payload!;

    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  l.entitleTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Lapsed cover leads: "your contract ran out" is the part a
            // reader who stops here still needs to have seen.
            for (final lapsed in payload.lapsed)
              _Hint(
                danger: true,
                icon: Icons.warning_amber_outlined,
                text: l.entitleLapsed(
                  lapsed.contract,
                  lapsed.model,
                  lapsed.ended,
                ),
              ),
            if (payload.contracts.isEmpty)
              _Hint(
                danger: true,
                icon: Icons.file_copy_outlined,
                text: l.entitleNoContract,
              )
            else ...[
              for (final contract in payload.contracts)
                _ContractRow(contract: contract),
              if (!payload.hasLaborCoverage)
                _Hint(
                  danger: false,
                  icon: Icons.timer_off_outlined,
                  text: l.entitleNoLabor,
                ),
            ],
            ..._uncontractedHint(l, payload),
            if (ent.isStale)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l.entitleStale(_age(ent.ageSeconds)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// What the client's uncontracted-work policy means for the reader —
  /// rendered only when there is actually no coverage; a covered client's
  /// policy is a hypothetical the card has no room for.
  List<Widget> _uncontractedHint(
    AppLocalizations l,
    EntitlementPayloadDto payload,
  ) {
    if (payload.hasLaborCoverage) return const [];
    final unc = payload.uncontracted;
    if (unc == null) return const [];
    return [
      switch (unc.policy) {
        EntitleUncontractedDto.block => _Hint(
          danger: true,
          icon: Icons.front_hand_outlined,
          text: l.entitleBlocked,
        ),
        EntitleUncontractedDto.approval => _Hint(
          danger: false,
          icon: Icons.how_to_reg_outlined,
          text: l.entitleApprovalNeeded,
        ),
        _ when unc.rate > 0 => _Hint(
          danger: false,
          icon: Icons.payments_outlined,
          text: l.entitleUncontractedBillable,
        ),
        _ => _Hint(
          danger: true,
          icon: Icons.money_off_outlined,
          text: l.entitleNoRate,
        ),
      },
    ];
  }

  String _age(int seconds) =>
      relativeAge(DateTime.now().subtract(Duration(seconds: seconds)));
}

class _ContractRow extends StatelessWidget {
  const _ContractRow({required this.contract});

  final EntitleContractDto contract;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                contract.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (contract.billingModel.isNotEmpty)
                _Badge(label: contract.billingModel),
              // Which contract actually bills this ticket's time is the
              // question the card exists to answer.
              if (contract.isLaborContract)
                _Badge(label: l.entitleBillsTicket, emphasized: true),
              if (contract.endingSoon && contract.endDate != null)
                _Badge(label: l.entitleEndsSoon(contract.endDate!)),
            ],
          ),
          if (contract.block != null)
            _BlockGauge(block: contract.block!, scheme: scheme),
        ],
      ),
    );
  }
}

class _BlockGauge extends StatelessWidget {
  const _BlockGauge({required this.block, required this.scheme});

  final EntitleBlockDto block;
  final ColorScheme scheme;

  static String _hours(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fraction = block.fraction;
    final label = l.entitleBlockHours(
      _hours(block.consumedHours),
      _hours(block.poolHours),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Semantics(
            label: label,
            excludeSemantics: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerHighest,
                // Color states the meaning too, but never alone: the label
                // above always carries the numbers.
                color: fraction >= 0.8 ? scheme.error : scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: emphasized
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: emphasized ? scheme.onPrimaryContainer : scheme.onSurface,
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.danger, required this.icon, required this.text});

  final bool danger;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = danger
        ? scheme.errorContainer
        : scheme.tertiaryContainer;
    final ink = danger ? scheme.onErrorContainer : scheme.onTertiaryContainer;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: ink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: ink),
            ),
          ),
        ],
      ),
    );
  }
}
