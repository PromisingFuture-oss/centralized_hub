// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppsTable extends Apps with TableInfo<$AppsTable, App> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconBytesMeta = const VerificationMeta(
    'iconBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> iconBytes = GeneratedColumn<Uint8List>(
    'icon_bytes',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGameMeta = const VerificationMeta('isGame');
  @override
  late final GeneratedColumn<bool> isGame = GeneratedColumn<bool>(
    'is_game',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_game" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isMediaMeta = const VerificationMeta(
    'isMedia',
  );
  @override
  late final GeneratedColumn<bool> isMedia = GeneratedColumn<bool>(
    'is_media',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_media" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAutoDetectedMeta = const VerificationMeta(
    'isAutoDetected',
  );
  @override
  late final GeneratedColumn<bool> isAutoDetected = GeneratedColumn<bool>(
    'is_auto_detected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_detected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isUserOverrideMeta = const VerificationMeta(
    'isUserOverride',
  );
  @override
  late final GeneratedColumn<bool> isUserOverride = GeneratedColumn<bool>(
    'is_user_override',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user_override" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    appName,
    iconBytes,
    isGame,
    isMedia,
    isAutoDetected,
    isUserOverride,
    firstSeenAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<App> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('icon_bytes')) {
      context.handle(
        _iconBytesMeta,
        iconBytes.isAcceptableOrUnknown(data['icon_bytes']!, _iconBytesMeta),
      );
    }
    if (data.containsKey('is_game')) {
      context.handle(
        _isGameMeta,
        isGame.isAcceptableOrUnknown(data['is_game']!, _isGameMeta),
      );
    }
    if (data.containsKey('is_media')) {
      context.handle(
        _isMediaMeta,
        isMedia.isAcceptableOrUnknown(data['is_media']!, _isMediaMeta),
      );
    }
    if (data.containsKey('is_auto_detected')) {
      context.handle(
        _isAutoDetectedMeta,
        isAutoDetected.isAcceptableOrUnknown(
          data['is_auto_detected']!,
          _isAutoDetectedMeta,
        ),
      );
    }
    if (data.containsKey('is_user_override')) {
      context.handle(
        _isUserOverrideMeta,
        isUserOverride.isAcceptableOrUnknown(
          data['is_user_override']!,
          _isUserOverrideMeta,
        ),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  App map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return App(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      iconBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}icon_bytes'],
      ),
      isGame: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_game'],
      )!,
      isMedia: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_media'],
      )!,
      isAutoDetected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_detected'],
      )!,
      isUserOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user_override'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppsTable createAlias(String alias) {
    return $AppsTable(attachedDatabase, alias);
  }
}

