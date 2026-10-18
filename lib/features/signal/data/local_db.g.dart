// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $LocalCrosswalksTable extends LocalCrosswalks
    with TableInfo<$LocalCrosswalksTable, LocalCrosswalk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCrosswalksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aLatMeta = const VerificationMeta('aLat');
  @override
  late final GeneratedColumn<double> aLat = GeneratedColumn<double>(
    'a_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aLngMeta = const VerificationMeta('aLng');
  @override
  late final GeneratedColumn<double> aLng = GeneratedColumn<double>(
    'a_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bLatMeta = const VerificationMeta('bLat');
  @override
  late final GeneratedColumn<double> bLat = GeneratedColumn<double>(
    'b_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bLngMeta = const VerificationMeta('bLng');
  @override
  late final GeneratedColumn<double> bLng = GeneratedColumn<double>(
    'b_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scrambleMeta = const VerificationMeta(
    'scramble',
  );
  @override
  late final GeneratedColumn<bool> scramble = GeneratedColumn<bool>(
    'scramble',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("scramble" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _buttonMarkedMeta = const VerificationMeta(
    'buttonMarked',
  );
  @override
  late final GeneratedColumn<bool> buttonMarked = GeneratedColumn<bool>(
    'button_marked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("button_marked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    aLat,
    aLng,
    bLat,
    bLng,
    name,
    groupId,
    scramble,
    buttonMarked,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_crosswalks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCrosswalk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('a_lat')) {
      context.handle(
        _aLatMeta,
        aLat.isAcceptableOrUnknown(data['a_lat']!, _aLatMeta),
      );
    }
    if (data.containsKey('a_lng')) {
      context.handle(
        _aLngMeta,
        aLng.isAcceptableOrUnknown(data['a_lng']!, _aLngMeta),
      );
    }
    if (data.containsKey('b_lat')) {
      context.handle(
        _bLatMeta,
        bLat.isAcceptableOrUnknown(data['b_lat']!, _bLatMeta),
      );
    }
    if (data.containsKey('b_lng')) {
      context.handle(
        _bLngMeta,
        bLng.isAcceptableOrUnknown(data['b_lng']!, _bLngMeta),
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
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('scramble')) {
      context.handle(
        _scrambleMeta,
        scramble.isAcceptableOrUnknown(data['scramble']!, _scrambleMeta),
      );
    }
    if (data.containsKey('button_marked')) {
      context.handle(
        _buttonMarkedMeta,
        buttonMarked.isAcceptableOrUnknown(
          data['button_marked']!,
          _buttonMarkedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCrosswalk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCrosswalk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      aLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}a_lat'],
      ),
      aLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}a_lng'],
      ),
      bLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}b_lat'],
      ),
      bLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}b_lng'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      scramble: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}scramble'],
      )!,
      buttonMarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}button_marked'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalCrosswalksTable createAlias(String alias) {
    return $LocalCrosswalksTable(attachedDatabase, alias);
  }
}

class LocalCrosswalk extends DataClass implements Insertable<LocalCrosswalk> {
  final String id;

  /// 끝점. 비어 있으면 위치 없는 나만 보기 신호등 (D-074). v5부터 비울 수 있다
  final double? aLat;
  final double? aLng;
  final double? bLat;
  final double? bLng;
  final String name;

  /// 신호 그룹 (FR-03-D-05). v3에서 추가 — 기존 행은 자기 id
  final String groupId;

  /// 전방향 동시 보행으로 묶인 그룹 (FR-03-C-03). 업로드 때 서버에 그대로 전한다. v4에서 추가
  final bool scramble;

