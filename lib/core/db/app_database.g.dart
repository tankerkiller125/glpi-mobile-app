// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TicketsTable extends Tickets with TableInfo<$TicketsTable, Ticket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemtypeMeta = const VerificationMeta(
    'itemtype',
  );
  @override
  late final GeneratedColumn<String> itemtype = GeneratedColumn<String>(
    'itemtype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Ticket'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _urgencyMeta = const VerificationMeta(
    'urgency',
  );
  @override
  late final GeneratedColumn<int> urgency = GeneratedColumn<int>(
    'urgency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<int> impact = GeneratedColumn<int>(
    'impact',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityLabelMeta = const VerificationMeta(
    'entityLabel',
  );
  @override
  late final GeneratedColumn<String> entityLabel = GeneratedColumn<String>(
    'entity_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestTypeNameMeta = const VerificationMeta(
    'requestTypeName',
  );
  @override
  late final GeneratedColumn<String> requestTypeName = GeneratedColumn<String>(
    'request_type_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<int> locationId = GeneratedColumn<int>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipientNameMeta = const VerificationMeta(
    'recipientName',
  );
  @override
  late final GeneratedColumn<String> recipientName = GeneratedColumn<String>(
    'recipient_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCreationMeta = const VerificationMeta(
    'dateCreation',
  );
  @override
  late final GeneratedColumn<String> dateCreation = GeneratedColumn<String>(
    'date_creation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateModMeta = const VerificationMeta(
    'dateMod',
  );
  @override
  late final GeneratedColumn<String> dateMod = GeneratedColumn<String>(
    'date_mod',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeToResolveMeta = const VerificationMeta(
    'timeToResolve',
  );
  @override
  late final GeneratedColumn<String> timeToResolve = GeneratedColumn<String>(
    'time_to_resolve',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeToOwnMeta = const VerificationMeta(
    'timeToOwn',
  );
  @override
  late final GeneratedColumn<String> timeToOwn = GeneratedColumn<String>(
    'time_to_own',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    itemtype,
    name,
    content,
    status,
    priority,
    urgency,
    impact,
    type,
    categoryId,
    categoryName,
    entityId,
    entityLabel,
    requestTypeName,
    locationId,
    locationName,
    recipientName,
    dateCreation,
    dateMod,
    timeToResolve,
    timeToOwn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tickets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ticket> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('itemtype')) {
      context.handle(
        _itemtypeMeta,
        itemtype.isAcceptableOrUnknown(data['itemtype']!, _itemtypeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('urgency')) {
      context.handle(
        _urgencyMeta,
        urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta),
      );
    }
    if (data.containsKey('impact')) {
      context.handle(
        _impactMeta,
        impact.isAcceptableOrUnknown(data['impact']!, _impactMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('entity_label')) {
      context.handle(
        _entityLabelMeta,
        entityLabel.isAcceptableOrUnknown(
          data['entity_label']!,
          _entityLabelMeta,
        ),
      );
    }
    if (data.containsKey('request_type_name')) {
      context.handle(
        _requestTypeNameMeta,
        requestTypeName.isAcceptableOrUnknown(
          data['request_type_name']!,
          _requestTypeNameMeta,
        ),
      );
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('recipient_name')) {
      context.handle(
        _recipientNameMeta,
        recipientName.isAcceptableOrUnknown(
          data['recipient_name']!,
          _recipientNameMeta,
        ),
      );
    }
    if (data.containsKey('date_creation')) {
      context.handle(
        _dateCreationMeta,
        dateCreation.isAcceptableOrUnknown(
          data['date_creation']!,
          _dateCreationMeta,
        ),
      );
    }
    if (data.containsKey('date_mod')) {
      context.handle(
        _dateModMeta,
        dateMod.isAcceptableOrUnknown(data['date_mod']!, _dateModMeta),
      );
    }
    if (data.containsKey('time_to_resolve')) {
      context.handle(
        _timeToResolveMeta,
        timeToResolve.isAcceptableOrUnknown(
          data['time_to_resolve']!,
          _timeToResolveMeta,
        ),
      );
    }
    if (data.containsKey('time_to_own')) {
      context.handle(
        _timeToOwnMeta,
        timeToOwn.isAcceptableOrUnknown(data['time_to_own']!, _timeToOwnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Ticket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ticket(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      itemtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}itemtype'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      urgency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}urgency'],
      )!,
      impact: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}impact'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      entityLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_label'],
      ),
      requestTypeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_type_name'],
      ),
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location_id'],
      ),
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      ),
      recipientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient_name'],
      ),
      dateCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_creation'],
      ),
      dateMod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_mod'],
      ),
      timeToResolve: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_to_resolve'],
      ),
      timeToOwn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_to_own'],
      ),
    );
  }

  @override
  $TicketsTable createAlias(String alias) {
    return $TicketsTable(attachedDatabase, alias);
  }
}

class Ticket extends DataClass implements Insertable<Ticket> {
  final String localId;
  final int? serverId;

  /// Which GLPI ITIL object this row is: Ticket | Change | Problem.
  final String itemtype;
  final String name;
  final String content;
  final int status;
  final int priority;
  final int urgency;
  final int impact;
  final int type;
  final int? categoryId;
  final String? categoryName;
  final int? entityId;
  final String? entityLabel;
  final String? requestTypeName;
  final int? locationId;
  final String? locationName;
  final String? recipientName;

  /// Server clock, ISO-8601 UTC strings (never the device clock).
  final String? dateCreation;
  final String? dateMod;
  final String? timeToResolve;
  final String? timeToOwn;
  const Ticket({
    required this.localId,
    this.serverId,
    required this.itemtype,
    required this.name,
    required this.content,
    required this.status,
    required this.priority,
    required this.urgency,
    required this.impact,
    required this.type,
    this.categoryId,
    this.categoryName,
    this.entityId,
    this.entityLabel,
    this.requestTypeName,
    this.locationId,
    this.locationName,
    this.recipientName,
    this.dateCreation,
    this.dateMod,
    this.timeToResolve,
    this.timeToOwn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['itemtype'] = Variable<String>(itemtype);
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    map['status'] = Variable<int>(status);
    map['priority'] = Variable<int>(priority);
    map['urgency'] = Variable<int>(urgency);
    map['impact'] = Variable<int>(impact);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    if (!nullToAbsent || entityLabel != null) {
      map['entity_label'] = Variable<String>(entityLabel);
    }
    if (!nullToAbsent || requestTypeName != null) {
      map['request_type_name'] = Variable<String>(requestTypeName);
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<int>(locationId);
    }
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || recipientName != null) {
      map['recipient_name'] = Variable<String>(recipientName);
    }
    if (!nullToAbsent || dateCreation != null) {
      map['date_creation'] = Variable<String>(dateCreation);
    }
    if (!nullToAbsent || dateMod != null) {
      map['date_mod'] = Variable<String>(dateMod);
    }
    if (!nullToAbsent || timeToResolve != null) {
      map['time_to_resolve'] = Variable<String>(timeToResolve);
    }
    if (!nullToAbsent || timeToOwn != null) {
      map['time_to_own'] = Variable<String>(timeToOwn);
    }
    return map;
  }