class App extends DataClass implements Insertable<App> {
  final int id;
  final String packageName;
  final String appName;
  final Uint8List? iconBytes;
  final bool isGame;
  final bool isMedia;
  final bool isAutoDetected;
  final bool isUserOverride;
  final DateTime firstSeenAt;
  final DateTime updatedAt;
  const App({
    required this.id,
    required this.packageName,
    required this.appName,
    this.iconBytes,
    required this.isGame,
    required this.isMedia,
    required this.isAutoDetected,
    required this.isUserOverride,
    required this.firstSeenAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    if (!nullToAbsent || iconBytes != null) {
      map['icon_bytes'] = Variable<Uint8List>(iconBytes);
    }
    map['is_game'] = Variable<bool>(isGame);
    map['is_media'] = Variable<bool>(isMedia);
    map['is_auto_detected'] = Variable<bool>(isAutoDetected);
    map['is_user_override'] = Variable<bool>(isUserOverride);
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppsCompanion toCompanion(bool nullToAbsent) {
    return AppsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      appName: Value(appName),
      iconBytes: iconBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(iconBytes),
      isGame: Value(isGame),
      isMedia: Value(isMedia),
      isAutoDetected: Value(isAutoDetected),
      isUserOverride: Value(isUserOverride),
      firstSeenAt: Value(firstSeenAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory App.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return App(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      iconBytes: serializer.fromJson<Uint8List?>(json['iconBytes']),
      isGame: serializer.fromJson<bool>(json['isGame']),
      isMedia: serializer.fromJson<bool>(json['isMedia']),
      isAutoDetected: serializer.fromJson<bool>(json['isAutoDetected']),
      isUserOverride: serializer.fromJson<bool>(json['isUserOverride']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'iconBytes': serializer.toJson<Uint8List?>(iconBytes),
      'isGame': serializer.toJson<bool>(isGame),
      'isMedia': serializer.toJson<bool>(isMedia),
      'isAutoDetected': serializer.toJson<bool>(isAutoDetected),
      'isUserOverride': serializer.toJson<bool>(isUserOverride),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  App copyWith({
    int? id,
    String? packageName,
    String? appName,
    Value<Uint8List?> iconBytes = const Value.absent(),
    bool? isGame,
    bool? isMedia,
    bool? isAutoDetected,
    bool? isUserOverride,
    DateTime? firstSeenAt,
    DateTime? updatedAt,
  }) => App(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    iconBytes: iconBytes.present ? iconBytes.value : this.iconBytes,
    isGame: isGame ?? this.isGame,
    isMedia: isMedia ?? this.isMedia,
    isAutoDetected: isAutoDetected ?? this.isAutoDetected,
    isUserOverride: isUserOverride ?? this.isUserOverride,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  App copyWithCompanion(AppsCompanion data) {
    return App(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      iconBytes: data.iconBytes.present ? data.iconBytes.value : this.iconBytes,
      isGame: data.isGame.present ? data.isGame.value : this.isGame,
      isMedia: data.isMedia.present ? data.isMedia.value : this.isMedia,
      isAutoDetected: data.isAutoDetected.present
          ? data.isAutoDetected.value
          : this.isAutoDetected,
      isUserOverride: data.isUserOverride.present
          ? data.isUserOverride.value
          : this.isUserOverride,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('App(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('iconBytes: $iconBytes, ')
          ..write('isGame: $isGame, ')
          ..write('isMedia: $isMedia, ')
          ..write('isAutoDetected: $isAutoDetected, ')
          ..write('isUserOverride: $isUserOverride, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    appName,
    $driftBlobEquality.hash(iconBytes),
    isGame,
    isMedia,
    isAutoDetected,
    isUserOverride,
    firstSeenAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is App &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          $driftBlobEquality.equals(other.iconBytes, this.iconBytes) &&
          other.isGame == this.isGame &&
          other.isMedia == this.isMedia &&
          other.isAutoDetected == this.isAutoDetected &&
          other.isUserOverride == this.isUserOverride &&
          other.firstSeenAt == this.firstSeenAt &&
          other.updatedAt == this.updatedAt);
}

class AppsCompanion extends UpdateCompanion<App> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> appName;
  final Value<Uint8List?> iconBytes;
  final Value<bool> isGame;
  final Value<bool> isMedia;
  final Value<bool> isAutoDetected;
  final Value<bool> isUserOverride;
  final Value<DateTime> firstSeenAt;
  final Value<DateTime> updatedAt;
  const AppsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.iconBytes = const Value.absent(),
    this.isGame = const Value.absent(),
    this.isMedia = const Value.absent(),
    this.isAutoDetected = const Value.absent(),
    this.isUserOverride = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppsCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String appName,
    this.iconBytes = const Value.absent(),
    this.isGame = const Value.absent(),
    this.isMedia = const Value.absent(),
    this.isAutoDetected = const Value.absent(),
    this.isUserOverride = const Value.absent(),
    required DateTime firstSeenAt,
    required DateTime updatedAt,
  }) : packageName = Value(packageName),
       appName = Value(appName),
       firstSeenAt = Value(firstSeenAt),
       updatedAt = Value(updatedAt);
  static Insertable<App> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<Uint8List>? iconBytes,
    Expression<bool>? isGame,
    Expression<bool>? isMedia,
    Expression<bool>? isAutoDetected,
    Expression<bool>? isUserOverride,
    Expression<DateTime>? firstSeenAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (iconBytes != null) 'icon_bytes': iconBytes,
      if (isGame != null) 'is_game': isGame,
      if (isMedia != null) 'is_media': isMedia,
      if (isAutoDetected != null) 'is_auto_detected': isAutoDetected,
      if (isUserOverride != null) 'is_user_override': isUserOverride,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppsCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? appName,
    Value<Uint8List?>? iconBytes,
    Value<bool>? isGame,
    Value<bool>? isMedia,
    Value<bool>? isAutoDetected,
    Value<bool>? isUserOverride,
    Value<DateTime>? firstSeenAt,
    Value<DateTime>? updatedAt,
  }) {
    return AppsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      iconBytes: iconBytes ?? this.iconBytes,
      isGame: isGame ?? this.isGame,
      isMedia: isMedia ?? this.isMedia,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      isUserOverride: isUserOverride ?? this.isUserOverride,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (iconBytes.present) {
      map['icon_bytes'] = Variable<Uint8List>(iconBytes.value);
    }
    if (isGame.present) {
      map['is_game'] = Variable<bool>(isGame.value);
    }
    if (isMedia.present) {
      map['is_media'] = Variable<bool>(isMedia.value);
    }
    if (isAutoDetected.present) {
      map['is_auto_detected'] = Variable<bool>(isAutoDetected.value);
    }
    if (isUserOverride.present) {
      map['is_user_override'] = Variable<bool>(isUserOverride.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('iconBytes: $iconBytes, ')
          ..write('isGame: $isGame, ')
          ..write('isMedia: $isMedia, ')
          ..write('isAutoDetected: $isAutoDetected, ')
          ..write('isUserOverride: $isUserOverride, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _appIdMeta = const VerificationMeta('appId');
  @override
  late final GeneratedColumn<int> appId = GeneratedColumn<int>(
    'app_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES apps (id)',
    ),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryStartMeta = const VerificationMeta(
    'batteryStart',
  );
  @override
  late final GeneratedColumn<int> batteryStart = GeneratedColumn<int>(
    'battery_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryEndMeta = const VerificationMeta(
    'batteryEnd',
  );
  @override
  late final GeneratedColumn<int> batteryEnd = GeneratedColumn<int>(
    'battery_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryDropMeta = const VerificationMeta(
    'batteryDrop',
  );
  @override
  late final GeneratedColumn<int> batteryDrop = GeneratedColumn<int>(
    'battery_drop',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasChargingStartMeta = const VerificationMeta(
    'wasChargingStart',
  );
  @override
  late final GeneratedColumn<bool> wasChargingStart = GeneratedColumn<bool>(
    'was_charging_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_charging_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wasChargingEndMeta = const VerificationMeta(
    'wasChargingEnd',
  );
  @override
  late final GeneratedColumn<bool> wasChargingEnd = GeneratedColumn<bool>(
    'was_charging_end',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_charging_end" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hadChargingDuringMeta = const VerificationMeta(
    'hadChargingDuring',
  );
  @override
  late final GeneratedColumn<bool> hadChargingDuring = GeneratedColumn<bool>(
    'had_charging_during',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("had_charging_during" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tempMinCMeta = const VerificationMeta(
    'tempMinC',
  );
  @override
  late final GeneratedColumn<double> tempMinC = GeneratedColumn<double>(
    'temp_min_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempAvgCMeta = const VerificationMeta(
    'tempAvgC',
  );
  @override
  late final GeneratedColumn<double> tempAvgC = GeneratedColumn<double>(
    'temp_avg_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempMaxCMeta = const VerificationMeta(
    'tempMaxC',
  );
  @override
  late final GeneratedColumn<double> tempMaxC = GeneratedColumn<double>(
    'temp_max_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thermalStatusMaxMeta = const VerificationMeta(
    'thermalStatusMax',
  );
  @override
  late final GeneratedColumn<int> thermalStatusMax = GeneratedColumn<int>(
    'thermal_status_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    appId,
    startTime,
    endTime,
    durationMs,
    batteryStart,
    batteryEnd,
    batteryDrop,
    wasChargingStart,
    wasChargingEnd,
    hadChargingDuring,
    tempMinC,
    tempAvgC,
    tempMaxC,
    thermalStatusMax,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('app_id')) {
      context.handle(
        _appIdMeta,
        appId.isAcceptableOrUnknown(data['app_id']!, _appIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('battery_start')) {
      context.handle(
        _batteryStartMeta,
        batteryStart.isAcceptableOrUnknown(
          data['battery_start']!,
          _batteryStartMeta,
        ),
      );
    }
    if (data.containsKey('battery_end')) {
      context.handle(
        _batteryEndMeta,
        batteryEnd.isAcceptableOrUnknown(data['battery_end']!, _batteryEndMeta),
      );
    }
    if (data.containsKey('battery_drop')) {
      context.handle(
        _batteryDropMeta,
        batteryDrop.isAcceptableOrUnknown(
          data['battery_drop']!,
          _batteryDropMeta,
        ),
      );
    }
    if (data.containsKey('was_charging_start')) {
      context.handle(
        _wasChargingStartMeta,
        wasChargingStart.isAcceptableOrUnknown(
          data['was_charging_start']!,
          _wasChargingStartMeta,
        ),
      );
    }
    if (data.containsKey('was_charging_end')) {
      context.handle(
        _wasChargingEndMeta,
        wasChargingEnd.isAcceptableOrUnknown(
          data['was_charging_end']!,
          _wasChargingEndMeta,
        ),
      );
    }
    if (data.containsKey('had_charging_during')) {
      context.handle(
        _hadChargingDuringMeta,
        hadChargingDuring.isAcceptableOrUnknown(
          data['had_charging_during']!,
          _hadChargingDuringMeta,
        ),
      );
    }
    if (data.containsKey('temp_min_c')) {
      context.handle(
        _tempMinCMeta,
        tempMinC.isAcceptableOrUnknown(data['temp_min_c']!, _tempMinCMeta),
      );
    }
    if (data.containsKey('temp_avg_c')) {
      context.handle(
        _tempAvgCMeta,
        tempAvgC.isAcceptableOrUnknown(data['temp_avg_c']!, _tempAvgCMeta),
      );
    }
    if (data.containsKey('temp_max_c')) {
      context.handle(
        _tempMaxCMeta,
        tempMaxC.isAcceptableOrUnknown(data['temp_max_c']!, _tempMaxCMeta),
      );
    }
    if (data.containsKey('thermal_status_max')) {
      context.handle(
        _thermalStatusMaxMeta,
        thermalStatusMax.isAcceptableOrUnknown(
          data['thermal_status_max']!,
          _thermalStatusMaxMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      appId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}app_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      batteryStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_start'],
      ),
      batteryEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_end'],
      ),
      batteryDrop: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_drop'],
      ),
      wasChargingStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_charging_start'],
      )!,
      wasChargingEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_charging_end'],
      )!,
      hadChargingDuring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}had_charging_during'],
      )!,
      tempMinC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_min_c'],
      ),
      tempAvgC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_avg_c'],
      ),
      tempMaxC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_max_c'],
      ),
      thermalStatusMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thermal_status_max'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int appId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMs;
  final int? batteryStart;
  final int? batteryEnd;
  final int? batteryDrop;
  final bool wasChargingStart;
  final bool wasChargingEnd;
  final bool hadChargingDuring;
  final double? tempMinC;
  final double? tempAvgC;
  final double? tempMaxC;
  final int? thermalStatusMax;
  const Session({
    required this.id,
    required this.appId,
    required this.startTime,
    this.endTime,
    this.durationMs,
    this.batteryStart,
    this.batteryEnd,
    this.batteryDrop,
    required this.wasChargingStart,
    required this.wasChargingEnd,
    required this.hadChargingDuring,
    this.tempMinC,
    this.tempAvgC,
    this.tempMaxC,
    this.thermalStatusMax,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['app_id'] = Variable<int>(appId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || batteryStart != null) {
      map['battery_start'] = Variable<int>(batteryStart);
    }
    if (!nullToAbsent || batteryEnd != null) {
      map['battery_end'] = Variable<int>(batteryEnd);
    }
    if (!nullToAbsent || batteryDrop != null) {
      map['battery_drop'] = Variable<int>(batteryDrop);
    }
    map['was_charging_start'] = Variable<bool>(wasChargingStart);
    map['was_charging_end'] = Variable<bool>(wasChargingEnd);
    map['had_charging_during'] = Variable<bool>(hadChargingDuring);
    if (!nullToAbsent || tempMinC != null) {
      map['temp_min_c'] = Variable<double>(tempMinC);
    }
    if (!nullToAbsent || tempAvgC != null) {
      map['temp_avg_c'] = Variable<double>(tempAvgC);
    }
    if (!nullToAbsent || tempMaxC != null) {
      map['temp_max_c'] = Variable<double>(tempMaxC);
    }
    if (!nullToAbsent || thermalStatusMax != null) {
      map['thermal_status_max'] = Variable<int>(thermalStatusMax);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      appId: Value(appId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      batteryStart: batteryStart == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryStart),
      batteryEnd: batteryEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryEnd),
      batteryDrop: batteryDrop == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryDrop),
      wasChargingStart: Value(wasChargingStart),
      wasChargingEnd: Value(wasChargingEnd),
      hadChargingDuring: Value(hadChargingDuring),
      tempMinC: tempMinC == null && nullToAbsent
          ? const Value.absent()
          : Value(tempMinC),
      tempAvgC: tempAvgC == null && nullToAbsent
          ? const Value.absent()
          : Value(tempAvgC),
      tempMaxC: tempMaxC == null && nullToAbsent
          ? const Value.absent()
          : Value(tempMaxC),
      thermalStatusMax: thermalStatusMax == null && nullToAbsent
          ? const Value.absent()
          : Value(thermalStatusMax),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      appId: serializer.fromJson<int>(json['appId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      batteryStart: serializer.fromJson<int?>(json['batteryStart']),
      batteryEnd: serializer.fromJson<int?>(json['batteryEnd']),
      batteryDrop: serializer.fromJson<int?>(json['batteryDrop']),
      wasChargingStart: serializer.fromJson<bool>(json['wasChargingStart']),
      wasChargingEnd: serializer.fromJson<bool>(json['wasChargingEnd']),
      hadChargingDuring: serializer.fromJson<bool>(json['hadChargingDuring']),
      tempMinC: serializer.fromJson<double?>(json['tempMinC']),
      tempAvgC: serializer.fromJson<double?>(json['tempAvgC']),
      tempMaxC: serializer.fromJson<double?>(json['tempMaxC']),
      thermalStatusMax: serializer.fromJson<int?>(json['thermalStatusMax']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'appId': serializer.toJson<int>(appId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'durationMs': serializer.toJson<int?>(durationMs),
      'batteryStart': serializer.toJson<int?>(batteryStart),
      'batteryEnd': serializer.toJson<int?>(batteryEnd),
      'batteryDrop': serializer.toJson<int?>(batteryDrop),
      'wasChargingStart': serializer.toJson<bool>(wasChargingStart),
      'wasChargingEnd': serializer.toJson<bool>(wasChargingEnd),
      'hadChargingDuring': serializer.toJson<bool>(hadChargingDuring),
      'tempMinC': serializer.toJson<double?>(tempMinC),
      'tempAvgC': serializer.toJson<double?>(tempAvgC),
      'tempMaxC': serializer.toJson<double?>(tempMaxC),
      'thermalStatusMax': serializer.toJson<int?>(thermalStatusMax),
    };
  }

  Session copyWith({
    int? id,
    int? appId,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<int?> batteryStart = const Value.absent(),
    Value<int?> batteryEnd = const Value.absent(),
    Value<int?> batteryDrop = const Value.absent(),
    bool? wasChargingStart,
    bool? wasChargingEnd,
    bool? hadChargingDuring,
    Value<double?> tempMinC = const Value.absent(),
    Value<double?> tempAvgC = const Value.absent(),
    Value<double?> tempMaxC = const Value.absent(),
    Value<int?> thermalStatusMax = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    appId: appId ?? this.appId,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    batteryStart: batteryStart.present ? batteryStart.value : this.batteryStart,
    batteryEnd: batteryEnd.present ? batteryEnd.value : this.batteryEnd,
    batteryDrop: batteryDrop.present ? batteryDrop.value : this.batteryDrop,
    wasChargingStart: wasChargingStart ?? this.wasChargingStart,
    wasChargingEnd: wasChargingEnd ?? this.wasChargingEnd,
    hadChargingDuring: hadChargingDuring ?? this.hadChargingDuring,
    tempMinC: tempMinC.present ? tempMinC.value : this.tempMinC,
    tempAvgC: tempAvgC.present ? tempAvgC.value : this.tempAvgC,
    tempMaxC: tempMaxC.present ? tempMaxC.value : this.tempMaxC,
    thermalStatusMax: thermalStatusMax.present
        ? thermalStatusMax.value
        : this.thermalStatusMax,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      appId: data.appId.present ? data.appId.value : this.appId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      batteryStart: data.batteryStart.present
          ? data.batteryStart.value
          : this.batteryStart,
      batteryEnd: data.batteryEnd.present
          ? data.batteryEnd.value
          : this.batteryEnd,
      batteryDrop: data.batteryDrop.present
          ? data.batteryDrop.value
          : this.batteryDrop,
      wasChargingStart: data.wasChargingStart.present
          ? data.wasChargingStart.value
          : this.wasChargingStart,
      wasChargingEnd: data.wasChargingEnd.present
          ? data.wasChargingEnd.value
          : this.wasChargingEnd,
      hadChargingDuring: data.hadChargingDuring.present
          ? data.hadChargingDuring.value
          : this.hadChargingDuring,
      tempMinC: data.tempMinC.present ? data.tempMinC.value : this.tempMinC,
      tempAvgC: data.tempAvgC.present ? data.tempAvgC.value : this.tempAvgC,
      tempMaxC: data.tempMaxC.present ? data.tempMaxC.value : this.tempMaxC,
      thermalStatusMax: data.thermalStatusMax.present
          ? data.thermalStatusMax.value
          : this.thermalStatusMax,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('appId: $appId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMs: $durationMs, ')
          ..write('batteryStart: $batteryStart, ')
          ..write('batteryEnd: $batteryEnd, ')
          ..write('batteryDrop: $batteryDrop, ')
          ..write('wasChargingStart: $wasChargingStart, ')
          ..write('wasChargingEnd: $wasChargingEnd, ')
          ..write('hadChargingDuring: $hadChargingDuring, ')
          ..write('tempMinC: $tempMinC, ')
          ..write('tempAvgC: $tempAvgC, ')
          ..write('tempMaxC: $tempMaxC, ')
          ..write('thermalStatusMax: $thermalStatusMax')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    appId,
    startTime,
    endTime,
    durationMs,
    batteryStart,
    batteryEnd,
    batteryDrop,
    wasChargingStart,
    wasChargingEnd,
    hadChargingDuring,
    tempMinC,
    tempAvgC,
    tempMaxC,
    thermalStatusMax,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.appId == this.appId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationMs == this.durationMs &&
          other.batteryStart == this.batteryStart &&
          other.batteryEnd == this.batteryEnd &&
          other.batteryDrop == this.batteryDrop &&
          other.wasChargingStart == this.wasChargingStart &&
          other.wasChargingEnd == this.wasChargingEnd &&
          other.hadChargingDuring == this.hadChargingDuring &&
          other.tempMinC == this.tempMinC &&
          other.tempAvgC == this.tempAvgC &&
          other.tempMaxC == this.tempMaxC &&
          other.thermalStatusMax == this.thermalStatusMax);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> appId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int?> durationMs;
  final Value<int?> batteryStart;
  final Value<int?> batteryEnd;
  final Value<int?> batteryDrop;
  final Value<bool> wasChargingStart;
  final Value<bool> wasChargingEnd;
  final Value<bool> hadChargingDuring;
  final Value<double?> tempMinC;
  final Value<double?> tempAvgC;
  final Value<double?> tempMaxC;
  final Value<int?> thermalStatusMax;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.appId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.batteryStart = const Value.absent(),
    this.batteryEnd = const Value.absent(),
    this.batteryDrop = const Value.absent(),
    this.wasChargingStart = const Value.absent(),
    this.wasChargingEnd = const Value.absent(),
    this.hadChargingDuring = const Value.absent(),
    this.tempMinC = const Value.absent(),
    this.tempAvgC = const Value.absent(),
    this.tempMaxC = const Value.absent(),
    this.thermalStatusMax = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int appId,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.batteryStart = const Value.absent(),
    this.batteryEnd = const Value.absent(),
    this.batteryDrop = const Value.absent(),
    this.wasChargingStart = const Value.absent(),
    this.wasChargingEnd = const Value.absent(),
    this.hadChargingDuring = const Value.absent(),
    this.tempMinC = const Value.absent(),
    this.tempAvgC = const Value.absent(),
    this.tempMaxC = const Value.absent(),
    this.thermalStatusMax = const Value.absent(),
  }) : appId = Value(appId),
       startTime = Value(startTime);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? appId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationMs,
    Expression<int>? batteryStart,
    Expression<int>? batteryEnd,
    Expression<int>? batteryDrop,
    Expression<bool>? wasChargingStart,
    Expression<bool>? wasChargingEnd,
    Expression<bool>? hadChargingDuring,
    Expression<double>? tempMinC,
    Expression<double>? tempAvgC,
    Expression<double>? tempMaxC,
    Expression<int>? thermalStatusMax,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appId != null) 'app_id': appId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationMs != null) 'duration_ms': durationMs,
      if (batteryStart != null) 'battery_start': batteryStart,
      if (batteryEnd != null) 'battery_end': batteryEnd,
      if (batteryDrop != null) 'battery_drop': batteryDrop,
      if (wasChargingStart != null) 'was_charging_start': wasChargingStart,
      if (wasChargingEnd != null) 'was_charging_end': wasChargingEnd,
      if (hadChargingDuring != null) 'had_charging_during': hadChargingDuring,
      if (tempMinC != null) 'temp_min_c': tempMinC,
      if (tempAvgC != null) 'temp_avg_c': tempAvgC,
      if (tempMaxC != null) 'temp_max_c': tempMaxC,
      if (thermalStatusMax != null) 'thermal_status_max': thermalStatusMax,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? appId,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int?>? durationMs,
    Value<int?>? batteryStart,
    Value<int?>? batteryEnd,
    Value<int?>? batteryDrop,
    Value<bool>? wasChargingStart,
    Value<bool>? wasChargingEnd,
    Value<bool>? hadChargingDuring,
    Value<double?>? tempMinC,
    Value<double?>? tempAvgC,
    Value<double?>? tempMaxC,
    Value<int?>? thermalStatusMax,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMs: durationMs ?? this.durationMs,
      batteryStart: batteryStart ?? this.batteryStart,
      batteryEnd: batteryEnd ?? this.batteryEnd,
      batteryDrop: batteryDrop ?? this.batteryDrop,
      wasChargingStart: wasChargingStart ?? this.wasChargingStart,
      wasChargingEnd: wasChargingEnd ?? this.wasChargingEnd,
      hadChargingDuring: hadChargingDuring ?? this.hadChargingDuring,
      tempMinC: tempMinC ?? this.tempMinC,
      tempAvgC: tempAvgC ?? this.tempAvgC,
      tempMaxC: tempMaxC ?? this.tempMaxC,
      thermalStatusMax: thermalStatusMax ?? this.thermalStatusMax,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (appId.present) {
      map['app_id'] = Variable<int>(appId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (batteryStart.present) {
      map['battery_start'] = Variable<int>(batteryStart.value);
    }
    if (batteryEnd.present) {
      map['battery_end'] = Variable<int>(batteryEnd.value);
    }
    if (batteryDrop.present) {
      map['battery_drop'] = Variable<int>(batteryDrop.value);
    }
    if (wasChargingStart.present) {
      map['was_charging_start'] = Variable<bool>(wasChargingStart.value);
    }
    if (wasChargingEnd.present) {
      map['was_charging_end'] = Variable<bool>(wasChargingEnd.value);
    }
    if (hadChargingDuring.present) {
      map['had_charging_during'] = Variable<bool>(hadChargingDuring.value);
    }
    if (tempMinC.present) {
      map['temp_min_c'] = Variable<double>(tempMinC.value);
    }
    if (tempAvgC.present) {
      map['temp_avg_c'] = Variable<double>(tempAvgC.value);
    }
    if (tempMaxC.present) {
      map['temp_max_c'] = Variable<double>(tempMaxC.value);
    }
    if (thermalStatusMax.present) {
      map['thermal_status_max'] = Variable<int>(thermalStatusMax.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('appId: $appId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMs: $durationMs, ')
          ..write('batteryStart: $batteryStart, ')
          ..write('batteryEnd: $batteryEnd, ')
          ..write('batteryDrop: $batteryDrop, ')
          ..write('wasChargingStart: $wasChargingStart, ')
          ..write('wasChargingEnd: $wasChargingEnd, ')
          ..write('hadChargingDuring: $hadChargingDuring, ')
          ..write('tempMinC: $tempMinC, ')
          ..write('tempAvgC: $tempAvgC, ')
          ..write('tempMaxC: $tempMaxC, ')
          ..write('thermalStatusMax: $thermalStatusMax')
          ..write(')'))
        .toString();
  }
}

class $SamplesTable extends Samples with TableInfo<$SamplesTable, Sample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SamplesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batteryLevelMeta = const VerificationMeta(
    'batteryLevel',
  );
  @override
  late final GeneratedColumn<int> batteryLevel = GeneratedColumn<int>(
    'battery_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryTempCMeta = const VerificationMeta(
    'batteryTempC',
  );
  @override
  late final GeneratedColumn<double> batteryTempC = GeneratedColumn<double>(
    'battery_temp_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isChargingMeta = const VerificationMeta(
    'isCharging',
  );
  @override
  late final GeneratedColumn<bool> isCharging = GeneratedColumn<bool>(
    'is_charging',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_charging" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _thermalStatusMeta = const VerificationMeta(
    'thermalStatus',
  );
  @override
  late final GeneratedColumn<int> thermalStatus = GeneratedColumn<int>(
    'thermal_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    timestamp,
    batteryLevel,
    batteryTempC,
    isCharging,
    thermalStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('battery_level')) {
      context.handle(
        _batteryLevelMeta,
        batteryLevel.isAcceptableOrUnknown(
          data['battery_level']!,
          _batteryLevelMeta,
        ),
      );
    }
    if (data.containsKey('battery_temp_c')) {
      context.handle(
        _batteryTempCMeta,
        batteryTempC.isAcceptableOrUnknown(
          data['battery_temp_c']!,
          _batteryTempCMeta,
        ),
      );
    }
    if (data.containsKey('is_charging')) {
      context.handle(
        _isChargingMeta,
        isCharging.isAcceptableOrUnknown(data['is_charging']!, _isChargingMeta),
      );
    }
    if (data.containsKey('thermal_status')) {
      context.handle(
        _thermalStatusMeta,
        thermalStatus.isAcceptableOrUnknown(
          data['thermal_status']!,
          _thermalStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      batteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_level'],
      ),
      batteryTempC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}battery_temp_c'],
      ),
      isCharging: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_charging'],
      )!,
      thermalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thermal_status'],
      ),
    );
  }

  @override
  $SamplesTable createAlias(String alias) {
    return $SamplesTable(attachedDatabase, alias);
  }
}

class Sample extends DataClass implements Insertable<Sample> {
  final int id;
  final int sessionId;
  final DateTime timestamp;
  final int? batteryLevel;
  final double? batteryTempC;
  final bool isCharging;
  final int? thermalStatus;
  const Sample({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    this.batteryLevel,
    this.batteryTempC,
    required this.isCharging,
    this.thermalStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || batteryLevel != null) {
      map['battery_level'] = Variable<int>(batteryLevel);
    }
    if (!nullToAbsent || batteryTempC != null) {
      map['battery_temp_c'] = Variable<double>(batteryTempC);
    }
    map['is_charging'] = Variable<bool>(isCharging);
    if (!nullToAbsent || thermalStatus != null) {
      map['thermal_status'] = Variable<int>(thermalStatus);
    }
    return map;
  }

  SamplesCompanion toCompanion(bool nullToAbsent) {
    return SamplesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timestamp: Value(timestamp),
      batteryLevel: batteryLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryLevel),
      batteryTempC: batteryTempC == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryTempC),
      isCharging: Value(isCharging),
      thermalStatus: thermalStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(thermalStatus),
    );
  }

