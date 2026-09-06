/// DTOs for the glpi-entitle plugin (`GET /GlpiEntitle/entitlement/{id}`).
///
/// The route returns `Entitlement::forEntity()`'s envelope verbatim:
/// `{state: fresh|stale|silent, payload, age, error}`. `silent` means "say
/// nothing" (entity not enabled, or nothing usable cached); `stale` means
/// "show it, but state the age honestly". The payload is ERPNext's
/// entitlement answer — contracts with block-hour balances, the labor
/// routing, lapsed contracts, and the uncontracted-work policy — read with
/// the same tolerance as the plugin's own Policy.php: a v1 payload without
/// the newer blocks reads as "feature unavailable", never a guessed default.
library;

double _doubleOf(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

/// The `{state, payload, age, error}` envelope.
class EntitlementDto {
  const EntitlementDto({
    required this.state,
    required this.ageSeconds,
    required this.error,
    required this.payload,
  });

  static const fresh = 'fresh';
  static const stale = 'stale';
  static const silent = 'silent';

  final String state;

  /// How old the payload is, in seconds (0 when fresh).
  final int ageSeconds;
  final String? error;
  final EntitlementPayloadDto? payload;

  bool get isSilent => state == silent || payload == null;
  bool get isStale => state == stale;

  factory EntitlementDto.fromJson(Object? json) {
    if (json is! Map) {
      return const EntitlementDto(
        state: silent,
        ageSeconds: 0,
        error: null,
        payload: null,
      );
    }
    final payload = json['payload'];
    return EntitlementDto(
      state: '${json['state'] ?? silent}',
      ageSeconds: (json['age'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
      payload: payload is Map<String, Object?>
          ? EntitlementPayloadDto.fromJson(payload)
          : null,
    );
  }
}

/// ERPNext's entitlement payload for one entity.
class EntitlementPayloadDto {
  const EntitlementPayloadDto({
    required this.contracts,
    required this.hasLaborCoverage,
    required this.labor,
    required this.lapsed,
    required this.uncontracted,
  });

  final List<EntitleContractDto> contracts;

  /// Whether any active contract covers ticket labor. When false, the
  /// uncontracted policy (if the payload carries one) applies.
  final bool hasLaborCoverage;

  /// The one-line labor answer — null on a v1 payload or a client with no
  /// labor-bearing contract.
  final EntitleLaborDto? labor;

  /// Contracts that ended while still flagged active.
  final List<EntitleLapsedDto> lapsed;

  /// The uncontracted-work policy block — null when the endpoint predates it.
  final EntitleUncontractedDto? uncontracted;

  factory EntitlementPayloadDto.fromJson(Map<String, Object?> json) {
    final contracts = json['contracts'];
    final lapsed = json['lapsed'];
    final labor = json['labor'];
    final unc = json['uncontracted'];
    return EntitlementPayloadDto(
      contracts: contracts is List
          ? contracts
                .whereType<Map<String, Object?>>()
                .map(EntitleContractDto.fromJson)
                .toList()
          : const [],
      hasLaborCoverage:
          json['has_labor_coverage'] == true || json['has_labor_coverage'] == 1,
      labor: labor is Map<String, Object?>
          ? EntitleLaborDto.fromJson(labor)
          : null,
      lapsed: lapsed is List
          ? lapsed
                .whereType<Map<String, Object?>>()
                .map(EntitleLapsedDto.fromJson)
                .toList()
          : const [],
      uncontracted: unc is Map<String, Object?>
          ? EntitleUncontractedDto.fromJson(unc)
          : null,
    );
  }
}

/// One contract row: name, billing model, whether it bills this ticket's
/// labor, and (for Block Hours) the consumption gauge.
class EntitleContractDto {
  const EntitleContractDto({
    required this.name,
    required this.billingModel,
    required this.isLaborContract,
    required this.endingSoon,
    required this.startDate,
    required this.endDate,
    required this.block,
  });

  final String name;
  final String billingModel;

  /// Marks the contract that actually bills ticket time — the question the
  /// card exists to answer for a client with several contracts.
  final bool isLaborContract;
  final bool endingSoon;
  final String? startDate;
  final String? endDate;
  final EntitleBlockDto? block;

  factory EntitleContractDto.fromJson(Map<String, Object?> json) {
    final block = json['block'];
    return EntitleContractDto(
      name: '${json['contract'] ?? ''}',
      billingModel: '${json['billing_model'] ?? ''}',
      isLaborContract:
          json['is_labor_contract'] == true || json['is_labor_contract'] == 1,
      endingSoon: json['ending_soon'] == true || json['ending_soon'] == 1,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      block: block is Map<String, Object?>
          ? EntitleBlockDto.fromJson(block)
          : null,
    );
  }
}

/// Block-hours consumption: hours used against the period's pool.
class EntitleBlockDto {
  const EntitleBlockDto({required this.consumedHours, required this.poolHours});

  final double consumedHours;
  final double poolHours;

  /// 0..1 for the gauge, defensively clamped.
  double get fraction =>
      poolHours <= 0 ? 1 : (consumedHours / poolHours).clamp(0.0, 1.0);

  factory EntitleBlockDto.fromJson(Map<String, Object?> json) =>
      EntitleBlockDto(
        consumedHours: _doubleOf(json['consumed_hours']),
        poolHours: _doubleOf(json['pool_hours']),
      );
}

/// Which contract bills ticket time, and how.
class EntitleLaborDto {
  const EntitleLaborDto({
    required this.contract,
    required this.model,
    required this.kind,
    required this.afterHoursBillable,
    required this.block,
  });

  final String contract;
  final String model;

  /// `covered` | `block` | `hourly`.
  final String kind;
  final bool afterHoursBillable;
  final EntitleBlockDto? block;

  factory EntitleLaborDto.fromJson(Map<String, Object?> json) {
    final block = json['block'];
    return EntitleLaborDto(
      contract: '${json['contract'] ?? ''}',
      model: '${json['model'] ?? ''}',
      kind: '${json['kind'] ?? 'covered'}',
      afterHoursBillable:
          json['after_hours_billable'] == true ||
          json['after_hours_billable'] == 1,
      block: block is Map<String, Object?>
          ? EntitleBlockDto.fromJson(block)
          : null,
    );
  }
}

/// A contract that ended while still flagged active.
class EntitleLapsedDto {
  const EntitleLapsedDto({
    required this.contract,
    required this.model,
    required this.ended,
  });

  final String contract;
  final String model;
  final String ended;

  factory EntitleLapsedDto.fromJson(Map<String, Object?> json) =>
      EntitleLapsedDto(
        contract: '${json['contract'] ?? ''}',
        model: '${json['model'] ?? ''}',
        ended: '${json['ended'] ?? ''}',
      );
}

/// The client's uncontracted-work policy. The policy strings are ERPNext's,
/// verbatim — data, not an enum, so an unrecognised value behaves like the
/// least restrictive one.
class EntitleUncontractedDto {
  const EntitleUncontractedDto({
    required this.policy,
    required this.rate,
    required this.currency,
  });

  static const block = 'Block Responses';
  static const approval = 'Require Customer Approval';
  static const bill = 'Bill at Uncontracted Rate';

  final String policy;
  final double rate;
  final String currency;

  factory EntitleUncontractedDto.fromJson(Map<String, Object?> json) {
    final policy = '${json['policy'] ?? ''}'.trim();
    return EntitleUncontractedDto(
      policy: policy.isNotEmpty ? policy : bill,
      rate: _doubleOf(json['rate']),
      currency: '${json['currency'] ?? ''}',
    );
  }
}