  TicketsCompanion toCompanion(bool nullToAbsent) {
    return TicketsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      itemtype: Value(itemtype),
      name: Value(name),
      content: Value(content),
      status: Value(status),
      priority: Value(priority),
      urgency: Value(urgency),
      impact: Value(impact),
      type: Value(type),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      entityLabel: entityLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(entityLabel),
      requestTypeName: requestTypeName == null && nullToAbsent
          ? const Value.absent()
          : Value(requestTypeName),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      recipientName: recipientName == null && nullToAbsent
          ? const Value.absent()
          : Value(recipientName),
      dateCreation: dateCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreation),
      dateMod: dateMod == null && nullToAbsent
          ? const Value.absent()
          : Value(dateMod),
      timeToResolve: timeToResolve == null && nullToAbsent
          ? const Value.absent()
          : Value(timeToResolve),
      timeToOwn: timeToOwn == null && nullToAbsent
          ? const Value.absent()
          : Value(timeToOwn),
    );
  }

  factory Ticket.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ticket(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      itemtype: serializer.fromJson<String>(json['itemtype']),
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
      status: serializer.fromJson<int>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      urgency: serializer.fromJson<int>(json['urgency']),
      impact: serializer.fromJson<int>(json['impact']),
      type: serializer.fromJson<int>(json['type']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      entityLabel: serializer.fromJson<String?>(json['entityLabel']),
      requestTypeName: serializer.fromJson<String?>(json['requestTypeName']),
      locationId: serializer.fromJson<int?>(json['locationId']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      recipientName: serializer.fromJson<String?>(json['recipientName']),
      dateCreation: serializer.fromJson<String?>(json['dateCreation']),
      dateMod: serializer.fromJson<String?>(json['dateMod']),
      timeToResolve: serializer.fromJson<String?>(json['timeToResolve']),
      timeToOwn: serializer.fromJson<String?>(json['timeToOwn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'itemtype': serializer.toJson<String>(itemtype),
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
      'status': serializer.toJson<int>(status),
      'priority': serializer.toJson<int>(priority),
      'urgency': serializer.toJson<int>(urgency),
      'impact': serializer.toJson<int>(impact),
      'type': serializer.toJson<int>(type),
      'categoryId': serializer.toJson<int?>(categoryId),
      'categoryName': serializer.toJson<String?>(categoryName),
      'entityId': serializer.toJson<int?>(entityId),
      'entityLabel': serializer.toJson<String?>(entityLabel),
      'requestTypeName': serializer.toJson<String?>(requestTypeName),
      'locationId': serializer.toJson<int?>(locationId),
      'locationName': serializer.toJson<String?>(locationName),
      'recipientName': serializer.toJson<String?>(recipientName),
      'dateCreation': serializer.toJson<String?>(dateCreation),
      'dateMod': serializer.toJson<String?>(dateMod),
      'timeToResolve': serializer.toJson<String?>(timeToResolve),
      'timeToOwn': serializer.toJson<String?>(timeToOwn),
    };
  }

  Ticket copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    String? itemtype,
    String? name,
    String? content,
    int? status,
    int? priority,
    int? urgency,
    int? impact,
    int? type,
    Value<int?> categoryId = const Value.absent(),
    Value<String?> categoryName = const Value.absent(),
    Value<int?> entityId = const Value.absent(),
    Value<String?> entityLabel = const Value.absent(),
    Value<String?> requestTypeName = const Value.absent(),
    Value<int?> locationId = const Value.absent(),
    Value<String?> locationName = const Value.absent(),
    Value<String?> recipientName = const Value.absent(),
    Value<String?> dateCreation = const Value.absent(),
    Value<String?> dateMod = const Value.absent(),
    Value<String?> timeToResolve = const Value.absent(),
    Value<String?> timeToOwn = const Value.absent(),
  }) => Ticket(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    itemtype: itemtype ?? this.itemtype,
    name: name ?? this.name,
    content: content ?? this.content,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    urgency: urgency ?? this.urgency,
    impact: impact ?? this.impact,
    type: type ?? this.type,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
    entityId: entityId.present ? entityId.value : this.entityId,
    entityLabel: entityLabel.present ? entityLabel.value : this.entityLabel,
    requestTypeName: requestTypeName.present
        ? requestTypeName.value
        : this.requestTypeName,
    locationId: locationId.present ? locationId.value : this.locationId,
    locationName: locationName.present ? locationName.value : this.locationName,
    recipientName: recipientName.present
        ? recipientName.value
        : this.recipientName,
    dateCreation: dateCreation.present ? dateCreation.value : this.dateCreation,
    dateMod: dateMod.present ? dateMod.value : this.dateMod,
    timeToResolve: timeToResolve.present
        ? timeToResolve.value
        : this.timeToResolve,
    timeToOwn: timeToOwn.present ? timeToOwn.value : this.timeToOwn,
  );
  Ticket copyWithCompanion(TicketsCompanion data) {
    return Ticket(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      itemtype: data.itemtype.present ? data.itemtype.value : this.itemtype,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      impact: data.impact.present ? data.impact.value : this.impact,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityLabel: data.entityLabel.present
          ? data.entityLabel.value
          : this.entityLabel,
      requestTypeName: data.requestTypeName.present
          ? data.requestTypeName.value
          : this.requestTypeName,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      recipientName: data.recipientName.present
          ? data.recipientName.value
          : this.recipientName,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
      dateMod: data.dateMod.present ? data.dateMod.value : this.dateMod,
      timeToResolve: data.timeToResolve.present
          ? data.timeToResolve.value
          : this.timeToResolve,
      timeToOwn: data.timeToOwn.present ? data.timeToOwn.value : this.timeToOwn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ticket(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('itemtype: $itemtype, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('urgency: $urgency, ')
          ..write('impact: $impact, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('entityId: $entityId, ')
          ..write('entityLabel: $entityLabel, ')
          ..write('requestTypeName: $requestTypeName, ')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('recipientName: $recipientName, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('dateMod: $dateMod, ')
          ..write('timeToResolve: $timeToResolve, ')
          ..write('timeToOwn: $timeToOwn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    localId,
    serverId,
    itemtype,
    name,
    content,
    status,
    priority,
    urgency,
    impact,
    type,
    categoryId,
    categoryName,
    entityId,
    entityLabel,
    requestTypeName,
    locationId,
    locationName,
    recipientName,
    dateCreation,
    dateMod,
    timeToResolve,
    timeToOwn,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ticket &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.itemtype == this.itemtype &&
          other.name == this.name &&
          other.content == this.content &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.urgency == this.urgency &&
          other.impact == this.impact &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.entityId == this.entityId &&
          other.entityLabel == this.entityLabel &&
          other.requestTypeName == this.requestTypeName &&
          other.locationId == this.locationId &&
          other.locationName == this.locationName &&
          other.recipientName == this.recipientName &&
          other.dateCreation == this.dateCreation &&
          other.dateMod == this.dateMod &&
          other.timeToResolve == this.timeToResolve &&
          other.timeToOwn == this.timeToOwn);
}

class TicketsCompanion extends UpdateCompanion<Ticket> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<String> itemtype;
  final Value<String> name;
  final Value<String> content;
  final Value<int> status;
  final Value<int> priority;
  final Value<int> urgency;
  final Value<int> impact;
  final Value<int> type;
  final Value<int?> categoryId;
  final Value<String?> categoryName;
  final Value<int?> entityId;
  final Value<String?> entityLabel;
  final Value<String?> requestTypeName;
  final Value<int?> locationId;
  final Value<String?> locationName;
  final Value<String?> recipientName;
  final Value<String?> dateCreation;
  final Value<String?> dateMod;
  final Value<String?> timeToResolve;
  final Value<String?> timeToOwn;
  final Value<int> rowid;
  const TicketsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.itemtype = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.urgency = const Value.absent(),
    this.impact = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityLabel = const Value.absent(),
    this.requestTypeName = const Value.absent(),
    this.locationId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.recipientName = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.dateMod = const Value.absent(),
    this.timeToResolve = const Value.absent(),
    this.timeToOwn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TicketsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    this.itemtype = const Value.absent(),
    required String name,
    this.content = const Value.absent(),
    required int status,
    this.priority = const Value.absent(),
    this.urgency = const Value.absent(),
    this.impact = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityLabel = const Value.absent(),
    this.requestTypeName = const Value.absent(),
    this.locationId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.recipientName = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.dateMod = const Value.absent(),
    this.timeToResolve = const Value.absent(),
    this.timeToOwn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       name = Value(name),
       status = Value(status);
  static Insertable<Ticket> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<String>? itemtype,
    Expression<String>? name,
    Expression<String>? content,
    Expression<int>? status,
    Expression<int>? priority,
    Expression<int>? urgency,
    Expression<int>? impact,
    Expression<int>? type,
    Expression<int>? categoryId,
    Expression<String>? categoryName,
    Expression<int>? entityId,
    Expression<String>? entityLabel,
    Expression<String>? requestTypeName,
    Expression<int>? locationId,
    Expression<String>? locationName,
    Expression<String>? recipientName,
    Expression<String>? dateCreation,
    Expression<String>? dateMod,
    Expression<String>? timeToResolve,
    Expression<String>? timeToOwn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (itemtype != null) 'itemtype': itemtype,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (urgency != null) 'urgency': urgency,
      if (impact != null) 'impact': impact,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (entityId != null) 'entity_id': entityId,
      if (entityLabel != null) 'entity_label': entityLabel,
      if (requestTypeName != null) 'request_type_name': requestTypeName,
      if (locationId != null) 'location_id': locationId,
      if (locationName != null) 'location_name': locationName,
      if (recipientName != null) 'recipient_name': recipientName,
      if (dateCreation != null) 'date_creation': dateCreation,
      if (dateMod != null) 'date_mod': dateMod,
      if (timeToResolve != null) 'time_to_resolve': timeToResolve,
      if (timeToOwn != null) 'time_to_own': timeToOwn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TicketsCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<String>? itemtype,
    Value<String>? name,
    Value<String>? content,
    Value<int>? status,
    Value<int>? priority,
    Value<int>? urgency,
    Value<int>? impact,
    Value<int>? type,
    Value<int?>? categoryId,
    Value<String?>? categoryName,
    Value<int?>? entityId,
    Value<String?>? entityLabel,
    Value<String?>? requestTypeName,
    Value<int?>? locationId,
    Value<String?>? locationName,
    Value<String?>? recipientName,
    Value<String?>? dateCreation,
    Value<String?>? dateMod,
    Value<String?>? timeToResolve,
    Value<String?>? timeToOwn,
    Value<int>? rowid,
  }) {
    return TicketsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      itemtype: itemtype ?? this.itemtype,
      name: name ?? this.name,
      content: content ?? this.content,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      urgency: urgency ?? this.urgency,
      impact: impact ?? this.impact,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      entityId: entityId ?? this.entityId,
      entityLabel: entityLabel ?? this.entityLabel,
      requestTypeName: requestTypeName ?? this.requestTypeName,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      recipientName: recipientName ?? this.recipientName,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMod: dateMod ?? this.dateMod,
      timeToResolve: timeToResolve ?? this.timeToResolve,
      timeToOwn: timeToOwn ?? this.timeToOwn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (itemtype.present) {
      map['itemtype'] = Variable<String>(itemtype.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<int>(urgency.value);
    }
    if (impact.present) {
      map['impact'] = Variable<int>(impact.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (entityLabel.present) {
      map['entity_label'] = Variable<String>(entityLabel.value);
    }
    if (requestTypeName.present) {
      map['request_type_name'] = Variable<String>(requestTypeName.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<int>(locationId.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (recipientName.present) {
      map['recipient_name'] = Variable<String>(recipientName.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<String>(dateCreation.value);
    }
    if (dateMod.present) {
      map['date_mod'] = Variable<String>(dateMod.value);
    }
    if (timeToResolve.present) {
      map['time_to_resolve'] = Variable<String>(timeToResolve.value);
    }
    if (timeToOwn.present) {
      map['time_to_own'] = Variable<String>(timeToOwn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('itemtype: $itemtype, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('urgency: $urgency, ')
          ..write('impact: $impact, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('entityId: $entityId, ')
          ..write('entityLabel: $entityLabel, ')
          ..write('requestTypeName: $requestTypeName, ')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('recipientName: $recipientName, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('dateMod: $dateMod, ')
          ..write('timeToResolve: $timeToResolve, ')
          ..write('timeToOwn: $timeToOwn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TicketTeamTable extends TicketTeam
    with TableInfo<$TicketTeamTable, TicketTeamData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketTeamTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketLocalIdMeta = const VerificationMeta(
    'ticketLocalId',
  );
  @override
  late final GeneratedColumn<String> ticketLocalId = GeneratedColumn<String>(
    'ticket_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tickets (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberTypeMeta = const VerificationMeta(
    'memberType',
  );
  @override
  late final GeneratedColumn<String> memberType = GeneratedColumn<String>(
    'member_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<int> memberId = GeneratedColumn<int>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    ticketLocalId,
    role,
    memberType,
    memberId,
    displayName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_team';
  @override
  VerificationContext validateIntegrity(
    Insertable<TicketTeamData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('ticket_local_id')) {
      context.handle(
        _ticketLocalIdMeta,
        ticketLocalId.isAcceptableOrUnknown(
          data['ticket_local_id']!,
          _ticketLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ticketLocalIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('member_type')) {
      context.handle(
        _memberTypeMeta,
        memberType.isAcceptableOrUnknown(data['member_type']!, _memberTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_memberTypeMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  TicketTeamData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketTeamData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      ticketLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_local_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      memberType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_type'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}member_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
    );
  }

  @override
  $TicketTeamTable createAlias(String alias) {
    return $TicketTeamTable(attachedDatabase, alias);
  }
}

class TicketTeamData extends DataClass implements Insertable<TicketTeamData> {
  final String localId;
  final String ticketLocalId;
  final String role;
  final String memberType;
  final int memberId;
  final String displayName;
  const TicketTeamData({
    required this.localId,
    required this.ticketLocalId,
    required this.role,
    required this.memberType,
    required this.memberId,
    required this.displayName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['ticket_local_id'] = Variable<String>(ticketLocalId);
    map['role'] = Variable<String>(role);
    map['member_type'] = Variable<String>(memberType);
    map['member_id'] = Variable<int>(memberId);
    map['display_name'] = Variable<String>(displayName);
    return map;
  }

  TicketTeamCompanion toCompanion(bool nullToAbsent) {
    return TicketTeamCompanion(
      localId: Value(localId),
      ticketLocalId: Value(ticketLocalId),
      role: Value(role),
      memberType: Value(memberType),
      memberId: Value(memberId),
      displayName: Value(displayName),
    );
  }

  factory TicketTeamData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketTeamData(
      localId: serializer.fromJson<String>(json['localId']),
      ticketLocalId: serializer.fromJson<String>(json['ticketLocalId']),
      role: serializer.fromJson<String>(json['role']),
      memberType: serializer.fromJson<String>(json['memberType']),
      memberId: serializer.fromJson<int>(json['memberId']),
      displayName: serializer.fromJson<String>(json['displayName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'ticketLocalId': serializer.toJson<String>(ticketLocalId),
      'role': serializer.toJson<String>(role),
      'memberType': serializer.toJson<String>(memberType),
      'memberId': serializer.toJson<int>(memberId),
      'displayName': serializer.toJson<String>(displayName),
    };
  }

  TicketTeamData copyWith({
    String? localId,
    String? ticketLocalId,
    String? role,
    String? memberType,
    int? memberId,
    String? displayName,
  }) => TicketTeamData(
    localId: localId ?? this.localId,
    ticketLocalId: ticketLocalId ?? this.ticketLocalId,
    role: role ?? this.role,
    memberType: memberType ?? this.memberType,
    memberId: memberId ?? this.memberId,
    displayName: displayName ?? this.displayName,
  );
  TicketTeamData copyWithCompanion(TicketTeamCompanion data) {
    return TicketTeamData(
      localId: data.localId.present ? data.localId.value : this.localId,
      ticketLocalId: data.ticketLocalId.present
          ? data.ticketLocalId.value
          : this.ticketLocalId,
      role: data.role.present ? data.role.value : this.role,
      memberType: data.memberType.present
          ? data.memberType.value
          : this.memberType,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketTeamData(')
          ..write('localId: $localId, ')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('role: $role, ')
          ..write('memberType: $memberType, ')
          ..write('memberId: $memberId, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    ticketLocalId,
    role,
    memberType,
    memberId,
    displayName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketTeamData &&
          other.localId == this.localId &&
          other.ticketLocalId == this.ticketLocalId &&
          other.role == this.role &&
          other.memberType == this.memberType &&
          other.memberId == this.memberId &&
          other.displayName == this.displayName);
}

class TicketTeamCompanion extends UpdateCompanion<TicketTeamData> {
  final Value<String> localId;
  final Value<String> ticketLocalId;
  final Value<String> role;
  final Value<String> memberType;
  final Value<int> memberId;
  final Value<String> displayName;
  final Value<int> rowid;
  const TicketTeamCompanion({
    this.localId = const Value.absent(),
    this.ticketLocalId = const Value.absent(),
    this.role = const Value.absent(),
    this.memberType = const Value.absent(),
    this.memberId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TicketTeamCompanion.insert({
    required String localId,
    required String ticketLocalId,
    required String role,
    required String memberType,
    required int memberId,
    this.displayName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       ticketLocalId = Value(ticketLocalId),
       role = Value(role),
       memberType = Value(memberType),
       memberId = Value(memberId);
  static Insertable<TicketTeamData> custom({
    Expression<String>? localId,
    Expression<String>? ticketLocalId,
    Expression<String>? role,
    Expression<String>? memberType,
    Expression<int>? memberId,
    Expression<String>? displayName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (ticketLocalId != null) 'ticket_local_id': ticketLocalId,
      if (role != null) 'role': role,
      if (memberType != null) 'member_type': memberType,
      if (memberId != null) 'member_id': memberId,
      if (displayName != null) 'display_name': displayName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TicketTeamCompanion copyWith({
    Value<String>? localId,
    Value<String>? ticketLocalId,
    Value<String>? role,
    Value<String>? memberType,
    Value<int>? memberId,
    Value<String>? displayName,
    Value<int>? rowid,
  }) {
    return TicketTeamCompanion(
      localId: localId ?? this.localId,
      ticketLocalId: ticketLocalId ?? this.ticketLocalId,
      role: role ?? this.role,
      memberType: memberType ?? this.memberType,
      memberId: memberId ?? this.memberId,
      displayName: displayName ?? this.displayName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (ticketLocalId.present) {
      map['ticket_local_id'] = Variable<String>(ticketLocalId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (memberType.present) {
      map['member_type'] = Variable<String>(memberType.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<int>(memberId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketTeamCompanion(')
          ..write('localId: $localId, ')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('role: $role, ')
          ..write('memberType: $memberType, ')
          ..write('memberId: $memberId, ')
          ..write('displayName: $displayName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineItemsTable extends TimelineItems
    with TableInfo<$TimelineItemsTable, TimelineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketLocalIdMeta = const VerificationMeta(
    'ticketLocalId',
  );
  @override
  late final GeneratedColumn<String> ticketLocalId = GeneratedColumn<String>(
    'ticket_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tickets (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPrivateMeta = const VerificationMeta(
    'isPrivate',
  );
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
    'is_private',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_private" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateCreationMeta = const VerificationMeta(
    'dateCreation',
  );
  @override
  late final GeneratedColumn<String> dateCreation = GeneratedColumn<String>(
    'date_creation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<int> authorId = GeneratedColumn<int>(
    'author_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskDurationMeta = const VerificationMeta(
    'taskDuration',
  );
  @override
  late final GeneratedColumn<int> taskDuration = GeneratedColumn<int>(
    'task_duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskStateMeta = const VerificationMeta(
    'taskState',
  );
  @override
  late final GeneratedColumn<int> taskState = GeneratedColumn<int>(
    'task_state',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _solutionStatusMeta = const VerificationMeta(
    'solutionStatus',
  );
  @override
  late final GeneratedColumn<int> solutionStatus = GeneratedColumn<int>(
    'solution_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validationStatusMeta = const VerificationMeta(
    'validationStatus',
  );
  @override
  late final GeneratedColumn<int> validationStatus = GeneratedColumn<int>(
    'validation_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approverIdMeta = const VerificationMeta(
    'approverId',
  );
  @override
  late final GeneratedColumn<int> approverId = GeneratedColumn<int>(
    'approver_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approverTypeMeta = const VerificationMeta(
    'approverType',
  );
  @override
  late final GeneratedColumn<String> approverType = GeneratedColumn<String>(
    'approver_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approvalCommentMeta = const VerificationMeta(
    'approvalComment',
  );
  @override
  late final GeneratedColumn<String> approvalComment = GeneratedColumn<String>(
    'approval_comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    ticketLocalId,
    serverId,
    itemType,
    content,
    isPrivate,
    dateCreation,
    authorId,
    authorName,
    taskDuration,
    taskState,
    solutionStatus,
    validationStatus,
    approverId,
    approverType,
    approvalComment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('ticket_local_id')) {
      context.handle(
        _ticketLocalIdMeta,
        ticketLocalId.isAcceptableOrUnknown(
          data['ticket_local_id']!,
          _ticketLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ticketLocalIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('is_private')) {
      context.handle(
        _isPrivateMeta,
        isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta),
      );
    }
    if (data.containsKey('date_creation')) {
      context.handle(
        _dateCreationMeta,
        dateCreation.isAcceptableOrUnknown(
          data['date_creation']!,
          _dateCreationMeta,
        ),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('task_duration')) {
      context.handle(
        _taskDurationMeta,
        taskDuration.isAcceptableOrUnknown(
          data['task_duration']!,
          _taskDurationMeta,
        ),
      );
    }
    if (data.containsKey('task_state')) {
      context.handle(
        _taskStateMeta,
        taskState.isAcceptableOrUnknown(data['task_state']!, _taskStateMeta),
      );
    }
    if (data.containsKey('solution_status')) {
      context.handle(
        _solutionStatusMeta,
        solutionStatus.isAcceptableOrUnknown(
          data['solution_status']!,
          _solutionStatusMeta,
        ),
      );
    }
    if (data.containsKey('validation_status')) {
      context.handle(
        _validationStatusMeta,
        validationStatus.isAcceptableOrUnknown(
          data['validation_status']!,
          _validationStatusMeta,
        ),
      );
    }
    if (data.containsKey('approver_id')) {
      context.handle(
        _approverIdMeta,
        approverId.isAcceptableOrUnknown(data['approver_id']!, _approverIdMeta),
      );
    }
    if (data.containsKey('approver_type')) {
      context.handle(
        _approverTypeMeta,
        approverType.isAcceptableOrUnknown(
          data['approver_type']!,
          _approverTypeMeta,
        ),
      );
    }
    if (data.containsKey('approval_comment')) {
      context.handle(
        _approvalCommentMeta,
        approvalComment.isAcceptableOrUnknown(
          data['approval_comment']!,
          _approvalCommentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  TimelineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineItem(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      ticketLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      isPrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_private'],
      )!,
      dateCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_creation'],
      ),
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}author_id'],
      ),
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      ),
      taskDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_duration'],
      ),
      taskState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_state'],
      ),
      solutionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}solution_status'],
      ),
      validationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}validation_status'],
      ),
      approverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}approver_id'],
      ),
      approverType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approver_type'],
      ),
      approvalComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approval_comment'],
      ),
    );
  }

  @override
  $TimelineItemsTable createAlias(String alias) {
    return $TimelineItemsTable(attachedDatabase, alias);
  }
}

class TimelineItem extends DataClass implements Insertable<TimelineItem> {
  final String localId;
  final String ticketLocalId;
  final int? serverId;
  final String itemType;
  final String content;
  final bool isPrivate;
  final String? dateCreation;
  final int? authorId;
  final String? authorName;
  final int? taskDuration;
  final int? taskState;
  final int? solutionStatus;
  final int? validationStatus;
  final int? approverId;
  final String? approverType;
  final String? approvalComment;
  const TimelineItem({
    required this.localId,
    required this.ticketLocalId,
    this.serverId,
    required this.itemType,
    required this.content,
    required this.isPrivate,
    this.dateCreation,
    this.authorId,
    this.authorName,
    this.taskDuration,
    this.taskState,
    this.solutionStatus,
    this.validationStatus,
    this.approverId,
    this.approverType,
    this.approvalComment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['ticket_local_id'] = Variable<String>(ticketLocalId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['item_type'] = Variable<String>(itemType);
    map['content'] = Variable<String>(content);
    map['is_private'] = Variable<bool>(isPrivate);
    if (!nullToAbsent || dateCreation != null) {
      map['date_creation'] = Variable<String>(dateCreation);
    }
    if (!nullToAbsent || authorId != null) {
      map['author_id'] = Variable<int>(authorId);
    }
    if (!nullToAbsent || authorName != null) {
      map['author_name'] = Variable<String>(authorName);
    }
    if (!nullToAbsent || taskDuration != null) {
      map['task_duration'] = Variable<int>(taskDuration);
    }
    if (!nullToAbsent || taskState != null) {
      map['task_state'] = Variable<int>(taskState);
    }
    if (!nullToAbsent || solutionStatus != null) {
      map['solution_status'] = Variable<int>(solutionStatus);
    }
    if (!nullToAbsent || validationStatus != null) {
      map['validation_status'] = Variable<int>(validationStatus);
    }
    if (!nullToAbsent || approverId != null) {
      map['approver_id'] = Variable<int>(approverId);
    }
    if (!nullToAbsent || approverType != null) {
      map['approver_type'] = Variable<String>(approverType);
    }
    if (!nullToAbsent || approvalComment != null) {
      map['approval_comment'] = Variable<String>(approvalComment);
    }
    return map;
  }

  TimelineItemsCompanion toCompanion(bool nullToAbsent) {
    return TimelineItemsCompanion(
      localId: Value(localId),
      ticketLocalId: Value(ticketLocalId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      itemType: Value(itemType),
      content: Value(content),
      isPrivate: Value(isPrivate),
      dateCreation: dateCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreation),
      authorId: authorId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorId),
      authorName: authorName == null && nullToAbsent
          ? const Value.absent()
          : Value(authorName),
      taskDuration: taskDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(taskDuration),
      taskState: taskState == null && nullToAbsent
          ? const Value.absent()
          : Value(taskState),
      solutionStatus: solutionStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(solutionStatus),
      validationStatus: validationStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(validationStatus),
      approverId: approverId == null && nullToAbsent
          ? const Value.absent()
          : Value(approverId),
      approverType: approverType == null && nullToAbsent
          ? const Value.absent()
          : Value(approverType),
      approvalComment: approvalComment == null && nullToAbsent
          ? const Value.absent()
          : Value(approvalComment),
    );
  }

  factory TimelineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineItem(
      localId: serializer.fromJson<String>(json['localId']),
      ticketLocalId: serializer.fromJson<String>(json['ticketLocalId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      content: serializer.fromJson<String>(json['content']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
      dateCreation: serializer.fromJson<String?>(json['dateCreation']),
      authorId: serializer.fromJson<int?>(json['authorId']),
      authorName: serializer.fromJson<String?>(json['authorName']),
      taskDuration: serializer.fromJson<int?>(json['taskDuration']),
      taskState: serializer.fromJson<int?>(json['taskState']),
      solutionStatus: serializer.fromJson<int?>(json['solutionStatus']),
      validationStatus: serializer.fromJson<int?>(json['validationStatus']),
      approverId: serializer.fromJson<int?>(json['approverId']),
      approverType: serializer.fromJson<String?>(json['approverType']),
      approvalComment: serializer.fromJson<String?>(json['approvalComment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'ticketLocalId': serializer.toJson<String>(ticketLocalId),
      'serverId': serializer.toJson<int?>(serverId),
      'itemType': serializer.toJson<String>(itemType),
      'content': serializer.toJson<String>(content),
      'isPrivate': serializer.toJson<bool>(isPrivate),
      'dateCreation': serializer.toJson<String?>(dateCreation),
      'authorId': serializer.toJson<int?>(authorId),
      'authorName': serializer.toJson<String?>(authorName),
      'taskDuration': serializer.toJson<int?>(taskDuration),
      'taskState': serializer.toJson<int?>(taskState),
      'solutionStatus': serializer.toJson<int?>(solutionStatus),
      'validationStatus': serializer.toJson<int?>(validationStatus),
      'approverId': serializer.toJson<int?>(approverId),
      'approverType': serializer.toJson<String?>(approverType),
      'approvalComment': serializer.toJson<String?>(approvalComment),
    };
  }

  TimelineItem copyWith({
    String? localId,
    String? ticketLocalId,
    Value<int?> serverId = const Value.absent(),
    String? itemType,
    String? content,
    bool? isPrivate,
    Value<String?> dateCreation = const Value.absent(),
    Value<int?> authorId = const Value.absent(),
    Value<String?> authorName = const Value.absent(),
    Value<int?> taskDuration = const Value.absent(),
    Value<int?> taskState = const Value.absent(),
    Value<int?> solutionStatus = const Value.absent(),
    Value<int?> validationStatus = const Value.absent(),
    Value<int?> approverId = const Value.absent(),
    Value<String?> approverType = const Value.absent(),
    Value<String?> approvalComment = const Value.absent(),
  }) => TimelineItem(
    localId: localId ?? this.localId,
    ticketLocalId: ticketLocalId ?? this.ticketLocalId,
    serverId: serverId.present ? serverId.value : this.serverId,
    itemType: itemType ?? this.itemType,
    content: content ?? this.content,
    isPrivate: isPrivate ?? this.isPrivate,
    dateCreation: dateCreation.present ? dateCreation.value : this.dateCreation,
    authorId: authorId.present ? authorId.value : this.authorId,
    authorName: authorName.present ? authorName.value : this.authorName,
    taskDuration: taskDuration.present ? taskDuration.value : this.taskDuration,
    taskState: taskState.present ? taskState.value : this.taskState,
    solutionStatus: solutionStatus.present
        ? solutionStatus.value
        : this.solutionStatus,
    validationStatus: validationStatus.present
        ? validationStatus.value
        : this.validationStatus,
    approverId: approverId.present ? approverId.value : this.approverId,
    approverType: approverType.present ? approverType.value : this.approverType,
    approvalComment: approvalComment.present
        ? approvalComment.value
        : this.approvalComment,
  );
  TimelineItem copyWithCompanion(TimelineItemsCompanion data) {
    return TimelineItem(
      localId: data.localId.present ? data.localId.value : this.localId,
      ticketLocalId: data.ticketLocalId.present
          ? data.ticketLocalId.value
          : this.ticketLocalId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      content: data.content.present ? data.content.value : this.content,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      taskDuration: data.taskDuration.present
          ? data.taskDuration.value
          : this.taskDuration,
      taskState: data.taskState.present ? data.taskState.value : this.taskState,
      solutionStatus: data.solutionStatus.present
          ? data.solutionStatus.value
          : this.solutionStatus,
      validationStatus: data.validationStatus.present
          ? data.validationStatus.value
          : this.validationStatus,
      approverId: data.approverId.present
          ? data.approverId.value
          : this.approverId,
      approverType: data.approverType.present
          ? data.approverType.value
          : this.approverType,
      approvalComment: data.approvalComment.present
          ? data.approvalComment.value
          : this.approvalComment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineItem(')
          ..write('localId: $localId, ')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('serverId: $serverId, ')
          ..write('itemType: $itemType, ')
          ..write('content: $content, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('authorId: $authorId, ')
          ..write('authorName: $authorName, ')
          ..write('taskDuration: $taskDuration, ')
          ..write('taskState: $taskState, ')
          ..write('solutionStatus: $solutionStatus, ')
          ..write('validationStatus: $validationStatus, ')
          ..write('approverId: $approverId, ')
          ..write('approverType: $approverType, ')
          ..write('approvalComment: $approvalComment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    ticketLocalId,
    serverId,
    itemType,
    content,
    isPrivate,
    dateCreation,
    authorId,
    authorName,
    taskDuration,
    taskState,
    solutionStatus,
    validationStatus,
    approverId,
    approverType,
    approvalComment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineItem &&
          other.localId == this.localId &&
          other.ticketLocalId == this.ticketLocalId &&
          other.serverId == this.serverId &&
          other.itemType == this.itemType &&
          other.content == this.content &&
          other.isPrivate == this.isPrivate &&
          other.dateCreation == this.dateCreation &&
          other.authorId == this.authorId &&
          other.authorName == this.authorName &&
          other.taskDuration == this.taskDuration &&
          other.taskState == this.taskState &&
          other.solutionStatus == this.solutionStatus &&
          other.validationStatus == this.validationStatus &&
          other.approverId == this.approverId &&
          other.approverType == this.approverType &&
          other.approvalComment == this.approvalComment);
}

class TimelineItemsCompanion extends UpdateCompanion<TimelineItem> {
  final Value<String> localId;
  final Value<String> ticketLocalId;
  final Value<int?> serverId;
  final Value<String> itemType;
  final Value<String> content;
  final Value<bool> isPrivate;
  final Value<String?> dateCreation;
  final Value<int?> authorId;
  final Value<String?> authorName;
  final Value<int?> taskDuration;
  final Value<int?> taskState;
  final Value<int?> solutionStatus;
  final Value<int?> validationStatus;
  final Value<int?> approverId;
  final Value<String?> approverType;
  final Value<String?> approvalComment;
  final Value<int> rowid;
  const TimelineItemsCompanion({
    this.localId = const Value.absent(),
    this.ticketLocalId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.content = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.authorId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.taskDuration = const Value.absent(),
    this.taskState = const Value.absent(),
    this.solutionStatus = const Value.absent(),
    this.validationStatus = const Value.absent(),
    this.approverId = const Value.absent(),
    this.approverType = const Value.absent(),
    this.approvalComment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineItemsCompanion.insert({
    required String localId,
    required String ticketLocalId,
    this.serverId = const Value.absent(),
    required String itemType,
    this.content = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.authorId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.taskDuration = const Value.absent(),
    this.taskState = const Value.absent(),
    this.solutionStatus = const Value.absent(),
    this.validationStatus = const Value.absent(),
    this.approverId = const Value.absent(),
    this.approverType = const Value.absent(),
    this.approvalComment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       ticketLocalId = Value(ticketLocalId),
       itemType = Value(itemType);
  static Insertable<TimelineItem> custom({
    Expression<String>? localId,
    Expression<String>? ticketLocalId,
    Expression<int>? serverId,
    Expression<String>? itemType,
    Expression<String>? content,
    Expression<bool>? isPrivate,
    Expression<String>? dateCreation,
    Expression<int>? authorId,
    Expression<String>? authorName,
    Expression<int>? taskDuration,
    Expression<int>? taskState,
    Expression<int>? solutionStatus,
    Expression<int>? validationStatus,
    Expression<int>? approverId,
    Expression<String>? approverType,
    Expression<String>? approvalComment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (ticketLocalId != null) 'ticket_local_id': ticketLocalId,
      if (serverId != null) 'server_id': serverId,
      if (itemType != null) 'item_type': itemType,
      if (content != null) 'content': content,
      if (isPrivate != null) 'is_private': isPrivate,
      if (dateCreation != null) 'date_creation': dateCreation,
      if (authorId != null) 'author_id': authorId,
      if (authorName != null) 'author_name': authorName,
      if (taskDuration != null) 'task_duration': taskDuration,
      if (taskState != null) 'task_state': taskState,
      if (solutionStatus != null) 'solution_status': solutionStatus,
      if (validationStatus != null) 'validation_status': validationStatus,
      if (approverId != null) 'approver_id': approverId,
      if (approverType != null) 'approver_type': approverType,
      if (approvalComment != null) 'approval_comment': approvalComment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineItemsCompanion copyWith({
    Value<String>? localId,
    Value<String>? ticketLocalId,
    Value<int?>? serverId,
    Value<String>? itemType,
    Value<String>? content,
    Value<bool>? isPrivate,
    Value<String?>? dateCreation,
    Value<int?>? authorId,
    Value<String?>? authorName,
    Value<int?>? taskDuration,
    Value<int?>? taskState,
    Value<int?>? solutionStatus,
    Value<int?>? validationStatus,
    Value<int?>? approverId,
    Value<String?>? approverType,
    Value<String?>? approvalComment,
    Value<int>? rowid,
  }) {
    return TimelineItemsCompanion(
      localId: localId ?? this.localId,
      ticketLocalId: ticketLocalId ?? this.ticketLocalId,
      serverId: serverId ?? this.serverId,
      itemType: itemType ?? this.itemType,
      content: content ?? this.content,
      isPrivate: isPrivate ?? this.isPrivate,
      dateCreation: dateCreation ?? this.dateCreation,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      taskDuration: taskDuration ?? this.taskDuration,
      taskState: taskState ?? this.taskState,
      solutionStatus: solutionStatus ?? this.solutionStatus,
      validationStatus: validationStatus ?? this.validationStatus,
      approverId: approverId ?? this.approverId,
      approverType: approverType ?? this.approverType,
      approvalComment: approvalComment ?? this.approvalComment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (ticketLocalId.present) {
      map['ticket_local_id'] = Variable<String>(ticketLocalId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<String>(dateCreation.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<int>(authorId.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (taskDuration.present) {
      map['task_duration'] = Variable<int>(taskDuration.value);
    }
    if (taskState.present) {
      map['task_state'] = Variable<int>(taskState.value);
    }
    if (solutionStatus.present) {
      map['solution_status'] = Variable<int>(solutionStatus.value);
    }
    if (validationStatus.present) {
      map['validation_status'] = Variable<int>(validationStatus.value);
    }
    if (approverId.present) {
      map['approver_id'] = Variable<int>(approverId.value);
    }
    if (approverType.present) {
      map['approver_type'] = Variable<String>(approverType.value);
    }
    if (approvalComment.present) {
      map['approval_comment'] = Variable<String>(approvalComment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineItemsCompanion(')
          ..write('localId: $localId, ')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('serverId: $serverId, ')
          ..write('itemType: $itemType, ')
          ..write('content: $content, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('authorId: $authorId, ')
          ..write('authorName: $authorName, ')
          ..write('taskDuration: $taskDuration, ')
          ..write('taskState: $taskState, ')
          ..write('solutionStatus: $solutionStatus, ')
          ..write('validationStatus: $validationStatus, ')
          ..write('approverId: $approverId, ')
          ..write('approverType: $approverType, ')
          ..write('approvalComment: $approvalComment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DropdownItemsTable extends DropdownItems
    with TableInfo<$DropdownItemsTable, DropdownItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DropdownItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [kind, serverId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dropdown_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DropdownItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, serverId};
  @override
  DropdownItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DropdownItem(
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $DropdownItemsTable createAlias(String alias) {
    return $DropdownItemsTable(attachedDatabase, alias);
  }
}

class DropdownItem extends DataClass implements Insertable<DropdownItem> {
  final String kind;
  final int serverId;
  final String name;
  const DropdownItem({
    required this.kind,
    required this.serverId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kind'] = Variable<String>(kind);
    map['server_id'] = Variable<int>(serverId);
    map['name'] = Variable<String>(name);
    return map;
  }

  DropdownItemsCompanion toCompanion(bool nullToAbsent) {
    return DropdownItemsCompanion(
      kind: Value(kind),
      serverId: Value(serverId),
      name: Value(name),
    );
  }

  factory DropdownItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DropdownItem(
      kind: serializer.fromJson<String>(json['kind']),
      serverId: serializer.fromJson<int>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kind': serializer.toJson<String>(kind),
      'serverId': serializer.toJson<int>(serverId),
      'name': serializer.toJson<String>(name),
    };
  }

  DropdownItem copyWith({String? kind, int? serverId, String? name}) =>
      DropdownItem(
        kind: kind ?? this.kind,
        serverId: serverId ?? this.serverId,
        name: name ?? this.name,
      );
  DropdownItem copyWithCompanion(DropdownItemsCompanion data) {
    return DropdownItem(
      kind: data.kind.present ? data.kind.value : this.kind,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DropdownItem(')
          ..write('kind: $kind, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(kind, serverId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DropdownItem &&
          other.kind == this.kind &&
          other.serverId == this.serverId &&
          other.name == this.name);
}

class DropdownItemsCompanion extends UpdateCompanion<DropdownItem> {
  final Value<String> kind;
  final Value<int> serverId;
  final Value<String> name;
  final Value<int> rowid;
  const DropdownItemsCompanion({
    this.kind = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DropdownItemsCompanion.insert({
    required String kind,
    required int serverId,
    required String name,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       serverId = Value(serverId),
       name = Value(name);
  static Insertable<DropdownItem> custom({
    Expression<String>? kind,
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DropdownItemsCompanion copyWith({
    Value<String>? kind,
    Value<int>? serverId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return DropdownItemsCompanion(
      kind: kind ?? this.kind,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DropdownItemsCompanion(')
          ..write('kind: $kind, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOpsTable extends PendingOps
    with TableInfo<$PendingOpsTable, PendingOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _opUuidMeta = const VerificationMeta('opUuid');
  @override
  late final GeneratedColumn<String> opUuid = GeneratedColumn<String>(
    'op_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemtypeMeta = const VerificationMeta(
    'itemtype',
  );
  @override
  late final GeneratedColumn<String> itemtype = GeneratedColumn<String>(
    'itemtype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Ticket'),
  );
  static const VerificationMeta _ticketLocalIdMeta = const VerificationMeta(
    'ticketLocalId',
  );
  @override
  late final GeneratedColumn<String> ticketLocalId = GeneratedColumn<String>(
    'ticket_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketServerIdMeta = const VerificationMeta(
    'ticketServerId',
  );
  @override
  late final GeneratedColumn<int> ticketServerId = GeneratedColumn<int>(
    'ticket_server_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetLocalIdMeta = const VerificationMeta(
    'targetLocalId',
  );
  @override
  late final GeneratedColumn<String> targetLocalId = GeneratedColumn<String>(
    'target_local_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetServerIdMeta = const VerificationMeta(
    'targetServerId',
  );
  @override
  late final GeneratedColumn<int> targetServerId = GeneratedColumn<int>(
    'target_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _baseSnapshotMeta = const VerificationMeta(
    'baseSnapshot',
  );
  @override
  late final GeneratedColumn<String> baseSnapshot = GeneratedColumn<String>(
    'base_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<String> nextRetryAt = GeneratedColumn<String>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityRecursiveMeta = const VerificationMeta(
    'entityRecursive',
  );
  @override
  late final GeneratedColumn<bool> entityRecursive = GeneratedColumn<bool>(
    'entity_recursive',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("entity_recursive" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opUuid,
    opType,
    itemtype,
    ticketLocalId,
    ticketServerId,
    targetLocalId,
    targetServerId,
    payload,
    baseSnapshot,
    status,
    attempts,
    nextRetryAt,
    lastError,
    createdAt,
    entityId,
    entityRecursive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('op_uuid')) {
      context.handle(
        _opUuidMeta,
        opUuid.isAcceptableOrUnknown(data['op_uuid']!, _opUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_opUuidMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('itemtype')) {
      context.handle(
        _itemtypeMeta,
        itemtype.isAcceptableOrUnknown(data['itemtype']!, _itemtypeMeta),
      );
    }
    if (data.containsKey('ticket_local_id')) {
      context.handle(
        _ticketLocalIdMeta,
        ticketLocalId.isAcceptableOrUnknown(
          data['ticket_local_id']!,
          _ticketLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ticketLocalIdMeta);
    }
    if (data.containsKey('ticket_server_id')) {
      context.handle(
        _ticketServerIdMeta,
        ticketServerId.isAcceptableOrUnknown(
          data['ticket_server_id']!,
          _ticketServerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ticketServerIdMeta);
    }
    if (data.containsKey('target_local_id')) {
      context.handle(
        _targetLocalIdMeta,
        targetLocalId.isAcceptableOrUnknown(
          data['target_local_id']!,
          _targetLocalIdMeta,
        ),
      );
    }
    if (data.containsKey('target_server_id')) {
      context.handle(
        _targetServerIdMeta,
        targetServerId.isAcceptableOrUnknown(
          data['target_server_id']!,
          _targetServerIdMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('base_snapshot')) {
      context.handle(
        _baseSnapshotMeta,
        baseSnapshot.isAcceptableOrUnknown(
          data['base_snapshot']!,
          _baseSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('entity_recursive')) {
      context.handle(
        _entityRecursiveMeta,
        entityRecursive.isAcceptableOrUnknown(
          data['entity_recursive']!,
          _entityRecursiveMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      opUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_uuid'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      itemtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}itemtype'],
      )!,
      ticketLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_local_id'],
      )!,
      ticketServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ticket_server_id'],
      )!,
      targetLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_local_id'],
      ),
      targetServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_server_id'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      baseSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_snapshot'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      entityRecursive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}entity_recursive'],
      ),
    );
  }

  @override
  $PendingOpsTable createAlias(String alias) {
    return $PendingOpsTable(attachedDatabase, alias);
  }
}

class PendingOp extends DataClass implements Insertable<PendingOp> {
  final int id;
  final String opUuid;
  final String opType;

  /// ITIL type of the target object (Ticket | Change | Problem).
  final String itemtype;
  final String ticketLocalId;
  final int ticketServerId;
  final String? targetLocalId;
  final int? targetServerId;
  final String payload;
  final String? baseSnapshot;
  final String status;
  final int attempts;
  final String? nextRetryAt;
  final String? lastError;
  final String createdAt;

  /// The GLPI entity context this op was composed in. A queued create files
  /// into whatever entity the request header names, so an op drained after the
  /// technician switched entities would land in the wrong one — it is pinned
  /// here instead of following the active context.
  final int? entityId;
  final bool? entityRecursive;
  const PendingOp({
    required this.id,
    required this.opUuid,
    required this.opType,
    required this.itemtype,
    required this.ticketLocalId,
    required this.ticketServerId,
    this.targetLocalId,
    this.targetServerId,
    required this.payload,
    this.baseSnapshot,
    required this.status,
    required this.attempts,
    this.nextRetryAt,
    this.lastError,
    required this.createdAt,
    this.entityId,
    this.entityRecursive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['op_uuid'] = Variable<String>(opUuid);
    map['op_type'] = Variable<String>(opType);
    map['itemtype'] = Variable<String>(itemtype);
    map['ticket_local_id'] = Variable<String>(ticketLocalId);
    map['ticket_server_id'] = Variable<int>(ticketServerId);
    if (!nullToAbsent || targetLocalId != null) {
      map['target_local_id'] = Variable<String>(targetLocalId);
    }
    if (!nullToAbsent || targetServerId != null) {
      map['target_server_id'] = Variable<int>(targetServerId);
    }
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || baseSnapshot != null) {
      map['base_snapshot'] = Variable<String>(baseSnapshot);
    }
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<String>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    if (!nullToAbsent || entityRecursive != null) {
      map['entity_recursive'] = Variable<bool>(entityRecursive);
    }
    return map;
  }

  PendingOpsCompanion toCompanion(bool nullToAbsent) {
    return PendingOpsCompanion(
      id: Value(id),
      opUuid: Value(opUuid),
      opType: Value(opType),
      itemtype: Value(itemtype),
      ticketLocalId: Value(ticketLocalId),
      ticketServerId: Value(ticketServerId),
      targetLocalId: targetLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetLocalId),
      targetServerId: targetServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetServerId),
      payload: Value(payload),
      baseSnapshot: baseSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(baseSnapshot),
      status: Value(status),
      attempts: Value(attempts),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      entityRecursive: entityRecursive == null && nullToAbsent
          ? const Value.absent()
          : Value(entityRecursive),
    );
  }

  factory PendingOp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOp(
      id: serializer.fromJson<int>(json['id']),
      opUuid: serializer.fromJson<String>(json['opUuid']),
      opType: serializer.fromJson<String>(json['opType']),
      itemtype: serializer.fromJson<String>(json['itemtype']),
      ticketLocalId: serializer.fromJson<String>(json['ticketLocalId']),
      ticketServerId: serializer.fromJson<int>(json['ticketServerId']),
      targetLocalId: serializer.fromJson<String?>(json['targetLocalId']),
      targetServerId: serializer.fromJson<int?>(json['targetServerId']),
      payload: serializer.fromJson<String>(json['payload']),
      baseSnapshot: serializer.fromJson<String?>(json['baseSnapshot']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextRetryAt: serializer.fromJson<String?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      entityRecursive: serializer.fromJson<bool?>(json['entityRecursive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'opUuid': serializer.toJson<String>(opUuid),
      'opType': serializer.toJson<String>(opType),
      'itemtype': serializer.toJson<String>(itemtype),
      'ticketLocalId': serializer.toJson<String>(ticketLocalId),
      'ticketServerId': serializer.toJson<int>(ticketServerId),
      'targetLocalId': serializer.toJson<String?>(targetLocalId),
      'targetServerId': serializer.toJson<int?>(targetServerId),
      'payload': serializer.toJson<String>(payload),
      'baseSnapshot': serializer.toJson<String?>(baseSnapshot),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'nextRetryAt': serializer.toJson<String?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<String>(createdAt),
      'entityId': serializer.toJson<int?>(entityId),
      'entityRecursive': serializer.toJson<bool?>(entityRecursive),
    };
  }

  PendingOp copyWith({
    int? id,
    String? opUuid,
    String? opType,
    String? itemtype,
    String? ticketLocalId,
    int? ticketServerId,
    Value<String?> targetLocalId = const Value.absent(),
    Value<int?> targetServerId = const Value.absent(),
    String? payload,
    Value<String?> baseSnapshot = const Value.absent(),
    String? status,
    int? attempts,
    Value<String?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    String? createdAt,
    Value<int?> entityId = const Value.absent(),
    Value<bool?> entityRecursive = const Value.absent(),
  }) => PendingOp(
    id: id ?? this.id,
    opUuid: opUuid ?? this.opUuid,
    opType: opType ?? this.opType,
    itemtype: itemtype ?? this.itemtype,
    ticketLocalId: ticketLocalId ?? this.ticketLocalId,
    ticketServerId: ticketServerId ?? this.ticketServerId,
    targetLocalId: targetLocalId.present
        ? targetLocalId.value
        : this.targetLocalId,
    targetServerId: targetServerId.present
        ? targetServerId.value
        : this.targetServerId,
    payload: payload ?? this.payload,
    baseSnapshot: baseSnapshot.present ? baseSnapshot.value : this.baseSnapshot,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    entityId: entityId.present ? entityId.value : this.entityId,
    entityRecursive: entityRecursive.present
        ? entityRecursive.value
        : this.entityRecursive,
  );
  PendingOp copyWithCompanion(PendingOpsCompanion data) {
    return PendingOp(
      id: data.id.present ? data.id.value : this.id,
      opUuid: data.opUuid.present ? data.opUuid.value : this.opUuid,
      opType: data.opType.present ? data.opType.value : this.opType,
      itemtype: data.itemtype.present ? data.itemtype.value : this.itemtype,
      ticketLocalId: data.ticketLocalId.present
          ? data.ticketLocalId.value
          : this.ticketLocalId,
      ticketServerId: data.ticketServerId.present
          ? data.ticketServerId.value
          : this.ticketServerId,
      targetLocalId: data.targetLocalId.present
          ? data.targetLocalId.value
          : this.targetLocalId,
      targetServerId: data.targetServerId.present
          ? data.targetServerId.value
          : this.targetServerId,
      payload: data.payload.present ? data.payload.value : this.payload,
      baseSnapshot: data.baseSnapshot.present
          ? data.baseSnapshot.value
          : this.baseSnapshot,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityRecursive: data.entityRecursive.present
          ? data.entityRecursive.value
          : this.entityRecursive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOp(')
          ..write('id: $id, ')
          ..write('opUuid: $opUuid, ')
          ..write('opType: $opType, ')
          ..write('itemtype: $itemtype, ')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('ticketServerId: $ticketServerId, ')
          ..write('targetLocalId: $targetLocalId, ')
          ..write('targetServerId: $targetServerId, ')
          ..write('payload: $payload, ')
          ..write('baseSnapshot: $baseSnapshot, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('entityId: $entityId, ')
          ..write('entityRecursive: $entityRecursive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opUuid,
    opType,
    itemtype,
    ticketLocalId,
    ticketServerId,
    targetLocalId,
    targetServerId,
    payload,
    baseSnapshot,
    status,
    attempts,
    nextRetryAt,
    lastError,
    createdAt,
    entityId,
    entityRecursive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOp &&
          other.id == this.id &&
          other.opUuid == this.opUuid &&
          other.opType == this.opType &&
          other.itemtype == this.itemtype &&
          other.ticketLocalId == this.ticketLocalId &&
          other.ticketServerId == this.ticketServerId &&
          other.targetLocalId == this.targetLocalId &&
          other.targetServerId == this.targetServerId &&
          other.payload == this.payload &&
          other.baseSnapshot == this.baseSnapshot &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.entityId == this.entityId &&
          other.entityRecursive == this.entityRecursive);
}

class PendingOpsCompanion extends UpdateCompanion<PendingOp> {
  final Value<int> id;
  final Value<String> opUuid;
  final Value<String> opType;
  final Value<String> itemtype;
  final Value<String> ticketLocalId;
  final Value<int> ticketServerId;
  final Value<String?> targetLocalId;
  final Value<int?> targetServerId;
  final Value<String> payload;
  final Value<String?> baseSnapshot;
  final Value<String> status;
  final Value<int> attempts;
  final Value<String?> nextRetryAt;
  final Value<String?> lastError;
  final Value<String> createdAt;
  final Value<int?> entityId;
  final Value<bool?> entityRecursive;
  const PendingOpsCompanion({
    this.id = const Value.absent(),
    this.opUuid = const Value.absent(),
    this.opType = const Value.absent(),
    this.itemtype = const Value.absent(),
    this.ticketLocalId = const Value.absent(),
    this.ticketServerId = const Value.absent(),
    this.targetLocalId = const Value.absent(),
    this.targetServerId = const Value.absent(),
    this.payload = const Value.absent(),
    this.baseSnapshot = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityRecursive = const Value.absent(),
  });
  PendingOpsCompanion.insert({
    this.id = const Value.absent(),
    required String opUuid,
    required String opType,
    this.itemtype = const Value.absent(),
    required String ticketLocalId,
    required int ticketServerId,
    this.targetLocalId = const Value.absent(),
    this.targetServerId = const Value.absent(),
    this.payload = const Value.absent(),
    this.baseSnapshot = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required String createdAt,
    this.entityId = const Value.absent(),
    this.entityRecursive = const Value.absent(),
  }) : opUuid = Value(opUuid),
       opType = Value(opType),
       ticketLocalId = Value(ticketLocalId),
       ticketServerId = Value(ticketServerId),
       createdAt = Value(createdAt);
  static Insertable<PendingOp> custom({
    Expression<int>? id,
    Expression<String>? opUuid,
    Expression<String>? opType,
    Expression<String>? itemtype,
    Expression<String>? ticketLocalId,
    Expression<int>? ticketServerId,
    Expression<String>? targetLocalId,
    Expression<int>? targetServerId,
    Expression<String>? payload,
    Expression<String>? baseSnapshot,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<String>? nextRetryAt,
    Expression<String>? lastError,
    Expression<String>? createdAt,
    Expression<int>? entityId,
    Expression<bool>? entityRecursive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opUuid != null) 'op_uuid': opUuid,
      if (opType != null) 'op_type': opType,
      if (itemtype != null) 'itemtype': itemtype,
      if (ticketLocalId != null) 'ticket_local_id': ticketLocalId,
      if (ticketServerId != null) 'ticket_server_id': ticketServerId,
      if (targetLocalId != null) 'target_local_id': targetLocalId,
      if (targetServerId != null) 'target_server_id': targetServerId,
      if (payload != null) 'payload': payload,
      if (baseSnapshot != null) 'base_snapshot': baseSnapshot,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (entityId != null) 'entity_id': entityId,
      if (entityRecursive != null) 'entity_recursive': entityRecursive,
    });
  }

  PendingOpsCompanion copyWith({
    Value<int>? id,
    Value<String>? opUuid,
    Value<String>? opType,
    Value<String>? itemtype,
    Value<String>? ticketLocalId,
    Value<int>? ticketServerId,
    Value<String?>? targetLocalId,
    Value<int?>? targetServerId,
    Value<String>? payload,
    Value<String?>? baseSnapshot,
    Value<String>? status,
    Value<int>? attempts,
    Value<String?>? nextRetryAt,
    Value<String?>? lastError,
    Value<String>? createdAt,
    Value<int?>? entityId,
    Value<bool?>? entityRecursive,
  }) {
    return PendingOpsCompanion(
      id: id ?? this.id,
      opUuid: opUuid ?? this.opUuid,
      opType: opType ?? this.opType,
      itemtype: itemtype ?? this.itemtype,
      ticketLocalId: ticketLocalId ?? this.ticketLocalId,
      ticketServerId: ticketServerId ?? this.ticketServerId,
      targetLocalId: targetLocalId ?? this.targetLocalId,
      targetServerId: targetServerId ?? this.targetServerId,
      payload: payload ?? this.payload,
      baseSnapshot: baseSnapshot ?? this.baseSnapshot,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      entityId: entityId ?? this.entityId,
      entityRecursive: entityRecursive ?? this.entityRecursive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (opUuid.present) {
      map['op_uuid'] = Variable<String>(opUuid.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (itemtype.present) {
      map['itemtype'] = Variable<String>(itemtype.value);
    }
    if (ticketLocalId.present) {
      map['ticket_local_id'] = Variable<String>(ticketLocalId.value);
    }
    if (ticketServerId.present) {
      map['ticket_server_id'] = Variable<int>(ticketServerId.value);
    }
    if (targetLocalId.present) {
      map['target_local_id'] = Variable<String>(targetLocalId.value);
    }
    if (targetServerId.present) {
      map['target_server_id'] = Variable<int>(targetServerId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (baseSnapshot.present) {
      map['base_snapshot'] = Variable<String>(baseSnapshot.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<String>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (entityRecursive.present) {
      map['entity_recursive'] = Variable<bool>(entityRecursive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpsCompanion(')
          ..write('id: $id, ')
          ..write('opUuid: $opUuid, ')
          ..write('opType: $opType, ')
          ..write('itemtype: $itemtype, ')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('ticketServerId: $ticketServerId, ')
          ..write('targetLocalId: $targetLocalId, ')
          ..write('targetServerId: $targetServerId, ')
          ..write('payload: $payload, ')
          ..write('baseSnapshot: $baseSnapshot, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('entityId: $entityId, ')
          ..write('entityRecursive: $entityRecursive')
          ..write(')'))
        .toString();
  }
}

class $ActiveTimersTable extends ActiveTimers
    with TableInfo<$ActiveTimersTable, ActiveTimer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveTimersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ticketLocalIdMeta = const VerificationMeta(
    'ticketLocalId',
  );
  @override
  late final GeneratedColumn<String> ticketLocalId = GeneratedColumn<String>(
    'ticket_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketServerIdMeta = const VerificationMeta(
    'ticketServerId',
  );
  @override
  late final GeneratedColumn<int> ticketServerId = GeneratedColumn<int>(
    'ticket_server_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketNameMeta = const VerificationMeta(
    'ticketName',
  );
  @override
  late final GeneratedColumn<String> ticketName = GeneratedColumn<String>(
    'ticket_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ticketLocalId,
    ticketServerId,
    ticketName,
    startedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_timers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveTimer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ticket_local_id')) {
      context.handle(
        _ticketLocalIdMeta,
        ticketLocalId.isAcceptableOrUnknown(
          data['ticket_local_id']!,
          _ticketLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ticketLocalIdMeta);
    }
    if (data.containsKey('ticket_server_id')) {
      context.handle(
        _ticketServerIdMeta,
        ticketServerId.isAcceptableOrUnknown(
          data['ticket_server_id']!,
          _ticketServerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ticketServerIdMeta);
    }
    if (data.containsKey('ticket_name')) {
      context.handle(
        _ticketNameMeta,
        ticketName.isAcceptableOrUnknown(data['ticket_name']!, _ticketNameMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ticketLocalId};
  @override
  ActiveTimer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveTimer(
      ticketLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_local_id'],
      )!,
      ticketServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ticket_server_id'],
      )!,
      ticketName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
    );
  }

  @override
  $ActiveTimersTable createAlias(String alias) {
    return $ActiveTimersTable(attachedDatabase, alias);
  }
}

class ActiveTimer extends DataClass implements Insertable<ActiveTimer> {
  final String ticketLocalId;
  final int ticketServerId;
  final String ticketName;
  final String startedAt;
  const ActiveTimer({
    required this.ticketLocalId,
    required this.ticketServerId,
    required this.ticketName,
    required this.startedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ticket_local_id'] = Variable<String>(ticketLocalId);
    map['ticket_server_id'] = Variable<int>(ticketServerId);
    map['ticket_name'] = Variable<String>(ticketName);
    map['started_at'] = Variable<String>(startedAt);
    return map;
  }

  ActiveTimersCompanion toCompanion(bool nullToAbsent) {
    return ActiveTimersCompanion(
      ticketLocalId: Value(ticketLocalId),
      ticketServerId: Value(ticketServerId),
      ticketName: Value(ticketName),
      startedAt: Value(startedAt),
    );
  }

  factory ActiveTimer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveTimer(
      ticketLocalId: serializer.fromJson<String>(json['ticketLocalId']),
      ticketServerId: serializer.fromJson<int>(json['ticketServerId']),
      ticketName: serializer.fromJson<String>(json['ticketName']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ticketLocalId': serializer.toJson<String>(ticketLocalId),
      'ticketServerId': serializer.toJson<int>(ticketServerId),
      'ticketName': serializer.toJson<String>(ticketName),
      'startedAt': serializer.toJson<String>(startedAt),
    };
  }

  ActiveTimer copyWith({
    String? ticketLocalId,
    int? ticketServerId,
    String? ticketName,
    String? startedAt,
  }) => ActiveTimer(
    ticketLocalId: ticketLocalId ?? this.ticketLocalId,
    ticketServerId: ticketServerId ?? this.ticketServerId,
    ticketName: ticketName ?? this.ticketName,
    startedAt: startedAt ?? this.startedAt,
  );
  ActiveTimer copyWithCompanion(ActiveTimersCompanion data) {
    return ActiveTimer(
      ticketLocalId: data.ticketLocalId.present
          ? data.ticketLocalId.value
          : this.ticketLocalId,
      ticketServerId: data.ticketServerId.present
          ? data.ticketServerId.value
          : this.ticketServerId,
      ticketName: data.ticketName.present
          ? data.ticketName.value
          : this.ticketName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimer(')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('ticketServerId: $ticketServerId, ')
          ..write('ticketName: $ticketName, ')
          ..write('startedAt: $startedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ticketLocalId, ticketServerId, ticketName, startedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveTimer &&
          other.ticketLocalId == this.ticketLocalId &&
          other.ticketServerId == this.ticketServerId &&
          other.ticketName == this.ticketName &&
          other.startedAt == this.startedAt);
}

class ActiveTimersCompanion extends UpdateCompanion<ActiveTimer> {
  final Value<String> ticketLocalId;
  final Value<int> ticketServerId;
  final Value<String> ticketName;
  final Value<String> startedAt;
  final Value<int> rowid;
  const ActiveTimersCompanion({
    this.ticketLocalId = const Value.absent(),
    this.ticketServerId = const Value.absent(),
    this.ticketName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActiveTimersCompanion.insert({
    required String ticketLocalId,
    required int ticketServerId,
    this.ticketName = const Value.absent(),
    required String startedAt,
    this.rowid = const Value.absent(),
  }) : ticketLocalId = Value(ticketLocalId),
       ticketServerId = Value(ticketServerId),
       startedAt = Value(startedAt);
  static Insertable<ActiveTimer> custom({
    Expression<String>? ticketLocalId,
    Expression<int>? ticketServerId,
    Expression<String>? ticketName,
    Expression<String>? startedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ticketLocalId != null) 'ticket_local_id': ticketLocalId,
      if (ticketServerId != null) 'ticket_server_id': ticketServerId,
      if (ticketName != null) 'ticket_name': ticketName,
      if (startedAt != null) 'started_at': startedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActiveTimersCompanion copyWith({
    Value<String>? ticketLocalId,
    Value<int>? ticketServerId,
    Value<String>? ticketName,
    Value<String>? startedAt,
    Value<int>? rowid,
  }) {
    return ActiveTimersCompanion(
      ticketLocalId: ticketLocalId ?? this.ticketLocalId,
      ticketServerId: ticketServerId ?? this.ticketServerId,
      ticketName: ticketName ?? this.ticketName,
      startedAt: startedAt ?? this.startedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ticketLocalId.present) {
      map['ticket_local_id'] = Variable<String>(ticketLocalId.value);
    }
    if (ticketServerId.present) {
      map['ticket_server_id'] = Variable<int>(ticketServerId.value);
    }
    if (ticketName.present) {
      map['ticket_name'] = Variable<String>(ticketName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimersCompanion(')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('ticketServerId: $ticketServerId, ')
          ..write('ticketName: $ticketName, ')
          ..write('startedAt: $startedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppConfigTable extends AppConfig
    with TableInfo<$AppConfigTable, AppConfigData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_config';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppConfigData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppConfigData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppConfigData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppConfigTable createAlias(String alias) {
    return $AppConfigTable(attachedDatabase, alias);
  }
}

class AppConfigData extends DataClass implements Insertable<AppConfigData> {
  final String key;
  final String value;
  const AppConfigData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppConfigCompanion toCompanion(bool nullToAbsent) {
    return AppConfigCompanion(key: Value(key), value: Value(value));
  }

  factory AppConfigData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppConfigData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppConfigData copyWith({String? key, String? value}) =>
      AppConfigData(key: key ?? this.key, value: value ?? this.value);
  AppConfigData copyWithCompanion(AppConfigCompanion data) {
    return AppConfigData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppConfigData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppConfigData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppConfigCompanion extends UpdateCompanion<AppConfigData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppConfigCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppConfigCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppConfigData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppConfigCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppConfigCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppConfigCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeKeyMeta = const VerificationMeta(
    'scopeKey',
  );
  @override
  late final GeneratedColumn<String> scopeKey = GeneratedColumn<String>(
    'scope_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watermarkMeta = const VerificationMeta(
    'watermark',
  );
  @override
  late final GeneratedColumn<String> watermark = GeneratedColumn<String>(
    'watermark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<String> lastSuccessAt = GeneratedColumn<String>(
    'last_success_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [scopeKey, watermark, lastSuccessAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope_key')) {
      context.handle(
        _scopeKeyMeta,
        scopeKey.isAcceptableOrUnknown(data['scope_key']!, _scopeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeKeyMeta);
    }
    if (data.containsKey('watermark')) {
      context.handle(
        _watermarkMeta,
        watermark.isAcceptableOrUnknown(data['watermark']!, _watermarkMeta),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scopeKey};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      scopeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_key'],
      )!,
      watermark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watermark'],
      ),
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_success_at'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String scopeKey;
  final String? watermark;
  final String? lastSuccessAt;
  const SyncStateData({
    required this.scopeKey,
    this.watermark,
    this.lastSuccessAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope_key'] = Variable<String>(scopeKey);
    if (!nullToAbsent || watermark != null) {
      map['watermark'] = Variable<String>(watermark);
    }
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<String>(lastSuccessAt);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      scopeKey: Value(scopeKey),
      watermark: watermark == null && nullToAbsent
          ? const Value.absent()
          : Value(watermark),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      scopeKey: serializer.fromJson<String>(json['scopeKey']),
      watermark: serializer.fromJson<String?>(json['watermark']),
      lastSuccessAt: serializer.fromJson<String?>(json['lastSuccessAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scopeKey': serializer.toJson<String>(scopeKey),
      'watermark': serializer.toJson<String?>(watermark),
      'lastSuccessAt': serializer.toJson<String?>(lastSuccessAt),
    };
  }

  SyncStateData copyWith({
    String? scopeKey,
    Value<String?> watermark = const Value.absent(),
    Value<String?> lastSuccessAt = const Value.absent(),
  }) => SyncStateData(
    scopeKey: scopeKey ?? this.scopeKey,
    watermark: watermark.present ? watermark.value : this.watermark,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      scopeKey: data.scopeKey.present ? data.scopeKey.value : this.scopeKey,
      watermark: data.watermark.present ? data.watermark.value : this.watermark,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('scopeKey: $scopeKey, ')
          ..write('watermark: $watermark, ')
          ..write('lastSuccessAt: $lastSuccessAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scopeKey, watermark, lastSuccessAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.scopeKey == this.scopeKey &&
          other.watermark == this.watermark &&
          other.lastSuccessAt == this.lastSuccessAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> scopeKey;
  final Value<String?> watermark;
  final Value<String?> lastSuccessAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.scopeKey = const Value.absent(),
    this.watermark = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String scopeKey,
    this.watermark = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scopeKey = Value(scopeKey);
  static Insertable<SyncStateData> custom({
    Expression<String>? scopeKey,
    Expression<String>? watermark,
    Expression<String>? lastSuccessAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scopeKey != null) 'scope_key': scopeKey,
      if (watermark != null) 'watermark': watermark,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? scopeKey,
    Value<String?>? watermark,
    Value<String?>? lastSuccessAt,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      scopeKey: scopeKey ?? this.scopeKey,
      watermark: watermark ?? this.watermark,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scopeKey.present) {
      map['scope_key'] = Variable<String>(scopeKey.value);
    }
    if (watermark.present) {
      map['watermark'] = Variable<String>(watermark.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<String>(lastSuccessAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('scopeKey: $scopeKey, ')
          ..write('watermark: $watermark, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketLocalIdMeta = const VerificationMeta(
    'ticketLocalId',
  );
  @override
  late final GeneratedColumn<String> ticketLocalId = GeneratedColumn<String>(
    'ticket_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tickets (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _serverDocIdMeta = const VerificationMeta(
    'serverDocId',
  );
  @override
  late final GeneratedColumn<int> serverDocId = GeneratedColumn<int>(
    'server_doc_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _opUuidMeta = const VerificationMeta('opUuid');
  @override
  late final GeneratedColumn<String> opUuid = GeneratedColumn<String>(
    'op_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCreationMeta = const VerificationMeta(
    'dateCreation',
  );
  @override
  late final GeneratedColumn<String> dateCreation = GeneratedColumn<String>(
    'date_creation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    ticketLocalId,
    serverDocId,
    name,
    filename,
    mime,
    localPath,
    sizeBytes,
    opUuid,
    dateCreation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('ticket_local_id')) {
      context.handle(
        _ticketLocalIdMeta,
        ticketLocalId.isAcceptableOrUnknown(
          data['ticket_local_id']!,
          _ticketLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ticketLocalIdMeta);
    }
    if (data.containsKey('server_doc_id')) {
      context.handle(
        _serverDocIdMeta,
        serverDocId.isAcceptableOrUnknown(
          data['server_doc_id']!,
          _serverDocIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('op_uuid')) {
      context.handle(
        _opUuidMeta,
        opUuid.isAcceptableOrUnknown(data['op_uuid']!, _opUuidMeta),
      );
    }
    if (data.containsKey('date_creation')) {
      context.handle(
        _dateCreationMeta,
        dateCreation.isAcceptableOrUnknown(
          data['date_creation']!,
          _dateCreationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      ticketLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_local_id'],
      )!,
      serverDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_doc_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      ),
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      opUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_uuid'],
      ),
      dateCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_creation'],
      ),
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String localId;
  final String ticketLocalId;
  final int? serverDocId;
  final String name;
  final String? filename;
  final String? mime;
  final String? localPath;
  final int? sizeBytes;
  final String? opUuid;
  final String? dateCreation;
  const AttachmentRow({
    required this.localId,
    required this.ticketLocalId,
    this.serverDocId,
    required this.name,
    this.filename,
    this.mime,
    this.localPath,
    this.sizeBytes,
    this.opUuid,
    this.dateCreation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['ticket_local_id'] = Variable<String>(ticketLocalId);
    if (!nullToAbsent || serverDocId != null) {
      map['server_doc_id'] = Variable<int>(serverDocId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || filename != null) {
      map['filename'] = Variable<String>(filename);
    }
    if (!nullToAbsent || mime != null) {
      map['mime'] = Variable<String>(mime);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || opUuid != null) {
      map['op_uuid'] = Variable<String>(opUuid);
    }
    if (!nullToAbsent || dateCreation != null) {
      map['date_creation'] = Variable<String>(dateCreation);
    }
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      localId: Value(localId),
      ticketLocalId: Value(ticketLocalId),
      serverDocId: serverDocId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverDocId),
      name: Value(name),
      filename: filename == null && nullToAbsent
          ? const Value.absent()
          : Value(filename),
      mime: mime == null && nullToAbsent ? const Value.absent() : Value(mime),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      opUuid: opUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(opUuid),
      dateCreation: dateCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreation),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      localId: serializer.fromJson<String>(json['localId']),
      ticketLocalId: serializer.fromJson<String>(json['ticketLocalId']),
      serverDocId: serializer.fromJson<int?>(json['serverDocId']),
      name: serializer.fromJson<String>(json['name']),
      filename: serializer.fromJson<String?>(json['filename']),
      mime: serializer.fromJson<String?>(json['mime']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      opUuid: serializer.fromJson<String?>(json['opUuid']),
      dateCreation: serializer.fromJson<String?>(json['dateCreation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'ticketLocalId': serializer.toJson<String>(ticketLocalId),
      'serverDocId': serializer.toJson<int?>(serverDocId),
      'name': serializer.toJson<String>(name),
      'filename': serializer.toJson<String?>(filename),
      'mime': serializer.toJson<String?>(mime),
      'localPath': serializer.toJson<String?>(localPath),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'opUuid': serializer.toJson<String?>(opUuid),
      'dateCreation': serializer.toJson<String?>(dateCreation),
    };
  }

  AttachmentRow copyWith({
    String? localId,
    String? ticketLocalId,
    Value<int?> serverDocId = const Value.absent(),
    String? name,
    Value<String?> filename = const Value.absent(),
    Value<String?> mime = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> opUuid = const Value.absent(),
    Value<String?> dateCreation = const Value.absent(),
  }) => AttachmentRow(
    localId: localId ?? this.localId,
    ticketLocalId: ticketLocalId ?? this.ticketLocalId,
    serverDocId: serverDocId.present ? serverDocId.value : this.serverDocId,
    name: name ?? this.name,
    filename: filename.present ? filename.value : this.filename,
    mime: mime.present ? mime.value : this.mime,
    localPath: localPath.present ? localPath.value : this.localPath,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    opUuid: opUuid.present ? opUuid.value : this.opUuid,
    dateCreation: dateCreation.present ? dateCreation.value : this.dateCreation,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      ticketLocalId: data.ticketLocalId.present
          ? data.ticketLocalId.value
          : this.ticketLocalId,
      serverDocId: data.serverDocId.present
          ? data.serverDocId.value
          : this.serverDocId,
      name: data.name.present ? data.name.value : this.name,
      filename: data.filename.present ? data.filename.value : this.filename,
      mime: data.mime.present ? data.mime.value : this.mime,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      opUuid: data.opUuid.present ? data.opUuid.value : this.opUuid,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('localId: $localId, ')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('serverDocId: $serverDocId, ')
          ..write('name: $name, ')
          ..write('filename: $filename, ')
          ..write('mime: $mime, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('opUuid: $opUuid, ')
          ..write('dateCreation: $dateCreation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    ticketLocalId,
    serverDocId,
    name,
    filename,
    mime,
    localPath,
    sizeBytes,
    opUuid,
    dateCreation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.localId == this.localId &&
          other.ticketLocalId == this.ticketLocalId &&
          other.serverDocId == this.serverDocId &&
          other.name == this.name &&
          other.filename == this.filename &&
          other.mime == this.mime &&
          other.localPath == this.localPath &&
          other.sizeBytes == this.sizeBytes &&
          other.opUuid == this.opUuid &&
          other.dateCreation == this.dateCreation);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> localId;
  final Value<String> ticketLocalId;
  final Value<int?> serverDocId;
  final Value<String> name;
  final Value<String?> filename;
  final Value<String?> mime;
  final Value<String?> localPath;
  final Value<int?> sizeBytes;
  final Value<String?> opUuid;
  final Value<String?> dateCreation;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.localId = const Value.absent(),
    this.ticketLocalId = const Value.absent(),
    this.serverDocId = const Value.absent(),
    this.name = const Value.absent(),
    this.filename = const Value.absent(),
    this.mime = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.opUuid = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String localId,
    required String ticketLocalId,
    this.serverDocId = const Value.absent(),
    this.name = const Value.absent(),
    this.filename = const Value.absent(),
    this.mime = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.opUuid = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       ticketLocalId = Value(ticketLocalId);
  static Insertable<AttachmentRow> custom({
    Expression<String>? localId,
    Expression<String>? ticketLocalId,
    Expression<int>? serverDocId,
    Expression<String>? name,
    Expression<String>? filename,
    Expression<String>? mime,
    Expression<String>? localPath,
    Expression<int>? sizeBytes,
    Expression<String>? opUuid,
    Expression<String>? dateCreation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (ticketLocalId != null) 'ticket_local_id': ticketLocalId,
      if (serverDocId != null) 'server_doc_id': serverDocId,
      if (name != null) 'name': name,
      if (filename != null) 'filename': filename,
      if (mime != null) 'mime': mime,
      if (localPath != null) 'local_path': localPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (opUuid != null) 'op_uuid': opUuid,
      if (dateCreation != null) 'date_creation': dateCreation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? localId,
    Value<String>? ticketLocalId,
    Value<int?>? serverDocId,
    Value<String>? name,
    Value<String?>? filename,
    Value<String?>? mime,
    Value<String?>? localPath,
    Value<int?>? sizeBytes,
    Value<String?>? opUuid,
    Value<String?>? dateCreation,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      localId: localId ?? this.localId,
      ticketLocalId: ticketLocalId ?? this.ticketLocalId,
      serverDocId: serverDocId ?? this.serverDocId,
      name: name ?? this.name,
      filename: filename ?? this.filename,
      mime: mime ?? this.mime,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      opUuid: opUuid ?? this.opUuid,
      dateCreation: dateCreation ?? this.dateCreation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (ticketLocalId.present) {
      map['ticket_local_id'] = Variable<String>(ticketLocalId.value);
    }
    if (serverDocId.present) {
      map['server_doc_id'] = Variable<int>(serverDocId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (opUuid.present) {
      map['op_uuid'] = Variable<String>(opUuid.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<String>(dateCreation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('localId: $localId, ')
          ..write('ticketLocalId: $ticketLocalId, ')
          ..write('serverDocId: $serverDocId, ')
          ..write('name: $name, ')
          ..write('filename: $filename, ')
          ..write('mime: $mime, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('opUuid: $opUuid, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItilLinksTable extends ItilLinks
    with TableInfo<$ItilLinksTable, ItilLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItilLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerLocalIdMeta = const VerificationMeta(
    'ownerLocalId',
  );
  @override
  late final GeneratedColumn<String> ownerLocalId = GeneratedColumn<String>(
    'owner_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tickets (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetItemtypeMeta = const VerificationMeta(
    'targetItemtype',
  );
  @override
  late final GeneratedColumn<String> targetItemtype = GeneratedColumn<String>(
    'target_itemtype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetServerIdMeta = const VerificationMeta(
    'targetServerId',
  );
  @override
  late final GeneratedColumn<int> targetServerId = GeneratedColumn<int>(
    'target_server_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetNameMeta = const VerificationMeta(
    'targetName',
  );
  @override
  late final GeneratedColumn<String> targetName = GeneratedColumn<String>(
    'target_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _targetStatusMeta = const VerificationMeta(
    'targetStatus',
  );
  @override
  late final GeneratedColumn<int> targetStatus = GeneratedColumn<int>(
    'target_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _linkTypeMeta = const VerificationMeta(
    'linkType',
  );
  @override
  late final GeneratedColumn<int> linkType = GeneratedColumn<int>(
    'link_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    ownerLocalId,
    targetItemtype,
    targetServerId,
    targetName,
    targetStatus,
    linkType,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itil_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItilLinkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('owner_local_id')) {
      context.handle(
        _ownerLocalIdMeta,
        ownerLocalId.isAcceptableOrUnknown(
          data['owner_local_id']!,
          _ownerLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerLocalIdMeta);
    }
    if (data.containsKey('target_itemtype')) {
      context.handle(
        _targetItemtypeMeta,
        targetItemtype.isAcceptableOrUnknown(
          data['target_itemtype']!,
          _targetItemtypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetItemtypeMeta);
    }
    if (data.containsKey('target_server_id')) {
      context.handle(
        _targetServerIdMeta,
        targetServerId.isAcceptableOrUnknown(
          data['target_server_id']!,
          _targetServerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetServerIdMeta);
    }
    if (data.containsKey('target_name')) {
      context.handle(
        _targetNameMeta,
        targetName.isAcceptableOrUnknown(data['target_name']!, _targetNameMeta),
      );
    }
    if (data.containsKey('target_status')) {
      context.handle(
        _targetStatusMeta,
        targetStatus.isAcceptableOrUnknown(
          data['target_status']!,
          _targetStatusMeta,
        ),
      );
    }
    if (data.containsKey('link_type')) {
      context.handle(
        _linkTypeMeta,
        linkType.isAcceptableOrUnknown(data['link_type']!, _linkTypeMeta),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ItilLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItilLinkRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      ownerLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_local_id'],
      )!,
      targetItemtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_itemtype'],
      )!,
      targetServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_server_id'],
      )!,
      targetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_name'],
      )!,
      targetStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_status'],
      )!,
      linkType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}link_type'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $ItilLinksTable createAlias(String alias) {
    return $ItilLinksTable(attachedDatabase, alias);
  }
}

class ItilLinkRow extends DataClass implements Insertable<ItilLinkRow> {
  final String localId;
  final String ownerLocalId;
  final String targetItemtype;
  final int targetServerId;
  final String targetName;
  final int targetStatus;
  final int linkType;

  /// Set while an add/remove is still queued in the outbox.
  final bool pending;
  const ItilLinkRow({
    required this.localId,
    required this.ownerLocalId,
    required this.targetItemtype,
    required this.targetServerId,
    required this.targetName,
    required this.targetStatus,
    required this.linkType,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['owner_local_id'] = Variable<String>(ownerLocalId);
    map['target_itemtype'] = Variable<String>(targetItemtype);
    map['target_server_id'] = Variable<int>(targetServerId);
    map['target_name'] = Variable<String>(targetName);
    map['target_status'] = Variable<int>(targetStatus);
    map['link_type'] = Variable<int>(linkType);
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  ItilLinksCompanion toCompanion(bool nullToAbsent) {
    return ItilLinksCompanion(
      localId: Value(localId),
      ownerLocalId: Value(ownerLocalId),
      targetItemtype: Value(targetItemtype),
      targetServerId: Value(targetServerId),
      targetName: Value(targetName),
      targetStatus: Value(targetStatus),
      linkType: Value(linkType),
      pending: Value(pending),
    );
  }

  factory ItilLinkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItilLinkRow(
      localId: serializer.fromJson<String>(json['localId']),
      ownerLocalId: serializer.fromJson<String>(json['ownerLocalId']),
      targetItemtype: serializer.fromJson<String>(json['targetItemtype']),
      targetServerId: serializer.fromJson<int>(json['targetServerId']),
      targetName: serializer.fromJson<String>(json['targetName']),
      targetStatus: serializer.fromJson<int>(json['targetStatus']),
      linkType: serializer.fromJson<int>(json['linkType']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'ownerLocalId': serializer.toJson<String>(ownerLocalId),
      'targetItemtype': serializer.toJson<String>(targetItemtype),
      'targetServerId': serializer.toJson<int>(targetServerId),
      'targetName': serializer.toJson<String>(targetName),
      'targetStatus': serializer.toJson<int>(targetStatus),
      'linkType': serializer.toJson<int>(linkType),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  ItilLinkRow copyWith({
    String? localId,
    String? ownerLocalId,
    String? targetItemtype,
    int? targetServerId,
    String? targetName,
    int? targetStatus,
    int? linkType,
    bool? pending,
  }) => ItilLinkRow(
    localId: localId ?? this.localId,
    ownerLocalId: ownerLocalId ?? this.ownerLocalId,
    targetItemtype: targetItemtype ?? this.targetItemtype,
    targetServerId: targetServerId ?? this.targetServerId,
    targetName: targetName ?? this.targetName,
    targetStatus: targetStatus ?? this.targetStatus,
    linkType: linkType ?? this.linkType,
    pending: pending ?? this.pending,
  );
  ItilLinkRow copyWithCompanion(ItilLinksCompanion data) {
    return ItilLinkRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      ownerLocalId: data.ownerLocalId.present
          ? data.ownerLocalId.value
          : this.ownerLocalId,
      targetItemtype: data.targetItemtype.present
          ? data.targetItemtype.value
          : this.targetItemtype,
      targetServerId: data.targetServerId.present
          ? data.targetServerId.value
          : this.targetServerId,
      targetName: data.targetName.present
          ? data.targetName.value
          : this.targetName,
      targetStatus: data.targetStatus.present
          ? data.targetStatus.value
          : this.targetStatus,
      linkType: data.linkType.present ? data.linkType.value : this.linkType,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItilLinkRow(')
          ..write('localId: $localId, ')
          ..write('ownerLocalId: $ownerLocalId, ')
          ..write('targetItemtype: $targetItemtype, ')
          ..write('targetServerId: $targetServerId, ')
          ..write('targetName: $targetName, ')
          ..write('targetStatus: $targetStatus, ')
          ..write('linkType: $linkType, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    ownerLocalId,
    targetItemtype,
    targetServerId,
    targetName,
    targetStatus,
    linkType,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItilLinkRow &&
          other.localId == this.localId &&
          other.ownerLocalId == this.ownerLocalId &&
          other.targetItemtype == this.targetItemtype &&
          other.targetServerId == this.targetServerId &&
          other.targetName == this.targetName &&
          other.targetStatus == this.targetStatus &&
          other.linkType == this.linkType &&
          other.pending == this.pending);
}

class ItilLinksCompanion extends UpdateCompanion<ItilLinkRow> {
  final Value<String> localId;
  final Value<String> ownerLocalId;
  final Value<String> targetItemtype;
  final Value<int> targetServerId;
  final Value<String> targetName;
  final Value<int> targetStatus;
  final Value<int> linkType;
  final Value<bool> pending;
  final Value<int> rowid;
  const ItilLinksCompanion({
    this.localId = const Value.absent(),
    this.ownerLocalId = const Value.absent(),
    this.targetItemtype = const Value.absent(),
    this.targetServerId = const Value.absent(),
    this.targetName = const Value.absent(),
    this.targetStatus = const Value.absent(),
    this.linkType = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItilLinksCompanion.insert({
    required String localId,
    required String ownerLocalId,
    required String targetItemtype,
    required int targetServerId,
    this.targetName = const Value.absent(),
    this.targetStatus = const Value.absent(),
    this.linkType = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       ownerLocalId = Value(ownerLocalId),
       targetItemtype = Value(targetItemtype),
       targetServerId = Value(targetServerId);
  static Insertable<ItilLinkRow> custom({
    Expression<String>? localId,
    Expression<String>? ownerLocalId,
    Expression<String>? targetItemtype,
    Expression<int>? targetServerId,
    Expression<String>? targetName,
    Expression<int>? targetStatus,
    Expression<int>? linkType,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (ownerLocalId != null) 'owner_local_id': ownerLocalId,
      if (targetItemtype != null) 'target_itemtype': targetItemtype,
      if (targetServerId != null) 'target_server_id': targetServerId,
      if (targetName != null) 'target_name': targetName,
      if (targetStatus != null) 'target_status': targetStatus,
      if (linkType != null) 'link_type': linkType,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItilLinksCompanion copyWith({
    Value<String>? localId,
    Value<String>? ownerLocalId,
    Value<String>? targetItemtype,
    Value<int>? targetServerId,
    Value<String>? targetName,
    Value<int>? targetStatus,
    Value<int>? linkType,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return ItilLinksCompanion(
      localId: localId ?? this.localId,
      ownerLocalId: ownerLocalId ?? this.ownerLocalId,
      targetItemtype: targetItemtype ?? this.targetItemtype,
      targetServerId: targetServerId ?? this.targetServerId,
      targetName: targetName ?? this.targetName,
      targetStatus: targetStatus ?? this.targetStatus,
      linkType: linkType ?? this.linkType,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (ownerLocalId.present) {
      map['owner_local_id'] = Variable<String>(ownerLocalId.value);
    }
    if (targetItemtype.present) {
      map['target_itemtype'] = Variable<String>(targetItemtype.value);
    }
    if (targetServerId.present) {
      map['target_server_id'] = Variable<int>(targetServerId.value);
    }
    if (targetName.present) {
      map['target_name'] = Variable<String>(targetName.value);
    }
    if (targetStatus.present) {
      map['target_status'] = Variable<int>(targetStatus.value);
    }
    if (linkType.present) {
      map['link_type'] = Variable<int>(linkType.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItilLinksCompanion(')
          ..write('localId: $localId, ')
          ..write('ownerLocalId: $ownerLocalId, ')
          ..write('targetItemtype: $targetItemtype, ')
          ..write('targetServerId: $targetServerId, ')
          ..write('targetName: $targetName, ')
          ..write('targetStatus: $targetStatus, ')
          ..write('linkType: $linkType, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItilExtrasTable extends ItilExtras
    with TableInfo<$ItilExtrasTable, ItilExtraRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItilExtrasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerLocalIdMeta = const VerificationMeta(
    'ownerLocalId',
  );
  @override
  late final GeneratedColumn<String> ownerLocalId = GeneratedColumn<String>(
    'owner_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tickets (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fieldsJsonMeta = const VerificationMeta(
    'fieldsJson',
  );
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
    'fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [ownerLocalId, fieldsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itil_extras';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItilExtraRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_local_id')) {
      context.handle(
        _ownerLocalIdMeta,
        ownerLocalId.isAcceptableOrUnknown(
          data['owner_local_id']!,
          _ownerLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerLocalIdMeta);
    }
    if (data.containsKey('fields_json')) {
      context.handle(
        _fieldsJsonMeta,
        fieldsJson.isAcceptableOrUnknown(data['fields_json']!, _fieldsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerLocalId};
  @override
  ItilExtraRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItilExtraRow(
      ownerLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_local_id'],
      )!,
      fieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_json'],
      )!,
    );
  }

  @override
  $ItilExtrasTable createAlias(String alias) {
    return $ItilExtrasTable(attachedDatabase, alias);
  }
}

class ItilExtraRow extends DataClass implements Insertable<ItilExtraRow> {
  final String ownerLocalId;
  final String fieldsJson;
  const ItilExtraRow({required this.ownerLocalId, required this.fieldsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_local_id'] = Variable<String>(ownerLocalId);
    map['fields_json'] = Variable<String>(fieldsJson);
    return map;
  }

  ItilExtrasCompanion toCompanion(bool nullToAbsent) {
    return ItilExtrasCompanion(
      ownerLocalId: Value(ownerLocalId),
      fieldsJson: Value(fieldsJson),
    );
  }

  factory ItilExtraRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItilExtraRow(
      ownerLocalId: serializer.fromJson<String>(json['ownerLocalId']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerLocalId': serializer.toJson<String>(ownerLocalId),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
    };
  }

  ItilExtraRow copyWith({String? ownerLocalId, String? fieldsJson}) =>
      ItilExtraRow(
        ownerLocalId: ownerLocalId ?? this.ownerLocalId,
        fieldsJson: fieldsJson ?? this.fieldsJson,
      );
  ItilExtraRow copyWithCompanion(ItilExtrasCompanion data) {
    return ItilExtraRow(
      ownerLocalId: data.ownerLocalId.present
          ? data.ownerLocalId.value
          : this.ownerLocalId,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItilExtraRow(')
          ..write('ownerLocalId: $ownerLocalId, ')
          ..write('fieldsJson: $fieldsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerLocalId, fieldsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItilExtraRow &&
          other.ownerLocalId == this.ownerLocalId &&
          other.fieldsJson == this.fieldsJson);
}

class ItilExtrasCompanion extends UpdateCompanion<ItilExtraRow> {
  final Value<String> ownerLocalId;
  final Value<String> fieldsJson;
  final Value<int> rowid;
  const ItilExtrasCompanion({
    this.ownerLocalId = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItilExtrasCompanion.insert({
    required String ownerLocalId,
    this.fieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerLocalId = Value(ownerLocalId);
  static Insertable<ItilExtraRow> custom({
    Expression<String>? ownerLocalId,
    Expression<String>? fieldsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerLocalId != null) 'owner_local_id': ownerLocalId,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItilExtrasCompanion copyWith({
    Value<String>? ownerLocalId,
    Value<String>? fieldsJson,
    Value<int>? rowid,
  }) {
    return ItilExtrasCompanion(
      ownerLocalId: ownerLocalId ?? this.ownerLocalId,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerLocalId.present) {
      map['owner_local_id'] = Variable<String>(ownerLocalId.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItilExtrasCompanion(')
          ..write('ownerLocalId: $ownerLocalId, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanningEventsTable extends PlanningEvents
    with TableInfo<$PlanningEventsTable, PlanningEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanningEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventItemtypeMeta = const VerificationMeta(
    'eventItemtype',
  );
  @override
  late final GeneratedColumn<String> eventItemtype = GeneratedColumn<String>(
    'event_itemtype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventServerIdMeta = const VerificationMeta(
    'eventServerId',
  );
  @override
  late final GeneratedColumn<int> eventServerId = GeneratedColumn<int>(
    'event_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentItemtypeMeta = const VerificationMeta(
    'parentItemtype',
  );
  @override
  late final GeneratedColumn<String> parentItemtype = GeneratedColumn<String>(
    'parent_itemtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentServerIdMeta = const VerificationMeta(
    'parentServerId',
  );
  @override
  late final GeneratedColumn<int> parentServerId = GeneratedColumn<int>(
    'parent_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentNameMeta = const VerificationMeta(
    'parentName',
  );
  @override
  late final GeneratedColumn<String> parentName = GeneratedColumn<String>(
    'parent_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _beginMeta = const VerificationMeta('begin');
  @override
  late final GeneratedColumn<String> begin = GeneratedColumn<String>(
    'begin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<String> end = GeneratedColumn<String>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    eventItemtype,
    eventServerId,
    parentItemtype,
    parentServerId,
    parentName,
    title,
    begin,
    end,
    isAllDay,
    state,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planning_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanningEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('event_itemtype')) {
      context.handle(
        _eventItemtypeMeta,
        eventItemtype.isAcceptableOrUnknown(
          data['event_itemtype']!,
          _eventItemtypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventItemtypeMeta);
    }
    if (data.containsKey('event_server_id')) {
      context.handle(
        _eventServerIdMeta,
        eventServerId.isAcceptableOrUnknown(
          data['event_server_id']!,
          _eventServerIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_itemtype')) {
      context.handle(
        _parentItemtypeMeta,
        parentItemtype.isAcceptableOrUnknown(
          data['parent_itemtype']!,
          _parentItemtypeMeta,
        ),
      );
    }
    if (data.containsKey('parent_server_id')) {
      context.handle(
        _parentServerIdMeta,
        parentServerId.isAcceptableOrUnknown(
          data['parent_server_id']!,
          _parentServerIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_name')) {
      context.handle(
        _parentNameMeta,
        parentName.isAcceptableOrUnknown(data['parent_name']!, _parentNameMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('begin')) {
      context.handle(
        _beginMeta,
        begin.isAcceptableOrUnknown(data['begin']!, _beginMeta),
      );
    } else if (isInserting) {
      context.missing(_beginMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  PlanningEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanningEventRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      eventItemtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_itemtype'],
      )!,
      eventServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_server_id'],
      ),
      parentItemtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_itemtype'],
      ),
      parentServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_server_id'],
      ),
      parentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_name'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      begin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}begin'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end'],
      )!,
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $PlanningEventsTable createAlias(String alias) {
    return $PlanningEventsTable(attachedDatabase, alias);
  }
}

class PlanningEventRow extends DataClass
    implements Insertable<PlanningEventRow> {
  final String localId;
  final String eventItemtype;
  final int? eventServerId;
  final String? parentItemtype;
  final int? parentServerId;
  final String? parentName;
  final String title;
  final String begin;
  final String end;
  final bool isAllDay;
  final int state;
  final bool pending;
  const PlanningEventRow({
    required this.localId,
    required this.eventItemtype,
    this.eventServerId,
    this.parentItemtype,
    this.parentServerId,
    this.parentName,
    required this.title,
    required this.begin,
    required this.end,
    required this.isAllDay,
    required this.state,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['event_itemtype'] = Variable<String>(eventItemtype);
    if (!nullToAbsent || eventServerId != null) {
      map['event_server_id'] = Variable<int>(eventServerId);
    }
    if (!nullToAbsent || parentItemtype != null) {
      map['parent_itemtype'] = Variable<String>(parentItemtype);
    }
    if (!nullToAbsent || parentServerId != null) {
      map['parent_server_id'] = Variable<int>(parentServerId);
    }
    if (!nullToAbsent || parentName != null) {
      map['parent_name'] = Variable<String>(parentName);
    }
    map['title'] = Variable<String>(title);
    map['begin'] = Variable<String>(begin);
    map['end'] = Variable<String>(end);
    map['is_all_day'] = Variable<bool>(isAllDay);
    map['state'] = Variable<int>(state);
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  PlanningEventsCompanion toCompanion(bool nullToAbsent) {
    return PlanningEventsCompanion(
      localId: Value(localId),
      eventItemtype: Value(eventItemtype),
      eventServerId: eventServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventServerId),
      parentItemtype: parentItemtype == null && nullToAbsent
          ? const Value.absent()
          : Value(parentItemtype),
      parentServerId: parentServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentServerId),
      parentName: parentName == null && nullToAbsent
          ? const Value.absent()
          : Value(parentName),
      title: Value(title),
      begin: Value(begin),
      end: Value(end),
      isAllDay: Value(isAllDay),
      state: Value(state),
      pending: Value(pending),
    );
  }

  factory PlanningEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanningEventRow(
      localId: serializer.fromJson<String>(json['localId']),
      eventItemtype: serializer.fromJson<String>(json['eventItemtype']),
      eventServerId: serializer.fromJson<int?>(json['eventServerId']),
      parentItemtype: serializer.fromJson<String?>(json['parentItemtype']),
      parentServerId: serializer.fromJson<int?>(json['parentServerId']),
      parentName: serializer.fromJson<String?>(json['parentName']),
      title: serializer.fromJson<String>(json['title']),
      begin: serializer.fromJson<String>(json['begin']),
      end: serializer.fromJson<String>(json['end']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      state: serializer.fromJson<int>(json['state']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'eventItemtype': serializer.toJson<String>(eventItemtype),
      'eventServerId': serializer.toJson<int?>(eventServerId),
      'parentItemtype': serializer.toJson<String?>(parentItemtype),
      'parentServerId': serializer.toJson<int?>(parentServerId),
      'parentName': serializer.toJson<String?>(parentName),
      'title': serializer.toJson<String>(title),
      'begin': serializer.toJson<String>(begin),
      'end': serializer.toJson<String>(end),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'state': serializer.toJson<int>(state),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  PlanningEventRow copyWith({
    String? localId,
    String? eventItemtype,
    Value<int?> eventServerId = const Value.absent(),
    Value<String?> parentItemtype = const Value.absent(),
    Value<int?> parentServerId = const Value.absent(),
    Value<String?> parentName = const Value.absent(),
    String? title,
    String? begin,
    String? end,
    bool? isAllDay,
    int? state,
    bool? pending,
  }) => PlanningEventRow(
    localId: localId ?? this.localId,
    eventItemtype: eventItemtype ?? this.eventItemtype,
    eventServerId: eventServerId.present
        ? eventServerId.value
        : this.eventServerId,
    parentItemtype: parentItemtype.present
        ? parentItemtype.value
        : this.parentItemtype,
    parentServerId: parentServerId.present
        ? parentServerId.value
        : this.parentServerId,
    parentName: parentName.present ? parentName.value : this.parentName,
    title: title ?? this.title,
    begin: begin ?? this.begin,
    end: end ?? this.end,
    isAllDay: isAllDay ?? this.isAllDay,
    state: state ?? this.state,
    pending: pending ?? this.pending,
  );
  PlanningEventRow copyWithCompanion(PlanningEventsCompanion data) {
    return PlanningEventRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      eventItemtype: data.eventItemtype.present
          ? data.eventItemtype.value
          : this.eventItemtype,
      eventServerId: data.eventServerId.present
          ? data.eventServerId.value
          : this.eventServerId,
      parentItemtype: data.parentItemtype.present
          ? data.parentItemtype.value
          : this.parentItemtype,
      parentServerId: data.parentServerId.present
          ? data.parentServerId.value
          : this.parentServerId,
      parentName: data.parentName.present
          ? data.parentName.value
          : this.parentName,
      title: data.title.present ? data.title.value : this.title,
      begin: data.begin.present ? data.begin.value : this.begin,
      end: data.end.present ? data.end.value : this.end,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      state: data.state.present ? data.state.value : this.state,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanningEventRow(')
          ..write('localId: $localId, ')
          ..write('eventItemtype: $eventItemtype, ')
          ..write('eventServerId: $eventServerId, ')
          ..write('parentItemtype: $parentItemtype, ')
          ..write('parentServerId: $parentServerId, ')
          ..write('parentName: $parentName, ')
          ..write('title: $title, ')
          ..write('begin: $begin, ')
          ..write('end: $end, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('state: $state, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    eventItemtype,
    eventServerId,
    parentItemtype,
    parentServerId,
    parentName,
    title,
    begin,
    end,
    isAllDay,
    state,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanningEventRow &&
          other.localId == this.localId &&
          other.eventItemtype == this.eventItemtype &&
          other.eventServerId == this.eventServerId &&
          other.parentItemtype == this.parentItemtype &&
          other.parentServerId == this.parentServerId &&
          other.parentName == this.parentName &&
          other.title == this.title &&
          other.begin == this.begin &&
          other.end == this.end &&
          other.isAllDay == this.isAllDay &&
          other.state == this.state &&
          other.pending == this.pending);
}

class PlanningEventsCompanion extends UpdateCompanion<PlanningEventRow> {
  final Value<String> localId;
  final Value<String> eventItemtype;
  final Value<int?> eventServerId;
  final Value<String?> parentItemtype;
  final Value<int?> parentServerId;
  final Value<String?> parentName;
  final Value<String> title;
  final Value<String> begin;
  final Value<String> end;
  final Value<bool> isAllDay;
  final Value<int> state;
  final Value<bool> pending;
  final Value<int> rowid;
  const PlanningEventsCompanion({
    this.localId = const Value.absent(),
    this.eventItemtype = const Value.absent(),
    this.eventServerId = const Value.absent(),
    this.parentItemtype = const Value.absent(),
    this.parentServerId = const Value.absent(),
    this.parentName = const Value.absent(),
    this.title = const Value.absent(),
    this.begin = const Value.absent(),
    this.end = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.state = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanningEventsCompanion.insert({
    required String localId,
    required String eventItemtype,
    this.eventServerId = const Value.absent(),
    this.parentItemtype = const Value.absent(),
    this.parentServerId = const Value.absent(),
    this.parentName = const Value.absent(),
    this.title = const Value.absent(),
    required String begin,
    required String end,
    this.isAllDay = const Value.absent(),
    this.state = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       eventItemtype = Value(eventItemtype),
       begin = Value(begin),
       end = Value(end);
  static Insertable<PlanningEventRow> custom({
    Expression<String>? localId,
    Expression<String>? eventItemtype,
    Expression<int>? eventServerId,
    Expression<String>? parentItemtype,
    Expression<int>? parentServerId,
    Expression<String>? parentName,
    Expression<String>? title,
    Expression<String>? begin,
    Expression<String>? end,
    Expression<bool>? isAllDay,
    Expression<int>? state,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (eventItemtype != null) 'event_itemtype': eventItemtype,
      if (eventServerId != null) 'event_server_id': eventServerId,
      if (parentItemtype != null) 'parent_itemtype': parentItemtype,
      if (parentServerId != null) 'parent_server_id': parentServerId,
      if (parentName != null) 'parent_name': parentName,
      if (title != null) 'title': title,
      if (begin != null) 'begin': begin,
      if (end != null) 'end': end,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (state != null) 'state': state,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanningEventsCompanion copyWith({
    Value<String>? localId,
    Value<String>? eventItemtype,
    Value<int?>? eventServerId,
    Value<String?>? parentItemtype,
    Value<int?>? parentServerId,
    Value<String?>? parentName,
    Value<String>? title,
    Value<String>? begin,
    Value<String>? end,
    Value<bool>? isAllDay,
    Value<int>? state,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return PlanningEventsCompanion(
      localId: localId ?? this.localId,
      eventItemtype: eventItemtype ?? this.eventItemtype,
      eventServerId: eventServerId ?? this.eventServerId,
      parentItemtype: parentItemtype ?? this.parentItemtype,
      parentServerId: parentServerId ?? this.parentServerId,
      parentName: parentName ?? this.parentName,
      title: title ?? this.title,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      state: state ?? this.state,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (eventItemtype.present) {
      map['event_itemtype'] = Variable<String>(eventItemtype.value);
    }
    if (eventServerId.present) {
      map['event_server_id'] = Variable<int>(eventServerId.value);
    }
    if (parentItemtype.present) {
      map['parent_itemtype'] = Variable<String>(parentItemtype.value);
    }
    if (parentServerId.present) {
      map['parent_server_id'] = Variable<int>(parentServerId.value);
    }
    if (parentName.present) {
      map['parent_name'] = Variable<String>(parentName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (begin.present) {
      map['begin'] = Variable<String>(begin.value);
    }
    if (end.present) {
      map['end'] = Variable<String>(end.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanningEventsCompanion(')
          ..write('localId: $localId, ')
          ..write('eventItemtype: $eventItemtype, ')
          ..write('eventServerId: $eventServerId, ')
          ..write('parentItemtype: $parentItemtype, ')
          ..write('parentServerId: $parentServerId, ')
          ..write('parentName: $parentName, ')
          ..write('title: $title, ')
          ..write('begin: $begin, ')
          ..write('end: $end, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('state: $state, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects
    with TableInfo<$ProjectsTable, ProjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusNameMeta = const VerificationMeta(
    'statusName',
  );
  @override
  late final GeneratedColumn<String> statusName = GeneratedColumn<String>(
    'status_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _percentDoneMeta = const VerificationMeta(
    'percentDone',
  );
  @override
  late final GeneratedColumn<int> percentDone = GeneratedColumn<int>(
    'percent_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _planStartDateMeta = const VerificationMeta(
    'planStartDate',
  );
  @override
  late final GeneratedColumn<String> planStartDate = GeneratedColumn<String>(
    'plan_start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planEndDateMeta = const VerificationMeta(
    'planEndDate',
  );
  @override
  late final GeneratedColumn<String> planEndDate = GeneratedColumn<String>(
    'plan_end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _managerNameMeta = const VerificationMeta(
    'managerName',
  );
  @override
  late final GeneratedColumn<String> managerName = GeneratedColumn<String>(
    'manager_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityLabelMeta = const VerificationMeta(
    'entityLabel',
  );
  @override
  late final GeneratedColumn<String> entityLabel = GeneratedColumn<String>(
    'entity_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateModMeta = const VerificationMeta(
    'dateMod',
  );
  @override
  late final GeneratedColumn<String> dateMod = GeneratedColumn<String>(
    'date_mod',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    name,
    code,
    content,
    statusName,
    priority,
    percentDone,
    planStartDate,
    planEndDate,
    managerName,
    entityLabel,
    dateMod,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('status_name')) {
      context.handle(
        _statusNameMeta,
        statusName.isAcceptableOrUnknown(data['status_name']!, _statusNameMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('percent_done')) {
      context.handle(
        _percentDoneMeta,
        percentDone.isAcceptableOrUnknown(
          data['percent_done']!,
          _percentDoneMeta,
        ),
      );
    }
    if (data.containsKey('plan_start_date')) {
      context.handle(
        _planStartDateMeta,
        planStartDate.isAcceptableOrUnknown(
          data['plan_start_date']!,
          _planStartDateMeta,
        ),
      );
    }
    if (data.containsKey('plan_end_date')) {
      context.handle(
        _planEndDateMeta,
        planEndDate.isAcceptableOrUnknown(
          data['plan_end_date']!,
          _planEndDateMeta,
        ),
      );
    }
    if (data.containsKey('manager_name')) {
      context.handle(
        _managerNameMeta,
        managerName.isAcceptableOrUnknown(
          data['manager_name']!,
          _managerNameMeta,
        ),
      );
    }
    if (data.containsKey('entity_label')) {
      context.handle(
        _entityLabelMeta,
        entityLabel.isAcceptableOrUnknown(
          data['entity_label']!,
          _entityLabelMeta,
        ),
      );
    }
    if (data.containsKey('date_mod')) {
      context.handle(
        _dateModMeta,
        dateMod.isAcceptableOrUnknown(data['date_mod']!, _dateModMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ProjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      statusName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_name'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      percentDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percent_done'],
      )!,
      planStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_start_date'],
      ),
      planEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_end_date'],
      ),
      managerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manager_name'],
      ),
      entityLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_label'],
      ),
      dateMod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_mod'],
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class ProjectRow extends DataClass implements Insertable<ProjectRow> {
  final String localId;
  final int? serverId;
  final String name;
  final String? code;
  final String content;
  final String? statusName;
  final int priority;
  final int percentDone;
  final String? planStartDate;
  final String? planEndDate;
  final String? managerName;
  final String? entityLabel;
  final String? dateMod;
  const ProjectRow({
    required this.localId,
    this.serverId,
    required this.name,
    this.code,
    required this.content,
    this.statusName,
    required this.priority,
    required this.percentDone,
    this.planStartDate,
    this.planEndDate,
    this.managerName,
    this.entityLabel,
    this.dateMod,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || statusName != null) {
      map['status_name'] = Variable<String>(statusName);
    }
    map['priority'] = Variable<int>(priority);
    map['percent_done'] = Variable<int>(percentDone);
    if (!nullToAbsent || planStartDate != null) {
      map['plan_start_date'] = Variable<String>(planStartDate);
    }
    if (!nullToAbsent || planEndDate != null) {
      map['plan_end_date'] = Variable<String>(planEndDate);
    }
    if (!nullToAbsent || managerName != null) {
      map['manager_name'] = Variable<String>(managerName);
    }
    if (!nullToAbsent || entityLabel != null) {
      map['entity_label'] = Variable<String>(entityLabel);
    }
    if (!nullToAbsent || dateMod != null) {
      map['date_mod'] = Variable<String>(dateMod);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      content: Value(content),
      statusName: statusName == null && nullToAbsent
          ? const Value.absent()
          : Value(statusName),
      priority: Value(priority),
      percentDone: Value(percentDone),
      planStartDate: planStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planStartDate),
      planEndDate: planEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planEndDate),
      managerName: managerName == null && nullToAbsent
          ? const Value.absent()
          : Value(managerName),
      entityLabel: entityLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(entityLabel),
      dateMod: dateMod == null && nullToAbsent
          ? const Value.absent()
          : Value(dateMod),
    );
  }

  factory ProjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRow(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      content: serializer.fromJson<String>(json['content']),
      statusName: serializer.fromJson<String?>(json['statusName']),
      priority: serializer.fromJson<int>(json['priority']),
      percentDone: serializer.fromJson<int>(json['percentDone']),
      planStartDate: serializer.fromJson<String?>(json['planStartDate']),
      planEndDate: serializer.fromJson<String?>(json['planEndDate']),
      managerName: serializer.fromJson<String?>(json['managerName']),
      entityLabel: serializer.fromJson<String?>(json['entityLabel']),
      dateMod: serializer.fromJson<String?>(json['dateMod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'content': serializer.toJson<String>(content),
      'statusName': serializer.toJson<String?>(statusName),
      'priority': serializer.toJson<int>(priority),
      'percentDone': serializer.toJson<int>(percentDone),
      'planStartDate': serializer.toJson<String?>(planStartDate),
      'planEndDate': serializer.toJson<String?>(planEndDate),
      'managerName': serializer.toJson<String?>(managerName),
      'entityLabel': serializer.toJson<String?>(entityLabel),
      'dateMod': serializer.toJson<String?>(dateMod),
    };
  }

  ProjectRow copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    String? name,
    Value<String?> code = const Value.absent(),
    String? content,
    Value<String?> statusName = const Value.absent(),
    int? priority,
    int? percentDone,
    Value<String?> planStartDate = const Value.absent(),
    Value<String?> planEndDate = const Value.absent(),
    Value<String?> managerName = const Value.absent(),
    Value<String?> entityLabel = const Value.absent(),
    Value<String?> dateMod = const Value.absent(),
  }) => ProjectRow(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    name: name ?? this.name,
    code: code.present ? code.value : this.code,
    content: content ?? this.content,
    statusName: statusName.present ? statusName.value : this.statusName,
    priority: priority ?? this.priority,
    percentDone: percentDone ?? this.percentDone,
    planStartDate: planStartDate.present
        ? planStartDate.value
        : this.planStartDate,
    planEndDate: planEndDate.present ? planEndDate.value : this.planEndDate,
    managerName: managerName.present ? managerName.value : this.managerName,
    entityLabel: entityLabel.present ? entityLabel.value : this.entityLabel,
    dateMod: dateMod.present ? dateMod.value : this.dateMod,
  );
  ProjectRow copyWithCompanion(ProjectsCompanion data) {
    return ProjectRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      content: data.content.present ? data.content.value : this.content,
      statusName: data.statusName.present
          ? data.statusName.value
          : this.statusName,
      priority: data.priority.present ? data.priority.value : this.priority,
      percentDone: data.percentDone.present
          ? data.percentDone.value
          : this.percentDone,
      planStartDate: data.planStartDate.present
          ? data.planStartDate.value
          : this.planStartDate,
      planEndDate: data.planEndDate.present
          ? data.planEndDate.value
          : this.planEndDate,
      managerName: data.managerName.present
          ? data.managerName.value
          : this.managerName,
      entityLabel: data.entityLabel.present
          ? data.entityLabel.value
          : this.entityLabel,
      dateMod: data.dateMod.present ? data.dateMod.value : this.dateMod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRow(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('content: $content, ')
          ..write('statusName: $statusName, ')
          ..write('priority: $priority, ')
          ..write('percentDone: $percentDone, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('planEndDate: $planEndDate, ')
          ..write('managerName: $managerName, ')
          ..write('entityLabel: $entityLabel, ')
          ..write('dateMod: $dateMod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    name,
    code,
    content,
    statusName,
    priority,
    percentDone,
    planStartDate,
    planEndDate,
    managerName,
    entityLabel,
    dateMod,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRow &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.code == this.code &&
          other.content == this.content &&
          other.statusName == this.statusName &&
          other.priority == this.priority &&
          other.percentDone == this.percentDone &&
          other.planStartDate == this.planStartDate &&
          other.planEndDate == this.planEndDate &&
          other.managerName == this.managerName &&
          other.entityLabel == this.entityLabel &&
          other.dateMod == this.dateMod);
}

class ProjectsCompanion extends UpdateCompanion<ProjectRow> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<String> name;
  final Value<String?> code;
  final Value<String> content;
  final Value<String?> statusName;
  final Value<int> priority;
  final Value<int> percentDone;
  final Value<String?> planStartDate;
  final Value<String?> planEndDate;
  final Value<String?> managerName;
  final Value<String?> entityLabel;
  final Value<String?> dateMod;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.content = const Value.absent(),
    this.statusName = const Value.absent(),
    this.priority = const Value.absent(),
    this.percentDone = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.planEndDate = const Value.absent(),
    this.managerName = const Value.absent(),
    this.entityLabel = const Value.absent(),
    this.dateMod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String name,
    this.code = const Value.absent(),
    this.content = const Value.absent(),
    this.statusName = const Value.absent(),
    this.priority = const Value.absent(),
    this.percentDone = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.planEndDate = const Value.absent(),
    this.managerName = const Value.absent(),
    this.entityLabel = const Value.absent(),
    this.dateMod = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       name = Value(name);
  static Insertable<ProjectRow> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? content,
    Expression<String>? statusName,
    Expression<int>? priority,
    Expression<int>? percentDone,
    Expression<String>? planStartDate,
    Expression<String>? planEndDate,
    Expression<String>? managerName,
    Expression<String>? entityLabel,
    Expression<String>? dateMod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (content != null) 'content': content,
      if (statusName != null) 'status_name': statusName,
      if (priority != null) 'priority': priority,
      if (percentDone != null) 'percent_done': percentDone,
      if (planStartDate != null) 'plan_start_date': planStartDate,
      if (planEndDate != null) 'plan_end_date': planEndDate,
      if (managerName != null) 'manager_name': managerName,
      if (entityLabel != null) 'entity_label': entityLabel,
      if (dateMod != null) 'date_mod': dateMod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<String>? name,
    Value<String?>? code,
    Value<String>? content,
    Value<String?>? statusName,
    Value<int>? priority,
    Value<int>? percentDone,
    Value<String?>? planStartDate,
    Value<String?>? planEndDate,
    Value<String?>? managerName,
    Value<String?>? entityLabel,
    Value<String?>? dateMod,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      code: code ?? this.code,
      content: content ?? this.content,
      statusName: statusName ?? this.statusName,
      priority: priority ?? this.priority,
      percentDone: percentDone ?? this.percentDone,
      planStartDate: planStartDate ?? this.planStartDate,
      planEndDate: planEndDate ?? this.planEndDate,
      managerName: managerName ?? this.managerName,
      entityLabel: entityLabel ?? this.entityLabel,
      dateMod: dateMod ?? this.dateMod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (statusName.present) {
      map['status_name'] = Variable<String>(statusName.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (percentDone.present) {
      map['percent_done'] = Variable<int>(percentDone.value);
    }
    if (planStartDate.present) {
      map['plan_start_date'] = Variable<String>(planStartDate.value);
    }
    if (planEndDate.present) {
      map['plan_end_date'] = Variable<String>(planEndDate.value);
    }
    if (managerName.present) {
      map['manager_name'] = Variable<String>(managerName.value);
    }
    if (entityLabel.present) {
      map['entity_label'] = Variable<String>(entityLabel.value);
    }
    if (dateMod.present) {
      map['date_mod'] = Variable<String>(dateMod.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('content: $content, ')
          ..write('statusName: $statusName, ')
          ..write('priority: $priority, ')
          ..write('percentDone: $percentDone, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('planEndDate: $planEndDate, ')
          ..write('managerName: $managerName, ')
          ..write('entityLabel: $entityLabel, ')
          ..write('dateMod: $dateMod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectTasksTable extends ProjectTasks
    with TableInfo<$ProjectTasksTable, ProjectTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectLocalIdMeta = const VerificationMeta(
    'projectLocalId',
  );
  @override
  late final GeneratedColumn<String> projectLocalId = GeneratedColumn<String>(
    'project_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (local_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentTaskServerIdMeta =
      const VerificationMeta('parentTaskServerId');
  @override
  late final GeneratedColumn<int> parentTaskServerId = GeneratedColumn<int>(
    'parent_task_server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusNameMeta = const VerificationMeta(
    'statusName',
  );
  @override
  late final GeneratedColumn<String> statusName = GeneratedColumn<String>(
    'status_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _percentDoneMeta = const VerificationMeta(
    'percentDone',
  );
  @override
  late final GeneratedColumn<int> percentDone = GeneratedColumn<int>(
    'percent_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _planStartDateMeta = const VerificationMeta(
    'planStartDate',
  );
  @override
  late final GeneratedColumn<String> planStartDate = GeneratedColumn<String>(
    'plan_start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planEndDateMeta = const VerificationMeta(
    'planEndDate',
  );
  @override
  late final GeneratedColumn<String> planEndDate = GeneratedColumn<String>(
    'plan_end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMilestoneMeta = const VerificationMeta(
    'isMilestone',
  );
  @override
  late final GeneratedColumn<bool> isMilestone = GeneratedColumn<bool>(
    'is_milestone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_milestone" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _assigneeNameMeta = const VerificationMeta(
    'assigneeName',
  );
  @override
  late final GeneratedColumn<String> assigneeName = GeneratedColumn<String>(
    'assignee_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    projectLocalId,
    serverId,
    parentTaskServerId,
    name,
    content,
    statusName,
    percentDone,
    planStartDate,
    planEndDate,
    isMilestone,
    assigneeName,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectTaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('project_local_id')) {
      context.handle(
        _projectLocalIdMeta,
        projectLocalId.isAcceptableOrUnknown(
          data['project_local_id']!,
          _projectLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectLocalIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('parent_task_server_id')) {
      context.handle(
        _parentTaskServerIdMeta,
        parentTaskServerId.isAcceptableOrUnknown(
          data['parent_task_server_id']!,
          _parentTaskServerIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('status_name')) {
      context.handle(
        _statusNameMeta,
        statusName.isAcceptableOrUnknown(data['status_name']!, _statusNameMeta),
      );
    }
    if (data.containsKey('percent_done')) {
      context.handle(
        _percentDoneMeta,
        percentDone.isAcceptableOrUnknown(
          data['percent_done']!,
          _percentDoneMeta,
        ),
      );
    }
    if (data.containsKey('plan_start_date')) {
      context.handle(
        _planStartDateMeta,
        planStartDate.isAcceptableOrUnknown(
          data['plan_start_date']!,
          _planStartDateMeta,
        ),
      );
    }
    if (data.containsKey('plan_end_date')) {
      context.handle(
        _planEndDateMeta,
        planEndDate.isAcceptableOrUnknown(
          data['plan_end_date']!,
          _planEndDateMeta,
        ),
      );
    }
    if (data.containsKey('is_milestone')) {
      context.handle(
        _isMilestoneMeta,
        isMilestone.isAcceptableOrUnknown(
          data['is_milestone']!,
          _isMilestoneMeta,
        ),
      );
    }
    if (data.containsKey('assignee_name')) {
      context.handle(
        _assigneeNameMeta,
        assigneeName.isAcceptableOrUnknown(
          data['assignee_name']!,
          _assigneeNameMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ProjectTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTaskRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      projectLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      parentTaskServerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_task_server_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      statusName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_name'],
      ),
      percentDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percent_done'],
      )!,
      planStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_start_date'],
      ),
      planEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_end_date'],
      ),
      isMilestone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_milestone'],
      )!,
      assigneeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee_name'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $ProjectTasksTable createAlias(String alias) {
    return $ProjectTasksTable(attachedDatabase, alias);
  }
}

class ProjectTaskRow extends DataClass implements Insertable<ProjectTaskRow> {
  final String localId;
  final String projectLocalId;
  final int? serverId;
  final int? parentTaskServerId;
  final String name;
  final String content;
  final String? statusName;
  final int percentDone;
  final String? planStartDate;
  final String? planEndDate;
  final bool isMilestone;
  final String? assigneeName;
  final bool pending;
  const ProjectTaskRow({
    required this.localId,
    required this.projectLocalId,
    this.serverId,
    this.parentTaskServerId,
    required this.name,
    required this.content,
    this.statusName,
    required this.percentDone,
    this.planStartDate,
    this.planEndDate,
    required this.isMilestone,
    this.assigneeName,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['project_local_id'] = Variable<String>(projectLocalId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    if (!nullToAbsent || parentTaskServerId != null) {
      map['parent_task_server_id'] = Variable<int>(parentTaskServerId);
    }
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || statusName != null) {
      map['status_name'] = Variable<String>(statusName);
    }
    map['percent_done'] = Variable<int>(percentDone);
    if (!nullToAbsent || planStartDate != null) {
      map['plan_start_date'] = Variable<String>(planStartDate);
    }
    if (!nullToAbsent || planEndDate != null) {
      map['plan_end_date'] = Variable<String>(planEndDate);
    }
    map['is_milestone'] = Variable<bool>(isMilestone);
    if (!nullToAbsent || assigneeName != null) {
      map['assignee_name'] = Variable<String>(assigneeName);
    }
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  ProjectTasksCompanion toCompanion(bool nullToAbsent) {
    return ProjectTasksCompanion(
      localId: Value(localId),
      projectLocalId: Value(projectLocalId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      parentTaskServerId: parentTaskServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTaskServerId),
      name: Value(name),
      content: Value(content),
      statusName: statusName == null && nullToAbsent
          ? const Value.absent()
          : Value(statusName),
      percentDone: Value(percentDone),
      planStartDate: planStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planStartDate),
      planEndDate: planEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(planEndDate),
      isMilestone: Value(isMilestone),
      assigneeName: assigneeName == null && nullToAbsent
          ? const Value.absent()
          : Value(assigneeName),
      pending: Value(pending),
    );
  }

  factory ProjectTaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTaskRow(
      localId: serializer.fromJson<String>(json['localId']),
      projectLocalId: serializer.fromJson<String>(json['projectLocalId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      parentTaskServerId: serializer.fromJson<int?>(json['parentTaskServerId']),
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
      statusName: serializer.fromJson<String?>(json['statusName']),
      percentDone: serializer.fromJson<int>(json['percentDone']),
      planStartDate: serializer.fromJson<String?>(json['planStartDate']),
      planEndDate: serializer.fromJson<String?>(json['planEndDate']),
      isMilestone: serializer.fromJson<bool>(json['isMilestone']),
      assigneeName: serializer.fromJson<String?>(json['assigneeName']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'projectLocalId': serializer.toJson<String>(projectLocalId),
      'serverId': serializer.toJson<int?>(serverId),
      'parentTaskServerId': serializer.toJson<int?>(parentTaskServerId),
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
      'statusName': serializer.toJson<String?>(statusName),
      'percentDone': serializer.toJson<int>(percentDone),
      'planStartDate': serializer.toJson<String?>(planStartDate),
      'planEndDate': serializer.toJson<String?>(planEndDate),
      'isMilestone': serializer.toJson<bool>(isMilestone),
      'assigneeName': serializer.toJson<String?>(assigneeName),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  ProjectTaskRow copyWith({
    String? localId,
    String? projectLocalId,
    Value<int?> serverId = const Value.absent(),
    Value<int?> parentTaskServerId = const Value.absent(),
    String? name,
    String? content,
    Value<String?> statusName = const Value.absent(),
    int? percentDone,
    Value<String?> planStartDate = const Value.absent(),
    Value<String?> planEndDate = const Value.absent(),
    bool? isMilestone,
    Value<String?> assigneeName = const Value.absent(),
    bool? pending,
  }) => ProjectTaskRow(
    localId: localId ?? this.localId,
    projectLocalId: projectLocalId ?? this.projectLocalId,
    serverId: serverId.present ? serverId.value : this.serverId,
    parentTaskServerId: parentTaskServerId.present
        ? parentTaskServerId.value
        : this.parentTaskServerId,
    name: name ?? this.name,
    content: content ?? this.content,
    statusName: statusName.present ? statusName.value : this.statusName,
    percentDone: percentDone ?? this.percentDone,
    planStartDate: planStartDate.present
        ? planStartDate.value
        : this.planStartDate,
    planEndDate: planEndDate.present ? planEndDate.value : this.planEndDate,
    isMilestone: isMilestone ?? this.isMilestone,
    assigneeName: assigneeName.present ? assigneeName.value : this.assigneeName,
    pending: pending ?? this.pending,
  );
  ProjectTaskRow copyWithCompanion(ProjectTasksCompanion data) {
    return ProjectTaskRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      projectLocalId: data.projectLocalId.present
          ? data.projectLocalId.value
          : this.projectLocalId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      parentTaskServerId: data.parentTaskServerId.present
          ? data.parentTaskServerId.value
          : this.parentTaskServerId,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      statusName: data.statusName.present
          ? data.statusName.value
          : this.statusName,
      percentDone: data.percentDone.present
          ? data.percentDone.value
          : this.percentDone,
      planStartDate: data.planStartDate.present
          ? data.planStartDate.value
          : this.planStartDate,
      planEndDate: data.planEndDate.present
          ? data.planEndDate.value
          : this.planEndDate,
      isMilestone: data.isMilestone.present
          ? data.isMilestone.value
          : this.isMilestone,
      assigneeName: data.assigneeName.present
          ? data.assigneeName.value
          : this.assigneeName,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTaskRow(')
          ..write('localId: $localId, ')
          ..write('projectLocalId: $projectLocalId, ')
          ..write('serverId: $serverId, ')
          ..write('parentTaskServerId: $parentTaskServerId, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('statusName: $statusName, ')
          ..write('percentDone: $percentDone, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('planEndDate: $planEndDate, ')
          ..write('isMilestone: $isMilestone, ')
          ..write('assigneeName: $assigneeName, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    projectLocalId,
    serverId,
    parentTaskServerId,
    name,
    content,
    statusName,
    percentDone,
    planStartDate,
    planEndDate,
    isMilestone,
    assigneeName,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTaskRow &&
          other.localId == this.localId &&
          other.projectLocalId == this.projectLocalId &&
          other.serverId == this.serverId &&
          other.parentTaskServerId == this.parentTaskServerId &&
          other.name == this.name &&
          other.content == this.content &&
          other.statusName == this.statusName &&
          other.percentDone == this.percentDone &&
          other.planStartDate == this.planStartDate &&
          other.planEndDate == this.planEndDate &&
          other.isMilestone == this.isMilestone &&
          other.assigneeName == this.assigneeName &&
          other.pending == this.pending);
}

class ProjectTasksCompanion extends UpdateCompanion<ProjectTaskRow> {
  final Value<String> localId;
  final Value<String> projectLocalId;
  final Value<int?> serverId;
  final Value<int?> parentTaskServerId;
  final Value<String> name;
  final Value<String> content;
  final Value<String?> statusName;
  final Value<int> percentDone;
  final Value<String?> planStartDate;
  final Value<String?> planEndDate;
  final Value<bool> isMilestone;
  final Value<String?> assigneeName;
  final Value<bool> pending;
  final Value<int> rowid;
  const ProjectTasksCompanion({
    this.localId = const Value.absent(),
    this.projectLocalId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.parentTaskServerId = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.statusName = const Value.absent(),
    this.percentDone = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.planEndDate = const Value.absent(),
    this.isMilestone = const Value.absent(),
    this.assigneeName = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectTasksCompanion.insert({
    required String localId,
    required String projectLocalId,
    this.serverId = const Value.absent(),
    this.parentTaskServerId = const Value.absent(),
    required String name,
    this.content = const Value.absent(),
    this.statusName = const Value.absent(),
    this.percentDone = const Value.absent(),
    this.planStartDate = const Value.absent(),
    this.planEndDate = const Value.absent(),
    this.isMilestone = const Value.absent(),
    this.assigneeName = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       projectLocalId = Value(projectLocalId),
       name = Value(name);
  static Insertable<ProjectTaskRow> custom({
    Expression<String>? localId,
    Expression<String>? projectLocalId,
    Expression<int>? serverId,
    Expression<int>? parentTaskServerId,
    Expression<String>? name,
    Expression<String>? content,
    Expression<String>? statusName,
    Expression<int>? percentDone,
    Expression<String>? planStartDate,
    Expression<String>? planEndDate,
    Expression<bool>? isMilestone,
    Expression<String>? assigneeName,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (projectLocalId != null) 'project_local_id': projectLocalId,
      if (serverId != null) 'server_id': serverId,
      if (parentTaskServerId != null)
        'parent_task_server_id': parentTaskServerId,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (statusName != null) 'status_name': statusName,
      if (percentDone != null) 'percent_done': percentDone,
      if (planStartDate != null) 'plan_start_date': planStartDate,
      if (planEndDate != null) 'plan_end_date': planEndDate,
      if (isMilestone != null) 'is_milestone': isMilestone,
      if (assigneeName != null) 'assignee_name': assigneeName,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectTasksCompanion copyWith({
    Value<String>? localId,
    Value<String>? projectLocalId,
    Value<int?>? serverId,
    Value<int?>? parentTaskServerId,
    Value<String>? name,
    Value<String>? content,
    Value<String?>? statusName,
    Value<int>? percentDone,
    Value<String?>? planStartDate,
    Value<String?>? planEndDate,
    Value<bool>? isMilestone,
    Value<String?>? assigneeName,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return ProjectTasksCompanion(
      localId: localId ?? this.localId,
      projectLocalId: projectLocalId ?? this.projectLocalId,
      serverId: serverId ?? this.serverId,
      parentTaskServerId: parentTaskServerId ?? this.parentTaskServerId,
      name: name ?? this.name,
      content: content ?? this.content,
      statusName: statusName ?? this.statusName,
      percentDone: percentDone ?? this.percentDone,
      planStartDate: planStartDate ?? this.planStartDate,
      planEndDate: planEndDate ?? this.planEndDate,
      isMilestone: isMilestone ?? this.isMilestone,
      assigneeName: assigneeName ?? this.assigneeName,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (projectLocalId.present) {
      map['project_local_id'] = Variable<String>(projectLocalId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (parentTaskServerId.present) {
      map['parent_task_server_id'] = Variable<int>(parentTaskServerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (statusName.present) {
      map['status_name'] = Variable<String>(statusName.value);
    }
    if (percentDone.present) {
      map['percent_done'] = Variable<int>(percentDone.value);
    }
    if (planStartDate.present) {
      map['plan_start_date'] = Variable<String>(planStartDate.value);
    }
    if (planEndDate.present) {
      map['plan_end_date'] = Variable<String>(planEndDate.value);
    }
    if (isMilestone.present) {
      map['is_milestone'] = Variable<bool>(isMilestone.value);
    }
    if (assigneeName.present) {
      map['assignee_name'] = Variable<String>(assigneeName.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTasksCompanion(')
          ..write('localId: $localId, ')
          ..write('projectLocalId: $projectLocalId, ')
          ..write('serverId: $serverId, ')
          ..write('parentTaskServerId: $parentTaskServerId, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('statusName: $statusName, ')
          ..write('percentDone: $percentDone, ')
          ..write('planStartDate: $planStartDate, ')
          ..write('planEndDate: $planEndDate, ')
          ..write('isMilestone: $isMilestone, ')
          ..write('assigneeName: $assigneeName, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _beginViewDateMeta = const VerificationMeta(
    'beginViewDate',
  );
  @override
  late final GeneratedColumn<String> beginViewDate = GeneratedColumn<String>(
    'begin_view_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endViewDateMeta = const VerificationMeta(
    'endViewDate',
  );
  @override
  late final GeneratedColumn<String> endViewDate = GeneratedColumn<String>(
    'end_view_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPlannedMeta = const VerificationMeta(
    'isPlanned',
  );
  @override
  late final GeneratedColumn<bool> isPlanned = GeneratedColumn<bool>(
    'is_planned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_planned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _beginMeta = const VerificationMeta('begin');
  @override
  late final GeneratedColumn<String> begin = GeneratedColumn<String>(
    'begin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<String> end = GeneratedColumn<String>(
    'end',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isMineMeta = const VerificationMeta('isMine');
  @override
  late final GeneratedColumn<bool> isMine = GeneratedColumn<bool>(
    'is_mine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mine" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    name,
    content,
    beginViewDate,
    endViewDate,
    isPlanned,
    begin,
    end,
    state,
    isMine,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('begin_view_date')) {
      context.handle(
        _beginViewDateMeta,
        beginViewDate.isAcceptableOrUnknown(
          data['begin_view_date']!,
          _beginViewDateMeta,
        ),
      );
    }
    if (data.containsKey('end_view_date')) {
      context.handle(
        _endViewDateMeta,
        endViewDate.isAcceptableOrUnknown(
          data['end_view_date']!,
          _endViewDateMeta,
        ),
      );
    }
    if (data.containsKey('is_planned')) {
      context.handle(
        _isPlannedMeta,
        isPlanned.isAcceptableOrUnknown(data['is_planned']!, _isPlannedMeta),
      );
    }
    if (data.containsKey('begin')) {
      context.handle(
        _beginMeta,
        begin.isAcceptableOrUnknown(data['begin']!, _beginMeta),
      );
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('is_mine')) {
      context.handle(
        _isMineMeta,
        isMine.isAcceptableOrUnknown(data['is_mine']!, _isMineMeta),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      beginViewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}begin_view_date'],
      ),
      endViewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_view_date'],
      ),
      isPlanned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_planned'],
      )!,
      begin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}begin'],
      ),
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      isMine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mine'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String localId;
  final int? serverId;
  final String name;
  final String content;
  final String? beginViewDate;
  final String? endViewDate;
  final bool isPlanned;
  final String? begin;
  final String? end;
  final int state;
  final bool isMine;
  final bool pending;
  const ReminderRow({
    required this.localId,
    this.serverId,
    required this.name,
    required this.content,
    this.beginViewDate,
    this.endViewDate,
    required this.isPlanned,
    this.begin,
    this.end,
    required this.state,
    required this.isMine,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || beginViewDate != null) {
      map['begin_view_date'] = Variable<String>(beginViewDate);
    }
    if (!nullToAbsent || endViewDate != null) {
      map['end_view_date'] = Variable<String>(endViewDate);
    }
    map['is_planned'] = Variable<bool>(isPlanned);
    if (!nullToAbsent || begin != null) {
      map['begin'] = Variable<String>(begin);
    }
    if (!nullToAbsent || end != null) {
      map['end'] = Variable<String>(end);
    }
    map['state'] = Variable<int>(state);
    map['is_mine'] = Variable<bool>(isMine);
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      name: Value(name),
      content: Value(content),
      beginViewDate: beginViewDate == null && nullToAbsent
          ? const Value.absent()
          : Value(beginViewDate),
      endViewDate: endViewDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endViewDate),
      isPlanned: Value(isPlanned),
      begin: begin == null && nullToAbsent
          ? const Value.absent()
          : Value(begin),
      end: end == null && nullToAbsent ? const Value.absent() : Value(end),
      state: Value(state),
      isMine: Value(isMine),
      pending: Value(pending),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
      beginViewDate: serializer.fromJson<String?>(json['beginViewDate']),
      endViewDate: serializer.fromJson<String?>(json['endViewDate']),
      isPlanned: serializer.fromJson<bool>(json['isPlanned']),
      begin: serializer.fromJson<String?>(json['begin']),
      end: serializer.fromJson<String?>(json['end']),
      state: serializer.fromJson<int>(json['state']),
      isMine: serializer.fromJson<bool>(json['isMine']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
      'beginViewDate': serializer.toJson<String?>(beginViewDate),
      'endViewDate': serializer.toJson<String?>(endViewDate),
      'isPlanned': serializer.toJson<bool>(isPlanned),
      'begin': serializer.toJson<String?>(begin),
      'end': serializer.toJson<String?>(end),
      'state': serializer.toJson<int>(state),
      'isMine': serializer.toJson<bool>(isMine),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  ReminderRow copyWith({
    String? localId,
    Value<int?> serverId = const Value.absent(),
    String? name,
    String? content,
    Value<String?> beginViewDate = const Value.absent(),
    Value<String?> endViewDate = const Value.absent(),
    bool? isPlanned,
    Value<String?> begin = const Value.absent(),
    Value<String?> end = const Value.absent(),
    int? state,
    bool? isMine,
    bool? pending,
  }) => ReminderRow(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    name: name ?? this.name,
    content: content ?? this.content,
    beginViewDate: beginViewDate.present
        ? beginViewDate.value
        : this.beginViewDate,
    endViewDate: endViewDate.present ? endViewDate.value : this.endViewDate,
    isPlanned: isPlanned ?? this.isPlanned,
    begin: begin.present ? begin.value : this.begin,
    end: end.present ? end.value : this.end,
    state: state ?? this.state,
    isMine: isMine ?? this.isMine,
    pending: pending ?? this.pending,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      beginViewDate: data.beginViewDate.present
          ? data.beginViewDate.value
          : this.beginViewDate,
      endViewDate: data.endViewDate.present
          ? data.endViewDate.value
          : this.endViewDate,
      isPlanned: data.isPlanned.present ? data.isPlanned.value : this.isPlanned,
      begin: data.begin.present ? data.begin.value : this.begin,
      end: data.end.present ? data.end.value : this.end,
      state: data.state.present ? data.state.value : this.state,
      isMine: data.isMine.present ? data.isMine.value : this.isMine,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('beginViewDate: $beginViewDate, ')
          ..write('endViewDate: $endViewDate, ')
          ..write('isPlanned: $isPlanned, ')
          ..write('begin: $begin, ')
          ..write('end: $end, ')
          ..write('state: $state, ')
          ..write('isMine: $isMine, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    name,
    content,
    beginViewDate,
    endViewDate,
    isPlanned,
    begin,
    end,
    state,
    isMine,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.content == this.content &&
          other.beginViewDate == this.beginViewDate &&
          other.endViewDate == this.endViewDate &&
          other.isPlanned == this.isPlanned &&
          other.begin == this.begin &&
          other.end == this.end &&
          other.state == this.state &&
          other.isMine == this.isMine &&
          other.pending == this.pending);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<String> name;
  final Value<String> content;
  final Value<String?> beginViewDate;
  final Value<String?> endViewDate;
  final Value<bool> isPlanned;
  final Value<String?> begin;
  final Value<String?> end;
  final Value<int> state;
  final Value<bool> isMine;
  final Value<bool> pending;
  final Value<int> rowid;
  const RemindersCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.beginViewDate = const Value.absent(),
    this.endViewDate = const Value.absent(),
    this.isPlanned = const Value.absent(),
    this.begin = const Value.absent(),
    this.end = const Value.absent(),
    this.state = const Value.absent(),
    this.isMine = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String name,
    this.content = const Value.absent(),
    this.beginViewDate = const Value.absent(),
    this.endViewDate = const Value.absent(),
    this.isPlanned = const Value.absent(),
    this.begin = const Value.absent(),
    this.end = const Value.absent(),
    this.state = const Value.absent(),
    this.isMine = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       name = Value(name);
  static Insertable<ReminderRow> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<String>? content,
    Expression<String>? beginViewDate,
    Expression<String>? endViewDate,
    Expression<bool>? isPlanned,
    Expression<String>? begin,
    Expression<String>? end,
    Expression<int>? state,
    Expression<bool>? isMine,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (beginViewDate != null) 'begin_view_date': beginViewDate,
      if (endViewDate != null) 'end_view_date': endViewDate,
      if (isPlanned != null) 'is_planned': isPlanned,
      if (begin != null) 'begin': begin,
      if (end != null) 'end': end,
      if (state != null) 'state': state,
      if (isMine != null) 'is_mine': isMine,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? localId,
    Value<int?>? serverId,
    Value<String>? name,
    Value<String>? content,
    Value<String?>? beginViewDate,
    Value<String?>? endViewDate,
    Value<bool>? isPlanned,
    Value<String?>? begin,
    Value<String?>? end,
    Value<int>? state,
    Value<bool>? isMine,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      content: content ?? this.content,
      beginViewDate: beginViewDate ?? this.beginViewDate,
      endViewDate: endViewDate ?? this.endViewDate,
      isPlanned: isPlanned ?? this.isPlanned,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      state: state ?? this.state,
      isMine: isMine ?? this.isMine,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (beginViewDate.present) {
      map['begin_view_date'] = Variable<String>(beginViewDate.value);
    }
    if (endViewDate.present) {
      map['end_view_date'] = Variable<String>(endViewDate.value);
    }
    if (isPlanned.present) {
      map['is_planned'] = Variable<bool>(isPlanned.value);
    }
    if (begin.present) {
      map['begin'] = Variable<String>(begin.value);
    }
    if (end.present) {
      map['end'] = Variable<String>(end.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (isMine.present) {
      map['is_mine'] = Variable<bool>(isMine.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('beginViewDate: $beginViewDate, ')
          ..write('endViewDate: $endViewDate, ')
          ..write('isPlanned: $isPlanned, ')
          ..write('begin: $begin, ')
          ..write('end: $end, ')
          ..write('state: $state, ')
          ..write('isMine: $isMine, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KbCategoriesTable extends KbCategories
    with TableInfo<$KbCategoriesTable, KbCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KbCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completenameMeta = const VerificationMeta(
    'completename',
  );
  @override
  late final GeneratedColumn<String> completename = GeneratedColumn<String>(
    'completename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [serverId, name, completename];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kb_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<KbCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('completename')) {
      context.handle(
        _completenameMeta,
        completename.isAcceptableOrUnknown(
          data['completename']!,
          _completenameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  KbCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KbCategoryRow(
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      completename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completename'],
      )!,
    );
  }

  @override
  $KbCategoriesTable createAlias(String alias) {
    return $KbCategoriesTable(attachedDatabase, alias);
  }
}

class KbCategoryRow extends DataClass implements Insertable<KbCategoryRow> {
  final int serverId;
  final String name;
  final String completename;
  const KbCategoryRow({
    required this.serverId,
    required this.name,
    required this.completename,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<int>(serverId);
    map['name'] = Variable<String>(name);
    map['completename'] = Variable<String>(completename);
    return map;
  }

  KbCategoriesCompanion toCompanion(bool nullToAbsent) {
    return KbCategoriesCompanion(
      serverId: Value(serverId),
      name: Value(name),
      completename: Value(completename),
    );
  }

  factory KbCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KbCategoryRow(
      serverId: serializer.fromJson<int>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      completename: serializer.fromJson<String>(json['completename']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<int>(serverId),
      'name': serializer.toJson<String>(name),
      'completename': serializer.toJson<String>(completename),
    };
  }

  KbCategoryRow copyWith({int? serverId, String? name, String? completename}) =>
      KbCategoryRow(
        serverId: serverId ?? this.serverId,
        name: name ?? this.name,
        completename: completename ?? this.completename,
      );
  KbCategoryRow copyWithCompanion(KbCategoriesCompanion data) {
    return KbCategoryRow(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      completename: data.completename.present
          ? data.completename.value
          : this.completename,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KbCategoryRow(')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('completename: $completename')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serverId, name, completename);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KbCategoryRow &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.completename == this.completename);
}

class KbCategoriesCompanion extends UpdateCompanion<KbCategoryRow> {
  final Value<int> serverId;
  final Value<String> name;
  final Value<String> completename;
  const KbCategoriesCompanion({
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.completename = const Value.absent(),
  });
  KbCategoriesCompanion.insert({
    this.serverId = const Value.absent(),
    required String name,
    this.completename = const Value.absent(),
  }) : name = Value(name);
  static Insertable<KbCategoryRow> custom({
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<String>? completename,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (completename != null) 'completename': completename,
    });
  }

  KbCategoriesCompanion copyWith({
    Value<int>? serverId,
    Value<String>? name,
    Value<String>? completename,
  }) {
    return KbCategoriesCompanion(
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      completename: completename ?? this.completename,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (completename.present) {
      map['completename'] = Variable<String>(completename.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KbCategoriesCompanion(')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('completename: $completename')
          ..write(')'))
        .toString();
  }
}

class $KbArticlesTable extends KbArticles
    with TableInfo<$KbArticlesTable, KbArticleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KbArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHtmlMeta = const VerificationMeta(
    'contentHtml',
  );
  @override
  late final GeneratedColumn<String> contentHtml = GeneratedColumn<String>(
    'content_html',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFaqMeta = const VerificationMeta('isFaq');
  @override
  late final GeneratedColumn<bool> isFaq = GeneratedColumn<bool>(
    'is_faq',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_faq" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _viewsMeta = const VerificationMeta('views');
  @override
  late final GeneratedColumn<int> views = GeneratedColumn<int>(
    'views',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateModMeta = const VerificationMeta(
    'dateMod',
  );
  @override
  late final GeneratedColumn<String> dateMod = GeneratedColumn<String>(
    'date_mod',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keepOfflineMeta = const VerificationMeta(
    'keepOffline',
  );
  @override
  late final GeneratedColumn<bool> keepOffline = GeneratedColumn<bool>(
    'keep_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverId,
    name,
    contentHtml,
    categoryId,
    categoryName,
    isFaq,
    views,
    dateMod,
    keepOffline,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kb_articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<KbArticleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content_html')) {
      context.handle(
        _contentHtmlMeta,
        contentHtml.isAcceptableOrUnknown(
          data['content_html']!,
          _contentHtmlMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('is_faq')) {
      context.handle(
        _isFaqMeta,
        isFaq.isAcceptableOrUnknown(data['is_faq']!, _isFaqMeta),
      );
    }
    if (data.containsKey('views')) {
      context.handle(
        _viewsMeta,
        views.isAcceptableOrUnknown(data['views']!, _viewsMeta),
      );
    }
    if (data.containsKey('date_mod')) {
      context.handle(
        _dateModMeta,
        dateMod.isAcceptableOrUnknown(data['date_mod']!, _dateModMeta),
      );
    }
    if (data.containsKey('keep_offline')) {
      context.handle(
        _keepOfflineMeta,
        keepOffline.isAcceptableOrUnknown(
          data['keep_offline']!,
          _keepOfflineMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId};
  @override
  KbArticleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KbArticleRow(
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contentHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_html'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
      isFaq: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_faq'],
      )!,
      views: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}views'],
      )!,
      dateMod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_mod'],
      ),
      keepOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_offline'],
      )!,
    );
  }

  @override
  $KbArticlesTable createAlias(String alias) {
    return $KbArticlesTable(attachedDatabase, alias);
  }
}

class KbArticleRow extends DataClass implements Insertable<KbArticleRow> {
  final int serverId;
  final String name;
  final String contentHtml;
  final int? categoryId;
  final String? categoryName;
  final bool isFaq;
  final int views;
  final String? dateMod;

  /// Set when the user pinned it for offline reading.
  final bool keepOffline;
  const KbArticleRow({
    required this.serverId,
    required this.name,
    required this.contentHtml,
    this.categoryId,
    this.categoryName,
    required this.isFaq,
    required this.views,
    this.dateMod,
    required this.keepOffline,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<int>(serverId);
    map['name'] = Variable<String>(name);
    map['content_html'] = Variable<String>(contentHtml);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    map['is_faq'] = Variable<bool>(isFaq);
    map['views'] = Variable<int>(views);
    if (!nullToAbsent || dateMod != null) {
      map['date_mod'] = Variable<String>(dateMod);
    }
    map['keep_offline'] = Variable<bool>(keepOffline);
    return map;
  }

  KbArticlesCompanion toCompanion(bool nullToAbsent) {
    return KbArticlesCompanion(
      serverId: Value(serverId),
      name: Value(name),
      contentHtml: Value(contentHtml),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      isFaq: Value(isFaq),
      views: Value(views),
      dateMod: dateMod == null && nullToAbsent
          ? const Value.absent()
          : Value(dateMod),
      keepOffline: Value(keepOffline),
    );
  }

  factory KbArticleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KbArticleRow(
      serverId: serializer.fromJson<int>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      contentHtml: serializer.fromJson<String>(json['contentHtml']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      isFaq: serializer.fromJson<bool>(json['isFaq']),
      views: serializer.fromJson<int>(json['views']),
      dateMod: serializer.fromJson<String?>(json['dateMod']),
      keepOffline: serializer.fromJson<bool>(json['keepOffline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<int>(serverId),
      'name': serializer.toJson<String>(name),
      'contentHtml': serializer.toJson<String>(contentHtml),
      'categoryId': serializer.toJson<int?>(categoryId),
      'categoryName': serializer.toJson<String?>(categoryName),
      'isFaq': serializer.toJson<bool>(isFaq),
      'views': serializer.toJson<int>(views),
      'dateMod': serializer.toJson<String?>(dateMod),
      'keepOffline': serializer.toJson<bool>(keepOffline),
    };
  }

  KbArticleRow copyWith({
    int? serverId,
    String? name,
    String? contentHtml,
    Value<int?> categoryId = const Value.absent(),
    Value<String?> categoryName = const Value.absent(),
    bool? isFaq,
    int? views,
    Value<String?> dateMod = const Value.absent(),
    bool? keepOffline,
  }) => KbArticleRow(
    serverId: serverId ?? this.serverId,
    name: name ?? this.name,
    contentHtml: contentHtml ?? this.contentHtml,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
    isFaq: isFaq ?? this.isFaq,
    views: views ?? this.views,
    dateMod: dateMod.present ? dateMod.value : this.dateMod,
    keepOffline: keepOffline ?? this.keepOffline,
  );
  KbArticleRow copyWithCompanion(KbArticlesCompanion data) {
    return KbArticleRow(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      contentHtml: data.contentHtml.present
          ? data.contentHtml.value
          : this.contentHtml,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      isFaq: data.isFaq.present ? data.isFaq.value : this.isFaq,
      views: data.views.present ? data.views.value : this.views,
      dateMod: data.dateMod.present ? data.dateMod.value : this.dateMod,
      keepOffline: data.keepOffline.present
          ? data.keepOffline.value
          : this.keepOffline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KbArticleRow(')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('isFaq: $isFaq, ')
          ..write('views: $views, ')
          ..write('dateMod: $dateMod, ')
          ..write('keepOffline: $keepOffline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverId,
    name,
    contentHtml,
    categoryId,
    categoryName,
    isFaq,
    views,
    dateMod,
    keepOffline,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KbArticleRow &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.contentHtml == this.contentHtml &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.isFaq == this.isFaq &&
          other.views == this.views &&
          other.dateMod == this.dateMod &&
          other.keepOffline == this.keepOffline);
}

class KbArticlesCompanion extends UpdateCompanion<KbArticleRow> {
  final Value<int> serverId;
  final Value<String> name;
  final Value<String> contentHtml;
  final Value<int?> categoryId;
  final Value<String?> categoryName;
  final Value<bool> isFaq;
  final Value<int> views;
  final Value<String?> dateMod;
  final Value<bool> keepOffline;
  const KbArticlesCompanion({
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.isFaq = const Value.absent(),
    this.views = const Value.absent(),
    this.dateMod = const Value.absent(),
    this.keepOffline = const Value.absent(),
  });
  KbArticlesCompanion.insert({
    this.serverId = const Value.absent(),
    required String name,
    this.contentHtml = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.isFaq = const Value.absent(),
    this.views = const Value.absent(),
    this.dateMod = const Value.absent(),
    this.keepOffline = const Value.absent(),
  }) : name = Value(name);
  static Insertable<KbArticleRow> custom({
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<String>? contentHtml,
    Expression<int>? categoryId,
    Expression<String>? categoryName,
    Expression<bool>? isFaq,
    Expression<int>? views,
    Expression<String>? dateMod,
    Expression<bool>? keepOffline,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (contentHtml != null) 'content_html': contentHtml,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (isFaq != null) 'is_faq': isFaq,
      if (views != null) 'views': views,
      if (dateMod != null) 'date_mod': dateMod,
      if (keepOffline != null) 'keep_offline': keepOffline,
    });
  }

  KbArticlesCompanion copyWith({
    Value<int>? serverId,
    Value<String>? name,
    Value<String>? contentHtml,
    Value<int?>? categoryId,
    Value<String?>? categoryName,
    Value<bool>? isFaq,
    Value<int>? views,
    Value<String?>? dateMod,
    Value<bool>? keepOffline,
  }) {
    return KbArticlesCompanion(
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      contentHtml: contentHtml ?? this.contentHtml,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isFaq: isFaq ?? this.isFaq,
      views: views ?? this.views,
      dateMod: dateMod ?? this.dateMod,
      keepOffline: keepOffline ?? this.keepOffline,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contentHtml.present) {
      map['content_html'] = Variable<String>(contentHtml.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (isFaq.present) {
      map['is_faq'] = Variable<bool>(isFaq.value);
    }
    if (views.present) {
      map['views'] = Variable<int>(views.value);
    }
    if (dateMod.present) {
      map['date_mod'] = Variable<String>(dateMod.value);
    }
    if (keepOffline.present) {
      map['keep_offline'] = Variable<bool>(keepOffline.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KbArticlesCompanion(')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('isFaq: $isFaq, ')
          ..write('views: $views, ')
          ..write('dateMod: $dateMod, ')
          ..write('keepOffline: $keepOffline')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemtypeMeta = const VerificationMeta(
    'itemtype',
  );
  @override
  late final GeneratedColumn<String> itemtype = GeneratedColumn<String>(
    'itemtype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
    'serial',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherserialMeta = const VerificationMeta(
    'otherserial',
  );
  @override
  late final GeneratedColumn<String> otherserial = GeneratedColumn<String>(
    'otherserial',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusNameMeta = const VerificationMeta(
    'statusName',
  );
  @override
  late final GeneratedColumn<String> statusName = GeneratedColumn<String>(
    'status_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manufacturerNameMeta = const VerificationMeta(
    'manufacturerName',
  );
  @override
  late final GeneratedColumn<String> manufacturerName = GeneratedColumn<String>(
    'manufacturer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeNameMeta = const VerificationMeta(
    'typeName',
  );
  @override
  late final GeneratedColumn<String> typeName = GeneratedColumn<String>(
    'type_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityLabelMeta = const VerificationMeta(
    'entityLabel',
  );
  @override
  late final GeneratedColumn<String> entityLabel = GeneratedColumn<String>(
    'entity_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<String> expiryDate = GeneratedColumn<String>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateModMeta = const VerificationMeta(
    'dateMod',
  );
  @override
  late final GeneratedColumn<String> dateMod = GeneratedColumn<String>(
    'date_mod',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldsJsonMeta = const VerificationMeta(
    'fieldsJson',
  );
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
    'fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    domain,
    itemtype,
    serverId,
    name,
    serial,
    otherserial,
    statusName,
    locationName,
    userName,
    groupName,
    manufacturerName,
    modelName,
    typeName,
    entityLabel,
    expiryDate,
    dateMod,
    fieldsJson,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('itemtype')) {
      context.handle(
        _itemtypeMeta,
        itemtype.isAcceptableOrUnknown(data['itemtype']!, _itemtypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemtypeMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['serial']!, _serialMeta),
      );
    }
    if (data.containsKey('otherserial')) {
      context.handle(
        _otherserialMeta,
        otherserial.isAcceptableOrUnknown(
          data['otherserial']!,
          _otherserialMeta,
        ),
      );
    }
    if (data.containsKey('status_name')) {
      context.handle(
        _statusNameMeta,
        statusName.isAcceptableOrUnknown(data['status_name']!, _statusNameMeta),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    if (data.containsKey('manufacturer_name')) {
      context.handle(
        _manufacturerNameMeta,
        manufacturerName.isAcceptableOrUnknown(
          data['manufacturer_name']!,
          _manufacturerNameMeta,
        ),
      );
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    }
    if (data.containsKey('type_name')) {
      context.handle(
        _typeNameMeta,
        typeName.isAcceptableOrUnknown(data['type_name']!, _typeNameMeta),
      );
    }
    if (data.containsKey('entity_label')) {
      context.handle(
        _entityLabelMeta,
        entityLabel.isAcceptableOrUnknown(
          data['entity_label']!,
          _entityLabelMeta,
        ),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('date_mod')) {
      context.handle(
        _dateModMeta,
        dateMod.isAcceptableOrUnknown(data['date_mod']!, _dateModMeta),
      );
    }
    if (data.containsKey('fields_json')) {
      context.handle(
        _fieldsJsonMeta,
        fieldsJson.isAcceptableOrUnknown(data['fields_json']!, _fieldsJsonMeta),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  CatalogItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItemRow(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      itemtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}itemtype'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial'],
      ),
      otherserial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}otherserial'],
      ),
      statusName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_name'],
      ),
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      ),
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
      manufacturerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer_name'],
      ),
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      ),
      typeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_name'],
      ),
      entityLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_label'],
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expiry_date'],
      ),
      dateMod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_mod'],
      ),
      fieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_json'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItemRow extends DataClass implements Insertable<CatalogItemRow> {
  final String localId;

  /// 'assets' or 'management' — which browser owns the row.
  final String domain;
  final String itemtype;
  final int serverId;
  final String name;
  final String? serial;
  final String? otherserial;
  final String? statusName;
  final String? locationName;
  final String? userName;
  final String? groupName;
  final String? manufacturerName;
  final String? modelName;
  final String? typeName;
  final String? entityLabel;

  /// Whichever date drives this itemtype's expiry badge (contracts, certs…).
  final String? expiryDate;
  final String? dateMod;
  final String fieldsJson;
  final bool pending;
  const CatalogItemRow({
    required this.localId,
    required this.domain,
    required this.itemtype,
    required this.serverId,
    required this.name,
    this.serial,
    this.otherserial,
    this.statusName,
    this.locationName,
    this.userName,
    this.groupName,
    this.manufacturerName,
    this.modelName,
    this.typeName,
    this.entityLabel,
    this.expiryDate,
    this.dateMod,
    required this.fieldsJson,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['domain'] = Variable<String>(domain);
    map['itemtype'] = Variable<String>(itemtype);
    map['server_id'] = Variable<int>(serverId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || serial != null) {
      map['serial'] = Variable<String>(serial);
    }
    if (!nullToAbsent || otherserial != null) {
      map['otherserial'] = Variable<String>(otherserial);
    }
    if (!nullToAbsent || statusName != null) {
      map['status_name'] = Variable<String>(statusName);
    }
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    if (!nullToAbsent || manufacturerName != null) {
      map['manufacturer_name'] = Variable<String>(manufacturerName);
    }
    if (!nullToAbsent || modelName != null) {
      map['model_name'] = Variable<String>(modelName);
    }
    if (!nullToAbsent || typeName != null) {
      map['type_name'] = Variable<String>(typeName);
    }
    if (!nullToAbsent || entityLabel != null) {
      map['entity_label'] = Variable<String>(entityLabel);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<String>(expiryDate);
    }
    if (!nullToAbsent || dateMod != null) {
      map['date_mod'] = Variable<String>(dateMod);
    }
    map['fields_json'] = Variable<String>(fieldsJson);
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      localId: Value(localId),
      domain: Value(domain),
      itemtype: Value(itemtype),
      serverId: Value(serverId),
      name: Value(name),
      serial: serial == null && nullToAbsent
          ? const Value.absent()
          : Value(serial),
      otherserial: otherserial == null && nullToAbsent
          ? const Value.absent()
          : Value(otherserial),
      statusName: statusName == null && nullToAbsent
          ? const Value.absent()
          : Value(statusName),
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      manufacturerName: manufacturerName == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturerName),
      modelName: modelName == null && nullToAbsent
          ? const Value.absent()
          : Value(modelName),
      typeName: typeName == null && nullToAbsent
          ? const Value.absent()
          : Value(typeName),
      entityLabel: entityLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(entityLabel),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      dateMod: dateMod == null && nullToAbsent
          ? const Value.absent()
          : Value(dateMod),
      fieldsJson: Value(fieldsJson),
      pending: Value(pending),
    );
  }

  factory CatalogItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItemRow(
      localId: serializer.fromJson<String>(json['localId']),
      domain: serializer.fromJson<String>(json['domain']),
      itemtype: serializer.fromJson<String>(json['itemtype']),
      serverId: serializer.fromJson<int>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      serial: serializer.fromJson<String?>(json['serial']),
      otherserial: serializer.fromJson<String?>(json['otherserial']),
      statusName: serializer.fromJson<String?>(json['statusName']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      userName: serializer.fromJson<String?>(json['userName']),
      groupName: serializer.fromJson<String?>(json['groupName']),
      manufacturerName: serializer.fromJson<String?>(json['manufacturerName']),
      modelName: serializer.fromJson<String?>(json['modelName']),
      typeName: serializer.fromJson<String?>(json['typeName']),
      entityLabel: serializer.fromJson<String?>(json['entityLabel']),
      expiryDate: serializer.fromJson<String?>(json['expiryDate']),
      dateMod: serializer.fromJson<String?>(json['dateMod']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'domain': serializer.toJson<String>(domain),
      'itemtype': serializer.toJson<String>(itemtype),
      'serverId': serializer.toJson<int>(serverId),
      'name': serializer.toJson<String>(name),
      'serial': serializer.toJson<String?>(serial),
      'otherserial': serializer.toJson<String?>(otherserial),
      'statusName': serializer.toJson<String?>(statusName),
      'locationName': serializer.toJson<String?>(locationName),
      'userName': serializer.toJson<String?>(userName),
      'groupName': serializer.toJson<String?>(groupName),
      'manufacturerName': serializer.toJson<String?>(manufacturerName),
      'modelName': serializer.toJson<String?>(modelName),
      'typeName': serializer.toJson<String?>(typeName),
      'entityLabel': serializer.toJson<String?>(entityLabel),
      'expiryDate': serializer.toJson<String?>(expiryDate),
      'dateMod': serializer.toJson<String?>(dateMod),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  CatalogItemRow copyWith({
    String? localId,
    String? domain,
    String? itemtype,
    int? serverId,
    String? name,
    Value<String?> serial = const Value.absent(),
    Value<String?> otherserial = const Value.absent(),
    Value<String?> statusName = const Value.absent(),
    Value<String?> locationName = const Value.absent(),
    Value<String?> userName = const Value.absent(),
    Value<String?> groupName = const Value.absent(),
    Value<String?> manufacturerName = const Value.absent(),
    Value<String?> modelName = const Value.absent(),
    Value<String?> typeName = const Value.absent(),
    Value<String?> entityLabel = const Value.absent(),
    Value<String?> expiryDate = const Value.absent(),
    Value<String?> dateMod = const Value.absent(),
    String? fieldsJson,
    bool? pending,
  }) => CatalogItemRow(
    localId: localId ?? this.localId,
    domain: domain ?? this.domain,
    itemtype: itemtype ?? this.itemtype,
    serverId: serverId ?? this.serverId,
    name: name ?? this.name,
    serial: serial.present ? serial.value : this.serial,
    otherserial: otherserial.present ? otherserial.value : this.otherserial,
    statusName: statusName.present ? statusName.value : this.statusName,
    locationName: locationName.present ? locationName.value : this.locationName,
    userName: userName.present ? userName.value : this.userName,
    groupName: groupName.present ? groupName.value : this.groupName,
    manufacturerName: manufacturerName.present
        ? manufacturerName.value
        : this.manufacturerName,
    modelName: modelName.present ? modelName.value : this.modelName,
    typeName: typeName.present ? typeName.value : this.typeName,
    entityLabel: entityLabel.present ? entityLabel.value : this.entityLabel,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    dateMod: dateMod.present ? dateMod.value : this.dateMod,
    fieldsJson: fieldsJson ?? this.fieldsJson,
    pending: pending ?? this.pending,
  );
  CatalogItemRow copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItemRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      domain: data.domain.present ? data.domain.value : this.domain,
      itemtype: data.itemtype.present ? data.itemtype.value : this.itemtype,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      serial: data.serial.present ? data.serial.value : this.serial,
      otherserial: data.otherserial.present
          ? data.otherserial.value
          : this.otherserial,
      statusName: data.statusName.present
          ? data.statusName.value
          : this.statusName,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      userName: data.userName.present ? data.userName.value : this.userName,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      manufacturerName: data.manufacturerName.present
          ? data.manufacturerName.value
          : this.manufacturerName,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      typeName: data.typeName.present ? data.typeName.value : this.typeName,
      entityLabel: data.entityLabel.present
          ? data.entityLabel.value
          : this.entityLabel,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      dateMod: data.dateMod.present ? data.dateMod.value : this.dateMod,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemRow(')
          ..write('localId: $localId, ')
          ..write('domain: $domain, ')
          ..write('itemtype: $itemtype, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('serial: $serial, ')
          ..write('otherserial: $otherserial, ')
          ..write('statusName: $statusName, ')
          ..write('locationName: $locationName, ')
          ..write('userName: $userName, ')
          ..write('groupName: $groupName, ')
          ..write('manufacturerName: $manufacturerName, ')
          ..write('modelName: $modelName, ')
          ..write('typeName: $typeName, ')
          ..write('entityLabel: $entityLabel, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('dateMod: $dateMod, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    domain,
    itemtype,
    serverId,
    name,
    serial,
    otherserial,
    statusName,
    locationName,
    userName,
    groupName,
    manufacturerName,
    modelName,
    typeName,
    entityLabel,
    expiryDate,
    dateMod,
    fieldsJson,
    pending,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItemRow &&
          other.localId == this.localId &&
          other.domain == this.domain &&
          other.itemtype == this.itemtype &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.serial == this.serial &&
          other.otherserial == this.otherserial &&
          other.statusName == this.statusName &&
          other.locationName == this.locationName &&
          other.userName == this.userName &&
          other.groupName == this.groupName &&
          other.manufacturerName == this.manufacturerName &&
          other.modelName == this.modelName &&
          other.typeName == this.typeName &&
          other.entityLabel == this.entityLabel &&
          other.expiryDate == this.expiryDate &&
          other.dateMod == this.dateMod &&
          other.fieldsJson == this.fieldsJson &&
          other.pending == this.pending);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItemRow> {
  final Value<String> localId;
  final Value<String> domain;
  final Value<String> itemtype;
  final Value<int> serverId;
  final Value<String> name;
  final Value<String?> serial;
  final Value<String?> otherserial;
  final Value<String?> statusName;
  final Value<String?> locationName;
  final Value<String?> userName;
  final Value<String?> groupName;
  final Value<String?> manufacturerName;
  final Value<String?> modelName;
  final Value<String?> typeName;
  final Value<String?> entityLabel;
  final Value<String?> expiryDate;
  final Value<String?> dateMod;
  final Value<String> fieldsJson;
  final Value<bool> pending;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.localId = const Value.absent(),
    this.domain = const Value.absent(),
    this.itemtype = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.serial = const Value.absent(),
    this.otherserial = const Value.absent(),
    this.statusName = const Value.absent(),
    this.locationName = const Value.absent(),
    this.userName = const Value.absent(),
    this.groupName = const Value.absent(),
    this.manufacturerName = const Value.absent(),
    this.modelName = const Value.absent(),
    this.typeName = const Value.absent(),
    this.entityLabel = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.dateMod = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required String localId,
    required String domain,
    required String itemtype,
    required int serverId,
    this.name = const Value.absent(),
    this.serial = const Value.absent(),
    this.otherserial = const Value.absent(),
    this.statusName = const Value.absent(),
    this.locationName = const Value.absent(),
    this.userName = const Value.absent(),
    this.groupName = const Value.absent(),
    this.manufacturerName = const Value.absent(),
    this.modelName = const Value.absent(),
    this.typeName = const Value.absent(),
    this.entityLabel = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.dateMod = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       domain = Value(domain),
       itemtype = Value(itemtype),
       serverId = Value(serverId);
  static Insertable<CatalogItemRow> custom({
    Expression<String>? localId,
    Expression<String>? domain,
    Expression<String>? itemtype,
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<String>? serial,
    Expression<String>? otherserial,
    Expression<String>? statusName,
    Expression<String>? locationName,
    Expression<String>? userName,
    Expression<String>? groupName,
    Expression<String>? manufacturerName,
    Expression<String>? modelName,
    Expression<String>? typeName,
    Expression<String>? entityLabel,
    Expression<String>? expiryDate,
    Expression<String>? dateMod,
    Expression<String>? fieldsJson,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (domain != null) 'domain': domain,
      if (itemtype != null) 'itemtype': itemtype,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (serial != null) 'serial': serial,
      if (otherserial != null) 'otherserial': otherserial,
      if (statusName != null) 'status_name': statusName,
      if (locationName != null) 'location_name': locationName,
      if (userName != null) 'user_name': userName,
      if (groupName != null) 'group_name': groupName,
      if (manufacturerName != null) 'manufacturer_name': manufacturerName,
      if (modelName != null) 'model_name': modelName,
      if (typeName != null) 'type_name': typeName,
      if (entityLabel != null) 'entity_label': entityLabel,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (dateMod != null) 'date_mod': dateMod,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith({
    Value<String>? localId,
    Value<String>? domain,
    Value<String>? itemtype,
    Value<int>? serverId,
    Value<String>? name,
    Value<String?>? serial,
    Value<String?>? otherserial,
    Value<String?>? statusName,
    Value<String?>? locationName,
    Value<String?>? userName,
    Value<String?>? groupName,
    Value<String?>? manufacturerName,
    Value<String?>? modelName,
    Value<String?>? typeName,
    Value<String?>? entityLabel,
    Value<String?>? expiryDate,
    Value<String?>? dateMod,
    Value<String>? fieldsJson,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return CatalogItemsCompanion(
      localId: localId ?? this.localId,
      domain: domain ?? this.domain,
      itemtype: itemtype ?? this.itemtype,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      serial: serial ?? this.serial,
      otherserial: otherserial ?? this.otherserial,
      statusName: statusName ?? this.statusName,
      locationName: locationName ?? this.locationName,
      userName: userName ?? this.userName,
      groupName: groupName ?? this.groupName,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      modelName: modelName ?? this.modelName,
      typeName: typeName ?? this.typeName,
      entityLabel: entityLabel ?? this.entityLabel,
      expiryDate: expiryDate ?? this.expiryDate,
      dateMod: dateMod ?? this.dateMod,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (itemtype.present) {
      map['itemtype'] = Variable<String>(itemtype.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (serial.present) {
      map['serial'] = Variable<String>(serial.value);
    }
    if (otherserial.present) {
      map['otherserial'] = Variable<String>(otherserial.value);
    }
    if (statusName.present) {
      map['status_name'] = Variable<String>(statusName.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (manufacturerName.present) {
      map['manufacturer_name'] = Variable<String>(manufacturerName.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (typeName.present) {
      map['type_name'] = Variable<String>(typeName.value);
    }
    if (entityLabel.present) {
      map['entity_label'] = Variable<String>(entityLabel.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<String>(expiryDate.value);
    }
    if (dateMod.present) {
      map['date_mod'] = Variable<String>(dateMod.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('localId: $localId, ')
          ..write('domain: $domain, ')
          ..write('itemtype: $itemtype, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('serial: $serial, ')
          ..write('otherserial: $otherserial, ')
          ..write('statusName: $statusName, ')
          ..write('locationName: $locationName, ')
          ..write('userName: $userName, ')
          ..write('groupName: $groupName, ')
          ..write('manufacturerName: $manufacturerName, ')
          ..write('modelName: $modelName, ')
          ..write('typeName: $typeName, ')
          ..write('entityLabel: $entityLabel, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('dateMod: $dateMod, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TicketsTable tickets = $TicketsTable(this);
  late final $TicketTeamTable ticketTeam = $TicketTeamTable(this);
  late final $TimelineItemsTable timelineItems = $TimelineItemsTable(this);
  late final $DropdownItemsTable dropdownItems = $DropdownItemsTable(this);
  late final $PendingOpsTable pendingOps = $PendingOpsTable(this);
  late final $ActiveTimersTable activeTimers = $ActiveTimersTable(this);
  late final $AppConfigTable appConfig = $AppConfigTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $ItilLinksTable itilLinks = $ItilLinksTable(this);
  late final $ItilExtrasTable itilExtras = $ItilExtrasTable(this);
  late final $PlanningEventsTable planningEvents = $PlanningEventsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ProjectTasksTable projectTasks = $ProjectTasksTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $KbCategoriesTable kbCategories = $KbCategoriesTable(this);
  late final $KbArticlesTable kbArticles = $KbArticlesTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tickets,
    ticketTeam,
    timelineItems,
    dropdownItems,
    pendingOps,
    activeTimers,
    appConfig,
    syncState,
    attachments,
    itilLinks,
    itilExtras,
    planningEvents,
    projects,
    projectTasks,
    reminders,
    kbCategories,
    kbArticles,
    catalogItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tickets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ticket_team', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tickets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timeline_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tickets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tickets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('itil_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tickets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('itil_extras', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('project_tasks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TicketsTableCreateCompanionBuilder =
    TicketsCompanion Function({
      required String localId,
      Value<int?> serverId,
      Value<String> itemtype,
      required String name,
      Value<String> content,
      required int status,
      Value<int> priority,
      Value<int> urgency,
      Value<int> impact,
      Value<int> type,
      Value<int?> categoryId,
      Value<String?> categoryName,
      Value<int?> entityId,
      Value<String?> entityLabel,
      Value<String?> requestTypeName,
      Value<int?> locationId,
      Value<String?> locationName,
      Value<String?> recipientName,
      Value<String?> dateCreation,
      Value<String?> dateMod,
      Value<String?> timeToResolve,
      Value<String?> timeToOwn,
      Value<int> rowid,
    });
typedef $$TicketsTableUpdateCompanionBuilder =
    TicketsCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<String> itemtype,
      Value<String> name,
      Value<String> content,
      Value<int> status,
      Value<int> priority,
      Value<int> urgency,
      Value<int> impact,
      Value<int> type,
      Value<int?> categoryId,
      Value<String?> categoryName,
      Value<int?> entityId,
      Value<String?> entityLabel,
      Value<String?> requestTypeName,
      Value<int?> locationId,
      Value<String?> locationName,
      Value<String?> recipientName,
      Value<String?> dateCreation,
      Value<String?> dateMod,
      Value<String?> timeToResolve,
      Value<String?> timeToOwn,
      Value<int> rowid,
    });

final class $$TicketsTableReferences
    extends BaseReferences<_$AppDatabase, $TicketsTable, Ticket> {
  $$TicketsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TicketTeamTable, List<TicketTeamData>>
  _ticketTeamRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ticketTeam,
    aliasName: 'tickets__local_id__ticket_team__ticket_local_id',
  );

  $$TicketTeamTableProcessedTableManager get ticketTeamRefs {
    final manager = $$TicketTeamTableTableManager($_db, $_db.ticketTeam).filter(
      (f) =>
          f.ticketLocalId.localId.sqlEquals($_itemColumn<String>('local_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_ticketTeamRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimelineItemsTable, List<TimelineItem>>
  _timelineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timelineItems,
    aliasName: 'tickets__local_id__timeline_items__ticket_local_id',
  );

  $$TimelineItemsTableProcessedTableManager get timelineItemsRefs {
    final manager = $$TimelineItemsTableTableManager($_db, $_db.timelineItems)
        .filter(
          (f) => f.ticketLocalId.localId.sqlEquals(
            $_itemColumn<String>('local_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_timelineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<AttachmentRow>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'tickets__local_id__attachments__ticket_local_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager($_db, $_db.attachments)
        .filter(
          (f) => f.ticketLocalId.localId.sqlEquals(
            $_itemColumn<String>('local_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItilLinksTable, List<ItilLinkRow>>
  _itilLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itilLinks,
    aliasName: 'tickets__local_id__itil_links__owner_local_id',
  );

  $$ItilLinksTableProcessedTableManager get itilLinksRefs {
    final manager = $$ItilLinksTableTableManager($_db, $_db.itilLinks).filter(
      (f) =>
          f.ownerLocalId.localId.sqlEquals($_itemColumn<String>('local_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_itilLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItilExtrasTable, List<ItilExtraRow>>
  _itilExtrasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itilExtras,
    aliasName: 'tickets__local_id__itil_extras__owner_local_id',
  );

  $$ItilExtrasTableProcessedTableManager get itilExtrasRefs {
    final manager = $$ItilExtrasTableTableManager($_db, $_db.itilExtras).filter(
      (f) =>
          f.ownerLocalId.localId.sqlEquals($_itemColumn<String>('local_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_itilExtrasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TicketsTableFilterComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemtype => $composableBuilder(
    column: $table.itemtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestTypeName => $composableBuilder(
    column: $table.requestTypeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipientName => $composableBuilder(
    column: $table.recipientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateMod => $composableBuilder(
    column: $table.dateMod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeToResolve => $composableBuilder(
    column: $table.timeToResolve,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeToOwn => $composableBuilder(
    column: $table.timeToOwn,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ticketTeamRefs(
    Expression<bool> Function($$TicketTeamTableFilterComposer f) f,
  ) {
    final $$TicketTeamTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.ticketTeam,
      getReferencedColumn: (t) => t.ticketLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketTeamTableFilterComposer(
            $db: $db,
            $table: $db.ticketTeam,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timelineItemsRefs(
    Expression<bool> Function($$TimelineItemsTableFilterComposer f) f,
  ) {
    final $$TimelineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.timelineItems,
      getReferencedColumn: (t) => t.ticketLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineItemsTableFilterComposer(
            $db: $db,
            $table: $db.timelineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.ticketLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itilLinksRefs(
    Expression<bool> Function($$ItilLinksTableFilterComposer f) f,
  ) {
    final $$ItilLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.itilLinks,
      getReferencedColumn: (t) => t.ownerLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItilLinksTableFilterComposer(
            $db: $db,
            $table: $db.itilLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itilExtrasRefs(
    Expression<bool> Function($$ItilExtrasTableFilterComposer f) f,
  ) {
    final $$ItilExtrasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.itilExtras,
      getReferencedColumn: (t) => t.ownerLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItilExtrasTableFilterComposer(
            $db: $db,
            $table: $db.itilExtras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemtype => $composableBuilder(
    column: $table.itemtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestTypeName => $composableBuilder(
    column: $table.requestTypeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipientName => $composableBuilder(
    column: $table.recipientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateMod => $composableBuilder(
    column: $table.dateMod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeToResolve => $composableBuilder(
    column: $table.timeToResolve,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeToOwn => $composableBuilder(
    column: $table.timeToOwn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketsTable> {
  $$TicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get itemtype =>
      $composableBuilder(column: $table.itemtype, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<int> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestTypeName => $composableBuilder(
    column: $table.requestTypeName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipientName => $composableBuilder(
    column: $table.recipientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateMod =>
      $composableBuilder(column: $table.dateMod, builder: (column) => column);

  GeneratedColumn<String> get timeToResolve => $composableBuilder(
    column: $table.timeToResolve,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeToOwn =>
      $composableBuilder(column: $table.timeToOwn, builder: (column) => column);

  Expression<T> ticketTeamRefs<T extends Object>(
    Expression<T> Function($$TicketTeamTableAnnotationComposer a) f,
  ) {
    final $$TicketTeamTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.ticketTeam,
      getReferencedColumn: (t) => t.ticketLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketTeamTableAnnotationComposer(
            $db: $db,
            $table: $db.ticketTeam,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timelineItemsRefs<T extends Object>(
    Expression<T> Function($$TimelineItemsTableAnnotationComposer a) f,
  ) {
    final $$TimelineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.timelineItems,
      getReferencedColumn: (t) => t.ticketLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.timelineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.ticketLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itilLinksRefs<T extends Object>(
    Expression<T> Function($$ItilLinksTableAnnotationComposer a) f,
  ) {
    final $$ItilLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.itilLinks,
      getReferencedColumn: (t) => t.ownerLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItilLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.itilLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itilExtrasRefs<T extends Object>(
    Expression<T> Function($$ItilExtrasTableAnnotationComposer a) f,
  ) {
    final $$ItilExtrasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.itilExtras,
      getReferencedColumn: (t) => t.ownerLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItilExtrasTableAnnotationComposer(
            $db: $db,
            $table: $db.itilExtras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TicketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TicketsTable,
          Ticket,
          $$TicketsTableFilterComposer,
          $$TicketsTableOrderingComposer,
          $$TicketsTableAnnotationComposer,
          $$TicketsTableCreateCompanionBuilder,
          $$TicketsTableUpdateCompanionBuilder,
          (Ticket, $$TicketsTableReferences),
          Ticket,
          PrefetchHooks Function({
            bool ticketTeamRefs,
            bool timelineItemsRefs,
            bool attachmentsRefs,
            bool itilLinksRefs,
            bool itilExtrasRefs,
          })
        > {
  $$TicketsTableTableManager(_$AppDatabase db, $TicketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> itemtype = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> urgency = const Value.absent(),
                Value<int> impact = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String?> entityLabel = const Value.absent(),
                Value<String?> requestTypeName = const Value.absent(),
                Value<int?> locationId = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> recipientName = const Value.absent(),
                Value<String?> dateCreation = const Value.absent(),
                Value<String?> dateMod = const Value.absent(),
                Value<String?> timeToResolve = const Value.absent(),
                Value<String?> timeToOwn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketsCompanion(
                localId: localId,
                serverId: serverId,
                itemtype: itemtype,
                name: name,
                content: content,
                status: status,
                priority: priority,
                urgency: urgency,
                impact: impact,
                type: type,
                categoryId: categoryId,
                categoryName: categoryName,
                entityId: entityId,
                entityLabel: entityLabel,
                requestTypeName: requestTypeName,
                locationId: locationId,
                locationName: locationName,
                recipientName: recipientName,
                dateCreation: dateCreation,
                dateMod: dateMod,
                timeToResolve: timeToResolve,
                timeToOwn: timeToOwn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                Value<String> itemtype = const Value.absent(),
                required String name,
                Value<String> content = const Value.absent(),
                required int status,
                Value<int> priority = const Value.absent(),
                Value<int> urgency = const Value.absent(),
                Value<int> impact = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String?> entityLabel = const Value.absent(),
                Value<String?> requestTypeName = const Value.absent(),
                Value<int?> locationId = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> recipientName = const Value.absent(),
                Value<String?> dateCreation = const Value.absent(),
                Value<String?> dateMod = const Value.absent(),
                Value<String?> timeToResolve = const Value.absent(),
                Value<String?> timeToOwn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketsCompanion.insert(
                localId: localId,
                serverId: serverId,
                itemtype: itemtype,
                name: name,
                content: content,
                status: status,
                priority: priority,
                urgency: urgency,
                impact: impact,
                type: type,
                categoryId: categoryId,
                categoryName: categoryName,
                entityId: entityId,
                entityLabel: entityLabel,
                requestTypeName: requestTypeName,
                locationId: locationId,
                locationName: locationName,
                recipientName: recipientName,
                dateCreation: dateCreation,
                dateMod: dateMod,
                timeToResolve: timeToResolve,
                timeToOwn: timeToOwn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TicketsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ticketTeamRefs = false,
                timelineItemsRefs = false,
                attachmentsRefs = false,
                itilLinksRefs = false,
                itilExtrasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ticketTeamRefs) db.ticketTeam,
                    if (timelineItemsRefs) db.timelineItems,
                    if (attachmentsRefs) db.attachments,
                    if (itilLinksRefs) db.itilLinks,
                    if (itilExtrasRefs) db.itilExtras,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ticketTeamRefs)
                        await $_getPrefetchedData<
                          Ticket,
                          $TicketsTable,
                          TicketTeamData
                        >(
                          currentTable: table,
                          referencedTable: $$TicketsTableReferences
                              ._ticketTeamRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TicketsTableReferences(
                                db,
                                table,
                                p0,
                              ).ticketTeamRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ticketLocalId == item.localId,
                              ),
                          typedResults: items,
                        ),
                      if (timelineItemsRefs)
                        await $_getPrefetchedData<
                          Ticket,
                          $TicketsTable,
                          TimelineItem
                        >(
                          currentTable: table,
                          referencedTable: $$TicketsTableReferences
                              ._timelineItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TicketsTableReferences(
                                db,
                                table,
                                p0,
                              ).timelineItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ticketLocalId == item.localId,
                              ),
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          Ticket,
                          $TicketsTable,
                          AttachmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$TicketsTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TicketsTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ticketLocalId == item.localId,
                              ),
                          typedResults: items,
                        ),
                      if (itilLinksRefs)
                        await $_getPrefetchedData<
                          Ticket,
                          $TicketsTable,
                          ItilLinkRow
                        >(
                          currentTable: table,
                          referencedTable: $$TicketsTableReferences
                              ._itilLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TicketsTableReferences(
                                db,
                                table,
                                p0,
                              ).itilLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerLocalId == item.localId,
                              ),
                          typedResults: items,
                        ),
                      if (itilExtrasRefs)
                        await $_getPrefetchedData<
                          Ticket,
                          $TicketsTable,
                          ItilExtraRow
                        >(
                          currentTable: table,
                          referencedTable: $$TicketsTableReferences
                              ._itilExtrasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TicketsTableReferences(
                                db,
                                table,
                                p0,
                              ).itilExtrasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerLocalId == item.localId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TicketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TicketsTable,
      Ticket,
      $$TicketsTableFilterComposer,
      $$TicketsTableOrderingComposer,
      $$TicketsTableAnnotationComposer,
      $$TicketsTableCreateCompanionBuilder,
      $$TicketsTableUpdateCompanionBuilder,
      (Ticket, $$TicketsTableReferences),
      Ticket,
      PrefetchHooks Function({
        bool ticketTeamRefs,
        bool timelineItemsRefs,
        bool attachmentsRefs,
        bool itilLinksRefs,
        bool itilExtrasRefs,
      })
    >;
typedef $$TicketTeamTableCreateCompanionBuilder =
    TicketTeamCompanion Function({
      required String localId,
      required String ticketLocalId,
      required String role,
      required String memberType,
      required int memberId,
      Value<String> displayName,
      Value<int> rowid,
    });
typedef $$TicketTeamTableUpdateCompanionBuilder =
    TicketTeamCompanion Function({
      Value<String> localId,
      Value<String> ticketLocalId,
      Value<String> role,
      Value<String> memberType,
      Value<int> memberId,
      Value<String> displayName,
      Value<int> rowid,
    });

final class $$TicketTeamTableReferences
    extends BaseReferences<_$AppDatabase, $TicketTeamTable, TicketTeamData> {
  $$TicketTeamTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketLocalIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('ticket_team__ticket_local_id__tickets__local_id');

  $$TicketsTableProcessedTableManager get ticketLocalId {
    final $_column = $_itemColumn<String>('ticket_local_id')!;

    final manager = $$TicketsTableTableManager(
      $_db,
      $_db.tickets,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketLocalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TicketTeamTableFilterComposer
    extends Composer<_$AppDatabase, $TicketTeamTable> {
  $$TicketTeamTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  $$TicketsTableFilterComposer get ticketLocalId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableFilterComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketTeamTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketTeamTable> {
  $$TicketTeamTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  $$TicketsTableOrderingComposer get ticketLocalId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableOrderingComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketTeamTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketTeamTable> {
  $$TicketTeamTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  $$TicketsTableAnnotationComposer get ticketLocalId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TicketTeamTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TicketTeamTable,
          TicketTeamData,
          $$TicketTeamTableFilterComposer,
          $$TicketTeamTableOrderingComposer,
          $$TicketTeamTableAnnotationComposer,
          $$TicketTeamTableCreateCompanionBuilder,
          $$TicketTeamTableUpdateCompanionBuilder,
          (TicketTeamData, $$TicketTeamTableReferences),
          TicketTeamData,
          PrefetchHooks Function({bool ticketLocalId})
        > {
  $$TicketTeamTableTableManager(_$AppDatabase db, $TicketTeamTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketTeamTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketTeamTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketTeamTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> ticketLocalId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> memberType = const Value.absent(),
                Value<int> memberId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketTeamCompanion(
                localId: localId,
                ticketLocalId: ticketLocalId,
                role: role,
                memberType: memberType,
                memberId: memberId,
                displayName: displayName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String ticketLocalId,
                required String role,
                required String memberType,
                required int memberId,
                Value<String> displayName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketTeamCompanion.insert(
                localId: localId,
                ticketLocalId: ticketLocalId,
                role: role,
                memberType: memberType,
                memberId: memberId,
                displayName: displayName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TicketTeamTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ticketLocalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ticketLocalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ticketLocalId,
                                referencedTable: $$TicketTeamTableReferences
                                    ._ticketLocalIdTable(db),
                                referencedColumn: $$TicketTeamTableReferences
                                    ._ticketLocalIdTable(db)
                                    .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TicketTeamTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TicketTeamTable,
      TicketTeamData,
      $$TicketTeamTableFilterComposer,
      $$TicketTeamTableOrderingComposer,
      $$TicketTeamTableAnnotationComposer,
      $$TicketTeamTableCreateCompanionBuilder,
      $$TicketTeamTableUpdateCompanionBuilder,
      (TicketTeamData, $$TicketTeamTableReferences),
      TicketTeamData,
      PrefetchHooks Function({bool ticketLocalId})
    >;
typedef $$TimelineItemsTableCreateCompanionBuilder =
    TimelineItemsCompanion Function({
      required String localId,
      required String ticketLocalId,
      Value<int?> serverId,
      required String itemType,
      Value<String> content,
      Value<bool> isPrivate,
      Value<String?> dateCreation,
      Value<int?> authorId,
      Value<String?> authorName,
      Value<int?> taskDuration,
      Value<int?> taskState,
      Value<int?> solutionStatus,
      Value<int?> validationStatus,
      Value<int?> approverId,
      Value<String?> approverType,
      Value<String?> approvalComment,
      Value<int> rowid,
    });
typedef $$TimelineItemsTableUpdateCompanionBuilder =
    TimelineItemsCompanion Function({
      Value<String> localId,
      Value<String> ticketLocalId,
      Value<int?> serverId,
      Value<String> itemType,
      Value<String> content,
      Value<bool> isPrivate,
      Value<String?> dateCreation,
      Value<int?> authorId,
      Value<String?> authorName,
      Value<int?> taskDuration,
      Value<int?> taskState,
      Value<int?> solutionStatus,
      Value<int?> validationStatus,
      Value<int?> approverId,
      Value<String?> approverType,
      Value<String?> approvalComment,
      Value<int> rowid,
    });

final class $$TimelineItemsTableReferences
    extends BaseReferences<_$AppDatabase, $TimelineItemsTable, TimelineItem> {
  $$TimelineItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TicketsTable _ticketLocalIdTable(_$AppDatabase db) => db.tickets
      .createAlias('timeline_items__ticket_local_id__tickets__local_id');

  $$TicketsTableProcessedTableManager get ticketLocalId {
    final $_column = $_itemColumn<String>('ticket_local_id')!;

    final manager = $$TicketsTableTableManager(
      $_db,
      $_db.tickets,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketLocalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimelineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineItemsTable> {
  $$TimelineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskDuration => $composableBuilder(
    column: $table.taskDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskState => $composableBuilder(
    column: $table.taskState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get solutionStatus => $composableBuilder(
    column: $table.solutionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validationStatus => $composableBuilder(
    column: $table.validationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get approverId => $composableBuilder(
    column: $table.approverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approverType => $composableBuilder(
    column: $table.approverType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvalComment => $composableBuilder(
    column: $table.approvalComment,
    builder: (column) => ColumnFilters(column),
  );

  $$TicketsTableFilterComposer get ticketLocalId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableFilterComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineItemsTable> {
  $$TimelineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskDuration => $composableBuilder(
    column: $table.taskDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskState => $composableBuilder(
    column: $table.taskState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get solutionStatus => $composableBuilder(
    column: $table.solutionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validationStatus => $composableBuilder(
    column: $table.validationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get approverId => $composableBuilder(
    column: $table.approverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approverType => $composableBuilder(
    column: $table.approverType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvalComment => $composableBuilder(
    column: $table.approvalComment,
    builder: (column) => ColumnOrderings(column),
  );

  $$TicketsTableOrderingComposer get ticketLocalId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableOrderingComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineItemsTable> {
  $$TimelineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taskDuration => $composableBuilder(
    column: $table.taskDuration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taskState =>
      $composableBuilder(column: $table.taskState, builder: (column) => column);

  GeneratedColumn<int> get solutionStatus => $composableBuilder(
    column: $table.solutionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get validationStatus => $composableBuilder(
    column: $table.validationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get approverId => $composableBuilder(
    column: $table.approverId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get approverType => $composableBuilder(
    column: $table.approverType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get approvalComment => $composableBuilder(
    column: $table.approvalComment,
    builder: (column) => column,
  );

  $$TicketsTableAnnotationComposer get ticketLocalId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineItemsTable,
          TimelineItem,
          $$TimelineItemsTableFilterComposer,
          $$TimelineItemsTableOrderingComposer,
          $$TimelineItemsTableAnnotationComposer,
          $$TimelineItemsTableCreateCompanionBuilder,
          $$TimelineItemsTableUpdateCompanionBuilder,
          (TimelineItem, $$TimelineItemsTableReferences),
          TimelineItem,
          PrefetchHooks Function({bool ticketLocalId})
        > {
  $$TimelineItemsTableTableManager(_$AppDatabase db, $TimelineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> ticketLocalId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<String?> dateCreation = const Value.absent(),
                Value<int?> authorId = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<int?> taskDuration = const Value.absent(),
                Value<int?> taskState = const Value.absent(),
                Value<int?> solutionStatus = const Value.absent(),
                Value<int?> validationStatus = const Value.absent(),
                Value<int?> approverId = const Value.absent(),
                Value<String?> approverType = const Value.absent(),
                Value<String?> approvalComment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineItemsCompanion(
                localId: localId,
                ticketLocalId: ticketLocalId,
                serverId: serverId,
                itemType: itemType,
                content: content,
                isPrivate: isPrivate,
                dateCreation: dateCreation,
                authorId: authorId,
                authorName: authorName,
                taskDuration: taskDuration,
                taskState: taskState,
                solutionStatus: solutionStatus,
                validationStatus: validationStatus,
                approverId: approverId,
                approverType: approverType,
                approvalComment: approvalComment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String ticketLocalId,
                Value<int?> serverId = const Value.absent(),
                required String itemType,
                Value<String> content = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<String?> dateCreation = const Value.absent(),
                Value<int?> authorId = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<int?> taskDuration = const Value.absent(),
                Value<int?> taskState = const Value.absent(),
                Value<int?> solutionStatus = const Value.absent(),
                Value<int?> validationStatus = const Value.absent(),
                Value<int?> approverId = const Value.absent(),
                Value<String?> approverType = const Value.absent(),
                Value<String?> approvalComment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineItemsCompanion.insert(
                localId: localId,
                ticketLocalId: ticketLocalId,
                serverId: serverId,
                itemType: itemType,
                content: content,
                isPrivate: isPrivate,
                dateCreation: dateCreation,
                authorId: authorId,
                authorName: authorName,
                taskDuration: taskDuration,
                taskState: taskState,
                solutionStatus: solutionStatus,
                validationStatus: validationStatus,
                approverId: approverId,
                approverType: approverType,
                approvalComment: approvalComment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimelineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ticketLocalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ticketLocalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ticketLocalId,
                                referencedTable: $$TimelineItemsTableReferences
                                    ._ticketLocalIdTable(db),
                                referencedColumn: $$TimelineItemsTableReferences
                                    ._ticketLocalIdTable(db)
                                    .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimelineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineItemsTable,
      TimelineItem,
      $$TimelineItemsTableFilterComposer,
      $$TimelineItemsTableOrderingComposer,
      $$TimelineItemsTableAnnotationComposer,
      $$TimelineItemsTableCreateCompanionBuilder,
      $$TimelineItemsTableUpdateCompanionBuilder,
      (TimelineItem, $$TimelineItemsTableReferences),
      TimelineItem,
      PrefetchHooks Function({bool ticketLocalId})
    >;
typedef $$DropdownItemsTableCreateCompanionBuilder =
    DropdownItemsCompanion Function({
      required String kind,
      required int serverId,
      required String name,
      Value<int> rowid,
    });
typedef $$DropdownItemsTableUpdateCompanionBuilder =
    DropdownItemsCompanion Function({
      Value<String> kind,
      Value<int> serverId,
      Value<String> name,
      Value<int> rowid,
    });

class $$DropdownItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DropdownItemsTable> {
  $$DropdownItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DropdownItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DropdownItemsTable> {
  $$DropdownItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DropdownItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DropdownItemsTable> {
  $$DropdownItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$DropdownItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DropdownItemsTable,
          DropdownItem,
          $$DropdownItemsTableFilterComposer,
          $$DropdownItemsTableOrderingComposer,
          $$DropdownItemsTableAnnotationComposer,
          $$DropdownItemsTableCreateCompanionBuilder,
          $$DropdownItemsTableUpdateCompanionBuilder,
          (
            DropdownItem,
            BaseReferences<_$AppDatabase, $DropdownItemsTable, DropdownItem>,
          ),
          DropdownItem,
          PrefetchHooks Function()
        > {
  $$DropdownItemsTableTableManager(_$AppDatabase db, $DropdownItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DropdownItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DropdownItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DropdownItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> kind = const Value.absent(),
                Value<int> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DropdownItemsCompanion(
                kind: kind,
                serverId: serverId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kind,
                required int serverId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => DropdownItemsCompanion.insert(
                kind: kind,
                serverId: serverId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DropdownItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DropdownItemsTable,
      DropdownItem,
      $$DropdownItemsTableFilterComposer,
      $$DropdownItemsTableOrderingComposer,
      $$DropdownItemsTableAnnotationComposer,
      $$DropdownItemsTableCreateCompanionBuilder,
      $$DropdownItemsTableUpdateCompanionBuilder,
      (
        DropdownItem,
        BaseReferences<_$AppDatabase, $DropdownItemsTable, DropdownItem>,
      ),
      DropdownItem,
      PrefetchHooks Function()
    >;
typedef $$PendingOpsTableCreateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<int> id,
      required String opUuid,
      required String opType,
      Value<String> itemtype,
      required String ticketLocalId,
      required int ticketServerId,
      Value<String?> targetLocalId,
      Value<int?> targetServerId,
      Value<String> payload,
      Value<String?> baseSnapshot,
      Value<String> status,
      Value<int> attempts,
      Value<String?> nextRetryAt,
      Value<String?> lastError,
      required String createdAt,
      Value<int?> entityId,
      Value<bool?> entityRecursive,
    });
typedef $$PendingOpsTableUpdateCompanionBuilder =
    PendingOpsCompanion Function({
      Value<int> id,
      Value<String> opUuid,
      Value<String> opType,
      Value<String> itemtype,
      Value<String> ticketLocalId,
      Value<int> ticketServerId,
      Value<String?> targetLocalId,
      Value<int?> targetServerId,
      Value<String> payload,
      Value<String?> baseSnapshot,
      Value<String> status,
      Value<int> attempts,
      Value<String?> nextRetryAt,
      Value<String?> lastError,
      Value<String> createdAt,
      Value<int?> entityId,
      Value<bool?> entityRecursive,
    });

class $$PendingOpsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opUuid => $composableBuilder(
    column: $table.opUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemtype => $composableBuilder(
    column: $table.itemtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticketLocalId => $composableBuilder(
    column: $table.ticketLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ticketServerId => $composableBuilder(
    column: $table.ticketServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLocalId => $composableBuilder(
    column: $table.targetLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetServerId => $composableBuilder(
    column: $table.targetServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseSnapshot => $composableBuilder(
    column: $table.baseSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get entityRecursive => $composableBuilder(
    column: $table.entityRecursive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opUuid => $composableBuilder(
    column: $table.opUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemtype => $composableBuilder(
    column: $table.itemtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticketLocalId => $composableBuilder(
    column: $table.ticketLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ticketServerId => $composableBuilder(
    column: $table.ticketServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLocalId => $composableBuilder(
    column: $table.targetLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetServerId => $composableBuilder(
    column: $table.targetServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseSnapshot => $composableBuilder(
    column: $table.baseSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get entityRecursive => $composableBuilder(
    column: $table.entityRecursive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOpsTable> {
  $$PendingOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opUuid =>
      $composableBuilder(column: $table.opUuid, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get itemtype =>
      $composableBuilder(column: $table.itemtype, builder: (column) => column);

  GeneratedColumn<String> get ticketLocalId => $composableBuilder(
    column: $table.ticketLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ticketServerId => $composableBuilder(
    column: $table.ticketServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLocalId => $composableBuilder(
    column: $table.targetLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetServerId => $composableBuilder(
    column: $table.targetServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get baseSnapshot => $composableBuilder(
    column: $table.baseSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<bool> get entityRecursive => $composableBuilder(
    column: $table.entityRecursive,
    builder: (column) => column,
  );
}

class $$PendingOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOpsTable,
          PendingOp,
          $$PendingOpsTableFilterComposer,
          $$PendingOpsTableOrderingComposer,
          $$PendingOpsTableAnnotationComposer,
          $$PendingOpsTableCreateCompanionBuilder,
          $$PendingOpsTableUpdateCompanionBuilder,
          (
            PendingOp,
            BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOp>,
          ),
          PendingOp,
          PrefetchHooks Function()
        > {
  $$PendingOpsTableTableManager(_$AppDatabase db, $PendingOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> opUuid = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> itemtype = const Value.absent(),
                Value<String> ticketLocalId = const Value.absent(),
                Value<int> ticketServerId = const Value.absent(),
                Value<String?> targetLocalId = const Value.absent(),
                Value<int?> targetServerId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> baseSnapshot = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<bool?> entityRecursive = const Value.absent(),
              }) => PendingOpsCompanion(
                id: id,
                opUuid: opUuid,
                opType: opType,
                itemtype: itemtype,
                ticketLocalId: ticketLocalId,
                ticketServerId: ticketServerId,
                targetLocalId: targetLocalId,
                targetServerId: targetServerId,
                payload: payload,
                baseSnapshot: baseSnapshot,
                status: status,
                attempts: attempts,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                createdAt: createdAt,
                entityId: entityId,
                entityRecursive: entityRecursive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String opUuid,
                required String opType,
                Value<String> itemtype = const Value.absent(),
                required String ticketLocalId,
                required int ticketServerId,
                Value<String?> targetLocalId = const Value.absent(),
                Value<int?> targetServerId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> baseSnapshot = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required String createdAt,
                Value<int?> entityId = const Value.absent(),
                Value<bool?> entityRecursive = const Value.absent(),
              }) => PendingOpsCompanion.insert(
                id: id,
                opUuid: opUuid,
                opType: opType,
                itemtype: itemtype,
                ticketLocalId: ticketLocalId,
                ticketServerId: ticketServerId,
                targetLocalId: targetLocalId,
                targetServerId: targetServerId,
                payload: payload,
                baseSnapshot: baseSnapshot,
                status: status,
                attempts: attempts,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                createdAt: createdAt,
                entityId: entityId,
                entityRecursive: entityRecursive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOpsTable,
      PendingOp,
      $$PendingOpsTableFilterComposer,
      $$PendingOpsTableOrderingComposer,
      $$PendingOpsTableAnnotationComposer,
      $$PendingOpsTableCreateCompanionBuilder,
      $$PendingOpsTableUpdateCompanionBuilder,
      (PendingOp, BaseReferences<_$AppDatabase, $PendingOpsTable, PendingOp>),
      PendingOp,
      PrefetchHooks Function()
    >;
typedef $$ActiveTimersTableCreateCompanionBuilder =
    ActiveTimersCompanion Function({
      required String ticketLocalId,
      required int ticketServerId,
      Value<String> ticketName,
      required String startedAt,
      Value<int> rowid,
    });
typedef $$ActiveTimersTableUpdateCompanionBuilder =
    ActiveTimersCompanion Function({
      Value<String> ticketLocalId,
      Value<int> ticketServerId,
      Value<String> ticketName,
      Value<String> startedAt,
      Value<int> rowid,
    });

class $$ActiveTimersTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ticketLocalId => $composableBuilder(
    column: $table.ticketLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ticketServerId => $composableBuilder(
    column: $table.ticketServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticketName => $composableBuilder(
    column: $table.ticketName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActiveTimersTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ticketLocalId => $composableBuilder(
    column: $table.ticketLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ticketServerId => $composableBuilder(
    column: $table.ticketServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticketName => $composableBuilder(
    column: $table.ticketName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActiveTimersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ticketLocalId => $composableBuilder(
    column: $table.ticketLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ticketServerId => $composableBuilder(
    column: $table.ticketServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ticketName => $composableBuilder(
    column: $table.ticketName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);
}

class $$ActiveTimersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveTimersTable,
          ActiveTimer,
          $$ActiveTimersTableFilterComposer,
          $$ActiveTimersTableOrderingComposer,
          $$ActiveTimersTableAnnotationComposer,
          $$ActiveTimersTableCreateCompanionBuilder,
          $$ActiveTimersTableUpdateCompanionBuilder,
          (
            ActiveTimer,
            BaseReferences<_$AppDatabase, $ActiveTimersTable, ActiveTimer>,
          ),
          ActiveTimer,
          PrefetchHooks Function()
        > {
  $$ActiveTimersTableTableManager(_$AppDatabase db, $ActiveTimersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveTimersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveTimersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveTimersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ticketLocalId = const Value.absent(),
                Value<int> ticketServerId = const Value.absent(),
                Value<String> ticketName = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveTimersCompanion(
                ticketLocalId: ticketLocalId,
                ticketServerId: ticketServerId,
                ticketName: ticketName,
                startedAt: startedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ticketLocalId,
                required int ticketServerId,
                Value<String> ticketName = const Value.absent(),
                required String startedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActiveTimersCompanion.insert(
                ticketLocalId: ticketLocalId,
                ticketServerId: ticketServerId,
                ticketName: ticketName,
                startedAt: startedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActiveTimersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveTimersTable,
      ActiveTimer,
      $$ActiveTimersTableFilterComposer,
      $$ActiveTimersTableOrderingComposer,
      $$ActiveTimersTableAnnotationComposer,
      $$ActiveTimersTableCreateCompanionBuilder,
      $$ActiveTimersTableUpdateCompanionBuilder,
      (
        ActiveTimer,
        BaseReferences<_$AppDatabase, $ActiveTimersTable, ActiveTimer>,
      ),
      ActiveTimer,
      PrefetchHooks Function()
    >;
typedef $$AppConfigTableCreateCompanionBuilder =
    AppConfigCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppConfigTableUpdateCompanionBuilder =
    AppConfigCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppConfigTableFilterComposer
    extends Composer<_$AppDatabase, $AppConfigTable> {
  $$AppConfigTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppConfigTableOrderingComposer
    extends Composer<_$AppDatabase, $AppConfigTable> {
  $$AppConfigTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppConfigTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppConfigTable> {
  $$AppConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppConfigTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppConfigTable,
          AppConfigData,
          $$AppConfigTableFilterComposer,
          $$AppConfigTableOrderingComposer,
          $$AppConfigTableAnnotationComposer,
          $$AppConfigTableCreateCompanionBuilder,
          $$AppConfigTableUpdateCompanionBuilder,
          (
            AppConfigData,
            BaseReferences<_$AppDatabase, $AppConfigTable, AppConfigData>,
          ),
          AppConfigData,
          PrefetchHooks Function()
        > {
  $$AppConfigTableTableManager(_$AppDatabase db, $AppConfigTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppConfigTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppConfigTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppConfigTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppConfigCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppConfigCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppConfigTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppConfigTable,
      AppConfigData,
      $$AppConfigTableFilterComposer,
      $$AppConfigTableOrderingComposer,
      $$AppConfigTableAnnotationComposer,
      $$AppConfigTableCreateCompanionBuilder,
      $$AppConfigTableUpdateCompanionBuilder,
      (
        AppConfigData,
        BaseReferences<_$AppDatabase, $AppConfigTable, AppConfigData>,
      ),
      AppConfigData,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String scopeKey,
      Value<String?> watermark,
      Value<String?> lastSuccessAt,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> scopeKey,
      Value<String?> watermark,
      Value<String?> lastSuccessAt,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scopeKey => $composableBuilder(
    column: $table.scopeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scopeKey => $composableBuilder(
    column: $table.scopeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scopeKey =>
      $composableBuilder(column: $table.scopeKey, builder: (column) => column);

  GeneratedColumn<String> get watermark =>
      $composableBuilder(column: $table.watermark, builder: (column) => column);

  GeneratedColumn<String> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scopeKey = const Value.absent(),
                Value<String?> watermark = const Value.absent(),
                Value<String?> lastSuccessAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                scopeKey: scopeKey,
                watermark: watermark,
                lastSuccessAt: lastSuccessAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scopeKey,
                Value<String?> watermark = const Value.absent(),
                Value<String?> lastSuccessAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                scopeKey: scopeKey,
                watermark: watermark,
                lastSuccessAt: lastSuccessAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String localId,
      required String ticketLocalId,
      Value<int?> serverDocId,
      Value<String> name,
      Value<String?> filename,
      Value<String?> mime,
      Value<String?> localPath,
      Value<int?> sizeBytes,
      Value<String?> opUuid,
      Value<String?> dateCreation,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> localId,
      Value<String> ticketLocalId,
      Value<int?> serverDocId,
      Value<String> name,
      Value<String?> filename,
      Value<String?> mime,
      Value<String?> localPath,
      Value<int?> sizeBytes,
      Value<String?> opUuid,
      Value<String?> dateCreation,
      Value<int> rowid,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ticketLocalIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('attachments__ticket_local_id__tickets__local_id');

  $$TicketsTableProcessedTableManager get ticketLocalId {
    final $_column = $_itemColumn<String>('ticket_local_id')!;

    final manager = $$TicketsTableTableManager(
      $_db,
      $_db.tickets,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ticketLocalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverDocId => $composableBuilder(
    column: $table.serverDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opUuid => $composableBuilder(
    column: $table.opUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnFilters(column),
  );

  $$TicketsTableFilterComposer get ticketLocalId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableFilterComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverDocId => $composableBuilder(
    column: $table.serverDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opUuid => $composableBuilder(
    column: $table.opUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnOrderings(column),
  );

  $$TicketsTableOrderingComposer get ticketLocalId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableOrderingComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverDocId => $composableBuilder(
    column: $table.serverDocId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get opUuid =>
      $composableBuilder(column: $table.opUuid, builder: (column) => column);

  GeneratedColumn<String> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => column,
  );

  $$TicketsTableAnnotationComposer get ticketLocalId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ticketLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (AttachmentRow, $$AttachmentsTableReferences),
          AttachmentRow,
          PrefetchHooks Function({bool ticketLocalId})
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> ticketLocalId = const Value.absent(),
                Value<int?> serverDocId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> filename = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> opUuid = const Value.absent(),
                Value<String?> dateCreation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                localId: localId,
                ticketLocalId: ticketLocalId,
                serverDocId: serverDocId,
                name: name,
                filename: filename,
                mime: mime,
                localPath: localPath,
                sizeBytes: sizeBytes,
                opUuid: opUuid,
                dateCreation: dateCreation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String ticketLocalId,
                Value<int?> serverDocId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> filename = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> opUuid = const Value.absent(),
                Value<String?> dateCreation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                localId: localId,
                ticketLocalId: ticketLocalId,
                serverDocId: serverDocId,
                name: name,
                filename: filename,
                mime: mime,
                localPath: localPath,
                sizeBytes: sizeBytes,
                opUuid: opUuid,
                dateCreation: dateCreation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ticketLocalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ticketLocalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ticketLocalId,
                                referencedTable: $$AttachmentsTableReferences
                                    ._ticketLocalIdTable(db),
                                referencedColumn: $$AttachmentsTableReferences
                                    ._ticketLocalIdTable(db)
                                    .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (AttachmentRow, $$AttachmentsTableReferences),
      AttachmentRow,
      PrefetchHooks Function({bool ticketLocalId})
    >;
typedef $$ItilLinksTableCreateCompanionBuilder =
    ItilLinksCompanion Function({
      required String localId,
      required String ownerLocalId,
      required String targetItemtype,
      required int targetServerId,
      Value<String> targetName,
      Value<int> targetStatus,
      Value<int> linkType,
      Value<bool> pending,
      Value<int> rowid,
    });
typedef $$ItilLinksTableUpdateCompanionBuilder =
    ItilLinksCompanion Function({
      Value<String> localId,
      Value<String> ownerLocalId,
      Value<String> targetItemtype,
      Value<int> targetServerId,
      Value<String> targetName,
      Value<int> targetStatus,
      Value<int> linkType,
      Value<bool> pending,
      Value<int> rowid,
    });

final class $$ItilLinksTableReferences
    extends BaseReferences<_$AppDatabase, $ItilLinksTable, ItilLinkRow> {
  $$ItilLinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ownerLocalIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('itil_links__owner_local_id__tickets__local_id');

  $$TicketsTableProcessedTableManager get ownerLocalId {
    final $_column = $_itemColumn<String>('owner_local_id')!;

    final manager = $$TicketsTableTableManager(
      $_db,
      $_db.tickets,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerLocalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItilLinksTableFilterComposer
    extends Composer<_$AppDatabase, $ItilLinksTable> {
  $$ItilLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetItemtype => $composableBuilder(
    column: $table.targetItemtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetServerId => $composableBuilder(
    column: $table.targetServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetStatus => $composableBuilder(
    column: $table.targetStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkType => $composableBuilder(
    column: $table.linkType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  $$TicketsTableFilterComposer get ownerLocalId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableFilterComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItilLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $ItilLinksTable> {
  $$ItilLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetItemtype => $composableBuilder(
    column: $table.targetItemtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetServerId => $composableBuilder(
    column: $table.targetServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetStatus => $composableBuilder(
    column: $table.targetStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkType => $composableBuilder(
    column: $table.linkType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  $$TicketsTableOrderingComposer get ownerLocalId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableOrderingComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItilLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItilLinksTable> {
  $$ItilLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get targetItemtype => $composableBuilder(
    column: $table.targetItemtype,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetServerId => $composableBuilder(
    column: $table.targetServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetStatus => $composableBuilder(
    column: $table.targetStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkType =>
      $composableBuilder(column: $table.linkType, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  $$TicketsTableAnnotationComposer get ownerLocalId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItilLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItilLinksTable,
          ItilLinkRow,
          $$ItilLinksTableFilterComposer,
          $$ItilLinksTableOrderingComposer,
          $$ItilLinksTableAnnotationComposer,
          $$ItilLinksTableCreateCompanionBuilder,
          $$ItilLinksTableUpdateCompanionBuilder,
          (ItilLinkRow, $$ItilLinksTableReferences),
          ItilLinkRow,
          PrefetchHooks Function({bool ownerLocalId})
        > {
  $$ItilLinksTableTableManager(_$AppDatabase db, $ItilLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItilLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItilLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItilLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> ownerLocalId = const Value.absent(),
                Value<String> targetItemtype = const Value.absent(),
                Value<int> targetServerId = const Value.absent(),
                Value<String> targetName = const Value.absent(),
                Value<int> targetStatus = const Value.absent(),
                Value<int> linkType = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItilLinksCompanion(
                localId: localId,
                ownerLocalId: ownerLocalId,
                targetItemtype: targetItemtype,
                targetServerId: targetServerId,
                targetName: targetName,
                targetStatus: targetStatus,
                linkType: linkType,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String ownerLocalId,
                required String targetItemtype,
                required int targetServerId,
                Value<String> targetName = const Value.absent(),
                Value<int> targetStatus = const Value.absent(),
                Value<int> linkType = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItilLinksCompanion.insert(
                localId: localId,
                ownerLocalId: ownerLocalId,
                targetItemtype: targetItemtype,
                targetServerId: targetServerId,
                targetName: targetName,
                targetStatus: targetStatus,
                linkType: linkType,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ItilLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerLocalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ownerLocalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ownerLocalId,
                                referencedTable: $$ItilLinksTableReferences
                                    ._ownerLocalIdTable(db),
                                referencedColumn: $$ItilLinksTableReferences
                                    ._ownerLocalIdTable(db)
                                    .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItilLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItilLinksTable,
      ItilLinkRow,
      $$ItilLinksTableFilterComposer,
      $$ItilLinksTableOrderingComposer,
      $$ItilLinksTableAnnotationComposer,
      $$ItilLinksTableCreateCompanionBuilder,
      $$ItilLinksTableUpdateCompanionBuilder,
      (ItilLinkRow, $$ItilLinksTableReferences),
      ItilLinkRow,
      PrefetchHooks Function({bool ownerLocalId})
    >;
typedef $$ItilExtrasTableCreateCompanionBuilder =
    ItilExtrasCompanion Function({
      required String ownerLocalId,
      Value<String> fieldsJson,
      Value<int> rowid,
    });
typedef $$ItilExtrasTableUpdateCompanionBuilder =
    ItilExtrasCompanion Function({
      Value<String> ownerLocalId,
      Value<String> fieldsJson,
      Value<int> rowid,
    });

final class $$ItilExtrasTableReferences
    extends BaseReferences<_$AppDatabase, $ItilExtrasTable, ItilExtraRow> {
  $$ItilExtrasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TicketsTable _ownerLocalIdTable(_$AppDatabase db) =>
      db.tickets.createAlias('itil_extras__owner_local_id__tickets__local_id');

  $$TicketsTableProcessedTableManager get ownerLocalId {
    final $_column = $_itemColumn<String>('owner_local_id')!;

    final manager = $$TicketsTableTableManager(
      $_db,
      $_db.tickets,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerLocalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItilExtrasTableFilterComposer
    extends Composer<_$AppDatabase, $ItilExtrasTable> {
  $$ItilExtrasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$TicketsTableFilterComposer get ownerLocalId {
    final $$TicketsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableFilterComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItilExtrasTableOrderingComposer
    extends Composer<_$AppDatabase, $ItilExtrasTable> {
  $$ItilExtrasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$TicketsTableOrderingComposer get ownerLocalId {
    final $$TicketsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableOrderingComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItilExtrasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItilExtrasTable> {
  $$ItilExtrasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => column,
  );

  $$TicketsTableAnnotationComposer get ownerLocalId {
    final $$TicketsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerLocalId,
      referencedTable: $db.tickets,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TicketsTableAnnotationComposer(
            $db: $db,
            $table: $db.tickets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItilExtrasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItilExtrasTable,
          ItilExtraRow,
          $$ItilExtrasTableFilterComposer,
          $$ItilExtrasTableOrderingComposer,
          $$ItilExtrasTableAnnotationComposer,
          $$ItilExtrasTableCreateCompanionBuilder,
          $$ItilExtrasTableUpdateCompanionBuilder,
          (ItilExtraRow, $$ItilExtrasTableReferences),
          ItilExtraRow,
          PrefetchHooks Function({bool ownerLocalId})
        > {
  $$ItilExtrasTableTableManager(_$AppDatabase db, $ItilExtrasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItilExtrasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItilExtrasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItilExtrasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerLocalId = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItilExtrasCompanion(
                ownerLocalId: ownerLocalId,
                fieldsJson: fieldsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerLocalId,
                Value<String> fieldsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItilExtrasCompanion.insert(
                ownerLocalId: ownerLocalId,
                fieldsJson: fieldsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ItilExtrasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerLocalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ownerLocalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ownerLocalId,
                                referencedTable: $$ItilExtrasTableReferences
                                    ._ownerLocalIdTable(db),
                                referencedColumn: $$ItilExtrasTableReferences
                                    ._ownerLocalIdTable(db)
                                    .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItilExtrasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItilExtrasTable,
      ItilExtraRow,
      $$ItilExtrasTableFilterComposer,
      $$ItilExtrasTableOrderingComposer,
      $$ItilExtrasTableAnnotationComposer,
      $$ItilExtrasTableCreateCompanionBuilder,
      $$ItilExtrasTableUpdateCompanionBuilder,
      (ItilExtraRow, $$ItilExtrasTableReferences),
      ItilExtraRow,
      PrefetchHooks Function({bool ownerLocalId})
    >;
typedef $$PlanningEventsTableCreateCompanionBuilder =
    PlanningEventsCompanion Function({
      required String localId,
      required String eventItemtype,
      Value<int?> eventServerId,
      Value<String?> parentItemtype,
      Value<int?> parentServerId,
      Value<String?> parentName,
      Value<String> title,
      required String begin,
      required String end,
      Value<bool> isAllDay,
      Value<int> state,
      Value<bool> pending,
      Value<int> rowid,
    });
typedef $$PlanningEventsTableUpdateCompanionBuilder =
    PlanningEventsCompanion Function({
      Value<String> localId,
      Value<String> eventItemtype,
      Value<int?> eventServerId,
      Value<String?> parentItemtype,
      Value<int?> parentServerId,
      Value<String?> parentName,
      Value<String> title,
      Value<String> begin,
      Value<String> end,
      Value<bool> isAllDay,
      Value<int> state,
      Value<bool> pending,
      Value<int> rowid,
    });

class $$PlanningEventsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanningEventsTable> {
  $$PlanningEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventItemtype => $composableBuilder(
    column: $table.eventItemtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventServerId => $composableBuilder(
    column: $table.eventServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentItemtype => $composableBuilder(
    column: $table.parentItemtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentServerId => $composableBuilder(
    column: $table.parentServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get begin => $composableBuilder(
    column: $table.begin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanningEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanningEventsTable> {
  $$PlanningEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventItemtype => $composableBuilder(
    column: $table.eventItemtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventServerId => $composableBuilder(
    column: $table.eventServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentItemtype => $composableBuilder(
    column: $table.parentItemtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentServerId => $composableBuilder(
    column: $table.parentServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get begin => $composableBuilder(
    column: $table.begin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanningEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanningEventsTable> {
  $$PlanningEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get eventItemtype => $composableBuilder(
    column: $table.eventItemtype,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventServerId => $composableBuilder(
    column: $table.eventServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentItemtype => $composableBuilder(
    column: $table.parentItemtype,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parentServerId => $composableBuilder(
    column: $table.parentServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get begin =>
      $composableBuilder(column: $table.begin, builder: (column) => column);

  GeneratedColumn<String> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$PlanningEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanningEventsTable,
          PlanningEventRow,
          $$PlanningEventsTableFilterComposer,
          $$PlanningEventsTableOrderingComposer,
          $$PlanningEventsTableAnnotationComposer,
          $$PlanningEventsTableCreateCompanionBuilder,
          $$PlanningEventsTableUpdateCompanionBuilder,
          (
            PlanningEventRow,
            BaseReferences<
              _$AppDatabase,
              $PlanningEventsTable,
              PlanningEventRow
            >,
          ),
          PlanningEventRow,
          PrefetchHooks Function()
        > {
  $$PlanningEventsTableTableManager(
    _$AppDatabase db,
    $PlanningEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanningEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanningEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanningEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> eventItemtype = const Value.absent(),
                Value<int?> eventServerId = const Value.absent(),
                Value<String?> parentItemtype = const Value.absent(),
                Value<int?> parentServerId = const Value.absent(),
                Value<String?> parentName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> begin = const Value.absent(),
                Value<String> end = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanningEventsCompanion(
                localId: localId,
                eventItemtype: eventItemtype,
                eventServerId: eventServerId,
                parentItemtype: parentItemtype,
                parentServerId: parentServerId,
                parentName: parentName,
                title: title,
                begin: begin,
                end: end,
                isAllDay: isAllDay,
                state: state,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String eventItemtype,
                Value<int?> eventServerId = const Value.absent(),
                Value<String?> parentItemtype = const Value.absent(),
                Value<int?> parentServerId = const Value.absent(),
                Value<String?> parentName = const Value.absent(),
                Value<String> title = const Value.absent(),
                required String begin,
                required String end,
                Value<bool> isAllDay = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanningEventsCompanion.insert(
                localId: localId,
                eventItemtype: eventItemtype,
                eventServerId: eventServerId,
                parentItemtype: parentItemtype,
                parentServerId: parentServerId,
                parentName: parentName,
                title: title,
                begin: begin,
                end: end,
                isAllDay: isAllDay,
                state: state,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanningEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanningEventsTable,
      PlanningEventRow,
      $$PlanningEventsTableFilterComposer,
      $$PlanningEventsTableOrderingComposer,
      $$PlanningEventsTableAnnotationComposer,
      $$PlanningEventsTableCreateCompanionBuilder,
      $$PlanningEventsTableUpdateCompanionBuilder,
      (
        PlanningEventRow,
        BaseReferences<_$AppDatabase, $PlanningEventsTable, PlanningEventRow>,
      ),
      PlanningEventRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String localId,
      Value<int?> serverId,
      required String name,
      Value<String?> code,
      Value<String> content,
      Value<String?> statusName,
      Value<int> priority,
      Value<int> percentDone,
      Value<String?> planStartDate,
      Value<String?> planEndDate,
      Value<String?> managerName,
      Value<String?> entityLabel,
      Value<String?> dateMod,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<String> name,
      Value<String?> code,
      Value<String> content,
      Value<String?> statusName,
      Value<int> priority,
      Value<int> percentDone,
      Value<String?> planStartDate,
      Value<String?> planEndDate,
      Value<String?> managerName,
      Value<String?> entityLabel,
      Value<String?> dateMod,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, ProjectRow> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectTasksTable, List<ProjectTaskRow>>
  _projectTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.projectTasks,
    aliasName: 'projects__local_id__project_tasks__project_local_id',
  );

  $$ProjectTasksTableProcessedTableManager get projectTasksRefs {
    final manager = $$ProjectTasksTableTableManager($_db, $_db.projectTasks)
        .filter(
          (f) => f.projectLocalId.localId.sqlEquals(
            $_itemColumn<String>('local_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_projectTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateMod => $composableBuilder(
    column: $table.dateMod,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectTasksRefs(
    Expression<bool> Function($$ProjectTasksTableFilterComposer f) f,
  ) {
    final $$ProjectTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.projectTasks,
      getReferencedColumn: (t) => t.projectLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectTasksTableFilterComposer(
            $db: $db,
            $table: $db.projectTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateMod => $composableBuilder(
    column: $table.dateMod,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get managerName => $composableBuilder(
    column: $table.managerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateMod =>
      $composableBuilder(column: $table.dateMod, builder: (column) => column);

  Expression<T> projectTasksRefs<T extends Object>(
    Expression<T> Function($$ProjectTasksTableAnnotationComposer a) f,
  ) {
    final $$ProjectTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localId,
      referencedTable: $db.projectTasks,
      getReferencedColumn: (t) => t.projectLocalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.projectTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          ProjectRow,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (ProjectRow, $$ProjectsTableReferences),
          ProjectRow,
          PrefetchHooks Function({bool projectTasksRefs})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> statusName = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> percentDone = const Value.absent(),
                Value<String?> planStartDate = const Value.absent(),
                Value<String?> planEndDate = const Value.absent(),
                Value<String?> managerName = const Value.absent(),
                Value<String?> entityLabel = const Value.absent(),
                Value<String?> dateMod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                localId: localId,
                serverId: serverId,
                name: name,
                code: code,
                content: content,
                statusName: statusName,
                priority: priority,
                percentDone: percentDone,
                planStartDate: planStartDate,
                planEndDate: planEndDate,
                managerName: managerName,
                entityLabel: entityLabel,
                dateMod: dateMod,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required String name,
                Value<String?> code = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> statusName = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> percentDone = const Value.absent(),
                Value<String?> planStartDate = const Value.absent(),
                Value<String?> planEndDate = const Value.absent(),
                Value<String?> managerName = const Value.absent(),
                Value<String?> entityLabel = const Value.absent(),
                Value<String?> dateMod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                localId: localId,
                serverId: serverId,
                name: name,
                code: code,
                content: content,
                statusName: statusName,
                priority: priority,
                percentDone: percentDone,
                planStartDate: planStartDate,
                planEndDate: planEndDate,
                managerName: managerName,
                entityLabel: entityLabel,
                dateMod: dateMod,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectTasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (projectTasksRefs) db.projectTasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectTasksRefs)
                    await $_getPrefetchedData<
                      ProjectRow,
                      $ProjectsTable,
                      ProjectTaskRow
                    >(
                      currentTable: table,
                      referencedTable: $$ProjectsTableReferences
                          ._projectTasksRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProjectsTableReferences(
                        db,
                        table,
                        p0,
                      ).projectTasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.projectLocalId == item.localId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      ProjectRow,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (ProjectRow, $$ProjectsTableReferences),
      ProjectRow,
      PrefetchHooks Function({bool projectTasksRefs})
    >;
typedef $$ProjectTasksTableCreateCompanionBuilder =
    ProjectTasksCompanion Function({
      required String localId,
      required String projectLocalId,
      Value<int?> serverId,
      Value<int?> parentTaskServerId,
      required String name,
      Value<String> content,
      Value<String?> statusName,
      Value<int> percentDone,
      Value<String?> planStartDate,
      Value<String?> planEndDate,
      Value<bool> isMilestone,
      Value<String?> assigneeName,
      Value<bool> pending,
      Value<int> rowid,
    });
typedef $$ProjectTasksTableUpdateCompanionBuilder =
    ProjectTasksCompanion Function({
      Value<String> localId,
      Value<String> projectLocalId,
      Value<int?> serverId,
      Value<int?> parentTaskServerId,
      Value<String> name,
      Value<String> content,
      Value<String?> statusName,
      Value<int> percentDone,
      Value<String?> planStartDate,
      Value<String?> planEndDate,
      Value<bool> isMilestone,
      Value<String?> assigneeName,
      Value<bool> pending,
      Value<int> rowid,
    });

final class $$ProjectTasksTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectTasksTable, ProjectTaskRow> {
  $$ProjectTasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectLocalIdTable(_$AppDatabase db) => db.projects
      .createAlias('project_tasks__project_local_id__projects__local_id');

  $$ProjectsTableProcessedTableManager get projectLocalId {
    final $_column = $_itemColumn<String>('project_local_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.localId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectLocalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProjectTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentTaskServerId => $composableBuilder(
    column: $table.parentTaskServerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMilestone => $composableBuilder(
    column: $table.isMilestone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assigneeName => $composableBuilder(
    column: $table.assigneeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectLocalId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectLocalId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentTaskServerId => $composableBuilder(
    column: $table.parentTaskServerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMilestone => $composableBuilder(
    column: $table.isMilestone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assigneeName => $composableBuilder(
    column: $table.assigneeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectLocalId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectLocalId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTasksTable> {
  $$ProjectTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get parentTaskServerId => $composableBuilder(
    column: $table.parentTaskServerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get percentDone => $composableBuilder(
    column: $table.percentDone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planStartDate => $composableBuilder(
    column: $table.planStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planEndDate => $composableBuilder(
    column: $table.planEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMilestone => $composableBuilder(
    column: $table.isMilestone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assigneeName => $composableBuilder(
    column: $table.assigneeName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectLocalId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectLocalId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.localId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectTasksTable,
          ProjectTaskRow,
          $$ProjectTasksTableFilterComposer,
          $$ProjectTasksTableOrderingComposer,
          $$ProjectTasksTableAnnotationComposer,
          $$ProjectTasksTableCreateCompanionBuilder,
          $$ProjectTasksTableUpdateCompanionBuilder,
          (ProjectTaskRow, $$ProjectTasksTableReferences),
          ProjectTaskRow,
          PrefetchHooks Function({bool projectLocalId})
        > {
  $$ProjectTasksTableTableManager(_$AppDatabase db, $ProjectTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> projectLocalId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int?> parentTaskServerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> statusName = const Value.absent(),
                Value<int> percentDone = const Value.absent(),
                Value<String?> planStartDate = const Value.absent(),
                Value<String?> planEndDate = const Value.absent(),
                Value<bool> isMilestone = const Value.absent(),
                Value<String?> assigneeName = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectTasksCompanion(
                localId: localId,
                projectLocalId: projectLocalId,
                serverId: serverId,
                parentTaskServerId: parentTaskServerId,
                name: name,
                content: content,
                statusName: statusName,
                percentDone: percentDone,
                planStartDate: planStartDate,
                planEndDate: planEndDate,
                isMilestone: isMilestone,
                assigneeName: assigneeName,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String projectLocalId,
                Value<int?> serverId = const Value.absent(),
                Value<int?> parentTaskServerId = const Value.absent(),
                required String name,
                Value<String> content = const Value.absent(),
                Value<String?> statusName = const Value.absent(),
                Value<int> percentDone = const Value.absent(),
                Value<String?> planStartDate = const Value.absent(),
                Value<String?> planEndDate = const Value.absent(),
                Value<bool> isMilestone = const Value.absent(),
                Value<String?> assigneeName = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectTasksCompanion.insert(
                localId: localId,
                projectLocalId: projectLocalId,
                serverId: serverId,
                parentTaskServerId: parentTaskServerId,
                name: name,
                content: content,
                statusName: statusName,
                percentDone: percentDone,
                planStartDate: planStartDate,
                planEndDate: planEndDate,
                isMilestone: isMilestone,
                assigneeName: assigneeName,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectLocalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectLocalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectLocalId,
                                referencedTable: $$ProjectTasksTableReferences
                                    ._projectLocalIdTable(db),
                                referencedColumn: $$ProjectTasksTableReferences
                                    ._projectLocalIdTable(db)
                                    .localId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProjectTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectTasksTable,
      ProjectTaskRow,
      $$ProjectTasksTableFilterComposer,
      $$ProjectTasksTableOrderingComposer,
      $$ProjectTasksTableAnnotationComposer,
      $$ProjectTasksTableCreateCompanionBuilder,
      $$ProjectTasksTableUpdateCompanionBuilder,
      (ProjectTaskRow, $$ProjectTasksTableReferences),
      ProjectTaskRow,
      PrefetchHooks Function({bool projectLocalId})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String localId,
      Value<int?> serverId,
      required String name,
      Value<String> content,
      Value<String?> beginViewDate,
      Value<String?> endViewDate,
      Value<bool> isPlanned,
      Value<String?> begin,
      Value<String?> end,
      Value<int> state,
      Value<bool> isMine,
      Value<bool> pending,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> localId,
      Value<int?> serverId,
      Value<String> name,
      Value<String> content,
      Value<String?> beginViewDate,
      Value<String?> endViewDate,
      Value<bool> isPlanned,
      Value<String?> begin,
      Value<String?> end,
      Value<int> state,
      Value<bool> isMine,
      Value<bool> pending,
      Value<int> rowid,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beginViewDate => $composableBuilder(
    column: $table.beginViewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endViewDate => $composableBuilder(
    column: $table.endViewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlanned => $composableBuilder(
    column: $table.isPlanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get begin => $composableBuilder(
    column: $table.begin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beginViewDate => $composableBuilder(
    column: $table.beginViewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endViewDate => $composableBuilder(
    column: $table.endViewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlanned => $composableBuilder(
    column: $table.isPlanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get begin => $composableBuilder(
    column: $table.begin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get beginViewDate => $composableBuilder(
    column: $table.beginViewDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endViewDate => $composableBuilder(
    column: $table.endViewDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlanned =>
      $composableBuilder(column: $table.isPlanned, builder: (column) => column);

  GeneratedColumn<String> get begin =>
      $composableBuilder(column: $table.begin, builder: (column) => column);

  GeneratedColumn<String> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get isMine =>
      $composableBuilder(column: $table.isMine, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> beginViewDate = const Value.absent(),
                Value<String?> endViewDate = const Value.absent(),
                Value<bool> isPlanned = const Value.absent(),
                Value<String?> begin = const Value.absent(),
                Value<String?> end = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<bool> isMine = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                localId: localId,
                serverId: serverId,
                name: name,
                content: content,
                beginViewDate: beginViewDate,
                endViewDate: endViewDate,
                isPlanned: isPlanned,
                begin: begin,
                end: end,
                state: state,
                isMine: isMine,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<int?> serverId = const Value.absent(),
                required String name,
                Value<String> content = const Value.absent(),
                Value<String?> beginViewDate = const Value.absent(),
                Value<String?> endViewDate = const Value.absent(),
                Value<bool> isPlanned = const Value.absent(),
                Value<String?> begin = const Value.absent(),
                Value<String?> end = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<bool> isMine = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                localId: localId,
                serverId: serverId,
                name: name,
                content: content,
                beginViewDate: beginViewDate,
                endViewDate: endViewDate,
                isPlanned: isPlanned,
                begin: begin,
                end: end,
                state: state,
                isMine: isMine,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;
typedef $$KbCategoriesTableCreateCompanionBuilder =
    KbCategoriesCompanion Function({
      Value<int> serverId,
      required String name,
      Value<String> completename,
    });
typedef $$KbCategoriesTableUpdateCompanionBuilder =
    KbCategoriesCompanion Function({
      Value<int> serverId,
      Value<String> name,
      Value<String> completename,
    });

class $$KbCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $KbCategoriesTable> {
  $$KbCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completename => $composableBuilder(
    column: $table.completename,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KbCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $KbCategoriesTable> {
  $$KbCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completename => $composableBuilder(
    column: $table.completename,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KbCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KbCategoriesTable> {
  $$KbCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get completename => $composableBuilder(
    column: $table.completename,
    builder: (column) => column,
  );
}

class $$KbCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KbCategoriesTable,
          KbCategoryRow,
          $$KbCategoriesTableFilterComposer,
          $$KbCategoriesTableOrderingComposer,
          $$KbCategoriesTableAnnotationComposer,
          $$KbCategoriesTableCreateCompanionBuilder,
          $$KbCategoriesTableUpdateCompanionBuilder,
          (
            KbCategoryRow,
            BaseReferences<_$AppDatabase, $KbCategoriesTable, KbCategoryRow>,
          ),
          KbCategoryRow,
          PrefetchHooks Function()
        > {
  $$KbCategoriesTableTableManager(_$AppDatabase db, $KbCategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KbCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KbCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KbCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> completename = const Value.absent(),
              }) => KbCategoriesCompanion(
                serverId: serverId,
                name: name,
                completename: completename,
              ),
          createCompanionCallback:
              ({
                Value<int> serverId = const Value.absent(),
                required String name,
                Value<String> completename = const Value.absent(),
              }) => KbCategoriesCompanion.insert(
                serverId: serverId,
                name: name,
                completename: completename,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KbCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KbCategoriesTable,
      KbCategoryRow,
      $$KbCategoriesTableFilterComposer,
      $$KbCategoriesTableOrderingComposer,
      $$KbCategoriesTableAnnotationComposer,
      $$KbCategoriesTableCreateCompanionBuilder,
      $$KbCategoriesTableUpdateCompanionBuilder,
      (
        KbCategoryRow,
        BaseReferences<_$AppDatabase, $KbCategoriesTable, KbCategoryRow>,
      ),
      KbCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$KbArticlesTableCreateCompanionBuilder =
    KbArticlesCompanion Function({
      Value<int> serverId,
      required String name,
      Value<String> contentHtml,
      Value<int?> categoryId,
      Value<String?> categoryName,
      Value<bool> isFaq,
      Value<int> views,
      Value<String?> dateMod,
      Value<bool> keepOffline,
    });
typedef $$KbArticlesTableUpdateCompanionBuilder =
    KbArticlesCompanion Function({
      Value<int> serverId,
      Value<String> name,
      Value<String> contentHtml,
      Value<int?> categoryId,
      Value<String?> categoryName,
      Value<bool> isFaq,
      Value<int> views,
      Value<String?> dateMod,
      Value<bool> keepOffline,
    });

class $$KbArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $KbArticlesTable> {
  $$KbArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFaq => $composableBuilder(
    column: $table.isFaq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get views => $composableBuilder(
    column: $table.views,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateMod => $composableBuilder(
    column: $table.dateMod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepOffline => $composableBuilder(
    column: $table.keepOffline,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KbArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $KbArticlesTable> {
  $$KbArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFaq => $composableBuilder(
    column: $table.isFaq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get views => $composableBuilder(
    column: $table.views,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateMod => $composableBuilder(
    column: $table.dateMod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepOffline => $composableBuilder(
    column: $table.keepOffline,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KbArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KbArticlesTable> {
  $$KbArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFaq =>
      $composableBuilder(column: $table.isFaq, builder: (column) => column);

  GeneratedColumn<int> get views =>
      $composableBuilder(column: $table.views, builder: (column) => column);

  GeneratedColumn<String> get dateMod =>
      $composableBuilder(column: $table.dateMod, builder: (column) => column);

  GeneratedColumn<bool> get keepOffline => $composableBuilder(
    column: $table.keepOffline,
    builder: (column) => column,
  );
}

class $$KbArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KbArticlesTable,
          KbArticleRow,
          $$KbArticlesTableFilterComposer,
          $$KbArticlesTableOrderingComposer,
          $$KbArticlesTableAnnotationComposer,
          $$KbArticlesTableCreateCompanionBuilder,
          $$KbArticlesTableUpdateCompanionBuilder,
          (
            KbArticleRow,
            BaseReferences<_$AppDatabase, $KbArticlesTable, KbArticleRow>,
          ),
          KbArticleRow,
          PrefetchHooks Function()
        > {
  $$KbArticlesTableTableManager(_$AppDatabase db, $KbArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KbArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KbArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KbArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> contentHtml = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<bool> isFaq = const Value.absent(),
                Value<int> views = const Value.absent(),
                Value<String?> dateMod = const Value.absent(),
                Value<bool> keepOffline = const Value.absent(),
              }) => KbArticlesCompanion(
                serverId: serverId,
                name: name,
                contentHtml: contentHtml,
                categoryId: categoryId,
                categoryName: categoryName,
                isFaq: isFaq,
                views: views,
                dateMod: dateMod,
                keepOffline: keepOffline,
              ),
          createCompanionCallback:
              ({
                Value<int> serverId = const Value.absent(),
                required String name,
                Value<String> contentHtml = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<bool> isFaq = const Value.absent(),
                Value<int> views = const Value.absent(),
                Value<String?> dateMod = const Value.absent(),
                Value<bool> keepOffline = const Value.absent(),
              }) => KbArticlesCompanion.insert(
                serverId: serverId,
                name: name,
                contentHtml: contentHtml,
                categoryId: categoryId,
                categoryName: categoryName,
                isFaq: isFaq,
                views: views,
                dateMod: dateMod,
                keepOffline: keepOffline,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KbArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KbArticlesTable,
      KbArticleRow,
      $$KbArticlesTableFilterComposer,
      $$KbArticlesTableOrderingComposer,
      $$KbArticlesTableAnnotationComposer,
      $$KbArticlesTableCreateCompanionBuilder,
      $$KbArticlesTableUpdateCompanionBuilder,
      (
        KbArticleRow,
        BaseReferences<_$AppDatabase, $KbArticlesTable, KbArticleRow>,
      ),
      KbArticleRow,
      PrefetchHooks Function()
    >;
typedef $$CatalogItemsTableCreateCompanionBuilder =
    CatalogItemsCompanion Function({
      required String localId,
      required String domain,
      required String itemtype,
      required int serverId,
      Value<String> name,
      Value<String?> serial,
      Value<String?> otherserial,
      Value<String?> statusName,
      Value<String?> locationName,
      Value<String?> userName,
      Value<String?> groupName,
      Value<String?> manufacturerName,
      Value<String?> modelName,
      Value<String?> typeName,
      Value<String?> entityLabel,
      Value<String?> expiryDate,
      Value<String?> dateMod,
      Value<String> fieldsJson,
      Value<bool> pending,
      Value<int> rowid,
    });
typedef $$CatalogItemsTableUpdateCompanionBuilder =
    CatalogItemsCompanion Function({
      Value<String> localId,
      Value<String> domain,
      Value<String> itemtype,
      Value<int> serverId,
      Value<String> name,
      Value<String?> serial,
      Value<String?> otherserial,
      Value<String?> statusName,
      Value<String?> locationName,
      Value<String?> userName,
      Value<String?> groupName,
      Value<String?> manufacturerName,
      Value<String?> modelName,
      Value<String?> typeName,
      Value<String?> entityLabel,
      Value<String?> expiryDate,
      Value<String?> dateMod,
      Value<String> fieldsJson,
      Value<bool> pending,
      Value<int> rowid,
    });

class $$CatalogItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemtype => $composableBuilder(
    column: $table.itemtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherserial => $composableBuilder(
    column: $table.otherserial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturerName => $composableBuilder(
    column: $table.manufacturerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateMod => $composableBuilder(
    column: $table.dateMod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemtype => $composableBuilder(
    column: $table.itemtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherserial => $composableBuilder(
    column: $table.otherserial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturerName => $composableBuilder(
    column: $table.manufacturerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateMod => $composableBuilder(
    column: $table.dateMod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get itemtype =>
      $composableBuilder(column: $table.itemtype, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<String> get otherserial => $composableBuilder(
    column: $table.otherserial,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusName => $composableBuilder(
    column: $table.statusName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get manufacturerName => $composableBuilder(
    column: $table.manufacturerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get typeName =>
      $composableBuilder(column: $table.typeName, builder: (column) => column);

  GeneratedColumn<String> get entityLabel => $composableBuilder(
    column: $table.entityLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateMod =>
      $composableBuilder(column: $table.dateMod, builder: (column) => column);

  GeneratedColumn<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$CatalogItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogItemsTable,
          CatalogItemRow,
          $$CatalogItemsTableFilterComposer,
          $$CatalogItemsTableOrderingComposer,
          $$CatalogItemsTableAnnotationComposer,
          $$CatalogItemsTableCreateCompanionBuilder,
          $$CatalogItemsTableUpdateCompanionBuilder,
          (
            CatalogItemRow,
            BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItemRow>,
          ),
          CatalogItemRow,
          PrefetchHooks Function()
        > {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> itemtype = const Value.absent(),
                Value<int> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> serial = const Value.absent(),
                Value<String?> otherserial = const Value.absent(),
                Value<String?> statusName = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<String?> manufacturerName = const Value.absent(),
                Value<String?> modelName = const Value.absent(),
                Value<String?> typeName = const Value.absent(),
                Value<String?> entityLabel = const Value.absent(),
                Value<String?> expiryDate = const Value.absent(),
                Value<String?> dateMod = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsCompanion(
                localId: localId,
                domain: domain,
                itemtype: itemtype,
                serverId: serverId,
                name: name,
                serial: serial,
                otherserial: otherserial,
                statusName: statusName,
                locationName: locationName,
                userName: userName,
                groupName: groupName,
                manufacturerName: manufacturerName,
                modelName: modelName,
                typeName: typeName,
                entityLabel: entityLabel,
                expiryDate: expiryDate,
                dateMod: dateMod,
                fieldsJson: fieldsJson,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String domain,
                required String itemtype,
                required int serverId,
                Value<String> name = const Value.absent(),
                Value<String?> serial = const Value.absent(),
                Value<String?> otherserial = const Value.absent(),
                Value<String?> statusName = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<String?> manufacturerName = const Value.absent(),
                Value<String?> modelName = const Value.absent(),
                Value<String?> typeName = const Value.absent(),
                Value<String?> entityLabel = const Value.absent(),
                Value<String?> expiryDate = const Value.absent(),
                Value<String?> dateMod = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsCompanion.insert(
                localId: localId,
                domain: domain,
                itemtype: itemtype,
                serverId: serverId,
                name: name,
                serial: serial,
                otherserial: otherserial,
                statusName: statusName,
                locationName: locationName,
                userName: userName,
                groupName: groupName,
                manufacturerName: manufacturerName,
                modelName: modelName,
                typeName: typeName,
                entityLabel: entityLabel,
                expiryDate: expiryDate,
                dateMod: dateMod,
                fieldsJson: fieldsJson,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogItemsTable,
      CatalogItemRow,
      $$CatalogItemsTableFilterComposer,
      $$CatalogItemsTableOrderingComposer,
      $$CatalogItemsTableAnnotationComposer,
      $$CatalogItemsTableCreateCompanionBuilder,
      $$CatalogItemsTableUpdateCompanionBuilder,
      (
        CatalogItemRow,
        BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItemRow>,
      ),
      CatalogItemRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TicketsTableTableManager get tickets =>
      $$TicketsTableTableManager(_db, _db.tickets);
  $$TicketTeamTableTableManager get ticketTeam =>
      $$TicketTeamTableTableManager(_db, _db.ticketTeam);
  $$TimelineItemsTableTableManager get timelineItems =>
      $$TimelineItemsTableTableManager(_db, _db.timelineItems);
  $$DropdownItemsTableTableManager get dropdownItems =>
      $$DropdownItemsTableTableManager(_db, _db.dropdownItems);
  $$PendingOpsTableTableManager get pendingOps =>
      $$PendingOpsTableTableManager(_db, _db.pendingOps);
  $$ActiveTimersTableTableManager get activeTimers =>
      $$ActiveTimersTableTableManager(_db, _db.activeTimers);
  $$AppConfigTableTableManager get appConfig =>
      $$AppConfigTableTableManager(_db, _db.appConfig);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$ItilLinksTableTableManager get itilLinks =>
      $$ItilLinksTableTableManager(_db, _db.itilLinks);
  $$ItilExtrasTableTableManager get itilExtras =>
      $$ItilExtrasTableTableManager(_db, _db.itilExtras);
  $$PlanningEventsTableTableManager get planningEvents =>
      $$PlanningEventsTableTableManager(_db, _db.planningEvents);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ProjectTasksTableTableManager get projectTasks =>
      $$ProjectTasksTableTableManager(_db, _db.projectTasks);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$KbCategoriesTableTableManager get kbCategories =>
      $$KbCategoriesTableTableManager(_db, _db.kbCategories);
  $$KbArticlesTableTableManager get kbArticles =>
      $$KbArticlesTableTableManager(_db, _db.kbArticles);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
}