  factory Sample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sample(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      batteryLevel: serializer.fromJson<int?>(json['batteryLevel']),
      batteryTempC: serializer.fromJson<double?>(json['batteryTempC']),
      isCharging: serializer.fromJson<bool>(json['isCharging']),
      thermalStatus: serializer.fromJson<int?>(json['thermalStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'batteryLevel': serializer.toJson<int?>(batteryLevel),
      'batteryTempC': serializer.toJson<double?>(batteryTempC),
      'isCharging': serializer.toJson<bool>(isCharging),
      'thermalStatus': serializer.toJson<int?>(thermalStatus),
    };
  }

  Sample copyWith({
    int? id,
    int? sessionId,
    DateTime? timestamp,
    Value<int?> batteryLevel = const Value.absent(),
    Value<double?> batteryTempC = const Value.absent(),
    bool? isCharging,
    Value<int?> thermalStatus = const Value.absent(),
  }) => Sample(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    timestamp: timestamp ?? this.timestamp,
    batteryLevel: batteryLevel.present ? batteryLevel.value : this.batteryLevel,
    batteryTempC: batteryTempC.present ? batteryTempC.value : this.batteryTempC,
    isCharging: isCharging ?? this.isCharging,
    thermalStatus: thermalStatus.present
        ? thermalStatus.value
        : this.thermalStatus,
  );
  Sample copyWithCompanion(SamplesCompanion data) {
    return Sample(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      batteryLevel: data.batteryLevel.present
          ? data.batteryLevel.value
          : this.batteryLevel,
      batteryTempC: data.batteryTempC.present
          ? data.batteryTempC.value
          : this.batteryTempC,
      isCharging: data.isCharging.present
          ? data.isCharging.value
          : this.isCharging,
      thermalStatus: data.thermalStatus.present
          ? data.thermalStatus.value
          : this.thermalStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sample(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestamp: $timestamp, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('batteryTempC: $batteryTempC, ')
          ..write('isCharging: $isCharging, ')
          ..write('thermalStatus: $thermalStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    timestamp,
    batteryLevel,
    batteryTempC,
    isCharging,
    thermalStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sample &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timestamp == this.timestamp &&
          other.batteryLevel == this.batteryLevel &&
          other.batteryTempC == this.batteryTempC &&
          other.isCharging == this.isCharging &&
          other.thermalStatus == this.thermalStatus);
}

class SamplesCompanion extends UpdateCompanion<Sample> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<DateTime> timestamp;
  final Value<int?> batteryLevel;
  final Value<double?> batteryTempC;
  final Value<bool> isCharging;
  final Value<int?> thermalStatus;
  const SamplesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.batteryTempC = const Value.absent(),
    this.isCharging = const Value.absent(),
    this.thermalStatus = const Value.absent(),
  });
  SamplesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required DateTime timestamp,
    this.batteryLevel = const Value.absent(),
    this.batteryTempC = const Value.absent(),
    this.isCharging = const Value.absent(),
    this.thermalStatus = const Value.absent(),
  }) : sessionId = Value(sessionId),
       timestamp = Value(timestamp);
  static Insertable<Sample> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<DateTime>? timestamp,
    Expression<int>? batteryLevel,
    Expression<double>? batteryTempC,
    Expression<bool>? isCharging,
    Expression<int>? thermalStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timestamp != null) 'timestamp': timestamp,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (batteryTempC != null) 'battery_temp_c': batteryTempC,
      if (isCharging != null) 'is_charging': isCharging,
      if (thermalStatus != null) 'thermal_status': thermalStatus,
    });
  }

  SamplesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<DateTime>? timestamp,
    Value<int?>? batteryLevel,
    Value<double?>? batteryTempC,
    Value<bool>? isCharging,
    Value<int?>? thermalStatus,
  }) {
    return SamplesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryTempC: batteryTempC ?? this.batteryTempC,
      isCharging: isCharging ?? this.isCharging,
      thermalStatus: thermalStatus ?? this.thermalStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (batteryLevel.present) {
      map['battery_level'] = Variable<int>(batteryLevel.value);
    }
    if (batteryTempC.present) {
      map['battery_temp_c'] = Variable<double>(batteryTempC.value);
    }
    if (isCharging.present) {
      map['is_charging'] = Variable<bool>(isCharging.value);
    }
    if (thermalStatus.present) {
      map['thermal_status'] = Variable<int>(thermalStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SamplesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestamp: $timestamp, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('batteryTempC: $batteryTempC, ')
          ..write('isCharging: $isCharging, ')
          ..write('thermalStatus: $thermalStatus')
          ..write(')'))
        .toString();
  }
}