  /// 버튼식 표시 (FR-04-D-02, D-042). 기기 기록은 사용자 1명이라 늘 "검증 전". v4에서 추가
  final bool buttonMarked;
  final DateTime createdAt;
  const LocalCrosswalk({
    required this.id,
    this.aLat,
    this.aLng,
    this.bLat,
    this.bLng,
    required this.name,
    required this.groupId,
    required this.scramble,
    required this.buttonMarked,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || aLat != null) {
      map['a_lat'] = Variable<double>(aLat);
    }
    if (!nullToAbsent || aLng != null) {
      map['a_lng'] = Variable<double>(aLng);
    }
    if (!nullToAbsent || bLat != null) {
      map['b_lat'] = Variable<double>(bLat);
    }
    if (!nullToAbsent || bLng != null) {
      map['b_lng'] = Variable<double>(bLng);
    }
    map['name'] = Variable<String>(name);
    map['group_id'] = Variable<String>(groupId);
    map['scramble'] = Variable<bool>(scramble);
    map['button_marked'] = Variable<bool>(buttonMarked);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalCrosswalksCompanion toCompanion(bool nullToAbsent) {
    return LocalCrosswalksCompanion(
      id: Value(id),
      aLat: aLat == null && nullToAbsent ? const Value.absent() : Value(aLat),
      aLng: aLng == null && nullToAbsent ? const Value.absent() : Value(aLng),
      bLat: bLat == null && nullToAbsent ? const Value.absent() : Value(bLat),
      bLng: bLng == null && nullToAbsent ? const Value.absent() : Value(bLng),
      name: Value(name),
      groupId: Value(groupId),
      scramble: Value(scramble),
      buttonMarked: Value(buttonMarked),
      createdAt: Value(createdAt),
    );
  }

  factory LocalCrosswalk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCrosswalk(
      id: serializer.fromJson<String>(json['id']),
      aLat: serializer.fromJson<double?>(json['aLat']),
      aLng: serializer.fromJson<double?>(json['aLng']),
      bLat: serializer.fromJson<double?>(json['bLat']),
      bLng: serializer.fromJson<double?>(json['bLng']),
      name: serializer.fromJson<String>(json['name']),
      groupId: serializer.fromJson<String>(json['groupId']),
      scramble: serializer.fromJson<bool>(json['scramble']),
      buttonMarked: serializer.fromJson<bool>(json['buttonMarked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'aLat': serializer.toJson<double?>(aLat),
      'aLng': serializer.toJson<double?>(aLng),
      'bLat': serializer.toJson<double?>(bLat),
      'bLng': serializer.toJson<double?>(bLng),
      'name': serializer.toJson<String>(name),
      'groupId': serializer.toJson<String>(groupId),
      'scramble': serializer.toJson<bool>(scramble),
      'buttonMarked': serializer.toJson<bool>(buttonMarked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalCrosswalk copyWith({
    String? id,
    Value<double?> aLat = const Value.absent(),
    Value<double?> aLng = const Value.absent(),
    Value<double?> bLat = const Value.absent(),
    Value<double?> bLng = const Value.absent(),
    String? name,
    String? groupId,
    bool? scramble,
    bool? buttonMarked,
    DateTime? createdAt,
  }) => LocalCrosswalk(
    id: id ?? this.id,
    aLat: aLat.present ? aLat.value : this.aLat,
    aLng: aLng.present ? aLng.value : this.aLng,
    bLat: bLat.present ? bLat.value : this.bLat,
    bLng: bLng.present ? bLng.value : this.bLng,
    name: name ?? this.name,
    groupId: groupId ?? this.groupId,
    scramble: scramble ?? this.scramble,
    buttonMarked: buttonMarked ?? this.buttonMarked,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalCrosswalk copyWithCompanion(LocalCrosswalksCompanion data) {
    return LocalCrosswalk(
      id: data.id.present ? data.id.value : this.id,
      aLat: data.aLat.present ? data.aLat.value : this.aLat,
      aLng: data.aLng.present ? data.aLng.value : this.aLng,
      bLat: data.bLat.present ? data.bLat.value : this.bLat,
      bLng: data.bLng.present ? data.bLng.value : this.bLng,
      name: data.name.present ? data.name.value : this.name,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      scramble: data.scramble.present ? data.scramble.value : this.scramble,
      buttonMarked: data.buttonMarked.present
          ? data.buttonMarked.value
          : this.buttonMarked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCrosswalk(')
          ..write('id: $id, ')
          ..write('aLat: $aLat, ')
          ..write('aLng: $aLng, ')
          ..write('bLat: $bLat, ')
          ..write('bLng: $bLng, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('scramble: $scramble, ')
          ..write('buttonMarked: $buttonMarked, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    aLat,
    aLng,
    bLat,
    bLng,
    name,
    groupId,
    scramble,
    buttonMarked,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCrosswalk &&
          other.id == this.id &&
          other.aLat == this.aLat &&
          other.aLng == this.aLng &&
          other.bLat == this.bLat &&
          other.bLng == this.bLng &&
          other.name == this.name &&
          other.groupId == this.groupId &&
          other.scramble == this.scramble &&
          other.buttonMarked == this.buttonMarked &&
          other.createdAt == this.createdAt);
}

class LocalCrosswalksCompanion extends UpdateCompanion<LocalCrosswalk> {
  final Value<String> id;
  final Value<double?> aLat;
  final Value<double?> aLng;
  final Value<double?> bLat;
  final Value<double?> bLng;
  final Value<String> name;
  final Value<String> groupId;
  final Value<bool> scramble;
  final Value<bool> buttonMarked;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalCrosswalksCompanion({
    this.id = const Value.absent(),
    this.aLat = const Value.absent(),
    this.aLng = const Value.absent(),
    this.bLat = const Value.absent(),
    this.bLng = const Value.absent(),
    this.name = const Value.absent(),
    this.groupId = const Value.absent(),
    this.scramble = const Value.absent(),
    this.buttonMarked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCrosswalksCompanion.insert({
    required String id,
    this.aLat = const Value.absent(),
    this.aLng = const Value.absent(),
    this.bLat = const Value.absent(),
    this.bLng = const Value.absent(),
    required String name,
    this.groupId = const Value.absent(),
    this.scramble = const Value.absent(),
    this.buttonMarked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<LocalCrosswalk> custom({
    Expression<String>? id,
    Expression<double>? aLat,
    Expression<double>? aLng,
    Expression<double>? bLat,
    Expression<double>? bLng,
    Expression<String>? name,
    Expression<String>? groupId,
    Expression<bool>? scramble,
    Expression<bool>? buttonMarked,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aLat != null) 'a_lat': aLat,
      if (aLng != null) 'a_lng': aLng,
      if (bLat != null) 'b_lat': bLat,
      if (bLng != null) 'b_lng': bLng,
      if (name != null) 'name': name,
      if (groupId != null) 'group_id': groupId,
      if (scramble != null) 'scramble': scramble,
      if (buttonMarked != null) 'button_marked': buttonMarked,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCrosswalksCompanion copyWith({
    Value<String>? id,
    Value<double?>? aLat,
    Value<double?>? aLng,
    Value<double?>? bLat,
    Value<double?>? bLng,
    Value<String>? name,
    Value<String>? groupId,
    Value<bool>? scramble,
    Value<bool>? buttonMarked,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalCrosswalksCompanion(
      id: id ?? this.id,
      aLat: aLat ?? this.aLat,
      aLng: aLng ?? this.aLng,
      bLat: bLat ?? this.bLat,
      bLng: bLng ?? this.bLng,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      scramble: scramble ?? this.scramble,
      buttonMarked: buttonMarked ?? this.buttonMarked,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (aLat.present) {
      map['a_lat'] = Variable<double>(aLat.value);
    }
    if (aLng.present) {
      map['a_lng'] = Variable<double>(aLng.value);
    }
    if (bLat.present) {
      map['b_lat'] = Variable<double>(bLat.value);
    }
    if (bLng.present) {
      map['b_lng'] = Variable<double>(bLng.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (scramble.present) {
      map['scramble'] = Variable<bool>(scramble.value);
    }
    if (buttonMarked.present) {
      map['button_marked'] = Variable<bool>(buttonMarked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCrosswalksCompanion(')
          ..write('id: $id, ')
          ..write('aLat: $aLat, ')
          ..write('aLng: $aLng, ')
          ..write('bLat: $bLat, ')
          ..write('bLng: $bLng, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('scramble: $scramble, ')
          ..write('buttonMarked: $buttonMarked, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRecordsTable extends LocalRecords
    with TableInfo<$LocalRecordsTable, LocalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _crosswalkIdMeta = const VerificationMeta(
    'crosswalkId',
  );
  @override
  late final GeneratedColumn<String> crosswalkId = GeneratedColumn<String>(
    'crosswalk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_crosswalks (id)',
    ),
  );
  static const VerificationMeta _cycleMeta = const VerificationMeta('cycle');
  @override
  late final GeneratedColumn<int> cycle = GeneratedColumn<int>(
    'cycle',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _greenMeta = const VerificationMeta('green');
  @override
  late final GeneratedColumn<int> green = GeneratedColumn<int>(
    'green',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<double> phase = GeneratedColumn<double>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<double> at = GeneratedColumn<double>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekendMeta = const VerificationMeta(
    'weekend',
  );
  @override
  late final GeneratedColumn<bool> weekend = GeneratedColumn<bool>(
    'weekend',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weekend" IN (0, 1))',
    ),
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tapsJsonMeta = const VerificationMeta(
    'tapsJson',
  );
  @override
  late final GeneratedColumn<String> tapsJson = GeneratedColumn<String>(
    'taps_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    crosswalkId,
    cycle,
    green,
    phase,
    at,
    weekend,
    hour,
    tapsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('crosswalk_id')) {
      context.handle(
        _crosswalkIdMeta,
        crosswalkId.isAcceptableOrUnknown(
          data['crosswalk_id']!,
          _crosswalkIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_crosswalkIdMeta);
    }
    if (data.containsKey('cycle')) {
      context.handle(
        _cycleMeta,
        cycle.isAcceptableOrUnknown(data['cycle']!, _cycleMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleMeta);
    }
    if (data.containsKey('green')) {
      context.handle(
        _greenMeta,
        green.isAcceptableOrUnknown(data['green']!, _greenMeta),
      );
    } else if (isInserting) {
      context.missing(_greenMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('weekend')) {
      context.handle(
        _weekendMeta,
        weekend.isAcceptableOrUnknown(data['weekend']!, _weekendMeta),
      );
    } else if (isInserting) {
      context.missing(_weekendMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('taps_json')) {
      context.handle(
        _tapsJsonMeta,
        tapsJson.isAcceptableOrUnknown(data['taps_json']!, _tapsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      crosswalkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crosswalk_id'],
      )!,
      cycle: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle'],
      )!,
      green: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}green'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}phase'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}at'],
      )!,
      weekend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekend'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      tapsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taps_json'],
      )!,
    );
  }

  @override
  $LocalRecordsTable createAlias(String alias) {
    return $LocalRecordsTable(attachedDatabase, alias);
  }
}

class LocalRecord extends DataClass implements Insertable<LocalRecord> {
  final int id;
  final String crosswalkId;
  final int cycle;
  final int green;
  final double phase;

  /// 기준 시점 (epoch 초)
  final double at;
  final bool weekend;
  final int hour;

  /// 탭 3회 원본 JSON — 로그인 후 업로드에 쓴다 (FR-08-D-02). v2에서 추가
  final String tapsJson;
  const LocalRecord({
    required this.id,
    required this.crosswalkId,
    required this.cycle,
    required this.green,
    required this.phase,
    required this.at,
    required this.weekend,
    required this.hour,
    required this.tapsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['crosswalk_id'] = Variable<String>(crosswalkId);
    map['cycle'] = Variable<int>(cycle);
    map['green'] = Variable<int>(green);
    map['phase'] = Variable<double>(phase);
    map['at'] = Variable<double>(at);
    map['weekend'] = Variable<bool>(weekend);
    map['hour'] = Variable<int>(hour);
    map['taps_json'] = Variable<String>(tapsJson);
    return map;
  }

  LocalRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalRecordsCompanion(
      id: Value(id),
      crosswalkId: Value(crosswalkId),
      cycle: Value(cycle),
      green: Value(green),
      phase: Value(phase),
      at: Value(at),
      weekend: Value(weekend),
      hour: Value(hour),
      tapsJson: Value(tapsJson),
    );
  }

  factory LocalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecord(
      id: serializer.fromJson<int>(json['id']),
      crosswalkId: serializer.fromJson<String>(json['crosswalkId']),
      cycle: serializer.fromJson<int>(json['cycle']),
      green: serializer.fromJson<int>(json['green']),
      phase: serializer.fromJson<double>(json['phase']),
      at: serializer.fromJson<double>(json['at']),
      weekend: serializer.fromJson<bool>(json['weekend']),
      hour: serializer.fromJson<int>(json['hour']),
      tapsJson: serializer.fromJson<String>(json['tapsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'crosswalkId': serializer.toJson<String>(crosswalkId),
      'cycle': serializer.toJson<int>(cycle),
      'green': serializer.toJson<int>(green),
      'phase': serializer.toJson<double>(phase),
      'at': serializer.toJson<double>(at),
      'weekend': serializer.toJson<bool>(weekend),
      'hour': serializer.toJson<int>(hour),
      'tapsJson': serializer.toJson<String>(tapsJson),
    };
  }

  LocalRecord copyWith({
    int? id,
    String? crosswalkId,
    int? cycle,
    int? green,
    double? phase,
    double? at,
    bool? weekend,
    int? hour,
    String? tapsJson,
  }) => LocalRecord(
    id: id ?? this.id,
    crosswalkId: crosswalkId ?? this.crosswalkId,
    cycle: cycle ?? this.cycle,
    green: green ?? this.green,
    phase: phase ?? this.phase,
    at: at ?? this.at,
    weekend: weekend ?? this.weekend,
    hour: hour ?? this.hour,
    tapsJson: tapsJson ?? this.tapsJson,
  );
  LocalRecord copyWithCompanion(LocalRecordsCompanion data) {
    return LocalRecord(
      id: data.id.present ? data.id.value : this.id,
      crosswalkId: data.crosswalkId.present
          ? data.crosswalkId.value
          : this.crosswalkId,
      cycle: data.cycle.present ? data.cycle.value : this.cycle,
      green: data.green.present ? data.green.value : this.green,
      phase: data.phase.present ? data.phase.value : this.phase,
      at: data.at.present ? data.at.value : this.at,
      weekend: data.weekend.present ? data.weekend.value : this.weekend,
      hour: data.hour.present ? data.hour.value : this.hour,
      tapsJson: data.tapsJson.present ? data.tapsJson.value : this.tapsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecord(')
          ..write('id: $id, ')
          ..write('crosswalkId: $crosswalkId, ')
          ..write('cycle: $cycle, ')
          ..write('green: $green, ')
          ..write('phase: $phase, ')
          ..write('at: $at, ')
          ..write('weekend: $weekend, ')
          ..write('hour: $hour, ')
          ..write('tapsJson: $tapsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    crosswalkId,
    cycle,
    green,
    phase,
    at,
    weekend,
    hour,
    tapsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecord &&
          other.id == this.id &&
          other.crosswalkId == this.crosswalkId &&
          other.cycle == this.cycle &&
          other.green == this.green &&
          other.phase == this.phase &&
          other.at == this.at &&
          other.weekend == this.weekend &&
          other.hour == this.hour &&
          other.tapsJson == this.tapsJson);
}

class LocalRecordsCompanion extends UpdateCompanion<LocalRecord> {
  final Value<int> id;
  final Value<String> crosswalkId;
  final Value<int> cycle;
  final Value<int> green;
  final Value<double> phase;
  final Value<double> at;
  final Value<bool> weekend;
  final Value<int> hour;
  final Value<String> tapsJson;
  const LocalRecordsCompanion({
    this.id = const Value.absent(),
    this.crosswalkId = const Value.absent(),
    this.cycle = const Value.absent(),
    this.green = const Value.absent(),
    this.phase = const Value.absent(),
    this.at = const Value.absent(),
    this.weekend = const Value.absent(),
    this.hour = const Value.absent(),
    this.tapsJson = const Value.absent(),
  });
  LocalRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String crosswalkId,
    required int cycle,
    required int green,
    required double phase,
    required double at,
    required bool weekend,
    required int hour,
    this.tapsJson = const Value.absent(),
  }) : crosswalkId = Value(crosswalkId),
       cycle = Value(cycle),
       green = Value(green),
       phase = Value(phase),
       at = Value(at),
       weekend = Value(weekend),
       hour = Value(hour);
  static Insertable<LocalRecord> custom({
    Expression<int>? id,
    Expression<String>? crosswalkId,
    Expression<int>? cycle,
    Expression<int>? green,
    Expression<double>? phase,
    Expression<double>? at,
    Expression<bool>? weekend,
    Expression<int>? hour,
    Expression<String>? tapsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (crosswalkId != null) 'crosswalk_id': crosswalkId,
      if (cycle != null) 'cycle': cycle,
      if (green != null) 'green': green,
      if (phase != null) 'phase': phase,
      if (at != null) 'at': at,
      if (weekend != null) 'weekend': weekend,
      if (hour != null) 'hour': hour,
      if (tapsJson != null) 'taps_json': tapsJson,
    });
  }

  LocalRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? crosswalkId,
    Value<int>? cycle,
    Value<int>? green,
    Value<double>? phase,
    Value<double>? at,
    Value<bool>? weekend,
    Value<int>? hour,
    Value<String>? tapsJson,
  }) {
    return LocalRecordsCompanion(
      id: id ?? this.id,
      crosswalkId: crosswalkId ?? this.crosswalkId,
      cycle: cycle ?? this.cycle,
      green: green ?? this.green,
      phase: phase ?? this.phase,
      at: at ?? this.at,
      weekend: weekend ?? this.weekend,
      hour: hour ?? this.hour,
      tapsJson: tapsJson ?? this.tapsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (crosswalkId.present) {
      map['crosswalk_id'] = Variable<String>(crosswalkId.value);
    }
    if (cycle.present) {
      map['cycle'] = Variable<int>(cycle.value);
    }
    if (green.present) {
      map['green'] = Variable<int>(green.value);
    }
    if (phase.present) {
      map['phase'] = Variable<double>(phase.value);
    }
    if (at.present) {
      map['at'] = Variable<double>(at.value);
    }
    if (weekend.present) {
      map['weekend'] = Variable<bool>(weekend.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (tapsJson.present) {
      map['taps_json'] = Variable<String>(tapsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('crosswalkId: $crosswalkId, ')
          ..write('cycle: $cycle, ')
          ..write('green: $green, ')
          ..write('phase: $phase, ')
          ..write('at: $at, ')
          ..write('weekend: $weekend, ')
          ..write('hour: $hour, ')
          ..write('tapsJson: $tapsJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDb extends GeneratedDatabase {
  _$LocalDb(QueryExecutor e) : super(e);
  $LocalDbManager get managers => $LocalDbManager(this);
  late final $LocalCrosswalksTable localCrosswalks = $LocalCrosswalksTable(
    this,
  );
  late final $LocalRecordsTable localRecords = $LocalRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localCrosswalks,
    localRecords,
  ];
}

typedef $$LocalCrosswalksTableCreateCompanionBuilder =
    LocalCrosswalksCompanion Function({
      required String id,
      Value<double?> aLat,
      Value<double?> aLng,
      Value<double?> bLat,
      Value<double?> bLng,
      required String name,
      Value<String> groupId,
      Value<bool> scramble,
      Value<bool> buttonMarked,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$LocalCrosswalksTableUpdateCompanionBuilder =
    LocalCrosswalksCompanion Function({
      Value<String> id,
      Value<double?> aLat,
      Value<double?> aLng,
      Value<double?> bLat,
      Value<double?> bLng,
      Value<String> name,
      Value<String> groupId,
      Value<bool> scramble,
      Value<bool> buttonMarked,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$LocalCrosswalksTableReferences
    extends BaseReferences<_$LocalDb, $LocalCrosswalksTable, LocalCrosswalk> {
  $$LocalCrosswalksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LocalRecordsTable, List<LocalRecord>>
  _localRecordsRefsTable(_$LocalDb db) => MultiTypedResultKey.fromTable(
    db.localRecords,
    aliasName: 'local_crosswalks__id__local_records__crosswalk_id',
  );

  $$LocalRecordsTableProcessedTableManager get localRecordsRefs {
    final manager = $$LocalRecordsTableTableManager(
      $_db,
      $_db.localRecords,
    ).filter((f) => f.crosswalkId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalCrosswalksTableFilterComposer
    extends Composer<_$LocalDb, $LocalCrosswalksTable> {
  $$LocalCrosswalksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aLat => $composableBuilder(
    column: $table.aLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aLng => $composableBuilder(
    column: $table.aLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bLat => $composableBuilder(
    column: $table.bLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bLng => $composableBuilder(
    column: $table.bLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get scramble => $composableBuilder(
    column: $table.scramble,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get buttonMarked => $composableBuilder(
    column: $table.buttonMarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localRecordsRefs(
    Expression<bool> Function($$LocalRecordsTableFilterComposer f) f,
  ) {
    final $$LocalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localRecords,
      getReferencedColumn: (t) => t.crosswalkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.localRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalCrosswalksTableOrderingComposer
    extends Composer<_$LocalDb, $LocalCrosswalksTable> {
  $$LocalCrosswalksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aLat => $composableBuilder(
    column: $table.aLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aLng => $composableBuilder(
    column: $table.aLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bLat => $composableBuilder(
    column: $table.bLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bLng => $composableBuilder(
    column: $table.bLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get scramble => $composableBuilder(
    column: $table.scramble,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get buttonMarked => $composableBuilder(
    column: $table.buttonMarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCrosswalksTableAnnotationComposer
    extends Composer<_$LocalDb, $LocalCrosswalksTable> {
  $$LocalCrosswalksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get aLat =>
      $composableBuilder(column: $table.aLat, builder: (column) => column);

  GeneratedColumn<double> get aLng =>
      $composableBuilder(column: $table.aLng, builder: (column) => column);

  GeneratedColumn<double> get bLat =>
      $composableBuilder(column: $table.bLat, builder: (column) => column);

  GeneratedColumn<double> get bLng =>
      $composableBuilder(column: $table.bLng, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<bool> get scramble =>
      $composableBuilder(column: $table.scramble, builder: (column) => column);

  GeneratedColumn<bool> get buttonMarked => $composableBuilder(
    column: $table.buttonMarked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> localRecordsRefs<T extends Object>(
    Expression<T> Function($$LocalRecordsTableAnnotationComposer a) f,
  ) {
    final $$LocalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localRecords,
      getReferencedColumn: (t) => t.crosswalkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.localRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalCrosswalksTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $LocalCrosswalksTable,
          LocalCrosswalk,
          $$LocalCrosswalksTableFilterComposer,
          $$LocalCrosswalksTableOrderingComposer,
          $$LocalCrosswalksTableAnnotationComposer,
          $$LocalCrosswalksTableCreateCompanionBuilder,
          $$LocalCrosswalksTableUpdateCompanionBuilder,
          (LocalCrosswalk, $$LocalCrosswalksTableReferences),
          LocalCrosswalk,
          PrefetchHooks Function({bool localRecordsRefs})
        > {
  $$LocalCrosswalksTableTableManager(_$LocalDb db, $LocalCrosswalksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCrosswalksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCrosswalksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCrosswalksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double?> aLat = const Value.absent(),
                Value<double?> aLng = const Value.absent(),
                Value<double?> bLat = const Value.absent(),
                Value<double?> bLng = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<bool> scramble = const Value.absent(),
                Value<bool> buttonMarked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCrosswalksCompanion(
                id: id,
                aLat: aLat,
                aLng: aLng,
                bLat: bLat,
                bLng: bLng,
                name: name,
                groupId: groupId,
                scramble: scramble,
                buttonMarked: buttonMarked,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<double?> aLat = const Value.absent(),
                Value<double?> aLng = const Value.absent(),
                Value<double?> bLat = const Value.absent(),
                Value<double?> bLng = const Value.absent(),
                required String name,
                Value<String> groupId = const Value.absent(),
                Value<bool> scramble = const Value.absent(),
                Value<bool> buttonMarked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCrosswalksCompanion.insert(
                id: id,
                aLat: aLat,
                aLng: aLng,
                bLat: bLat,
                bLng: bLng,
                name: name,
                groupId: groupId,
                scramble: scramble,
                buttonMarked: buttonMarked,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCrosswalksTable, LocalCrosswalk>(table),
                  $$LocalCrosswalksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (localRecordsRefs) db.localRecords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localRecordsRefs)
                    await $_getPrefetchedData<
                      LocalCrosswalk,
                      $LocalCrosswalksTable,
                      LocalRecord
                    >(
                      currentTable: table,
                      referencedTable: $$LocalCrosswalksTableReferences
                          ._localRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocalCrosswalksTableReferences(
                            db,
                            table,
                            p0,
                          ).localRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.crosswalkId == item.id,
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

typedef $$LocalCrosswalksTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $LocalCrosswalksTable,
      LocalCrosswalk,
      $$LocalCrosswalksTableFilterComposer,
      $$LocalCrosswalksTableOrderingComposer,
      $$LocalCrosswalksTableAnnotationComposer,
      $$LocalCrosswalksTableCreateCompanionBuilder,
      $$LocalCrosswalksTableUpdateCompanionBuilder,
      (LocalCrosswalk, $$LocalCrosswalksTableReferences),
      LocalCrosswalk,
      PrefetchHooks Function({bool localRecordsRefs})
    >;
typedef $$LocalRecordsTableCreateCompanionBuilder =
    LocalRecordsCompanion Function({
      Value<int> id,
      required String crosswalkId,
      required int cycle,
      required int green,
      required double phase,
      required double at,
      required bool weekend,
      required int hour,
      Value<String> tapsJson,
    });
typedef $$LocalRecordsTableUpdateCompanionBuilder =
    LocalRecordsCompanion Function({
      Value<int> id,
      Value<String> crosswalkId,
      Value<int> cycle,
      Value<int> green,
      Value<double> phase,
      Value<double> at,
      Value<bool> weekend,
      Value<int> hour,
      Value<String> tapsJson,
    });

final class $$LocalRecordsTableReferences
    extends BaseReferences<_$LocalDb, $LocalRecordsTable, LocalRecord> {
  $$LocalRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalCrosswalksTable _crosswalkIdTable(_$LocalDb db) => db
      .localCrosswalks
      .createAlias('local_records__crosswalk_id__local_crosswalks__id');

  $$LocalCrosswalksTableProcessedTableManager get crosswalkId {
    final $_column = $_itemColumn<String>('crosswalk_id')!;

    final manager = $$LocalCrosswalksTableTableManager(
      $_db,
      $_db.localCrosswalks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_crosswalkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalRecordsTableFilterComposer
    extends Composer<_$LocalDb, $LocalRecordsTable> {
  $$LocalRecordsTableFilterComposer({
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

  ColumnFilters<int> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get green => $composableBuilder(
    column: $table.green,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weekend => $composableBuilder(
    column: $table.weekend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tapsJson => $composableBuilder(
    column: $table.tapsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalCrosswalksTableFilterComposer get crosswalkId {
    final $$LocalCrosswalksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crosswalkId,
      referencedTable: $db.localCrosswalks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalCrosswalksTableFilterComposer(
            $db: $db,
            $table: $db.localCrosswalks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalRecordsTableOrderingComposer
    extends Composer<_$LocalDb, $LocalRecordsTable> {
  $$LocalRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get green => $composableBuilder(
    column: $table.green,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weekend => $composableBuilder(
    column: $table.weekend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tapsJson => $composableBuilder(
    column: $table.tapsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalCrosswalksTableOrderingComposer get crosswalkId {
    final $$LocalCrosswalksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crosswalkId,
      referencedTable: $db.localCrosswalks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalCrosswalksTableOrderingComposer(
            $db: $db,
            $table: $db.localCrosswalks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalRecordsTableAnnotationComposer
    extends Composer<_$LocalDb, $LocalRecordsTable> {
  $$LocalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycle =>
      $composableBuilder(column: $table.cycle, builder: (column) => column);

  GeneratedColumn<int> get green =>
      $composableBuilder(column: $table.green, builder: (column) => column);

  GeneratedColumn<double> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<double> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<bool> get weekend =>
      $composableBuilder(column: $table.weekend, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<String> get tapsJson =>
      $composableBuilder(column: $table.tapsJson, builder: (column) => column);

  $$LocalCrosswalksTableAnnotationComposer get crosswalkId {
    final $$LocalCrosswalksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crosswalkId,
      referencedTable: $db.localCrosswalks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalCrosswalksTableAnnotationComposer(
            $db: $db,
            $table: $db.localCrosswalks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalRecordsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $LocalRecordsTable,
          LocalRecord,
          $$LocalRecordsTableFilterComposer,
          $$LocalRecordsTableOrderingComposer,
          $$LocalRecordsTableAnnotationComposer,
          $$LocalRecordsTableCreateCompanionBuilder,
          $$LocalRecordsTableUpdateCompanionBuilder,
          (LocalRecord, $$LocalRecordsTableReferences),
          LocalRecord,
          PrefetchHooks Function({bool crosswalkId})
        > {
  $$LocalRecordsTableTableManager(_$LocalDb db, $LocalRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> crosswalkId = const Value.absent(),
                Value<int> cycle = const Value.absent(),
                Value<int> green = const Value.absent(),
                Value<double> phase = const Value.absent(),
                Value<double> at = const Value.absent(),
                Value<bool> weekend = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<String> tapsJson = const Value.absent(),
              }) => LocalRecordsCompanion(
                id: id,
                crosswalkId: crosswalkId,
                cycle: cycle,
                green: green,
                phase: phase,
                at: at,
                weekend: weekend,
                hour: hour,
                tapsJson: tapsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String crosswalkId,
                required int cycle,
                required int green,
                required double phase,
                required double at,
                required bool weekend,
                required int hour,
                Value<String> tapsJson = const Value.absent(),
              }) => LocalRecordsCompanion.insert(
                id: id,
                crosswalkId: crosswalkId,
                cycle: cycle,
                green: green,
                phase: phase,
                at: at,
                weekend: weekend,
                hour: hour,
                tapsJson: tapsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalRecordsTable, LocalRecord>(table),
                  $$LocalRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({crosswalkId = false}) {
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
                    if (crosswalkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.crosswalkId,
                                referencedTable: $$LocalRecordsTableReferences
                                    ._crosswalkIdTable(db),
                                referencedColumn: $$LocalRecordsTableReferences
                                    ._crosswalkIdTable(db)
                                    .id,
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

typedef $$LocalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $LocalRecordsTable,
      LocalRecord,
      $$LocalRecordsTableFilterComposer,
      $$LocalRecordsTableOrderingComposer,
      $$LocalRecordsTableAnnotationComposer,
      $$LocalRecordsTableCreateCompanionBuilder,
      $$LocalRecordsTableUpdateCompanionBuilder,
      (LocalRecord, $$LocalRecordsTableReferences),
      LocalRecord,
      PrefetchHooks Function({bool crosswalkId})
    >;

class $LocalDbManager {
  final _$LocalDb _db;
  $LocalDbManager(this._db);
  $$LocalCrosswalksTableTableManager get localCrosswalks =>
      $$LocalCrosswalksTableTableManager(_db, _db.localCrosswalks);
  $$LocalRecordsTableTableManager get localRecords =>
      $$LocalRecordsTableTableManager(_db, _db.localRecords);
}