class $DashboardLayoutsTable extends DashboardLayouts
    with TableInfo<$DashboardLayoutsTable, DashboardLayout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashboardLayoutsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cardsJsonMeta = const VerificationMeta(
    'cardsJson',
  );
  @override
  late final GeneratedColumn<String> cardsJson = GeneratedColumn<String>(
    'cards_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isActive,
    isPreset,
    cardsJson,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashboard_layouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DashboardLayout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
      );
    }
    if (data.containsKey('cards_json')) {
      context.handle(
        _cardsJsonMeta,
        cardsJson.isAcceptableOrUnknown(data['cards_json']!, _cardsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_cardsJsonMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DashboardLayout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DashboardLayout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preset'],
      )!,
      cardsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cards_json'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DashboardLayoutsTable createAlias(String alias) {
    return $DashboardLayoutsTable(attachedDatabase, alias);
  }
}

class DashboardLayout extends DataClass implements Insertable<DashboardLayout> {
  final int id;
  final String name;
  final bool isActive;
  final bool isPreset;
  final String cardsJson;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DashboardLayout({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isPreset,
    required this.cardsJson,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['is_preset'] = Variable<bool>(isPreset);
    map['cards_json'] = Variable<String>(cardsJson);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DashboardLayoutsCompanion toCompanion(bool nullToAbsent) {
    return DashboardLayoutsCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      isPreset: Value(isPreset),
      cardsJson: Value(cardsJson),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DashboardLayout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DashboardLayout(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      cardsJson: serializer.fromJson<String>(json['cardsJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'isPreset': serializer.toJson<bool>(isPreset),
      'cardsJson': serializer.toJson<String>(cardsJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DashboardLayout copyWith({
    int? id,
    String? name,
    bool? isActive,
    bool? isPreset,
    String? cardsJson,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DashboardLayout(
    id: id ?? this.id,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    isPreset: isPreset ?? this.isPreset,
    cardsJson: cardsJson ?? this.cardsJson,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DashboardLayout copyWithCompanion(DashboardLayoutsCompanion data) {
    return DashboardLayout(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      cardsJson: data.cardsJson.present ? data.cardsJson.value : this.cardsJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DashboardLayout(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('isPreset: $isPreset, ')
          ..write('cardsJson: $cardsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    isActive,
    isPreset,
    cardsJson,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardLayout &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.isPreset == this.isPreset &&
          other.cardsJson == this.cardsJson &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DashboardLayoutsCompanion extends UpdateCompanion<DashboardLayout> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<bool> isPreset;
  final Value<String> cardsJson;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DashboardLayoutsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.cardsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DashboardLayoutsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
    this.isPreset = const Value.absent(),
    required String cardsJson,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       cardsJson = Value(cardsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DashboardLayout> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<bool>? isPreset,
    Expression<String>? cardsJson,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (isPreset != null) 'is_preset': isPreset,
      if (cardsJson != null) 'cards_json': cardsJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DashboardLayoutsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isActive,
    Value<bool>? isPreset,
    Value<String>? cardsJson,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DashboardLayoutsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isPreset: isPreset ?? this.isPreset,
      cardsJson: cardsJson ?? this.cardsJson,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    if (cardsJson.present) {
      map['cards_json'] = Variable<String>(cardsJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DashboardLayoutsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('isPreset: $isPreset, ')
          ..write('cardsJson: $cardsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
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
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
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
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
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

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
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
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
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

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppsTable apps = $AppsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SamplesTable samples = $SamplesTable(this);
  late final $DashboardLayoutsTable dashboardLayouts = $DashboardLayoutsTable(
    this,
  );
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index idxSamplesSessionTime = Index(
    'idx_samples_session_time',
    'CREATE INDEX idx_samples_session_time ON samples (session_id, timestamp)',
  );
  late final AppsDao appsDao = AppsDao(this as AppDatabase);
  late final SessionsDao sessionsDao = SessionsDao(this as AppDatabase);
  late final SamplesDao samplesDao = SamplesDao(this as AppDatabase);
  late final DashboardDao dashboardDao = DashboardDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    apps,
    sessions,
    samples,
    dashboardLayouts,
    settings,
    idxSamplesSessionTime,
  ];
}

typedef $$AppsTableCreateCompanionBuilder =
    AppsCompanion Function({
      Value<int> id,
      required String packageName,
      required String appName,
      Value<Uint8List?> iconBytes,
      Value<bool> isGame,
      Value<bool> isMedia,
      Value<bool> isAutoDetected,
      Value<bool> isUserOverride,
      required DateTime firstSeenAt,
      required DateTime updatedAt,
    });
typedef $$AppsTableUpdateCompanionBuilder =
    AppsCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> appName,
      Value<Uint8List?> iconBytes,
      Value<bool> isGame,
      Value<bool> isMedia,
      Value<bool> isAutoDetected,
      Value<bool> isUserOverride,
      Value<DateTime> firstSeenAt,
      Value<DateTime> updatedAt,
    });

final class $$AppsTableReferences
    extends BaseReferences<_$AppDatabase, $AppsTable, App> {
  $$AppsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.apps.id, db.sessions.appId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.appId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppsTableFilterComposer extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableFilterComposer({
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

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get iconBytes => $composableBuilder(
    column: $table.iconBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGame => $composableBuilder(
    column: $table.isGame,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMedia => $composableBuilder(
    column: $table.isMedia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoDetected => $composableBuilder(
    column: $table.isAutoDetected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUserOverride => $composableBuilder(
    column: $table.isUserOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.appId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppsTableOrderingComposer extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableOrderingComposer({
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

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get iconBytes => $composableBuilder(
    column: $table.iconBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGame => $composableBuilder(
    column: $table.isGame,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMedia => $composableBuilder(
    column: $table.isMedia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoDetected => $composableBuilder(
    column: $table.isAutoDetected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUserOverride => $composableBuilder(
    column: $table.isUserOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppsTable> {
  $$AppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<Uint8List> get iconBytes =>
      $composableBuilder(column: $table.iconBytes, builder: (column) => column);

  GeneratedColumn<bool> get isGame =>
      $composableBuilder(column: $table.isGame, builder: (column) => column);

  GeneratedColumn<bool> get isMedia =>
      $composableBuilder(column: $table.isMedia, builder: (column) => column);

  GeneratedColumn<bool> get isAutoDetected => $composableBuilder(
    column: $table.isAutoDetected,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUserOverride => $composableBuilder(
    column: $table.isUserOverride,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.appId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppsTable,
          App,
          $$AppsTableFilterComposer,
          $$AppsTableOrderingComposer,
          $$AppsTableAnnotationComposer,
          $$AppsTableCreateCompanionBuilder,
          $$AppsTableUpdateCompanionBuilder,
          (App, $$AppsTableReferences),
          App,
          PrefetchHooks Function({bool sessionsRefs})
        > {
  $$AppsTableTableManager(_$AppDatabase db, $AppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<Uint8List?> iconBytes = const Value.absent(),
                Value<bool> isGame = const Value.absent(),
                Value<bool> isMedia = const Value.absent(),
                Value<bool> isAutoDetected = const Value.absent(),
                Value<bool> isUserOverride = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppsCompanion(
                id: id,
                packageName: packageName,
                appName: appName,
                iconBytes: iconBytes,
                isGame: isGame,
                isMedia: isMedia,
                isAutoDetected: isAutoDetected,
                isUserOverride: isUserOverride,
                firstSeenAt: firstSeenAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String appName,
                Value<Uint8List?> iconBytes = const Value.absent(),
                Value<bool> isGame = const Value.absent(),
                Value<bool> isMedia = const Value.absent(),
                Value<bool> isAutoDetected = const Value.absent(),
                Value<bool> isUserOverride = const Value.absent(),
                required DateTime firstSeenAt,
                required DateTime updatedAt,
              }) => AppsCompanion.insert(
                id: id,
                packageName: packageName,
                appName: appName,
                iconBytes: iconBytes,
                isGame: isGame,
                isMedia: isMedia,
                isAutoDetected: isAutoDetected,
                isUserOverride: isUserOverride,
                firstSeenAt: firstSeenAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AppsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedData<App, $AppsTable, Session>(
                      currentTable: table,
                      referencedTable: $$AppsTableReferences._sessionsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$AppsTableReferences(db, table, p0).sessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.appId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AppsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppsTable,
      App,
      $$AppsTableFilterComposer,
      $$AppsTableOrderingComposer,
      $$AppsTableAnnotationComposer,
      $$AppsTableCreateCompanionBuilder,
      $$AppsTableUpdateCompanionBuilder,
      (App, $$AppsTableReferences),
      App,
      PrefetchHooks Function({bool sessionsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required int appId,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<int?> durationMs,
      Value<int?> batteryStart,
      Value<int?> batteryEnd,
      Value<int?> batteryDrop,
      Value<bool> wasChargingStart,
      Value<bool> wasChargingEnd,
      Value<bool> hadChargingDuring,
      Value<double?> tempMinC,
      Value<double?> tempAvgC,
      Value<double?> tempMaxC,
      Value<int?> thermalStatusMax,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<int> appId,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int?> durationMs,
      Value<int?> batteryStart,
      Value<int?> batteryEnd,
      Value<int?> batteryDrop,
      Value<bool> wasChargingStart,
      Value<bool> wasChargingEnd,
      Value<bool> hadChargingDuring,
      Value<double?> tempMinC,
      Value<double?> tempAvgC,
      Value<double?> tempMaxC,
      Value<int?> thermalStatusMax,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppsTable _appIdTable(_$AppDatabase db) =>
      db.apps.createAlias($_aliasNameGenerator(db.sessions.appId, db.apps.id));

  $$AppsTableProcessedTableManager get appId {
    final $_column = $_itemColumn<int>('app_id')!;

    final manager = $$AppsTableTableManager(
      $_db,
      $_db.apps,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_appIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SamplesTable, List<Sample>> _samplesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.samples,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.samples.sessionId),
  );

  $$SamplesTableProcessedTableManager get samplesRefs {
    final manager = $$SamplesTableTableManager(
      $_db,
      $_db.samples,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_samplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryStart => $composableBuilder(
    column: $table.batteryStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryEnd => $composableBuilder(
    column: $table.batteryEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryDrop => $composableBuilder(
    column: $table.batteryDrop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasChargingStart => $composableBuilder(
    column: $table.wasChargingStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasChargingEnd => $composableBuilder(
    column: $table.wasChargingEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hadChargingDuring => $composableBuilder(
    column: $table.hadChargingDuring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempMinC => $composableBuilder(
    column: $table.tempMinC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempAvgC => $composableBuilder(
    column: $table.tempAvgC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempMaxC => $composableBuilder(
    column: $table.tempMaxC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thermalStatusMax => $composableBuilder(
    column: $table.thermalStatusMax,
    builder: (column) => ColumnFilters(column),
  );

  $$AppsTableFilterComposer get appId {
    final $$AppsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appId,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableFilterComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> samplesRefs(
    Expression<bool> Function($$SamplesTableFilterComposer f) f,
  ) {
    final $$SamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.samples,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SamplesTableFilterComposer(
            $db: $db,
            $table: $db.samples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryStart => $composableBuilder(
    column: $table.batteryStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryEnd => $composableBuilder(
    column: $table.batteryEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryDrop => $composableBuilder(
    column: $table.batteryDrop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasChargingStart => $composableBuilder(
    column: $table.wasChargingStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasChargingEnd => $composableBuilder(
    column: $table.wasChargingEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hadChargingDuring => $composableBuilder(
    column: $table.hadChargingDuring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempMinC => $composableBuilder(
    column: $table.tempMinC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempAvgC => $composableBuilder(
    column: $table.tempAvgC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempMaxC => $composableBuilder(
    column: $table.tempMaxC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thermalStatusMax => $composableBuilder(
    column: $table.thermalStatusMax,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppsTableOrderingComposer get appId {
    final $$AppsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appId,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableOrderingComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryStart => $composableBuilder(
    column: $table.batteryStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryEnd => $composableBuilder(
    column: $table.batteryEnd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryDrop => $composableBuilder(
    column: $table.batteryDrop,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasChargingStart => $composableBuilder(
    column: $table.wasChargingStart,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasChargingEnd => $composableBuilder(
    column: $table.wasChargingEnd,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hadChargingDuring => $composableBuilder(
    column: $table.hadChargingDuring,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tempMinC =>
      $composableBuilder(column: $table.tempMinC, builder: (column) => column);

  GeneratedColumn<double> get tempAvgC =>
      $composableBuilder(column: $table.tempAvgC, builder: (column) => column);

  GeneratedColumn<double> get tempMaxC =>
      $composableBuilder(column: $table.tempMaxC, builder: (column) => column);

  GeneratedColumn<int> get thermalStatusMax => $composableBuilder(
    column: $table.thermalStatusMax,
    builder: (column) => column,
  );

  $$AppsTableAnnotationComposer get appId {
    final $$AppsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appId,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableAnnotationComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> samplesRefs<T extends Object>(
    Expression<T> Function($$SamplesTableAnnotationComposer a) f,
  ) {
    final $$SamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.samples,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.samples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool appId, bool samplesRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> appId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> batteryStart = const Value.absent(),
                Value<int?> batteryEnd = const Value.absent(),
                Value<int?> batteryDrop = const Value.absent(),
                Value<bool> wasChargingStart = const Value.absent(),
                Value<bool> wasChargingEnd = const Value.absent(),
                Value<bool> hadChargingDuring = const Value.absent(),
                Value<double?> tempMinC = const Value.absent(),
                Value<double?> tempAvgC = const Value.absent(),
                Value<double?> tempMaxC = const Value.absent(),
                Value<int?> thermalStatusMax = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                appId: appId,
                startTime: startTime,
                endTime: endTime,
                durationMs: durationMs,
                batteryStart: batteryStart,
                batteryEnd: batteryEnd,
                batteryDrop: batteryDrop,
                wasChargingStart: wasChargingStart,
                wasChargingEnd: wasChargingEnd,
                hadChargingDuring: hadChargingDuring,
                tempMinC: tempMinC,
                tempAvgC: tempAvgC,
                tempMaxC: tempMaxC,
                thermalStatusMax: thermalStatusMax,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int appId,
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> batteryStart = const Value.absent(),
                Value<int?> batteryEnd = const Value.absent(),
                Value<int?> batteryDrop = const Value.absent(),
                Value<bool> wasChargingStart = const Value.absent(),
                Value<bool> wasChargingEnd = const Value.absent(),
                Value<bool> hadChargingDuring = const Value.absent(),
                Value<double?> tempMinC = const Value.absent(),
                Value<double?> tempAvgC = const Value.absent(),
                Value<double?> tempMaxC = const Value.absent(),
                Value<int?> thermalStatusMax = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                appId: appId,
                startTime: startTime,
                endTime: endTime,
                durationMs: durationMs,
                batteryStart: batteryStart,
                batteryEnd: batteryEnd,
                batteryDrop: batteryDrop,
                wasChargingStart: wasChargingStart,
                wasChargingEnd: wasChargingEnd,
                hadChargingDuring: hadChargingDuring,
                tempMinC: tempMinC,
                tempAvgC: tempAvgC,
                tempMaxC: tempMaxC,
                thermalStatusMax: thermalStatusMax,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({appId = false, samplesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (samplesRefs) db.samples],
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
                    if (appId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.appId,
                                referencedTable: $$SessionsTableReferences
                                    ._appIdTable(db),
                                referencedColumn: $$SessionsTableReferences
                                    ._appIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (samplesRefs)
                    await $_getPrefetchedData<Session, $SessionsTable, Sample>(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._samplesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionsTableReferences(db, table, p0).samplesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool appId, bool samplesRefs})
    >;
typedef $$SamplesTableCreateCompanionBuilder =
    SamplesCompanion Function({
      Value<int> id,
      required int sessionId,
      required DateTime timestamp,
      Value<int?> batteryLevel,
      Value<double?> batteryTempC,
      Value<bool> isCharging,
      Value<int?> thermalStatus,
    });
typedef $$SamplesTableUpdateCompanionBuilder =
    SamplesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<DateTime> timestamp,
      Value<int?> batteryLevel,
      Value<double?> batteryTempC,
      Value<bool> isCharging,
      Value<int?> thermalStatus,
    });

final class $$SamplesTableReferences
    extends BaseReferences<_$AppDatabase, $SamplesTable, Sample> {
  $$SamplesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.samples.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SamplesTableFilterComposer
    extends Composer<_$AppDatabase, $SamplesTable> {
  $$SamplesTableFilterComposer({
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

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get batteryTempC => $composableBuilder(
    column: $table.batteryTempC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thermalStatus => $composableBuilder(
    column: $table.thermalStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $SamplesTable> {
  $$SamplesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get batteryTempC => $composableBuilder(
    column: $table.batteryTempC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thermalStatus => $composableBuilder(
    column: $table.thermalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SamplesTable> {
  $$SamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get batteryTempC => $composableBuilder(
    column: $table.batteryTempC,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => column,
  );

  GeneratedColumn<int> get thermalStatus => $composableBuilder(
    column: $table.thermalStatus,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SamplesTable,
          Sample,
          $$SamplesTableFilterComposer,
          $$SamplesTableOrderingComposer,
          $$SamplesTableAnnotationComposer,
          $$SamplesTableCreateCompanionBuilder,
          $$SamplesTableUpdateCompanionBuilder,
          (Sample, $$SamplesTableReferences),
          Sample,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SamplesTableTableManager(_$AppDatabase db, $SamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int?> batteryLevel = const Value.absent(),
                Value<double?> batteryTempC = const Value.absent(),
                Value<bool> isCharging = const Value.absent(),
                Value<int?> thermalStatus = const Value.absent(),
              }) => SamplesCompanion(
                id: id,
                sessionId: sessionId,
                timestamp: timestamp,
                batteryLevel: batteryLevel,
                batteryTempC: batteryTempC,
                isCharging: isCharging,
                thermalStatus: thermalStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required DateTime timestamp,
                Value<int?> batteryLevel = const Value.absent(),
                Value<double?> batteryTempC = const Value.absent(),
                Value<bool> isCharging = const Value.absent(),
                Value<int?> thermalStatus = const Value.absent(),
              }) => SamplesCompanion.insert(
                id: id,
                sessionId: sessionId,
                timestamp: timestamp,
                batteryLevel: batteryLevel,
                batteryTempC: batteryTempC,
                isCharging: isCharging,
                thermalStatus: thermalStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SamplesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SamplesTableReferences
                                    ._sessionIdTable(db)
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

typedef $$SamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SamplesTable,
      Sample,
      $$SamplesTableFilterComposer,
      $$SamplesTableOrderingComposer,
      $$SamplesTableAnnotationComposer,
      $$SamplesTableCreateCompanionBuilder,
      $$SamplesTableUpdateCompanionBuilder,
      (Sample, $$SamplesTableReferences),
      Sample,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$DashboardLayoutsTableCreateCompanionBuilder =
    DashboardLayoutsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isActive,
      Value<bool> isPreset,
      required String cardsJson,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DashboardLayoutsTableUpdateCompanionBuilder =
    DashboardLayoutsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isActive,
      Value<bool> isPreset,
      Value<String> cardsJson,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DashboardLayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $DashboardLayoutsTable> {
  $$DashboardLayoutsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardsJson => $composableBuilder(
    column: $table.cardsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DashboardLayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $DashboardLayoutsTable> {
  $$DashboardLayoutsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardsJson => $composableBuilder(
    column: $table.cardsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DashboardLayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DashboardLayoutsTable> {
  $$DashboardLayoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);

  GeneratedColumn<String> get cardsJson =>
      $composableBuilder(column: $table.cardsJson, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DashboardLayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DashboardLayoutsTable,
          DashboardLayout,
          $$DashboardLayoutsTableFilterComposer,
          $$DashboardLayoutsTableOrderingComposer,
          $$DashboardLayoutsTableAnnotationComposer,
          $$DashboardLayoutsTableCreateCompanionBuilder,
          $$DashboardLayoutsTableUpdateCompanionBuilder,
          (
            DashboardLayout,
            BaseReferences<
              _$AppDatabase,
              $DashboardLayoutsTable,
              DashboardLayout
            >,
          ),
          DashboardLayout,
          PrefetchHooks Function()
        > {
  $$DashboardLayoutsTableTableManager(
    _$AppDatabase db,
    $DashboardLayoutsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DashboardLayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DashboardLayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DashboardLayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<String> cardsJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DashboardLayoutsCompanion(
                id: id,
                name: name,
                isActive: isActive,
                isPreset: isPreset,
                cardsJson: cardsJson,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isActive = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                required String cardsJson,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DashboardLayoutsCompanion.insert(
                id: id,
                name: name,
                isActive: isActive,
                isPreset: isPreset,
                cardsJson: cardsJson,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DashboardLayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DashboardLayoutsTable,
      DashboardLayout,
      $$DashboardLayoutsTableFilterComposer,
      $$DashboardLayoutsTableOrderingComposer,
      $$DashboardLayoutsTableAnnotationComposer,
      $$DashboardLayoutsTableCreateCompanionBuilder,
      $$DashboardLayoutsTableUpdateCompanionBuilder,
      (
        DashboardLayout,
        BaseReferences<_$AppDatabase, $DashboardLayoutsTable, DashboardLayout>,
      ),
      DashboardLayout,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
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

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppsTableTableManager get apps => $$AppsTableTableManager(_db, _db.apps);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SamplesTableTableManager get samples =>
      $$SamplesTableTableManager(_db, _db.samples);
  $$DashboardLayoutsTableTableManager get dashboardLayouts =>
      $$DashboardLayoutsTableTableManager(_db, _db.dashboardLayouts);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
