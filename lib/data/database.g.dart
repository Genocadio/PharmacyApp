// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $InsurancesTable extends Insurances
    with TableInfo<$InsurancesTable, Insurance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsurancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _acronymMeta = const VerificationMeta(
    'acronym',
  );
  @override
  late final GeneratedColumn<String> acronym = GeneratedColumn<String>(
    'acronym',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _clientPercentageMeta = const VerificationMeta(
    'clientPercentage',
  );
  @override
  late final GeneratedColumn<double> clientPercentage = GeneratedColumn<double>(
    'client_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    acronym,
    clientPercentage,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insurances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Insurance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('acronym')) {
      context.handle(
        _acronymMeta,
        acronym.isAcceptableOrUnknown(data['acronym']!, _acronymMeta),
      );
    } else if (isInserting) {
      context.missing(_acronymMeta);
    }
    if (data.containsKey('client_percentage')) {
      context.handle(
        _clientPercentageMeta,
        clientPercentage.isAcceptableOrUnknown(
          data['client_percentage']!,
          _clientPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientPercentageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Insurance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Insurance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      acronym: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}acronym'],
      )!,
      clientPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}client_percentage'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $InsurancesTable createAlias(String alias) {
    return $InsurancesTable(attachedDatabase, alias);
  }
}

class Insurance extends DataClass implements Insertable<Insurance> {
  final String id;
  final String name;
  final String acronym;
  final double clientPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  const Insurance({
    required this.id,
    required this.name,
    required this.acronym,
    required this.clientPercentage,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['acronym'] = Variable<String>(acronym);
    map['client_percentage'] = Variable<double>(clientPercentage);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  InsurancesCompanion toCompanion(bool nullToAbsent) {
    return InsurancesCompanion(
      id: Value(id),
      name: Value(name),
      acronym: Value(acronym),
      clientPercentage: Value(clientPercentage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
    );
  }

  factory Insurance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Insurance(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      acronym: serializer.fromJson<String>(json['acronym']),
      clientPercentage: serializer.fromJson<double>(json['clientPercentage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'acronym': serializer.toJson<String>(acronym),
      'clientPercentage': serializer.toJson<double>(clientPercentage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  Insurance copyWith({
    String? id,
    String? name,
    String? acronym,
    double? clientPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
  }) => Insurance(
    id: id ?? this.id,
    name: name ?? this.name,
    acronym: acronym ?? this.acronym,
    clientPercentage: clientPercentage ?? this.clientPercentage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
  );
  Insurance copyWithCompanion(InsurancesCompanion data) {
    return Insurance(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      acronym: data.acronym.present ? data.acronym.value : this.acronym,
      clientPercentage: data.clientPercentage.present
          ? data.clientPercentage.value
          : this.clientPercentage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Insurance(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('acronym: $acronym, ')
          ..write('clientPercentage: $clientPercentage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    acronym,
    clientPercentage,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Insurance &&
          other.id == this.id &&
          other.name == this.name &&
          other.acronym == this.acronym &&
          other.clientPercentage == this.clientPercentage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version);
}

class InsurancesCompanion extends UpdateCompanion<Insurance> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> acronym;
  final Value<double> clientPercentage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<int> rowid;
  const InsurancesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.acronym = const Value.absent(),
    this.clientPercentage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsurancesCompanion.insert({
    required String id,
    required String name,
    required String acronym,
    required double clientPercentage,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       acronym = Value(acronym),
       clientPercentage = Value(clientPercentage);
  static Insertable<Insurance> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? acronym,
    Expression<double>? clientPercentage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (acronym != null) 'acronym': acronym,
      if (clientPercentage != null) 'client_percentage': clientPercentage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsurancesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? acronym,
    Value<double>? clientPercentage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return InsurancesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      acronym: acronym ?? this.acronym,
      clientPercentage: clientPercentage ?? this.clientPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (acronym.present) {
      map['acronym'] = Variable<String>(acronym.value);
    }
    if (clientPercentage.present) {
      map['client_percentage'] = Variable<double>(clientPercentage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsurancesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('acronym: $acronym, ')
          ..write('clientPercentage: $clientPercentage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ItemType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ItemType>($ProductsTable.$convertertype);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellingUnitMeta = const VerificationMeta(
    'sellingUnit',
  );
  @override
  late final GeneratedColumn<String> sellingUnit = GeneratedColumn<String>(
    'selling_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    description,
    sellingUnit,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('selling_unit')) {
      context.handle(
        _sellingUnitMeta,
        sellingUnit.isAcceptableOrUnknown(
          data['selling_unit']!,
          _sellingUnitMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $ProductsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sellingUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selling_unit'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ItemType, String, String> $convertertype =
      const EnumNameConverter<ItemType>(ItemType.values);
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String name;
  final ItemType type;
  final String? description;
  final String? sellingUnit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  const Product({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.sellingUnit,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($ProductsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || sellingUnit != null) {
      map['selling_unit'] = Variable<String>(sellingUnit);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sellingUnit: sellingUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(sellingUnit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $ProductsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      description: serializer.fromJson<String?>(json['description']),
      sellingUnit: serializer.fromJson<String?>(json['sellingUnit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $ProductsTable.$convertertype.toJson(type),
      ),
      'description': serializer.toJson<String?>(description),
      'sellingUnit': serializer.toJson<String?>(sellingUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    ItemType? type,
    Value<String?> description = const Value.absent(),
    Value<String?> sellingUnit = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
    sellingUnit: sellingUnit.present ? sellingUnit.value : this.sellingUnit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      sellingUnit: data.sellingUnit.present
          ? data.sellingUnit.value
          : this.sellingUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('sellingUnit: $sellingUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    description,
    sellingUnit,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.description == this.description &&
          other.sellingUnit == this.sellingUnit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<ItemType> type;
  final Value<String?> description;
  final Value<String?> sellingUnit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.sellingUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required ItemType type,
    this.description = const Value.absent(),
    this.sellingUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? description,
    Expression<String>? sellingUnit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (sellingUnit != null) 'selling_unit': sellingUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<ItemType>? type,
    Value<String?>? description,
    Value<String?>? sellingUnit,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      sellingUnit: sellingUnit ?? this.sellingUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $ProductsTable.$convertertype.toSql(type.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sellingUnit.present) {
      map['selling_unit'] = Variable<String>(sellingUnit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('sellingUnit: $sellingUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductInsurancesTable extends ProductInsurances
    with TableInfo<$ProductInsurancesTable, ProductInsurance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductInsurancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utilizationCountMeta = const VerificationMeta(
    'utilizationCount',
  );
  @override
  late final GeneratedColumn<int> utilizationCount = GeneratedColumn<int>(
    'utilization_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Unit, String> unit =
      GeneratedColumn<String>(
        'unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Unit>($ProductInsurancesTable.$converterunit);
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AuthorisedLevel, String>
  authorisedLevel =
      GeneratedColumn<String>(
        'authorised_level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AuthorisedLevel>(
        $ProductInsurancesTable.$converterauthorisedLevel,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MustPrescribedBy, String>
  mustPrescribedBy =
      GeneratedColumn<String>(
        'must_prescribed_by',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MustPrescribedBy>(
        $ProductInsurancesTable.$convertermustPrescribedBy,
      );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _insuranceIdMeta = const VerificationMeta(
    'insuranceId',
  );
  @override
  late final GeneratedColumn<String> insuranceId = GeneratedColumn<String>(
    'insurance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES insurances (id)',
    ),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    utilizationCount,
    unit,
    cost,
    authorisedLevel,
    mustPrescribedBy,
    productId,
    insuranceId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_insurances';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductInsurance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('utilization_count')) {
      context.handle(
        _utilizationCountMeta,
        utilizationCount.isAcceptableOrUnknown(
          data['utilization_count']!,
          _utilizationCountMeta,
        ),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('insurance_id')) {
      context.handle(
        _insuranceIdMeta,
        insuranceId.isAcceptableOrUnknown(
          data['insurance_id']!,
          _insuranceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insuranceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductInsurance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductInsurance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      utilizationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}utilization_count'],
      ),
      unit: $ProductInsurancesTable.$converterunit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit'],
        )!,
      ),
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      authorisedLevel: $ProductInsurancesTable.$converterauthorisedLevel
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}authorised_level'],
            )!,
          ),
      mustPrescribedBy: $ProductInsurancesTable.$convertermustPrescribedBy
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}must_prescribed_by'],
            )!,
          ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      insuranceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $ProductInsurancesTable createAlias(String alias) {
    return $ProductInsurancesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Unit, String, String> $converterunit =
      const EnumNameConverter<Unit>(Unit.values);
  static JsonTypeConverter2<AuthorisedLevel, String, String>
  $converterauthorisedLevel = const EnumNameConverter<AuthorisedLevel>(
    AuthorisedLevel.values,
  );
  static JsonTypeConverter2<MustPrescribedBy, String, String>
  $convertermustPrescribedBy = const EnumNameConverter<MustPrescribedBy>(
    MustPrescribedBy.values,
  );
}

class ProductInsurance extends DataClass
    implements Insertable<ProductInsurance> {
  final String id;
  final String code;
  final int? utilizationCount;
  final Unit unit;
  final double cost;
  final AuthorisedLevel authorisedLevel;
  final MustPrescribedBy mustPrescribedBy;
  final String productId;
  final String insuranceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  const ProductInsurance({
    required this.id,
    required this.code,
    this.utilizationCount,
    required this.unit,
    required this.cost,
    required this.authorisedLevel,
    required this.mustPrescribedBy,
    required this.productId,
    required this.insuranceId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || utilizationCount != null) {
      map['utilization_count'] = Variable<int>(utilizationCount);
    }
    {
      map['unit'] = Variable<String>(
        $ProductInsurancesTable.$converterunit.toSql(unit),
      );
    }
    map['cost'] = Variable<double>(cost);
    {
      map['authorised_level'] = Variable<String>(
        $ProductInsurancesTable.$converterauthorisedLevel.toSql(
          authorisedLevel,
        ),
      );
    }
    {
      map['must_prescribed_by'] = Variable<String>(
        $ProductInsurancesTable.$convertermustPrescribedBy.toSql(
          mustPrescribedBy,
        ),
      );
    }
    map['product_id'] = Variable<String>(productId);
    map['insurance_id'] = Variable<String>(insuranceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  ProductInsurancesCompanion toCompanion(bool nullToAbsent) {
    return ProductInsurancesCompanion(
      id: Value(id),
      code: Value(code),
      utilizationCount: utilizationCount == null && nullToAbsent
          ? const Value.absent()
          : Value(utilizationCount),
      unit: Value(unit),
      cost: Value(cost),
      authorisedLevel: Value(authorisedLevel),
      mustPrescribedBy: Value(mustPrescribedBy),
      productId: Value(productId),
      insuranceId: Value(insuranceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
    );
  }

  factory ProductInsurance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductInsurance(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      utilizationCount: serializer.fromJson<int?>(json['utilizationCount']),
      unit: $ProductInsurancesTable.$converterunit.fromJson(
        serializer.fromJson<String>(json['unit']),
      ),
      cost: serializer.fromJson<double>(json['cost']),
      authorisedLevel: $ProductInsurancesTable.$converterauthorisedLevel
          .fromJson(serializer.fromJson<String>(json['authorisedLevel'])),
      mustPrescribedBy: $ProductInsurancesTable.$convertermustPrescribedBy
          .fromJson(serializer.fromJson<String>(json['mustPrescribedBy'])),
      productId: serializer.fromJson<String>(json['productId']),
      insuranceId: serializer.fromJson<String>(json['insuranceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'utilizationCount': serializer.toJson<int?>(utilizationCount),
      'unit': serializer.toJson<String>(
        $ProductInsurancesTable.$converterunit.toJson(unit),
      ),
      'cost': serializer.toJson<double>(cost),
      'authorisedLevel': serializer.toJson<String>(
        $ProductInsurancesTable.$converterauthorisedLevel.toJson(
          authorisedLevel,
        ),
      ),
      'mustPrescribedBy': serializer.toJson<String>(
        $ProductInsurancesTable.$convertermustPrescribedBy.toJson(
          mustPrescribedBy,
        ),
      ),
      'productId': serializer.toJson<String>(productId),
      'insuranceId': serializer.toJson<String>(insuranceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  ProductInsurance copyWith({
    String? id,
    String? code,
    Value<int?> utilizationCount = const Value.absent(),
    Unit? unit,
    double? cost,
    AuthorisedLevel? authorisedLevel,
    MustPrescribedBy? mustPrescribedBy,
    String? productId,
    String? insuranceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
  }) => ProductInsurance(
    id: id ?? this.id,
    code: code ?? this.code,
    utilizationCount: utilizationCount.present
        ? utilizationCount.value
        : this.utilizationCount,
    unit: unit ?? this.unit,
    cost: cost ?? this.cost,
    authorisedLevel: authorisedLevel ?? this.authorisedLevel,
    mustPrescribedBy: mustPrescribedBy ?? this.mustPrescribedBy,
    productId: productId ?? this.productId,
    insuranceId: insuranceId ?? this.insuranceId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
  );
  ProductInsurance copyWithCompanion(ProductInsurancesCompanion data) {
    return ProductInsurance(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      utilizationCount: data.utilizationCount.present
          ? data.utilizationCount.value
          : this.utilizationCount,
      unit: data.unit.present ? data.unit.value : this.unit,
      cost: data.cost.present ? data.cost.value : this.cost,
      authorisedLevel: data.authorisedLevel.present
          ? data.authorisedLevel.value
          : this.authorisedLevel,
      mustPrescribedBy: data.mustPrescribedBy.present
          ? data.mustPrescribedBy.value
          : this.mustPrescribedBy,
      productId: data.productId.present ? data.productId.value : this.productId,
      insuranceId: data.insuranceId.present
          ? data.insuranceId.value
          : this.insuranceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductInsurance(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('utilizationCount: $utilizationCount, ')
          ..write('unit: $unit, ')
          ..write('cost: $cost, ')
          ..write('authorisedLevel: $authorisedLevel, ')
          ..write('mustPrescribedBy: $mustPrescribedBy, ')
          ..write('productId: $productId, ')
          ..write('insuranceId: $insuranceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    utilizationCount,
    unit,
    cost,
    authorisedLevel,
    mustPrescribedBy,
    productId,
    insuranceId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductInsurance &&
          other.id == this.id &&
          other.code == this.code &&
          other.utilizationCount == this.utilizationCount &&
          other.unit == this.unit &&
          other.cost == this.cost &&
          other.authorisedLevel == this.authorisedLevel &&
          other.mustPrescribedBy == this.mustPrescribedBy &&
          other.productId == this.productId &&
          other.insuranceId == this.insuranceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version);
}

class ProductInsurancesCompanion extends UpdateCompanion<ProductInsurance> {
  final Value<String> id;
  final Value<String> code;
  final Value<int?> utilizationCount;
  final Value<Unit> unit;
  final Value<double> cost;
  final Value<AuthorisedLevel> authorisedLevel;
  final Value<MustPrescribedBy> mustPrescribedBy;
  final Value<String> productId;
  final Value<String> insuranceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<int> rowid;
  const ProductInsurancesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.utilizationCount = const Value.absent(),
    this.unit = const Value.absent(),
    this.cost = const Value.absent(),
    this.authorisedLevel = const Value.absent(),
    this.mustPrescribedBy = const Value.absent(),
    this.productId = const Value.absent(),
    this.insuranceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductInsurancesCompanion.insert({
    required String id,
    required String code,
    this.utilizationCount = const Value.absent(),
    required Unit unit,
    required double cost,
    required AuthorisedLevel authorisedLevel,
    required MustPrescribedBy mustPrescribedBy,
    required String productId,
    required String insuranceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       unit = Value(unit),
       cost = Value(cost),
       authorisedLevel = Value(authorisedLevel),
       mustPrescribedBy = Value(mustPrescribedBy),
       productId = Value(productId),
       insuranceId = Value(insuranceId);
  static Insertable<ProductInsurance> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<int>? utilizationCount,
    Expression<String>? unit,
    Expression<double>? cost,
    Expression<String>? authorisedLevel,
    Expression<String>? mustPrescribedBy,
    Expression<String>? productId,
    Expression<String>? insuranceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (utilizationCount != null) 'utilization_count': utilizationCount,
      if (unit != null) 'unit': unit,
      if (cost != null) 'cost': cost,
      if (authorisedLevel != null) 'authorised_level': authorisedLevel,
      if (mustPrescribedBy != null) 'must_prescribed_by': mustPrescribedBy,
      if (productId != null) 'product_id': productId,
      if (insuranceId != null) 'insurance_id': insuranceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductInsurancesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<int?>? utilizationCount,
    Value<Unit>? unit,
    Value<double>? cost,
    Value<AuthorisedLevel>? authorisedLevel,
    Value<MustPrescribedBy>? mustPrescribedBy,
    Value<String>? productId,
    Value<String>? insuranceId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ProductInsurancesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      utilizationCount: utilizationCount ?? this.utilizationCount,
      unit: unit ?? this.unit,
      cost: cost ?? this.cost,
      authorisedLevel: authorisedLevel ?? this.authorisedLevel,
      mustPrescribedBy: mustPrescribedBy ?? this.mustPrescribedBy,
      productId: productId ?? this.productId,
      insuranceId: insuranceId ?? this.insuranceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (utilizationCount.present) {
      map['utilization_count'] = Variable<int>(utilizationCount.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(
        $ProductInsurancesTable.$converterunit.toSql(unit.value),
      );
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (authorisedLevel.present) {
      map['authorised_level'] = Variable<String>(
        $ProductInsurancesTable.$converterauthorisedLevel.toSql(
          authorisedLevel.value,
        ),
      );
    }
    if (mustPrescribedBy.present) {
      map['must_prescribed_by'] = Variable<String>(
        $ProductInsurancesTable.$convertermustPrescribedBy.toSql(
          mustPrescribedBy.value,
        ),
      );
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (insuranceId.present) {
      map['insurance_id'] = Variable<String>(insuranceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductInsurancesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('utilizationCount: $utilizationCount, ')
          ..write('unit: $unit, ')
          ..write('cost: $cost, ')
          ..write('authorisedLevel: $authorisedLevel, ')
          ..write('mustPrescribedBy: $mustPrescribedBy, ')
          ..write('productId: $productId, ')
          ..write('insuranceId: $insuranceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namesMeta = const VerificationMeta('names');
  @override
  late final GeneratedColumn<String> names = GeneratedColumn<String>(
    'names',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 6,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<UserRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<UserRole>($UsersTable.$converterrole);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    names,
    phoneNumber,
    email,
    password,
    role,
    createdAt,
    updatedAt,
    deletedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('names')) {
      context.handle(
        _namesMeta,
        names.isAcceptableOrUnknown(data['names']!, _namesMeta),
      );
    } else if (isInserting) {
      context.missing(_namesMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      names: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}names'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      role: $UsersTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UserRole, String, String> $converterrole =
      const EnumNameConverter<UserRole>(UserRole.values);
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String names;
  final String phoneNumber;
  final String? email;
  final String password;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? lastSyncedAt;
  const User({
    required this.id,
    required this.names,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['names'] = Variable<String>(names);
    map['phone_number'] = Variable<String>(phoneNumber);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['password'] = Variable<String>(password);
    {
      map['role'] = Variable<String>($UsersTable.$converterrole.toSql(role));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      names: Value(names),
      phoneNumber: Value(phoneNumber),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      password: Value(password),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      names: serializer.fromJson<String>(json['names']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      email: serializer.fromJson<String?>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      role: $UsersTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'names': serializer.toJson<String>(names),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'email': serializer.toJson<String?>(email),
      'password': serializer.toJson<String>(password),
      'role': serializer.toJson<String>(
        $UsersTable.$converterrole.toJson(role),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  User copyWith({
    String? id,
    String? names,
    String? phoneNumber,
    Value<String?> email = const Value.absent(),
    String? password,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => User(
    id: id ?? this.id,
    names: names ?? this.names,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    email: email.present ? email.value : this.email,
    password: password ?? this.password,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      names: data.names.present ? data.names.value : this.names,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('names: $names, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    names,
    phoneNumber,
    email,
    password,
    role,
    createdAt,
    updatedAt,
    deletedAt,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.names == this.names &&
          other.phoneNumber == this.phoneNumber &&
          other.email == this.email &&
          other.password == this.password &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> names;
  final Value<String> phoneNumber;
  final Value<String?> email;
  final Value<String> password;
  final Value<UserRole> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.names = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String names,
    required String phoneNumber,
    this.email = const Value.absent(),
    required String password,
    required UserRole role,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       names = Value(names),
       phoneNumber = Value(phoneNumber),
       password = Value(password),
       role = Value(role);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? names,
    Expression<String>? phoneNumber,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (names != null) 'names': names,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? names,
    Value<String>? phoneNumber,
    Value<String?>? email,
    Value<String>? password,
    Value<UserRole>? role,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      names: names ?? this.names,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (names.present) {
      map['names'] = Variable<String>(names.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $UsersTable.$converterrole.toSql(role.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('names: $names, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockInsTable extends StockIns with TableInfo<$StockInsTable, StockIn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockInsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricePerUnitMeta = const VerificationMeta(
    'pricePerUnit',
  );
  @override
  late final GeneratedColumn<double> pricePerUnit = GeneratedColumn<double>(
    'price_per_unit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<int> reorderLevel = GeneratedColumn<int>(
    'reorder_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quantity,
    location,
    pricePerUnit,
    batchNumber,
    expiryDate,
    reorderLevel,
    productId,
    userId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_ins';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockIn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
        _pricePerUnitMeta,
        pricePerUnit.isAcceptableOrUnknown(
          data['price_per_unit']!,
          _pricePerUnitMeta,
        ),
      );
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockIn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockIn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      pricePerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_unit'],
      ),
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reorder_level'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $StockInsTable createAlias(String alias) {
    return $StockInsTable(attachedDatabase, alias);
  }
}

class StockIn extends DataClass implements Insertable<StockIn> {
  final String id;
  final int quantity;
  final String? location;
  final double? pricePerUnit;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int? reorderLevel;
  final String productId;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const StockIn({
    required this.id,
    required this.quantity,
    this.location,
    this.pricePerUnit,
    this.batchNumber,
    this.expiryDate,
    this.reorderLevel,
    required this.productId,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || pricePerUnit != null) {
      map['price_per_unit'] = Variable<double>(pricePerUnit);
    }
    if (!nullToAbsent || batchNumber != null) {
      map['batch_number'] = Variable<String>(batchNumber);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    if (!nullToAbsent || reorderLevel != null) {
      map['reorder_level'] = Variable<int>(reorderLevel);
    }
    map['product_id'] = Variable<String>(productId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  StockInsCompanion toCompanion(bool nullToAbsent) {
    return StockInsCompanion(
      id: Value(id),
      quantity: Value(quantity),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      pricePerUnit: pricePerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerUnit),
      batchNumber: batchNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(batchNumber),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      reorderLevel: reorderLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderLevel),
      productId: Value(productId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory StockIn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockIn(
      id: serializer.fromJson<String>(json['id']),
      quantity: serializer.fromJson<int>(json['quantity']),
      location: serializer.fromJson<String?>(json['location']),
      pricePerUnit: serializer.fromJson<double?>(json['pricePerUnit']),
      batchNumber: serializer.fromJson<String?>(json['batchNumber']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      reorderLevel: serializer.fromJson<int?>(json['reorderLevel']),
      productId: serializer.fromJson<String>(json['productId']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quantity': serializer.toJson<int>(quantity),
      'location': serializer.toJson<String?>(location),
      'pricePerUnit': serializer.toJson<double?>(pricePerUnit),
      'batchNumber': serializer.toJson<String?>(batchNumber),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'reorderLevel': serializer.toJson<int?>(reorderLevel),
      'productId': serializer.toJson<String>(productId),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  StockIn copyWith({
    String? id,
    int? quantity,
    Value<String?> location = const Value.absent(),
    Value<double?> pricePerUnit = const Value.absent(),
    Value<String?> batchNumber = const Value.absent(),
    Value<DateTime?> expiryDate = const Value.absent(),
    Value<int?> reorderLevel = const Value.absent(),
    String? productId,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => StockIn(
    id: id ?? this.id,
    quantity: quantity ?? this.quantity,
    location: location.present ? location.value : this.location,
    pricePerUnit: pricePerUnit.present ? pricePerUnit.value : this.pricePerUnit,
    batchNumber: batchNumber.present ? batchNumber.value : this.batchNumber,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    reorderLevel: reorderLevel.present ? reorderLevel.value : this.reorderLevel,
    productId: productId ?? this.productId,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  StockIn copyWithCompanion(StockInsCompanion data) {
    return StockIn(
      id: data.id.present ? data.id.value : this.id,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      location: data.location.present ? data.location.value : this.location,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      productId: data.productId.present ? data.productId.value : this.productId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockIn(')
          ..write('id: $id, ')
          ..write('quantity: $quantity, ')
          ..write('location: $location, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('productId: $productId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quantity,
    location,
    pricePerUnit,
    batchNumber,
    expiryDate,
    reorderLevel,
    productId,
    userId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockIn &&
          other.id == this.id &&
          other.quantity == this.quantity &&
          other.location == this.location &&
          other.pricePerUnit == this.pricePerUnit &&
          other.batchNumber == this.batchNumber &&
          other.expiryDate == this.expiryDate &&
          other.reorderLevel == this.reorderLevel &&
          other.productId == this.productId &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class StockInsCompanion extends UpdateCompanion<StockIn> {
  final Value<String> id;
  final Value<int> quantity;
  final Value<String?> location;
  final Value<double?> pricePerUnit;
  final Value<String?> batchNumber;
  final Value<DateTime?> expiryDate;
  final Value<int?> reorderLevel;
  final Value<String> productId;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const StockInsCompanion({
    this.id = const Value.absent(),
    this.quantity = const Value.absent(),
    this.location = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.productId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockInsCompanion.insert({
    required String id,
    required int quantity,
    this.location = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    required String productId,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       quantity = Value(quantity),
       productId = Value(productId);
  static Insertable<StockIn> custom({
    Expression<String>? id,
    Expression<int>? quantity,
    Expression<String>? location,
    Expression<double>? pricePerUnit,
    Expression<String>? batchNumber,
    Expression<DateTime>? expiryDate,
    Expression<int>? reorderLevel,
    Expression<String>? productId,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quantity != null) 'quantity': quantity,
      if (location != null) 'location': location,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (productId != null) 'product_id': productId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockInsCompanion copyWith({
    Value<String>? id,
    Value<int>? quantity,
    Value<String?>? location,
    Value<double?>? pricePerUnit,
    Value<String?>? batchNumber,
    Value<DateTime?>? expiryDate,
    Value<int?>? reorderLevel,
    Value<String>? productId,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return StockInsCompanion(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<double>(pricePerUnit.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<int>(reorderLevel.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockInsCompanion(')
          ..write('id: $id, ')
          ..write('quantity: $quantity, ')
          ..write('location: $location, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('productId: $productId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockOutsTable extends StockOuts
    with TableInfo<$StockOutsTable, StockOut> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockOutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockInIdMeta = const VerificationMeta(
    'stockInId',
  );
  @override
  late final GeneratedColumn<String> stockInId = GeneratedColumn<String>(
    'stock_in_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stock_ins (id)',
    ),
  );
  static const VerificationMeta _quantitySoldMeta = const VerificationMeta(
    'quantitySold',
  );
  @override
  late final GeneratedColumn<int> quantitySold = GeneratedColumn<int>(
    'quantity_sold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerUnitMeta = const VerificationMeta(
    'pricePerUnit',
  );
  @override
  late final GeneratedColumn<double> pricePerUnit = GeneratedColumn<double>(
    'price_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insuranceIdMeta = const VerificationMeta(
    'insuranceId',
  );
  @override
  late final GeneratedColumn<String> insuranceId = GeneratedColumn<String>(
    'insurance_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemTotalMeta = const VerificationMeta(
    'itemTotal',
  );
  @override
  late final GeneratedColumn<double> itemTotal = GeneratedColumn<double>(
    'item_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientPaysMeta = const VerificationMeta(
    'patientPays',
  );
  @override
  late final GeneratedColumn<double> patientPays = GeneratedColumn<double>(
    'patient_pays',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insurancePaysMeta = const VerificationMeta(
    'insurancePays',
  );
  @override
  late final GeneratedColumn<double> insurancePays = GeneratedColumn<double>(
    'insurance_pays',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stockInId,
    quantitySold,
    pricePerUnit,
    insuranceId,
    itemTotal,
    patientPays,
    insurancePays,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_outs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockOut> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stock_in_id')) {
      context.handle(
        _stockInIdMeta,
        stockInId.isAcceptableOrUnknown(data['stock_in_id']!, _stockInIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stockInIdMeta);
    }
    if (data.containsKey('quantity_sold')) {
      context.handle(
        _quantitySoldMeta,
        quantitySold.isAcceptableOrUnknown(
          data['quantity_sold']!,
          _quantitySoldMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantitySoldMeta);
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
        _pricePerUnitMeta,
        pricePerUnit.isAcceptableOrUnknown(
          data['price_per_unit']!,
          _pricePerUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerUnitMeta);
    }
    if (data.containsKey('insurance_id')) {
      context.handle(
        _insuranceIdMeta,
        insuranceId.isAcceptableOrUnknown(
          data['insurance_id']!,
          _insuranceIdMeta,
        ),
      );
    }
    if (data.containsKey('item_total')) {
      context.handle(
        _itemTotalMeta,
        itemTotal.isAcceptableOrUnknown(data['item_total']!, _itemTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTotalMeta);
    }
    if (data.containsKey('patient_pays')) {
      context.handle(
        _patientPaysMeta,
        patientPays.isAcceptableOrUnknown(
          data['patient_pays']!,
          _patientPaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientPaysMeta);
    }
    if (data.containsKey('insurance_pays')) {
      context.handle(
        _insurancePaysMeta,
        insurancePays.isAcceptableOrUnknown(
          data['insurance_pays']!,
          _insurancePaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insurancePaysMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockOut map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockOut(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      stockInId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_in_id'],
      )!,
      quantitySold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_sold'],
      )!,
      pricePerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_unit'],
      )!,
      insuranceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_id'],
      ),
      itemTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}item_total'],
      )!,
      patientPays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}patient_pays'],
      )!,
      insurancePays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}insurance_pays'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $StockOutsTable createAlias(String alias) {
    return $StockOutsTable(attachedDatabase, alias);
  }
}

class StockOut extends DataClass implements Insertable<StockOut> {
  final String id;
  final String stockInId;
  final int quantitySold;
  final double pricePerUnit;
  final String? insuranceId;
  final double itemTotal;
  final double patientPays;
  final double insurancePays;
  final DateTime? lastSyncedAt;
  const StockOut({
    required this.id,
    required this.stockInId,
    required this.quantitySold,
    required this.pricePerUnit,
    this.insuranceId,
    required this.itemTotal,
    required this.patientPays,
    required this.insurancePays,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stock_in_id'] = Variable<String>(stockInId);
    map['quantity_sold'] = Variable<int>(quantitySold);
    map['price_per_unit'] = Variable<double>(pricePerUnit);
    if (!nullToAbsent || insuranceId != null) {
      map['insurance_id'] = Variable<String>(insuranceId);
    }
    map['item_total'] = Variable<double>(itemTotal);
    map['patient_pays'] = Variable<double>(patientPays);
    map['insurance_pays'] = Variable<double>(insurancePays);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  StockOutsCompanion toCompanion(bool nullToAbsent) {
    return StockOutsCompanion(
      id: Value(id),
      stockInId: Value(stockInId),
      quantitySold: Value(quantitySold),
      pricePerUnit: Value(pricePerUnit),
      insuranceId: insuranceId == null && nullToAbsent
          ? const Value.absent()
          : Value(insuranceId),
      itemTotal: Value(itemTotal),
      patientPays: Value(patientPays),
      insurancePays: Value(insurancePays),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory StockOut.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockOut(
      id: serializer.fromJson<String>(json['id']),
      stockInId: serializer.fromJson<String>(json['stockInId']),
      quantitySold: serializer.fromJson<int>(json['quantitySold']),
      pricePerUnit: serializer.fromJson<double>(json['pricePerUnit']),
      insuranceId: serializer.fromJson<String?>(json['insuranceId']),
      itemTotal: serializer.fromJson<double>(json['itemTotal']),
      patientPays: serializer.fromJson<double>(json['patientPays']),
      insurancePays: serializer.fromJson<double>(json['insurancePays']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stockInId': serializer.toJson<String>(stockInId),
      'quantitySold': serializer.toJson<int>(quantitySold),
      'pricePerUnit': serializer.toJson<double>(pricePerUnit),
      'insuranceId': serializer.toJson<String?>(insuranceId),
      'itemTotal': serializer.toJson<double>(itemTotal),
      'patientPays': serializer.toJson<double>(patientPays),
      'insurancePays': serializer.toJson<double>(insurancePays),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  StockOut copyWith({
    String? id,
    String? stockInId,
    int? quantitySold,
    double? pricePerUnit,
    Value<String?> insuranceId = const Value.absent(),
    double? itemTotal,
    double? patientPays,
    double? insurancePays,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => StockOut(
    id: id ?? this.id,
    stockInId: stockInId ?? this.stockInId,
    quantitySold: quantitySold ?? this.quantitySold,
    pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    insuranceId: insuranceId.present ? insuranceId.value : this.insuranceId,
    itemTotal: itemTotal ?? this.itemTotal,
    patientPays: patientPays ?? this.patientPays,
    insurancePays: insurancePays ?? this.insurancePays,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  StockOut copyWithCompanion(StockOutsCompanion data) {
    return StockOut(
      id: data.id.present ? data.id.value : this.id,
      stockInId: data.stockInId.present ? data.stockInId.value : this.stockInId,
      quantitySold: data.quantitySold.present
          ? data.quantitySold.value
          : this.quantitySold,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      insuranceId: data.insuranceId.present
          ? data.insuranceId.value
          : this.insuranceId,
      itemTotal: data.itemTotal.present ? data.itemTotal.value : this.itemTotal,
      patientPays: data.patientPays.present
          ? data.patientPays.value
          : this.patientPays,
      insurancePays: data.insurancePays.present
          ? data.insurancePays.value
          : this.insurancePays,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockOut(')
          ..write('id: $id, ')
          ..write('stockInId: $stockInId, ')
          ..write('quantitySold: $quantitySold, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('insuranceId: $insuranceId, ')
          ..write('itemTotal: $itemTotal, ')
          ..write('patientPays: $patientPays, ')
          ..write('insurancePays: $insurancePays, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stockInId,
    quantitySold,
    pricePerUnit,
    insuranceId,
    itemTotal,
    patientPays,
    insurancePays,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockOut &&
          other.id == this.id &&
          other.stockInId == this.stockInId &&
          other.quantitySold == this.quantitySold &&
          other.pricePerUnit == this.pricePerUnit &&
          other.insuranceId == this.insuranceId &&
          other.itemTotal == this.itemTotal &&
          other.patientPays == this.patientPays &&
          other.insurancePays == this.insurancePays &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class StockOutsCompanion extends UpdateCompanion<StockOut> {
  final Value<String> id;
  final Value<String> stockInId;
  final Value<int> quantitySold;
  final Value<double> pricePerUnit;
  final Value<String?> insuranceId;
  final Value<double> itemTotal;
  final Value<double> patientPays;
  final Value<double> insurancePays;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const StockOutsCompanion({
    this.id = const Value.absent(),
    this.stockInId = const Value.absent(),
    this.quantitySold = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.insuranceId = const Value.absent(),
    this.itemTotal = const Value.absent(),
    this.patientPays = const Value.absent(),
    this.insurancePays = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockOutsCompanion.insert({
    required String id,
    required String stockInId,
    required int quantitySold,
    required double pricePerUnit,
    this.insuranceId = const Value.absent(),
    required double itemTotal,
    required double patientPays,
    required double insurancePays,
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stockInId = Value(stockInId),
       quantitySold = Value(quantitySold),
       pricePerUnit = Value(pricePerUnit),
       itemTotal = Value(itemTotal),
       patientPays = Value(patientPays),
       insurancePays = Value(insurancePays);
  static Insertable<StockOut> custom({
    Expression<String>? id,
    Expression<String>? stockInId,
    Expression<int>? quantitySold,
    Expression<double>? pricePerUnit,
    Expression<String>? insuranceId,
    Expression<double>? itemTotal,
    Expression<double>? patientPays,
    Expression<double>? insurancePays,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stockInId != null) 'stock_in_id': stockInId,
      if (quantitySold != null) 'quantity_sold': quantitySold,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (insuranceId != null) 'insurance_id': insuranceId,
      if (itemTotal != null) 'item_total': itemTotal,
      if (patientPays != null) 'patient_pays': patientPays,
      if (insurancePays != null) 'insurance_pays': insurancePays,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockOutsCompanion copyWith({
    Value<String>? id,
    Value<String>? stockInId,
    Value<int>? quantitySold,
    Value<double>? pricePerUnit,
    Value<String?>? insuranceId,
    Value<double>? itemTotal,
    Value<double>? patientPays,
    Value<double>? insurancePays,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return StockOutsCompanion(
      id: id ?? this.id,
      stockInId: stockInId ?? this.stockInId,
      quantitySold: quantitySold ?? this.quantitySold,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      insuranceId: insuranceId ?? this.insuranceId,
      itemTotal: itemTotal ?? this.itemTotal,
      patientPays: patientPays ?? this.patientPays,
      insurancePays: insurancePays ?? this.insurancePays,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stockInId.present) {
      map['stock_in_id'] = Variable<String>(stockInId.value);
    }
    if (quantitySold.present) {
      map['quantity_sold'] = Variable<int>(quantitySold.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<double>(pricePerUnit.value);
    }
    if (insuranceId.present) {
      map['insurance_id'] = Variable<String>(insuranceId.value);
    }
    if (itemTotal.present) {
      map['item_total'] = Variable<double>(itemTotal.value);
    }
    if (patientPays.present) {
      map['patient_pays'] = Variable<double>(patientPays.value);
    }
    if (insurancePays.present) {
      map['insurance_pays'] = Variable<double>(insurancePays.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockOutsCompanion(')
          ..write('id: $id, ')
          ..write('stockInId: $stockInId, ')
          ..write('quantitySold: $quantitySold, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('insuranceId: $insuranceId, ')
          ..write('itemTotal: $itemTotal, ')
          ..write('patientPays: $patientPays, ')
          ..write('insurancePays: $insurancePays, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockOutSalesTable extends StockOutSales
    with TableInfo<$StockOutSalesTable, StockOutSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockOutSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockOutIdMeta = const VerificationMeta(
    'stockOutId',
  );
  @override
  late final GeneratedColumn<String> stockOutId = GeneratedColumn<String>(
    'stock_out_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stock_outs (id)',
    ),
  );
  static const VerificationMeta _patientNameMeta = const VerificationMeta(
    'patientName',
  );
  @override
  late final GeneratedColumn<String> patientName = GeneratedColumn<String>(
    'patient_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationClinicServiceMeta =
      const VerificationMeta('destinationClinicService');
  @override
  late final GeneratedColumn<String> destinationClinicService =
      GeneratedColumn<String>(
        'destination_clinic_service',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _insuranceCardNumberMeta =
      const VerificationMeta('insuranceCardNumber');
  @override
  late final GeneratedColumn<String> insuranceCardNumber =
      GeneratedColumn<String>(
        'insurance_card_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _issuingCompanyMeta = const VerificationMeta(
    'issuingCompany',
  );
  @override
  late final GeneratedColumn<String> issuingCompany = GeneratedColumn<String>(
    'issuing_company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prescriberNameMeta = const VerificationMeta(
    'prescriberName',
  );
  @override
  late final GeneratedColumn<String> prescriberName = GeneratedColumn<String>(
    'prescriber_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prescriberLicenseIdMeta =
      const VerificationMeta('prescriberLicenseId');
  @override
  late final GeneratedColumn<String> prescriberLicenseId =
      GeneratedColumn<String>(
        'prescriber_license_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _prescribingOrganizationMeta =
      const VerificationMeta('prescribingOrganization');
  @override
  late final GeneratedColumn<String> prescribingOrganization =
      GeneratedColumn<String>(
        'prescribing_organization',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalPriceMeta = const VerificationMeta(
    'totalPrice',
  );
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
    'total_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    stockOutId,
    patientName,
    destinationClinicService,
    insuranceCardNumber,
    issuingCompany,
    prescriberName,
    prescriberLicenseId,
    prescribingOrganization,
    totalPrice,
    userId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_out_sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockOutSale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('stock_out_id')) {
      context.handle(
        _stockOutIdMeta,
        stockOutId.isAcceptableOrUnknown(
          data['stock_out_id']!,
          _stockOutIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockOutIdMeta);
    }
    if (data.containsKey('patient_name')) {
      context.handle(
        _patientNameMeta,
        patientName.isAcceptableOrUnknown(
          data['patient_name']!,
          _patientNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientNameMeta);
    }
    if (data.containsKey('destination_clinic_service')) {
      context.handle(
        _destinationClinicServiceMeta,
        destinationClinicService.isAcceptableOrUnknown(
          data['destination_clinic_service']!,
          _destinationClinicServiceMeta,
        ),
      );
    }
    if (data.containsKey('insurance_card_number')) {
      context.handle(
        _insuranceCardNumberMeta,
        insuranceCardNumber.isAcceptableOrUnknown(
          data['insurance_card_number']!,
          _insuranceCardNumberMeta,
        ),
      );
    }
    if (data.containsKey('issuing_company')) {
      context.handle(
        _issuingCompanyMeta,
        issuingCompany.isAcceptableOrUnknown(
          data['issuing_company']!,
          _issuingCompanyMeta,
        ),
      );
    }
    if (data.containsKey('prescriber_name')) {
      context.handle(
        _prescriberNameMeta,
        prescriberName.isAcceptableOrUnknown(
          data['prescriber_name']!,
          _prescriberNameMeta,
        ),
      );
    }
    if (data.containsKey('prescriber_license_id')) {
      context.handle(
        _prescriberLicenseIdMeta,
        prescriberLicenseId.isAcceptableOrUnknown(
          data['prescriber_license_id']!,
          _prescriberLicenseIdMeta,
        ),
      );
    }
    if (data.containsKey('prescribing_organization')) {
      context.handle(
        _prescribingOrganizationMeta,
        prescribingOrganization.isAcceptableOrUnknown(
          data['prescribing_organization']!,
          _prescribingOrganizationMeta,
        ),
      );
    }
    if (data.containsKey('total_price')) {
      context.handle(
        _totalPriceMeta,
        totalPrice.isAcceptableOrUnknown(data['total_price']!, _totalPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockOutSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockOutSale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      stockOutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_out_id'],
      )!,
      patientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_name'],
      )!,
      destinationClinicService: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_clinic_service'],
      ),
      insuranceCardNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_card_number'],
      ),
      issuingCompany: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuing_company'],
      ),
      prescriberName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescriber_name'],
      ),
      prescriberLicenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescriber_license_id'],
      ),
      prescribingOrganization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescribing_organization'],
      ),
      totalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_price'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $StockOutSalesTable createAlias(String alias) {
    return $StockOutSalesTable(attachedDatabase, alias);
  }
}

class StockOutSale extends DataClass implements Insertable<StockOutSale> {
  final String id;
  final String transactionId;
  final String stockOutId;
  final String patientName;
  final String? destinationClinicService;
  final String? insuranceCardNumber;
  final String? issuingCompany;
  final String? prescriberName;
  final String? prescriberLicenseId;
  final String? prescribingOrganization;
  final double totalPrice;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const StockOutSale({
    required this.id,
    required this.transactionId,
    required this.stockOutId,
    required this.patientName,
    this.destinationClinicService,
    this.insuranceCardNumber,
    this.issuingCompany,
    this.prescriberName,
    this.prescriberLicenseId,
    this.prescribingOrganization,
    required this.totalPrice,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['stock_out_id'] = Variable<String>(stockOutId);
    map['patient_name'] = Variable<String>(patientName);
    if (!nullToAbsent || destinationClinicService != null) {
      map['destination_clinic_service'] = Variable<String>(
        destinationClinicService,
      );
    }
    if (!nullToAbsent || insuranceCardNumber != null) {
      map['insurance_card_number'] = Variable<String>(insuranceCardNumber);
    }
    if (!nullToAbsent || issuingCompany != null) {
      map['issuing_company'] = Variable<String>(issuingCompany);
    }
    if (!nullToAbsent || prescriberName != null) {
      map['prescriber_name'] = Variable<String>(prescriberName);
    }
    if (!nullToAbsent || prescriberLicenseId != null) {
      map['prescriber_license_id'] = Variable<String>(prescriberLicenseId);
    }
    if (!nullToAbsent || prescribingOrganization != null) {
      map['prescribing_organization'] = Variable<String>(
        prescribingOrganization,
      );
    }
    map['total_price'] = Variable<double>(totalPrice);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  StockOutSalesCompanion toCompanion(bool nullToAbsent) {
    return StockOutSalesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      stockOutId: Value(stockOutId),
      patientName: Value(patientName),
      destinationClinicService: destinationClinicService == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationClinicService),
      insuranceCardNumber: insuranceCardNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(insuranceCardNumber),
      issuingCompany: issuingCompany == null && nullToAbsent
          ? const Value.absent()
          : Value(issuingCompany),
      prescriberName: prescriberName == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriberName),
      prescriberLicenseId: prescriberLicenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriberLicenseId),
      prescribingOrganization: prescribingOrganization == null && nullToAbsent
          ? const Value.absent()
          : Value(prescribingOrganization),
      totalPrice: Value(totalPrice),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory StockOutSale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockOutSale(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      stockOutId: serializer.fromJson<String>(json['stockOutId']),
      patientName: serializer.fromJson<String>(json['patientName']),
      destinationClinicService: serializer.fromJson<String?>(
        json['destinationClinicService'],
      ),
      insuranceCardNumber: serializer.fromJson<String?>(
        json['insuranceCardNumber'],
      ),
      issuingCompany: serializer.fromJson<String?>(json['issuingCompany']),
      prescriberName: serializer.fromJson<String?>(json['prescriberName']),
      prescriberLicenseId: serializer.fromJson<String?>(
        json['prescriberLicenseId'],
      ),
      prescribingOrganization: serializer.fromJson<String?>(
        json['prescribingOrganization'],
      ),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'stockOutId': serializer.toJson<String>(stockOutId),
      'patientName': serializer.toJson<String>(patientName),
      'destinationClinicService': serializer.toJson<String?>(
        destinationClinicService,
      ),
      'insuranceCardNumber': serializer.toJson<String?>(insuranceCardNumber),
      'issuingCompany': serializer.toJson<String?>(issuingCompany),
      'prescriberName': serializer.toJson<String?>(prescriberName),
      'prescriberLicenseId': serializer.toJson<String?>(prescriberLicenseId),
      'prescribingOrganization': serializer.toJson<String?>(
        prescribingOrganization,
      ),
      'totalPrice': serializer.toJson<double>(totalPrice),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  StockOutSale copyWith({
    String? id,
    String? transactionId,
    String? stockOutId,
    String? patientName,
    Value<String?> destinationClinicService = const Value.absent(),
    Value<String?> insuranceCardNumber = const Value.absent(),
    Value<String?> issuingCompany = const Value.absent(),
    Value<String?> prescriberName = const Value.absent(),
    Value<String?> prescriberLicenseId = const Value.absent(),
    Value<String?> prescribingOrganization = const Value.absent(),
    double? totalPrice,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => StockOutSale(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    stockOutId: stockOutId ?? this.stockOutId,
    patientName: patientName ?? this.patientName,
    destinationClinicService: destinationClinicService.present
        ? destinationClinicService.value
        : this.destinationClinicService,
    insuranceCardNumber: insuranceCardNumber.present
        ? insuranceCardNumber.value
        : this.insuranceCardNumber,
    issuingCompany: issuingCompany.present
        ? issuingCompany.value
        : this.issuingCompany,
    prescriberName: prescriberName.present
        ? prescriberName.value
        : this.prescriberName,
    prescriberLicenseId: prescriberLicenseId.present
        ? prescriberLicenseId.value
        : this.prescriberLicenseId,
    prescribingOrganization: prescribingOrganization.present
        ? prescribingOrganization.value
        : this.prescribingOrganization,
    totalPrice: totalPrice ?? this.totalPrice,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  StockOutSale copyWithCompanion(StockOutSalesCompanion data) {
    return StockOutSale(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      stockOutId: data.stockOutId.present
          ? data.stockOutId.value
          : this.stockOutId,
      patientName: data.patientName.present
          ? data.patientName.value
          : this.patientName,
      destinationClinicService: data.destinationClinicService.present
          ? data.destinationClinicService.value
          : this.destinationClinicService,
      insuranceCardNumber: data.insuranceCardNumber.present
          ? data.insuranceCardNumber.value
          : this.insuranceCardNumber,
      issuingCompany: data.issuingCompany.present
          ? data.issuingCompany.value
          : this.issuingCompany,
      prescriberName: data.prescriberName.present
          ? data.prescriberName.value
          : this.prescriberName,
      prescriberLicenseId: data.prescriberLicenseId.present
          ? data.prescriberLicenseId.value
          : this.prescriberLicenseId,
      prescribingOrganization: data.prescribingOrganization.present
          ? data.prescribingOrganization.value
          : this.prescribingOrganization,
      totalPrice: data.totalPrice.present
          ? data.totalPrice.value
          : this.totalPrice,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockOutSale(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('stockOutId: $stockOutId, ')
          ..write('patientName: $patientName, ')
          ..write('destinationClinicService: $destinationClinicService, ')
          ..write('insuranceCardNumber: $insuranceCardNumber, ')
          ..write('issuingCompany: $issuingCompany, ')
          ..write('prescriberName: $prescriberName, ')
          ..write('prescriberLicenseId: $prescriberLicenseId, ')
          ..write('prescribingOrganization: $prescribingOrganization, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    stockOutId,
    patientName,
    destinationClinicService,
    insuranceCardNumber,
    issuingCompany,
    prescriberName,
    prescriberLicenseId,
    prescribingOrganization,
    totalPrice,
    userId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockOutSale &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.stockOutId == this.stockOutId &&
          other.patientName == this.patientName &&
          other.destinationClinicService == this.destinationClinicService &&
          other.insuranceCardNumber == this.insuranceCardNumber &&
          other.issuingCompany == this.issuingCompany &&
          other.prescriberName == this.prescriberName &&
          other.prescriberLicenseId == this.prescriberLicenseId &&
          other.prescribingOrganization == this.prescribingOrganization &&
          other.totalPrice == this.totalPrice &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class StockOutSalesCompanion extends UpdateCompanion<StockOutSale> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> stockOutId;
  final Value<String> patientName;
  final Value<String?> destinationClinicService;
  final Value<String?> insuranceCardNumber;
  final Value<String?> issuingCompany;
  final Value<String?> prescriberName;
  final Value<String?> prescriberLicenseId;
  final Value<String?> prescribingOrganization;
  final Value<double> totalPrice;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const StockOutSalesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.stockOutId = const Value.absent(),
    this.patientName = const Value.absent(),
    this.destinationClinicService = const Value.absent(),
    this.insuranceCardNumber = const Value.absent(),
    this.issuingCompany = const Value.absent(),
    this.prescriberName = const Value.absent(),
    this.prescriberLicenseId = const Value.absent(),
    this.prescribingOrganization = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockOutSalesCompanion.insert({
    required String id,
    required String transactionId,
    required String stockOutId,
    required String patientName,
    this.destinationClinicService = const Value.absent(),
    this.insuranceCardNumber = const Value.absent(),
    this.issuingCompany = const Value.absent(),
    this.prescriberName = const Value.absent(),
    this.prescriberLicenseId = const Value.absent(),
    this.prescribingOrganization = const Value.absent(),
    required double totalPrice,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       stockOutId = Value(stockOutId),
       patientName = Value(patientName),
       totalPrice = Value(totalPrice);
  static Insertable<StockOutSale> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? stockOutId,
    Expression<String>? patientName,
    Expression<String>? destinationClinicService,
    Expression<String>? insuranceCardNumber,
    Expression<String>? issuingCompany,
    Expression<String>? prescriberName,
    Expression<String>? prescriberLicenseId,
    Expression<String>? prescribingOrganization,
    Expression<double>? totalPrice,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (stockOutId != null) 'stock_out_id': stockOutId,
      if (patientName != null) 'patient_name': patientName,
      if (destinationClinicService != null)
        'destination_clinic_service': destinationClinicService,
      if (insuranceCardNumber != null)
        'insurance_card_number': insuranceCardNumber,
      if (issuingCompany != null) 'issuing_company': issuingCompany,
      if (prescriberName != null) 'prescriber_name': prescriberName,
      if (prescriberLicenseId != null)
        'prescriber_license_id': prescriberLicenseId,
      if (prescribingOrganization != null)
        'prescribing_organization': prescribingOrganization,
      if (totalPrice != null) 'total_price': totalPrice,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockOutSalesCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? stockOutId,
    Value<String>? patientName,
    Value<String?>? destinationClinicService,
    Value<String?>? insuranceCardNumber,
    Value<String?>? issuingCompany,
    Value<String?>? prescriberName,
    Value<String?>? prescriberLicenseId,
    Value<String?>? prescribingOrganization,
    Value<double>? totalPrice,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return StockOutSalesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      stockOutId: stockOutId ?? this.stockOutId,
      patientName: patientName ?? this.patientName,
      destinationClinicService:
          destinationClinicService ?? this.destinationClinicService,
      insuranceCardNumber: insuranceCardNumber ?? this.insuranceCardNumber,
      issuingCompany: issuingCompany ?? this.issuingCompany,
      prescriberName: prescriberName ?? this.prescriberName,
      prescriberLicenseId: prescriberLicenseId ?? this.prescriberLicenseId,
      prescribingOrganization:
          prescribingOrganization ?? this.prescribingOrganization,
      totalPrice: totalPrice ?? this.totalPrice,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (stockOutId.present) {
      map['stock_out_id'] = Variable<String>(stockOutId.value);
    }
    if (patientName.present) {
      map['patient_name'] = Variable<String>(patientName.value);
    }
    if (destinationClinicService.present) {
      map['destination_clinic_service'] = Variable<String>(
        destinationClinicService.value,
      );
    }
    if (insuranceCardNumber.present) {
      map['insurance_card_number'] = Variable<String>(
        insuranceCardNumber.value,
      );
    }
    if (issuingCompany.present) {
      map['issuing_company'] = Variable<String>(issuingCompany.value);
    }
    if (prescriberName.present) {
      map['prescriber_name'] = Variable<String>(prescriberName.value);
    }
    if (prescriberLicenseId.present) {
      map['prescriber_license_id'] = Variable<String>(
        prescriberLicenseId.value,
      );
    }
    if (prescribingOrganization.present) {
      map['prescribing_organization'] = Variable<String>(
        prescribingOrganization.value,
      );
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockOutSalesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('stockOutId: $stockOutId, ')
          ..write('patientName: $patientName, ')
          ..write('destinationClinicService: $destinationClinicService, ')
          ..write('insuranceCardNumber: $insuranceCardNumber, ')
          ..write('issuingCompany: $issuingCompany, ')
          ..write('prescriberName: $prescriberName, ')
          ..write('prescriberLicenseId: $prescriberLicenseId, ')
          ..write('prescribingOrganization: $prescribingOrganization, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockRequestsTable extends StockRequests
    with TableInfo<$StockRequestsTable, StockRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _requestNumberMeta = const VerificationMeta(
    'requestNumber',
  );
  @override
  late final GeneratedColumn<String> requestNumber = GeneratedColumn<String>(
    'request_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _requestDateMeta = const VerificationMeta(
    'requestDate',
  );
  @override
  late final GeneratedColumn<DateTime> requestDate = GeneratedColumn<DateTime>(
    'request_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _neededByDateMeta = const VerificationMeta(
    'neededByDate',
  );
  @override
  late final GeneratedColumn<DateTime> neededByDate = GeneratedColumn<DateTime>(
    'needed_by_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StockRequestStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<StockRequestStatus>($StockRequestsTable.$converterstatus);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    requestNumber,
    requestDate,
    neededByDate,
    status,
    notes,
    createdAt,
    updatedAt,
    submittedAt,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('request_number')) {
      context.handle(
        _requestNumberMeta,
        requestNumber.isAcceptableOrUnknown(
          data['request_number']!,
          _requestNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestNumberMeta);
    }
    if (data.containsKey('request_date')) {
      context.handle(
        _requestDateMeta,
        requestDate.isAcceptableOrUnknown(
          data['request_date']!,
          _requestDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestDateMeta);
    }
    if (data.containsKey('needed_by_date')) {
      context.handle(
        _neededByDateMeta,
        neededByDate.isAcceptableOrUnknown(
          data['needed_by_date']!,
          _neededByDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      requestNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_number'],
      )!,
      requestDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}request_date'],
      )!,
      neededByDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}needed_by_date'],
      ),
      status: $StockRequestsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      ),
    );
  }

  @override
  $StockRequestsTable createAlias(String alias) {
    return $StockRequestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StockRequestStatus, String, String>
  $converterstatus = const EnumNameConverter<StockRequestStatus>(
    StockRequestStatus.values,
  );
}

class StockRequest extends DataClass implements Insertable<StockRequest> {
  final String id;
  final String userId;
  final String requestNumber;
  final DateTime requestDate;
  final DateTime? neededByDate;
  final StockRequestStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime? receivedAt;
  const StockRequest({
    required this.id,
    required this.userId,
    required this.requestNumber,
    required this.requestDate,
    this.neededByDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['request_number'] = Variable<String>(requestNumber);
    map['request_date'] = Variable<DateTime>(requestDate);
    if (!nullToAbsent || neededByDate != null) {
      map['needed_by_date'] = Variable<DateTime>(neededByDate);
    }
    {
      map['status'] = Variable<String>(
        $StockRequestsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    return map;
  }

  StockRequestsCompanion toCompanion(bool nullToAbsent) {
    return StockRequestsCompanion(
      id: Value(id),
      userId: Value(userId),
      requestNumber: Value(requestNumber),
      requestDate: Value(requestDate),
      neededByDate: neededByDate == null && nullToAbsent
          ? const Value.absent()
          : Value(neededByDate),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
    );
  }

  factory StockRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockRequest(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      requestNumber: serializer.fromJson<String>(json['requestNumber']),
      requestDate: serializer.fromJson<DateTime>(json['requestDate']),
      neededByDate: serializer.fromJson<DateTime?>(json['neededByDate']),
      status: $StockRequestsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'requestNumber': serializer.toJson<String>(requestNumber),
      'requestDate': serializer.toJson<DateTime>(requestDate),
      'neededByDate': serializer.toJson<DateTime?>(neededByDate),
      'status': serializer.toJson<String>(
        $StockRequestsTable.$converterstatus.toJson(status),
      ),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
    };
  }

  StockRequest copyWith({
    String? id,
    String? userId,
    String? requestNumber,
    DateTime? requestDate,
    Value<DateTime?> neededByDate = const Value.absent(),
    StockRequestStatus? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> submittedAt = const Value.absent(),
    Value<DateTime?> receivedAt = const Value.absent(),
  }) => StockRequest(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    requestNumber: requestNumber ?? this.requestNumber,
    requestDate: requestDate ?? this.requestDate,
    neededByDate: neededByDate.present ? neededByDate.value : this.neededByDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
  );
  StockRequest copyWithCompanion(StockRequestsCompanion data) {
    return StockRequest(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      requestNumber: data.requestNumber.present
          ? data.requestNumber.value
          : this.requestNumber,
      requestDate: data.requestDate.present
          ? data.requestDate.value
          : this.requestDate,
      neededByDate: data.neededByDate.present
          ? data.neededByDate.value
          : this.neededByDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockRequest(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('requestNumber: $requestNumber, ')
          ..write('requestDate: $requestDate, ')
          ..write('neededByDate: $neededByDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    requestNumber,
    requestDate,
    neededByDate,
    status,
    notes,
    createdAt,
    updatedAt,
    submittedAt,
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockRequest &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.requestNumber == this.requestNumber &&
          other.requestDate == this.requestDate &&
          other.neededByDate == this.neededByDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.submittedAt == this.submittedAt &&
          other.receivedAt == this.receivedAt);
}

class StockRequestsCompanion extends UpdateCompanion<StockRequest> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> requestNumber;
  final Value<DateTime> requestDate;
  final Value<DateTime?> neededByDate;
  final Value<StockRequestStatus> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> submittedAt;
  final Value<DateTime?> receivedAt;
  final Value<int> rowid;
  const StockRequestsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.requestNumber = const Value.absent(),
    this.requestDate = const Value.absent(),
    this.neededByDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockRequestsCompanion.insert({
    required String id,
    required String userId,
    required String requestNumber,
    required DateTime requestDate,
    this.neededByDate = const Value.absent(),
    required StockRequestStatus status,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       requestNumber = Value(requestNumber),
       requestDate = Value(requestDate),
       status = Value(status);
  static Insertable<StockRequest> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? requestNumber,
    Expression<DateTime>? requestDate,
    Expression<DateTime>? neededByDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? submittedAt,
    Expression<DateTime>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (requestNumber != null) 'request_number': requestNumber,
      if (requestDate != null) 'request_date': requestDate,
      if (neededByDate != null) 'needed_by_date': neededByDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? requestNumber,
    Value<DateTime>? requestDate,
    Value<DateTime?>? neededByDate,
    Value<StockRequestStatus>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? submittedAt,
    Value<DateTime?>? receivedAt,
    Value<int>? rowid,
  }) {
    return StockRequestsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      requestNumber: requestNumber ?? this.requestNumber,
      requestDate: requestDate ?? this.requestDate,
      neededByDate: neededByDate ?? this.neededByDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (requestNumber.present) {
      map['request_number'] = Variable<String>(requestNumber.value);
    }
    if (requestDate.present) {
      map['request_date'] = Variable<DateTime>(requestDate.value);
    }
    if (neededByDate.present) {
      map['needed_by_date'] = Variable<DateTime>(neededByDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $StockRequestsTable.$converterstatus.toSql(status.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockRequestsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('requestNumber: $requestNumber, ')
          ..write('requestDate: $requestDate, ')
          ..write('neededByDate: $neededByDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockRequestItemsTable extends StockRequestItems
    with TableInfo<$StockRequestItemsTable, StockRequestItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockRequestItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stock_requests (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _quantityRequestedMeta = const VerificationMeta(
    'quantityRequested',
  );
  @override
  late final GeneratedColumn<int> quantityRequested = GeneratedColumn<int>(
    'quantity_requested',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    requestId,
    productId,
    quantityRequested,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_request_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockRequestItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity_requested')) {
      context.handle(
        _quantityRequestedMeta,
        quantityRequested.isAcceptableOrUnknown(
          data['quantity_requested']!,
          _quantityRequestedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityRequestedMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockRequestItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockRequestItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantityRequested: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_requested'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $StockRequestItemsTable createAlias(String alias) {
    return $StockRequestItemsTable(attachedDatabase, alias);
  }
}

class StockRequestItem extends DataClass
    implements Insertable<StockRequestItem> {
  final String id;
  final String requestId;
  final String productId;
  final int quantityRequested;
  final String? notes;
  const StockRequestItem({
    required this.id,
    required this.requestId,
    required this.productId,
    required this.quantityRequested,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_id'] = Variable<String>(requestId);
    map['product_id'] = Variable<String>(productId);
    map['quantity_requested'] = Variable<int>(quantityRequested);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  StockRequestItemsCompanion toCompanion(bool nullToAbsent) {
    return StockRequestItemsCompanion(
      id: Value(id),
      requestId: Value(requestId),
      productId: Value(productId),
      quantityRequested: Value(quantityRequested),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory StockRequestItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockRequestItem(
      id: serializer.fromJson<String>(json['id']),
      requestId: serializer.fromJson<String>(json['requestId']),
      productId: serializer.fromJson<String>(json['productId']),
      quantityRequested: serializer.fromJson<int>(json['quantityRequested']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestId': serializer.toJson<String>(requestId),
      'productId': serializer.toJson<String>(productId),
      'quantityRequested': serializer.toJson<int>(quantityRequested),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  StockRequestItem copyWith({
    String? id,
    String? requestId,
    String? productId,
    int? quantityRequested,
    Value<String?> notes = const Value.absent(),
  }) => StockRequestItem(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    productId: productId ?? this.productId,
    quantityRequested: quantityRequested ?? this.quantityRequested,
    notes: notes.present ? notes.value : this.notes,
  );
  StockRequestItem copyWithCompanion(StockRequestItemsCompanion data) {
    return StockRequestItem(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantityRequested: data.quantityRequested.present
          ? data.quantityRequested.value
          : this.quantityRequested,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockRequestItem(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('productId: $productId, ')
          ..write('quantityRequested: $quantityRequested, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, requestId, productId, quantityRequested, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockRequestItem &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.productId == this.productId &&
          other.quantityRequested == this.quantityRequested &&
          other.notes == this.notes);
}

class StockRequestItemsCompanion extends UpdateCompanion<StockRequestItem> {
  final Value<String> id;
  final Value<String> requestId;
  final Value<String> productId;
  final Value<int> quantityRequested;
  final Value<String?> notes;
  final Value<int> rowid;
  const StockRequestItemsCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantityRequested = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockRequestItemsCompanion.insert({
    required String id,
    required String requestId,
    required String productId,
    required int quantityRequested,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       requestId = Value(requestId),
       productId = Value(productId),
       quantityRequested = Value(quantityRequested);
  static Insertable<StockRequestItem> custom({
    Expression<String>? id,
    Expression<String>? requestId,
    Expression<String>? productId,
    Expression<int>? quantityRequested,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (productId != null) 'product_id': productId,
      if (quantityRequested != null) 'quantity_requested': quantityRequested,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockRequestItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? requestId,
    Value<String>? productId,
    Value<int>? quantityRequested,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return StockRequestItemsCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      productId: productId ?? this.productId,
      quantityRequested: quantityRequested ?? this.quantityRequested,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantityRequested.present) {
      map['quantity_requested'] = Variable<int>(quantityRequested.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockRequestItemsCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('productId: $productId, ')
          ..write('quantityRequested: $quantityRequested, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModulesTable extends Modules with TableInfo<$ModulesTable, Module> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _moduleCodeMeta = const VerificationMeta(
    'moduleCode',
  );
  @override
  late final GeneratedColumn<String> moduleCode = GeneratedColumn<String>(
    'module_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provinceMeta = const VerificationMeta(
    'province',
  );
  @override
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
    'province',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivationStatus, String>
  activationStatus = GeneratedColumn<String>(
    'activation_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivationStatus>($ModulesTable.$converteractivationStatus);
  static const VerificationMeta _activationTimeMeta = const VerificationMeta(
    'activationTime',
  );
  @override
  late final GeneratedColumn<DateTime> activationTime =
      GeneratedColumn<DateTime>(
        'activation_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SubscriptionTier?, String>
  subscriptionTier = GeneratedColumn<String>(
    'subscription_tier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<SubscriptionTier?>($ModulesTable.$convertersubscriptionTiern);
  static const VerificationMeta _expirationDateMeta = const VerificationMeta(
    'expirationDate',
  );
  @override
  late final GeneratedColumn<DateTime> expirationDate =
      GeneratedColumn<DateTime>(
        'expiration_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ServiceType?, String>
  serviceType = GeneratedColumn<String>(
    'service_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ServiceType?>($ModulesTable.$converterserviceTypen);
  @override
  late final GeneratedColumnWithTypeConverter<ModuleSubtype?, String> subType =
      GeneratedColumn<String>(
        'sub_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<ModuleSubtype?>($ModulesTable.$convertersubTypen);
  static const VerificationMeta _privateKeyMeta = const VerificationMeta(
    'privateKey',
  );
  @override
  late final GeneratedColumn<String> privateKey = GeneratedColumn<String>(
    'private_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    moduleCode,
    publicKey,
    name,
    phone,
    email,
    country,
    province,
    district,
    sector,
    logoUrl,
    activationStatus,
    activationTime,
    subscriptionTier,
    expirationDate,
    timestamp,
    latitude,
    longitude,
    serviceType,
    subType,
    privateKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Module> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('module_code')) {
      context.handle(
        _moduleCodeMeta,
        moduleCode.isAcceptableOrUnknown(data['module_code']!, _moduleCodeMeta),
      );
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('province')) {
      context.handle(
        _provinceMeta,
        province.isAcceptableOrUnknown(data['province']!, _provinceMeta),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('activation_time')) {
      context.handle(
        _activationTimeMeta,
        activationTime.isAcceptableOrUnknown(
          data['activation_time']!,
          _activationTimeMeta,
        ),
      );
    }
    if (data.containsKey('expiration_date')) {
      context.handle(
        _expirationDateMeta,
        expirationDate.isAcceptableOrUnknown(
          data['expiration_date']!,
          _expirationDateMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('private_key')) {
      context.handle(
        _privateKeyMeta,
        privateKey.isAcceptableOrUnknown(data['private_key']!, _privateKeyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Module map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Module(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      moduleCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_code'],
      ),
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      province: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province'],
      ),
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      ),
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      activationStatus: $ModulesTable.$converteractivationStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activation_status'],
        )!,
      ),
      activationTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}activation_time'],
      ),
      subscriptionTier: $ModulesTable.$convertersubscriptionTiern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subscription_tier'],
        ),
      ),
      expirationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiration_date'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      serviceType: $ModulesTable.$converterserviceTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}service_type'],
        ),
      ),
      subType: $ModulesTable.$convertersubTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sub_type'],
        ),
      ),
      privateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_key'],
      ),
    );
  }

  @override
  $ModulesTable createAlias(String alias) {
    return $ModulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivationStatus, String, String>
  $converteractivationStatus = const EnumNameConverter<ActivationStatus>(
    ActivationStatus.values,
  );
  static JsonTypeConverter2<SubscriptionTier, String, String>
  $convertersubscriptionTier = const EnumNameConverter<SubscriptionTier>(
    SubscriptionTier.values,
  );
  static JsonTypeConverter2<SubscriptionTier?, String?, String?>
  $convertersubscriptionTiern = JsonTypeConverter2.asNullable(
    $convertersubscriptionTier,
  );
  static JsonTypeConverter2<ServiceType, String, String> $converterserviceType =
      const EnumNameConverter<ServiceType>(ServiceType.values);
  static JsonTypeConverter2<ServiceType?, String?, String?>
  $converterserviceTypen = JsonTypeConverter2.asNullable($converterserviceType);
  static JsonTypeConverter2<ModuleSubtype, String, String> $convertersubType =
      const EnumNameConverter<ModuleSubtype>(ModuleSubtype.values);
  static JsonTypeConverter2<ModuleSubtype?, String?, String?>
  $convertersubTypen = JsonTypeConverter2.asNullable($convertersubType);
}

class Module extends DataClass implements Insertable<Module> {
  final int id;
  final String? moduleCode;
  final String? publicKey;
  final String? name;
  final String? phone;
  final String? email;
  final String? country;
  final String? province;
  final String? district;
  final String? sector;
  final String? logoUrl;
  final ActivationStatus activationStatus;
  final DateTime? activationTime;
  final SubscriptionTier? subscriptionTier;
  final DateTime? expirationDate;
  final DateTime? timestamp;
  final double? latitude;
  final double? longitude;
  final ServiceType? serviceType;
  final ModuleSubtype? subType;
  final String? privateKey;
  const Module({
    required this.id,
    this.moduleCode,
    this.publicKey,
    this.name,
    this.phone,
    this.email,
    this.country,
    this.province,
    this.district,
    this.sector,
    this.logoUrl,
    required this.activationStatus,
    this.activationTime,
    this.subscriptionTier,
    this.expirationDate,
    this.timestamp,
    this.latitude,
    this.longitude,
    this.serviceType,
    this.subType,
    this.privateKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || moduleCode != null) {
      map['module_code'] = Variable<String>(moduleCode);
    }
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || province != null) {
      map['province'] = Variable<String>(province);
    }
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || sector != null) {
      map['sector'] = Variable<String>(sector);
    }
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    {
      map['activation_status'] = Variable<String>(
        $ModulesTable.$converteractivationStatus.toSql(activationStatus),
      );
    }
    if (!nullToAbsent || activationTime != null) {
      map['activation_time'] = Variable<DateTime>(activationTime);
    }
    if (!nullToAbsent || subscriptionTier != null) {
      map['subscription_tier'] = Variable<String>(
        $ModulesTable.$convertersubscriptionTiern.toSql(subscriptionTier),
      );
    }
    if (!nullToAbsent || expirationDate != null) {
      map['expiration_date'] = Variable<DateTime>(expirationDate);
    }
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || serviceType != null) {
      map['service_type'] = Variable<String>(
        $ModulesTable.$converterserviceTypen.toSql(serviceType),
      );
    }
    if (!nullToAbsent || subType != null) {
      map['sub_type'] = Variable<String>(
        $ModulesTable.$convertersubTypen.toSql(subType),
      );
    }
    if (!nullToAbsent || privateKey != null) {
      map['private_key'] = Variable<String>(privateKey);
    }
    return map;
  }

  ModulesCompanion toCompanion(bool nullToAbsent) {
    return ModulesCompanion(
      id: Value(id),
      moduleCode: moduleCode == null && nullToAbsent
          ? const Value.absent()
          : Value(moduleCode),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      province: province == null && nullToAbsent
          ? const Value.absent()
          : Value(province),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      sector: sector == null && nullToAbsent
          ? const Value.absent()
          : Value(sector),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      activationStatus: Value(activationStatus),
      activationTime: activationTime == null && nullToAbsent
          ? const Value.absent()
          : Value(activationTime),
      subscriptionTier: subscriptionTier == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionTier),
      expirationDate: expirationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expirationDate),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      serviceType: serviceType == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceType),
      subType: subType == null && nullToAbsent
          ? const Value.absent()
          : Value(subType),
      privateKey: privateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(privateKey),
    );
  }

  factory Module.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Module(
      id: serializer.fromJson<int>(json['id']),
      moduleCode: serializer.fromJson<String?>(json['moduleCode']),
      publicKey: serializer.fromJson<String?>(json['publicKey']),
      name: serializer.fromJson<String?>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      country: serializer.fromJson<String?>(json['country']),
      province: serializer.fromJson<String?>(json['province']),
      district: serializer.fromJson<String?>(json['district']),
      sector: serializer.fromJson<String?>(json['sector']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      activationStatus: $ModulesTable.$converteractivationStatus.fromJson(
        serializer.fromJson<String>(json['activationStatus']),
      ),
      activationTime: serializer.fromJson<DateTime?>(json['activationTime']),
      subscriptionTier: $ModulesTable.$convertersubscriptionTiern.fromJson(
        serializer.fromJson<String?>(json['subscriptionTier']),
      ),
      expirationDate: serializer.fromJson<DateTime?>(json['expirationDate']),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      serviceType: $ModulesTable.$converterserviceTypen.fromJson(
        serializer.fromJson<String?>(json['serviceType']),
      ),
      subType: $ModulesTable.$convertersubTypen.fromJson(
        serializer.fromJson<String?>(json['subType']),
      ),
      privateKey: serializer.fromJson<String?>(json['privateKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moduleCode': serializer.toJson<String?>(moduleCode),
      'publicKey': serializer.toJson<String?>(publicKey),
      'name': serializer.toJson<String?>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'country': serializer.toJson<String?>(country),
      'province': serializer.toJson<String?>(province),
      'district': serializer.toJson<String?>(district),
      'sector': serializer.toJson<String?>(sector),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'activationStatus': serializer.toJson<String>(
        $ModulesTable.$converteractivationStatus.toJson(activationStatus),
      ),
      'activationTime': serializer.toJson<DateTime?>(activationTime),
      'subscriptionTier': serializer.toJson<String?>(
        $ModulesTable.$convertersubscriptionTiern.toJson(subscriptionTier),
      ),
      'expirationDate': serializer.toJson<DateTime?>(expirationDate),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'serviceType': serializer.toJson<String?>(
        $ModulesTable.$converterserviceTypen.toJson(serviceType),
      ),
      'subType': serializer.toJson<String?>(
        $ModulesTable.$convertersubTypen.toJson(subType),
      ),
      'privateKey': serializer.toJson<String?>(privateKey),
    };
  }

  Module copyWith({
    int? id,
    Value<String?> moduleCode = const Value.absent(),
    Value<String?> publicKey = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> province = const Value.absent(),
    Value<String?> district = const Value.absent(),
    Value<String?> sector = const Value.absent(),
    Value<String?> logoUrl = const Value.absent(),
    ActivationStatus? activationStatus,
    Value<DateTime?> activationTime = const Value.absent(),
    Value<SubscriptionTier?> subscriptionTier = const Value.absent(),
    Value<DateTime?> expirationDate = const Value.absent(),
    Value<DateTime?> timestamp = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<ServiceType?> serviceType = const Value.absent(),
    Value<ModuleSubtype?> subType = const Value.absent(),
    Value<String?> privateKey = const Value.absent(),
  }) => Module(
    id: id ?? this.id,
    moduleCode: moduleCode.present ? moduleCode.value : this.moduleCode,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    name: name.present ? name.value : this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    country: country.present ? country.value : this.country,
    province: province.present ? province.value : this.province,
    district: district.present ? district.value : this.district,
    sector: sector.present ? sector.value : this.sector,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    activationStatus: activationStatus ?? this.activationStatus,
    activationTime: activationTime.present
        ? activationTime.value
        : this.activationTime,
    subscriptionTier: subscriptionTier.present
        ? subscriptionTier.value
        : this.subscriptionTier,
    expirationDate: expirationDate.present
        ? expirationDate.value
        : this.expirationDate,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    serviceType: serviceType.present ? serviceType.value : this.serviceType,
    subType: subType.present ? subType.value : this.subType,
    privateKey: privateKey.present ? privateKey.value : this.privateKey,
  );
  Module copyWithCompanion(ModulesCompanion data) {
    return Module(
      id: data.id.present ? data.id.value : this.id,
      moduleCode: data.moduleCode.present
          ? data.moduleCode.value
          : this.moduleCode,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      country: data.country.present ? data.country.value : this.country,
      province: data.province.present ? data.province.value : this.province,
      district: data.district.present ? data.district.value : this.district,
      sector: data.sector.present ? data.sector.value : this.sector,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      activationStatus: data.activationStatus.present
          ? data.activationStatus.value
          : this.activationStatus,
      activationTime: data.activationTime.present
          ? data.activationTime.value
          : this.activationTime,
      subscriptionTier: data.subscriptionTier.present
          ? data.subscriptionTier.value
          : this.subscriptionTier,
      expirationDate: data.expirationDate.present
          ? data.expirationDate.value
          : this.expirationDate,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      serviceType: data.serviceType.present
          ? data.serviceType.value
          : this.serviceType,
      subType: data.subType.present ? data.subType.value : this.subType,
      privateKey: data.privateKey.present
          ? data.privateKey.value
          : this.privateKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Module(')
          ..write('id: $id, ')
          ..write('moduleCode: $moduleCode, ')
          ..write('publicKey: $publicKey, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('country: $country, ')
          ..write('province: $province, ')
          ..write('district: $district, ')
          ..write('sector: $sector, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('activationStatus: $activationStatus, ')
          ..write('activationTime: $activationTime, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('expirationDate: $expirationDate, ')
          ..write('timestamp: $timestamp, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('serviceType: $serviceType, ')
          ..write('subType: $subType, ')
          ..write('privateKey: $privateKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    moduleCode,
    publicKey,
    name,
    phone,
    email,
    country,
    province,
    district,
    sector,
    logoUrl,
    activationStatus,
    activationTime,
    subscriptionTier,
    expirationDate,
    timestamp,
    latitude,
    longitude,
    serviceType,
    subType,
    privateKey,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Module &&
          other.id == this.id &&
          other.moduleCode == this.moduleCode &&
          other.publicKey == this.publicKey &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.country == this.country &&
          other.province == this.province &&
          other.district == this.district &&
          other.sector == this.sector &&
          other.logoUrl == this.logoUrl &&
          other.activationStatus == this.activationStatus &&
          other.activationTime == this.activationTime &&
          other.subscriptionTier == this.subscriptionTier &&
          other.expirationDate == this.expirationDate &&
          other.timestamp == this.timestamp &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.serviceType == this.serviceType &&
          other.subType == this.subType &&
          other.privateKey == this.privateKey);
}

class ModulesCompanion extends UpdateCompanion<Module> {
  final Value<int> id;
  final Value<String?> moduleCode;
  final Value<String?> publicKey;
  final Value<String?> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> country;
  final Value<String?> province;
  final Value<String?> district;
  final Value<String?> sector;
  final Value<String?> logoUrl;
  final Value<ActivationStatus> activationStatus;
  final Value<DateTime?> activationTime;
  final Value<SubscriptionTier?> subscriptionTier;
  final Value<DateTime?> expirationDate;
  final Value<DateTime?> timestamp;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<ServiceType?> serviceType;
  final Value<ModuleSubtype?> subType;
  final Value<String?> privateKey;
  const ModulesCompanion({
    this.id = const Value.absent(),
    this.moduleCode = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.country = const Value.absent(),
    this.province = const Value.absent(),
    this.district = const Value.absent(),
    this.sector = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.activationStatus = const Value.absent(),
    this.activationTime = const Value.absent(),
    this.subscriptionTier = const Value.absent(),
    this.expirationDate = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.subType = const Value.absent(),
    this.privateKey = const Value.absent(),
  });
  ModulesCompanion.insert({
    this.id = const Value.absent(),
    this.moduleCode = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.country = const Value.absent(),
    this.province = const Value.absent(),
    this.district = const Value.absent(),
    this.sector = const Value.absent(),
    this.logoUrl = const Value.absent(),
    required ActivationStatus activationStatus,
    this.activationTime = const Value.absent(),
    this.subscriptionTier = const Value.absent(),
    this.expirationDate = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.subType = const Value.absent(),
    this.privateKey = const Value.absent(),
  }) : activationStatus = Value(activationStatus);
  static Insertable<Module> custom({
    Expression<int>? id,
    Expression<String>? moduleCode,
    Expression<String>? publicKey,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? country,
    Expression<String>? province,
    Expression<String>? district,
    Expression<String>? sector,
    Expression<String>? logoUrl,
    Expression<String>? activationStatus,
    Expression<DateTime>? activationTime,
    Expression<String>? subscriptionTier,
    Expression<DateTime>? expirationDate,
    Expression<DateTime>? timestamp,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? serviceType,
    Expression<String>? subType,
    Expression<String>? privateKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleCode != null) 'module_code': moduleCode,
      if (publicKey != null) 'public_key': publicKey,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (country != null) 'country': country,
      if (province != null) 'province': province,
      if (district != null) 'district': district,
      if (sector != null) 'sector': sector,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (activationStatus != null) 'activation_status': activationStatus,
      if (activationTime != null) 'activation_time': activationTime,
      if (subscriptionTier != null) 'subscription_tier': subscriptionTier,
      if (expirationDate != null) 'expiration_date': expirationDate,
      if (timestamp != null) 'timestamp': timestamp,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (serviceType != null) 'service_type': serviceType,
      if (subType != null) 'sub_type': subType,
      if (privateKey != null) 'private_key': privateKey,
    });
  }

  ModulesCompanion copyWith({
    Value<int>? id,
    Value<String?>? moduleCode,
    Value<String?>? publicKey,
    Value<String?>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? country,
    Value<String?>? province,
    Value<String?>? district,
    Value<String?>? sector,
    Value<String?>? logoUrl,
    Value<ActivationStatus>? activationStatus,
    Value<DateTime?>? activationTime,
    Value<SubscriptionTier?>? subscriptionTier,
    Value<DateTime?>? expirationDate,
    Value<DateTime?>? timestamp,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<ServiceType?>? serviceType,
    Value<ModuleSubtype?>? subType,
    Value<String?>? privateKey,
  }) {
    return ModulesCompanion(
      id: id ?? this.id,
      moduleCode: moduleCode ?? this.moduleCode,
      publicKey: publicKey ?? this.publicKey,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      country: country ?? this.country,
      province: province ?? this.province,
      district: district ?? this.district,
      sector: sector ?? this.sector,
      logoUrl: logoUrl ?? this.logoUrl,
      activationStatus: activationStatus ?? this.activationStatus,
      activationTime: activationTime ?? this.activationTime,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      expirationDate: expirationDate ?? this.expirationDate,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceType: serviceType ?? this.serviceType,
      subType: subType ?? this.subType,
      privateKey: privateKey ?? this.privateKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (moduleCode.present) {
      map['module_code'] = Variable<String>(moduleCode.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (activationStatus.present) {
      map['activation_status'] = Variable<String>(
        $ModulesTable.$converteractivationStatus.toSql(activationStatus.value),
      );
    }
    if (activationTime.present) {
      map['activation_time'] = Variable<DateTime>(activationTime.value);
    }
    if (subscriptionTier.present) {
      map['subscription_tier'] = Variable<String>(
        $ModulesTable.$convertersubscriptionTiern.toSql(subscriptionTier.value),
      );
    }
    if (expirationDate.present) {
      map['expiration_date'] = Variable<DateTime>(expirationDate.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(
        $ModulesTable.$converterserviceTypen.toSql(serviceType.value),
      );
    }
    if (subType.present) {
      map['sub_type'] = Variable<String>(
        $ModulesTable.$convertersubTypen.toSql(subType.value),
      );
    }
    if (privateKey.present) {
      map['private_key'] = Variable<String>(privateKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModulesCompanion(')
          ..write('id: $id, ')
          ..write('moduleCode: $moduleCode, ')
          ..write('publicKey: $publicKey, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('country: $country, ')
          ..write('province: $province, ')
          ..write('district: $district, ')
          ..write('sector: $sector, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('activationStatus: $activationStatus, ')
          ..write('activationTime: $activationTime, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('expirationDate: $expirationDate, ')
          ..write('timestamp: $timestamp, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('serviceType: $serviceType, ')
          ..write('subType: $subType, ')
          ..write('privateKey: $privateKey')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastActionMeta = const VerificationMeta(
    'lastAction',
  );
  @override
  late final GeneratedColumn<String> lastAction = GeneratedColumn<String>(
    'last_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceTypeMeta = const VerificationMeta(
    'deviceType',
  );
  @override
  late final GeneratedColumn<String> deviceType = GeneratedColumn<String>(
    'device_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivationStatus, String>
  activationStatus = GeneratedColumn<String>(
    'activation_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivationStatus>($DevicesTable.$converteractivationStatus);
  static const VerificationMeta _supportMultiUsersMeta = const VerificationMeta(
    'supportMultiUsers',
  );
  @override
  late final GeneratedColumn<bool> supportMultiUsers = GeneratedColumn<bool>(
    'support_multi_users',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("support_multi_users" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    moduleId,
    deviceId,
    deviceName,
    appVersion,
    latitude,
    longitude,
    lastAction,
    deviceType,
    activationStatus,
    supportMultiUsers,
    lastSeenAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('last_action')) {
      context.handle(
        _lastActionMeta,
        lastAction.isAcceptableOrUnknown(data['last_action']!, _lastActionMeta),
      );
    }
    if (data.containsKey('device_type')) {
      context.handle(
        _deviceTypeMeta,
        deviceType.isAcceptableOrUnknown(data['device_type']!, _deviceTypeMeta),
      );
    }
    if (data.containsKey('support_multi_users')) {
      context.handle(
        _supportMultiUsersMeta,
        supportMultiUsers.isAcceptableOrUnknown(
          data['support_multi_users']!,
          _supportMultiUsersMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
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
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      ),
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      lastAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_action'],
      ),
      deviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_type'],
      ),
      activationStatus: $DevicesTable.$converteractivationStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activation_status'],
        )!,
      ),
      supportMultiUsers: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}support_multi_users'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivationStatus, String, String>
  $converteractivationStatus = const EnumNameConverter<ActivationStatus>(
    ActivationStatus.values,
  );
}

class Device extends DataClass implements Insertable<Device> {
  final int id;
  final String? moduleId;
  final String deviceId;
  final String? deviceName;
  final String? appVersion;
  final double? latitude;
  final double? longitude;
  final String? lastAction;
  final String? deviceType;
  final ActivationStatus activationStatus;
  final bool supportMultiUsers;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;
  const Device({
    required this.id,
    this.moduleId,
    required this.deviceId,
    this.deviceName,
    this.appVersion,
    this.latitude,
    this.longitude,
    this.lastAction,
    this.deviceType,
    required this.activationStatus,
    required this.supportMultiUsers,
    this.lastSeenAt,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || moduleId != null) {
      map['module_id'] = Variable<String>(moduleId);
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<String>(appVersion);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || lastAction != null) {
      map['last_action'] = Variable<String>(lastAction);
    }
    if (!nullToAbsent || deviceType != null) {
      map['device_type'] = Variable<String>(deviceType);
    }
    {
      map['activation_status'] = Variable<String>(
        $DevicesTable.$converteractivationStatus.toSql(activationStatus),
      );
    }
    map['support_multi_users'] = Variable<bool>(supportMultiUsers);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      moduleId: moduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(moduleId),
      deviceId: Value(deviceId),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      lastAction: lastAction == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAction),
      deviceType: deviceType == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceType),
      activationStatus: Value(activationStatus),
      supportMultiUsers: Value(supportMultiUsers),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<int>(json['id']),
      moduleId: serializer.fromJson<String?>(json['moduleId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      appVersion: serializer.fromJson<String?>(json['appVersion']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      lastAction: serializer.fromJson<String?>(json['lastAction']),
      deviceType: serializer.fromJson<String?>(json['deviceType']),
      activationStatus: $DevicesTable.$converteractivationStatus.fromJson(
        serializer.fromJson<String>(json['activationStatus']),
      ),
      supportMultiUsers: serializer.fromJson<bool>(json['supportMultiUsers']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moduleId': serializer.toJson<String?>(moduleId),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceName': serializer.toJson<String?>(deviceName),
      'appVersion': serializer.toJson<String?>(appVersion),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'lastAction': serializer.toJson<String?>(lastAction),
      'deviceType': serializer.toJson<String?>(deviceType),
      'activationStatus': serializer.toJson<String>(
        $DevicesTable.$converteractivationStatus.toJson(activationStatus),
      ),
      'supportMultiUsers': serializer.toJson<bool>(supportMultiUsers),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Device copyWith({
    int? id,
    Value<String?> moduleId = const Value.absent(),
    String? deviceId,
    Value<String?> deviceName = const Value.absent(),
    Value<String?> appVersion = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> lastAction = const Value.absent(),
    Value<String?> deviceType = const Value.absent(),
    ActivationStatus? activationStatus,
    bool? supportMultiUsers,
    Value<DateTime?> lastSeenAt = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => Device(
    id: id ?? this.id,
    moduleId: moduleId.present ? moduleId.value : this.moduleId,
    deviceId: deviceId ?? this.deviceId,
    deviceName: deviceName.present ? deviceName.value : this.deviceName,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    lastAction: lastAction.present ? lastAction.value : this.lastAction,
    deviceType: deviceType.present ? deviceType.value : this.deviceType,
    activationStatus: activationStatus ?? this.activationStatus,
    supportMultiUsers: supportMultiUsers ?? this.supportMultiUsers,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      lastAction: data.lastAction.present
          ? data.lastAction.value
          : this.lastAction,
      deviceType: data.deviceType.present
          ? data.deviceType.value
          : this.deviceType,
      activationStatus: data.activationStatus.present
          ? data.activationStatus.value
          : this.activationStatus,
      supportMultiUsers: data.supportMultiUsers.present
          ? data.supportMultiUsers.value
          : this.supportMultiUsers,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('appVersion: $appVersion, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('lastAction: $lastAction, ')
          ..write('deviceType: $deviceType, ')
          ..write('activationStatus: $activationStatus, ')
          ..write('supportMultiUsers: $supportMultiUsers, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    moduleId,
    deviceId,
    deviceName,
    appVersion,
    latitude,
    longitude,
    lastAction,
    deviceType,
    activationStatus,
    supportMultiUsers,
    lastSeenAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.moduleId == this.moduleId &&
          other.deviceId == this.deviceId &&
          other.deviceName == this.deviceName &&
          other.appVersion == this.appVersion &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.lastAction == this.lastAction &&
          other.deviceType == this.deviceType &&
          other.activationStatus == this.activationStatus &&
          other.supportMultiUsers == this.supportMultiUsers &&
          other.lastSeenAt == this.lastSeenAt &&
          other.createdAt == this.createdAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<int> id;
  final Value<String?> moduleId;
  final Value<String> deviceId;
  final Value<String?> deviceName;
  final Value<String?> appVersion;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> lastAction;
  final Value<String?> deviceType;
  final Value<ActivationStatus> activationStatus;
  final Value<bool> supportMultiUsers;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime?> createdAt;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.lastAction = const Value.absent(),
    this.deviceType = const Value.absent(),
    this.activationStatus = const Value.absent(),
    this.supportMultiUsers = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    required String deviceId,
    this.deviceName = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.lastAction = const Value.absent(),
    this.deviceType = const Value.absent(),
    required ActivationStatus activationStatus,
    this.supportMultiUsers = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : deviceId = Value(deviceId),
       activationStatus = Value(activationStatus);
  static Insertable<Device> custom({
    Expression<int>? id,
    Expression<String>? moduleId,
    Expression<String>? deviceId,
    Expression<String>? deviceName,
    Expression<String>? appVersion,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? lastAction,
    Expression<String>? deviceType,
    Expression<String>? activationStatus,
    Expression<bool>? supportMultiUsers,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (appVersion != null) 'app_version': appVersion,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (lastAction != null) 'last_action': lastAction,
      if (deviceType != null) 'device_type': deviceType,
      if (activationStatus != null) 'activation_status': activationStatus,
      if (supportMultiUsers != null) 'support_multi_users': supportMultiUsers,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DevicesCompanion copyWith({
    Value<int>? id,
    Value<String?>? moduleId,
    Value<String>? deviceId,
    Value<String?>? deviceName,
    Value<String?>? appVersion,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? lastAction,
    Value<String?>? deviceType,
    Value<ActivationStatus>? activationStatus,
    Value<bool>? supportMultiUsers,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime?>? createdAt,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      appVersion: appVersion ?? this.appVersion,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastAction: lastAction ?? this.lastAction,
      deviceType: deviceType ?? this.deviceType,
      activationStatus: activationStatus ?? this.activationStatus,
      supportMultiUsers: supportMultiUsers ?? this.supportMultiUsers,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (lastAction.present) {
      map['last_action'] = Variable<String>(lastAction.value);
    }
    if (deviceType.present) {
      map['device_type'] = Variable<String>(deviceType.value);
    }
    if (activationStatus.present) {
      map['activation_status'] = Variable<String>(
        $DevicesTable.$converteractivationStatus.toSql(activationStatus.value),
      );
    }
    if (supportMultiUsers.present) {
      map['support_multi_users'] = Variable<bool>(supportMultiUsers.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('appVersion: $appVersion, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('lastAction: $lastAction, ')
          ..write('deviceType: $deviceType, ')
          ..write('activationStatus: $activationStatus, ')
          ..write('supportMultiUsers: $supportMultiUsers, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InsurancesTable insurances = $InsurancesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductInsurancesTable productInsurances =
      $ProductInsurancesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $StockInsTable stockIns = $StockInsTable(this);
  late final $StockOutsTable stockOuts = $StockOutsTable(this);
  late final $StockOutSalesTable stockOutSales = $StockOutSalesTable(this);
  late final $StockRequestsTable stockRequests = $StockRequestsTable(this);
  late final $StockRequestItemsTable stockRequestItems =
      $StockRequestItemsTable(this);
  late final $ModulesTable modules = $ModulesTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    insurances,
    products,
    productInsurances,
    users,
    stockIns,
    stockOuts,
    stockOutSales,
    stockRequests,
    stockRequestItems,
    modules,
    devices,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'stock_requests',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stock_request_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$InsurancesTableCreateCompanionBuilder =
    InsurancesCompanion Function({
      required String id,
      required String name,
      required String acronym,
      required double clientPercentage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$InsurancesTableUpdateCompanionBuilder =
    InsurancesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> acronym,
      Value<double> clientPercentage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });

final class $$InsurancesTableReferences
    extends BaseReferences<_$AppDatabase, $InsurancesTable, Insurance> {
  $$InsurancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductInsurancesTable, List<ProductInsurance>>
  _productInsurancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productInsurances,
        aliasName: $_aliasNameGenerator(
          db.insurances.id,
          db.productInsurances.insuranceId,
        ),
      );

  $$ProductInsurancesTableProcessedTableManager get productInsurancesRefs {
    final manager = $$ProductInsurancesTableTableManager(
      $_db,
      $_db.productInsurances,
    ).filter((f) => f.insuranceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productInsurancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InsurancesTableFilterComposer
    extends Composer<_$AppDatabase, $InsurancesTable> {
  $$InsurancesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acronym => $composableBuilder(
    column: $table.acronym,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get clientPercentage => $composableBuilder(
    column: $table.clientPercentage,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productInsurancesRefs(
    Expression<bool> Function($$ProductInsurancesTableFilterComposer f) f,
  ) {
    final $$ProductInsurancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productInsurances,
      getReferencedColumn: (t) => t.insuranceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductInsurancesTableFilterComposer(
            $db: $db,
            $table: $db.productInsurances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InsurancesTableOrderingComposer
    extends Composer<_$AppDatabase, $InsurancesTable> {
  $$InsurancesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acronym => $composableBuilder(
    column: $table.acronym,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get clientPercentage => $composableBuilder(
    column: $table.clientPercentage,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InsurancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsurancesTable> {
  $$InsurancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get acronym =>
      $composableBuilder(column: $table.acronym, builder: (column) => column);

  GeneratedColumn<double> get clientPercentage => $composableBuilder(
    column: $table.clientPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  Expression<T> productInsurancesRefs<T extends Object>(
    Expression<T> Function($$ProductInsurancesTableAnnotationComposer a) f,
  ) {
    final $$ProductInsurancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productInsurances,
          getReferencedColumn: (t) => t.insuranceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductInsurancesTableAnnotationComposer(
                $db: $db,
                $table: $db.productInsurances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InsurancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsurancesTable,
          Insurance,
          $$InsurancesTableFilterComposer,
          $$InsurancesTableOrderingComposer,
          $$InsurancesTableAnnotationComposer,
          $$InsurancesTableCreateCompanionBuilder,
          $$InsurancesTableUpdateCompanionBuilder,
          (Insurance, $$InsurancesTableReferences),
          Insurance,
          PrefetchHooks Function({bool productInsurancesRefs})
        > {
  $$InsurancesTableTableManager(_$AppDatabase db, $InsurancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsurancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsurancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsurancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> acronym = const Value.absent(),
                Value<double> clientPercentage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsurancesCompanion(
                id: id,
                name: name,
                acronym: acronym,
                clientPercentage: clientPercentage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String acronym,
                required double clientPercentage,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsurancesCompanion.insert(
                id: id,
                name: name,
                acronym: acronym,
                clientPercentage: clientPercentage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InsurancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productInsurancesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (productInsurancesRefs) db.productInsurances,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productInsurancesRefs)
                    await $_getPrefetchedData<
                      Insurance,
                      $InsurancesTable,
                      ProductInsurance
                    >(
                      currentTable: table,
                      referencedTable: $$InsurancesTableReferences
                          ._productInsurancesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$InsurancesTableReferences(
                            db,
                            table,
                            p0,
                          ).productInsurancesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.insuranceId == item.id,
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

typedef $$InsurancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsurancesTable,
      Insurance,
      $$InsurancesTableFilterComposer,
      $$InsurancesTableOrderingComposer,
      $$InsurancesTableAnnotationComposer,
      $$InsurancesTableCreateCompanionBuilder,
      $$InsurancesTableUpdateCompanionBuilder,
      (Insurance, $$InsurancesTableReferences),
      Insurance,
      PrefetchHooks Function({bool productInsurancesRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String name,
      required ItemType type,
      Value<String?> description,
      Value<String?> sellingUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<ItemType> type,
      Value<String?> description,
      Value<String?> sellingUnit,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductInsurancesTable, List<ProductInsurance>>
  _productInsurancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productInsurances,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.productInsurances.productId,
        ),
      );

  $$ProductInsurancesTableProcessedTableManager get productInsurancesRefs {
    final manager = $$ProductInsurancesTableTableManager(
      $_db,
      $_db.productInsurances,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productInsurancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockInsTable, List<StockIn>> _stockInsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stockIns,
    aliasName: $_aliasNameGenerator(db.products.id, db.stockIns.productId),
  );

  $$StockInsTableProcessedTableManager get stockInsRefs {
    final manager = $$StockInsTableTableManager(
      $_db,
      $_db.stockIns,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockInsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockRequestItemsTable, List<StockRequestItem>>
  _stockRequestItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockRequestItems,
        aliasName: $_aliasNameGenerator(
          db.products.id,
          db.stockRequestItems.productId,
        ),
      );

  $$StockRequestItemsTableProcessedTableManager get stockRequestItemsRefs {
    final manager = $$StockRequestItemsTableTableManager(
      $_db,
      $_db.stockRequestItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockRequestItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ItemType, ItemType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sellingUnit => $composableBuilder(
    column: $table.sellingUnit,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productInsurancesRefs(
    Expression<bool> Function($$ProductInsurancesTableFilterComposer f) f,
  ) {
    final $$ProductInsurancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productInsurances,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductInsurancesTableFilterComposer(
            $db: $db,
            $table: $db.productInsurances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockInsRefs(
    Expression<bool> Function($$StockInsTableFilterComposer f) f,
  ) {
    final $$StockInsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockIns,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockInsTableFilterComposer(
            $db: $db,
            $table: $db.stockIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockRequestItemsRefs(
    Expression<bool> Function($$StockRequestItemsTableFilterComposer f) f,
  ) {
    final $$StockRequestItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockRequestItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockRequestItemsTableFilterComposer(
            $db: $db,
            $table: $db.stockRequestItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sellingUnit => $composableBuilder(
    column: $table.sellingUnit,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sellingUnit => $composableBuilder(
    column: $table.sellingUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  Expression<T> productInsurancesRefs<T extends Object>(
    Expression<T> Function($$ProductInsurancesTableAnnotationComposer a) f,
  ) {
    final $$ProductInsurancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productInsurances,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductInsurancesTableAnnotationComposer(
                $db: $db,
                $table: $db.productInsurances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> stockInsRefs<T extends Object>(
    Expression<T> Function($$StockInsTableAnnotationComposer a) f,
  ) {
    final $$StockInsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockIns,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockInsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockRequestItemsRefs<T extends Object>(
    Expression<T> Function($$StockRequestItemsTableAnnotationComposer a) f,
  ) {
    final $$StockRequestItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockRequestItems,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockRequestItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockRequestItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, $$ProductsTableReferences),
          Product,
          PrefetchHooks Function({
            bool productInsurancesRefs,
            bool stockInsRefs,
            bool stockRequestItemsRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ItemType> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> sellingUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                type: type,
                description: description,
                sellingUnit: sellingUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required ItemType type,
                Value<String?> description = const Value.absent(),
                Value<String?> sellingUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                type: type,
                description: description,
                sellingUnit: sellingUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productInsurancesRefs = false,
                stockInsRefs = false,
                stockRequestItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productInsurancesRefs) db.productInsurances,
                    if (stockInsRefs) db.stockIns,
                    if (stockRequestItemsRefs) db.stockRequestItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productInsurancesRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          ProductInsurance
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productInsurancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productInsurancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockInsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          StockIn
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockInsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockInsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockRequestItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          StockRequestItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockRequestItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockRequestItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
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

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, $$ProductsTableReferences),
      Product,
      PrefetchHooks Function({
        bool productInsurancesRefs,
        bool stockInsRefs,
        bool stockRequestItemsRefs,
      })
    >;
typedef $$ProductInsurancesTableCreateCompanionBuilder =
    ProductInsurancesCompanion Function({
      required String id,
      required String code,
      Value<int?> utilizationCount,
      required Unit unit,
      required double cost,
      required AuthorisedLevel authorisedLevel,
      required MustPrescribedBy mustPrescribedBy,
      required String productId,
      required String insuranceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$ProductInsurancesTableUpdateCompanionBuilder =
    ProductInsurancesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<int?> utilizationCount,
      Value<Unit> unit,
      Value<double> cost,
      Value<AuthorisedLevel> authorisedLevel,
      Value<MustPrescribedBy> mustPrescribedBy,
      Value<String> productId,
      Value<String> insuranceId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<int> rowid,
    });

final class $$ProductInsurancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProductInsurancesTable,
          ProductInsurance
        > {
  $$ProductInsurancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.productInsurances.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InsurancesTable _insuranceIdTable(_$AppDatabase db) =>
      db.insurances.createAlias(
        $_aliasNameGenerator(
          db.productInsurances.insuranceId,
          db.insurances.id,
        ),
      );

  $$InsurancesTableProcessedTableManager get insuranceId {
    final $_column = $_itemColumn<String>('insurance_id')!;

    final manager = $$InsurancesTableTableManager(
      $_db,
      $_db.insurances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_insuranceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductInsurancesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductInsurancesTable> {
  $$ProductInsurancesTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get utilizationCount => $composableBuilder(
    column: $table.utilizationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Unit, Unit, String> get unit =>
      $composableBuilder(
        column: $table.unit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AuthorisedLevel, AuthorisedLevel, String>
  get authorisedLevel => $composableBuilder(
    column: $table.authorisedLevel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MustPrescribedBy, MustPrescribedBy, String>
  get mustPrescribedBy => $composableBuilder(
    column: $table.mustPrescribedBy,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InsurancesTableFilterComposer get insuranceId {
    final $$InsurancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.insuranceId,
      referencedTable: $db.insurances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsurancesTableFilterComposer(
            $db: $db,
            $table: $db.insurances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductInsurancesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductInsurancesTable> {
  $$ProductInsurancesTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get utilizationCount => $composableBuilder(
    column: $table.utilizationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorisedLevel => $composableBuilder(
    column: $table.authorisedLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mustPrescribedBy => $composableBuilder(
    column: $table.mustPrescribedBy,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InsurancesTableOrderingComposer get insuranceId {
    final $$InsurancesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.insuranceId,
      referencedTable: $db.insurances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsurancesTableOrderingComposer(
            $db: $db,
            $table: $db.insurances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductInsurancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductInsurancesTable> {
  $$ProductInsurancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get utilizationCount => $composableBuilder(
    column: $table.utilizationCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Unit, String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AuthorisedLevel, String>
  get authorisedLevel => $composableBuilder(
    column: $table.authorisedLevel,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MustPrescribedBy, String>
  get mustPrescribedBy => $composableBuilder(
    column: $table.mustPrescribedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InsurancesTableAnnotationComposer get insuranceId {
    final $$InsurancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.insuranceId,
      referencedTable: $db.insurances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InsurancesTableAnnotationComposer(
            $db: $db,
            $table: $db.insurances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductInsurancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductInsurancesTable,
          ProductInsurance,
          $$ProductInsurancesTableFilterComposer,
          $$ProductInsurancesTableOrderingComposer,
          $$ProductInsurancesTableAnnotationComposer,
          $$ProductInsurancesTableCreateCompanionBuilder,
          $$ProductInsurancesTableUpdateCompanionBuilder,
          (ProductInsurance, $$ProductInsurancesTableReferences),
          ProductInsurance,
          PrefetchHooks Function({bool productId, bool insuranceId})
        > {
  $$ProductInsurancesTableTableManager(
    _$AppDatabase db,
    $ProductInsurancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductInsurancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductInsurancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductInsurancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int?> utilizationCount = const Value.absent(),
                Value<Unit> unit = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<AuthorisedLevel> authorisedLevel = const Value.absent(),
                Value<MustPrescribedBy> mustPrescribedBy = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> insuranceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductInsurancesCompanion(
                id: id,
                code: code,
                utilizationCount: utilizationCount,
                unit: unit,
                cost: cost,
                authorisedLevel: authorisedLevel,
                mustPrescribedBy: mustPrescribedBy,
                productId: productId,
                insuranceId: insuranceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                Value<int?> utilizationCount = const Value.absent(),
                required Unit unit,
                required double cost,
                required AuthorisedLevel authorisedLevel,
                required MustPrescribedBy mustPrescribedBy,
                required String productId,
                required String insuranceId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductInsurancesCompanion.insert(
                id: id,
                code: code,
                utilizationCount: utilizationCount,
                unit: unit,
                cost: cost,
                authorisedLevel: authorisedLevel,
                mustPrescribedBy: mustPrescribedBy,
                productId: productId,
                insuranceId: insuranceId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductInsurancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false, insuranceId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$ProductInsurancesTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$ProductInsurancesTableReferences
                                        ._productIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (insuranceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.insuranceId,
                                referencedTable:
                                    $$ProductInsurancesTableReferences
                                        ._insuranceIdTable(db),
                                referencedColumn:
                                    $$ProductInsurancesTableReferences
                                        ._insuranceIdTable(db)
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

typedef $$ProductInsurancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductInsurancesTable,
      ProductInsurance,
      $$ProductInsurancesTableFilterComposer,
      $$ProductInsurancesTableOrderingComposer,
      $$ProductInsurancesTableAnnotationComposer,
      $$ProductInsurancesTableCreateCompanionBuilder,
      $$ProductInsurancesTableUpdateCompanionBuilder,
      (ProductInsurance, $$ProductInsurancesTableReferences),
      ProductInsurance,
      PrefetchHooks Function({bool productId, bool insuranceId})
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String names,
      required String phoneNumber,
      Value<String?> email,
      required String password,
      required UserRole role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> names,
      Value<String> phoneNumber,
      Value<String?> email,
      Value<String> password,
      Value<UserRole> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StockInsTable, List<StockIn>> _stockInsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stockIns,
    aliasName: $_aliasNameGenerator(db.users.id, db.stockIns.userId),
  );

  $$StockInsTableProcessedTableManager get stockInsRefs {
    final manager = $$StockInsTableTableManager(
      $_db,
      $_db.stockIns,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockInsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockOutSalesTable, List<StockOutSale>>
  _stockOutSalesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockOutSales,
    aliasName: $_aliasNameGenerator(db.users.id, db.stockOutSales.userId),
  );

  $$StockOutSalesTableProcessedTableManager get stockOutSalesRefs {
    final manager = $$StockOutSalesTableTableManager(
      $_db,
      $_db.stockOutSales,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockOutSalesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockRequestsTable, List<StockRequest>>
  _stockRequestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockRequests,
    aliasName: $_aliasNameGenerator(db.users.id, db.stockRequests.userId),
  );

  $$StockRequestsTableProcessedTableManager get stockRequestsRefs {
    final manager = $$StockRequestsTableTableManager(
      $_db,
      $_db.stockRequests,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockRequestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get names => $composableBuilder(
    column: $table.names,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UserRole, UserRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stockInsRefs(
    Expression<bool> Function($$StockInsTableFilterComposer f) f,
  ) {
    final $$StockInsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockIns,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockInsTableFilterComposer(
            $db: $db,
            $table: $db.stockIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockOutSalesRefs(
    Expression<bool> Function($$StockOutSalesTableFilterComposer f) f,
  ) {
    final $$StockOutSalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockOutSales,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutSalesTableFilterComposer(
            $db: $db,
            $table: $db.stockOutSales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockRequestsRefs(
    Expression<bool> Function($$StockRequestsTableFilterComposer f) f,
  ) {
    final $$StockRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockRequests,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockRequestsTableFilterComposer(
            $db: $db,
            $table: $db.stockRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get names => $composableBuilder(
    column: $table.names,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get names =>
      $composableBuilder(column: $table.names, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UserRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  Expression<T> stockInsRefs<T extends Object>(
    Expression<T> Function($$StockInsTableAnnotationComposer a) f,
  ) {
    final $$StockInsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockIns,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockInsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockOutSalesRefs<T extends Object>(
    Expression<T> Function($$StockOutSalesTableAnnotationComposer a) f,
  ) {
    final $$StockOutSalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockOutSales,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutSalesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockOutSales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockRequestsRefs<T extends Object>(
    Expression<T> Function($$StockRequestsTableAnnotationComposer a) f,
  ) {
    final $$StockRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockRequests,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool stockInsRefs,
            bool stockOutSalesRefs,
            bool stockRequestsRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> names = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<UserRole> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                names: names,
                phoneNumber: phoneNumber,
                email: email,
                password: password,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String names,
                required String phoneNumber,
                Value<String?> email = const Value.absent(),
                required String password,
                required UserRole role,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                names: names,
                phoneNumber: phoneNumber,
                email: email,
                password: password,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stockInsRefs = false,
                stockOutSalesRefs = false,
                stockRequestsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockInsRefs) db.stockIns,
                    if (stockOutSalesRefs) db.stockOutSales,
                    if (stockRequestsRefs) db.stockRequests,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockInsRefs)
                        await $_getPrefetchedData<User, $UsersTable, StockIn>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._stockInsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).stockInsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockOutSalesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          StockOutSale
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._stockOutSalesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).stockOutSalesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockRequestsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          StockRequest
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._stockRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).stockRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
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

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({
        bool stockInsRefs,
        bool stockOutSalesRefs,
        bool stockRequestsRefs,
      })
    >;
typedef $$StockInsTableCreateCompanionBuilder =
    StockInsCompanion Function({
      required String id,
      required int quantity,
      Value<String?> location,
      Value<double?> pricePerUnit,
      Value<String?> batchNumber,
      Value<DateTime?> expiryDate,
      Value<int?> reorderLevel,
      required String productId,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$StockInsTableUpdateCompanionBuilder =
    StockInsCompanion Function({
      Value<String> id,
      Value<int> quantity,
      Value<String?> location,
      Value<double?> pricePerUnit,
      Value<String?> batchNumber,
      Value<DateTime?> expiryDate,
      Value<int?> reorderLevel,
      Value<String> productId,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$StockInsTableReferences
    extends BaseReferences<_$AppDatabase, $StockInsTable, StockIn> {
  $$StockInsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) => db.products
      .createAlias($_aliasNameGenerator(db.stockIns.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.stockIns.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager? get userId {
    final $_column = $_itemColumn<String>('user_id');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockOutsTable, List<StockOut>>
  _stockOutsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockOuts,
    aliasName: $_aliasNameGenerator(db.stockIns.id, db.stockOuts.stockInId),
  );

  $$StockOutsTableProcessedTableManager get stockOutsRefs {
    final manager = $$StockOutsTableTableManager(
      $_db,
      $_db.stockOuts,
    ).filter((f) => f.stockInId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockOutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StockInsTableFilterComposer
    extends Composer<_$AppDatabase, $StockInsTable> {
  $$StockInsTableFilterComposer({
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

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockOutsRefs(
    Expression<bool> Function($$StockOutsTableFilterComposer f) f,
  ) {
    final $$StockOutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockOuts,
      getReferencedColumn: (t) => t.stockInId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutsTableFilterComposer(
            $db: $db,
            $table: $db.stockOuts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockInsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockInsTable> {
  $$StockInsTableOrderingComposer({
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

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockInsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockInsTable> {
  $$StockInsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockOutsRefs<T extends Object>(
    Expression<T> Function($$StockOutsTableAnnotationComposer a) f,
  ) {
    final $$StockOutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockOuts,
      getReferencedColumn: (t) => t.stockInId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockOuts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockInsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockInsTable,
          StockIn,
          $$StockInsTableFilterComposer,
          $$StockInsTableOrderingComposer,
          $$StockInsTableAnnotationComposer,
          $$StockInsTableCreateCompanionBuilder,
          $$StockInsTableUpdateCompanionBuilder,
          (StockIn, $$StockInsTableReferences),
          StockIn,
          PrefetchHooks Function({
            bool productId,
            bool userId,
            bool stockOutsRefs,
          })
        > {
  $$StockInsTableTableManager(_$AppDatabase db, $StockInsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockInsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockInsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockInsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<double?> pricePerUnit = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<int?> reorderLevel = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockInsCompanion(
                id: id,
                quantity: quantity,
                location: location,
                pricePerUnit: pricePerUnit,
                batchNumber: batchNumber,
                expiryDate: expiryDate,
                reorderLevel: reorderLevel,
                productId: productId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int quantity,
                Value<String?> location = const Value.absent(),
                Value<double?> pricePerUnit = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<int?> reorderLevel = const Value.absent(),
                required String productId,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockInsCompanion.insert(
                id: id,
                quantity: quantity,
                location: location,
                pricePerUnit: pricePerUnit,
                batchNumber: batchNumber,
                expiryDate: expiryDate,
                reorderLevel: reorderLevel,
                productId: productId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockInsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({productId = false, userId = false, stockOutsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (stockOutsRefs) db.stockOuts],
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
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable: $$StockInsTableReferences
                                        ._productIdTable(db),
                                    referencedColumn: $$StockInsTableReferences
                                        ._productIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable: $$StockInsTableReferences
                                        ._userIdTable(db),
                                    referencedColumn: $$StockInsTableReferences
                                        ._userIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockOutsRefs)
                        await $_getPrefetchedData<
                          StockIn,
                          $StockInsTable,
                          StockOut
                        >(
                          currentTable: table,
                          referencedTable: $$StockInsTableReferences
                              ._stockOutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StockInsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockOutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stockInId == item.id,
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

typedef $$StockInsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockInsTable,
      StockIn,
      $$StockInsTableFilterComposer,
      $$StockInsTableOrderingComposer,
      $$StockInsTableAnnotationComposer,
      $$StockInsTableCreateCompanionBuilder,
      $$StockInsTableUpdateCompanionBuilder,
      (StockIn, $$StockInsTableReferences),
      StockIn,
      PrefetchHooks Function({bool productId, bool userId, bool stockOutsRefs})
    >;
typedef $$StockOutsTableCreateCompanionBuilder =
    StockOutsCompanion Function({
      required String id,
      required String stockInId,
      required int quantitySold,
      required double pricePerUnit,
      Value<String?> insuranceId,
      required double itemTotal,
      required double patientPays,
      required double insurancePays,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$StockOutsTableUpdateCompanionBuilder =
    StockOutsCompanion Function({
      Value<String> id,
      Value<String> stockInId,
      Value<int> quantitySold,
      Value<double> pricePerUnit,
      Value<String?> insuranceId,
      Value<double> itemTotal,
      Value<double> patientPays,
      Value<double> insurancePays,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$StockOutsTableReferences
    extends BaseReferences<_$AppDatabase, $StockOutsTable, StockOut> {
  $$StockOutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StockInsTable _stockInIdTable(_$AppDatabase db) =>
      db.stockIns.createAlias(
        $_aliasNameGenerator(db.stockOuts.stockInId, db.stockIns.id),
      );

  $$StockInsTableProcessedTableManager get stockInId {
    final $_column = $_itemColumn<String>('stock_in_id')!;

    final manager = $$StockInsTableTableManager(
      $_db,
      $_db.stockIns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stockInIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockOutSalesTable, List<StockOutSale>>
  _stockOutSalesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockOutSales,
    aliasName: $_aliasNameGenerator(
      db.stockOuts.id,
      db.stockOutSales.stockOutId,
    ),
  );

  $$StockOutSalesTableProcessedTableManager get stockOutSalesRefs {
    final manager = $$StockOutSalesTableTableManager(
      $_db,
      $_db.stockOutSales,
    ).filter((f) => f.stockOutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockOutSalesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StockOutsTableFilterComposer
    extends Composer<_$AppDatabase, $StockOutsTable> {
  $$StockOutsTableFilterComposer({
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

  ColumnFilters<int> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insuranceId => $composableBuilder(
    column: $table.insuranceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get itemTotal => $composableBuilder(
    column: $table.itemTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get patientPays => $composableBuilder(
    column: $table.patientPays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get insurancePays => $composableBuilder(
    column: $table.insurancePays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StockInsTableFilterComposer get stockInId {
    final $$StockInsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockInId,
      referencedTable: $db.stockIns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockInsTableFilterComposer(
            $db: $db,
            $table: $db.stockIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockOutSalesRefs(
    Expression<bool> Function($$StockOutSalesTableFilterComposer f) f,
  ) {
    final $$StockOutSalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockOutSales,
      getReferencedColumn: (t) => t.stockOutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutSalesTableFilterComposer(
            $db: $db,
            $table: $db.stockOutSales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockOutsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockOutsTable> {
  $$StockOutsTableOrderingComposer({
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

  ColumnOrderings<int> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insuranceId => $composableBuilder(
    column: $table.insuranceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get itemTotal => $composableBuilder(
    column: $table.itemTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get patientPays => $composableBuilder(
    column: $table.patientPays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get insurancePays => $composableBuilder(
    column: $table.insurancePays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StockInsTableOrderingComposer get stockInId {
    final $$StockInsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockInId,
      referencedTable: $db.stockIns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockInsTableOrderingComposer(
            $db: $db,
            $table: $db.stockIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockOutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockOutsTable> {
  $$StockOutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantitySold => $composableBuilder(
    column: $table.quantitySold,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insuranceId => $composableBuilder(
    column: $table.insuranceId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get itemTotal =>
      $composableBuilder(column: $table.itemTotal, builder: (column) => column);

  GeneratedColumn<double> get patientPays => $composableBuilder(
    column: $table.patientPays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get insurancePays => $composableBuilder(
    column: $table.insurancePays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $$StockInsTableAnnotationComposer get stockInId {
    final $$StockInsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockInId,
      referencedTable: $db.stockIns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockInsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockOutSalesRefs<T extends Object>(
    Expression<T> Function($$StockOutSalesTableAnnotationComposer a) f,
  ) {
    final $$StockOutSalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockOutSales,
      getReferencedColumn: (t) => t.stockOutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutSalesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockOutSales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockOutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockOutsTable,
          StockOut,
          $$StockOutsTableFilterComposer,
          $$StockOutsTableOrderingComposer,
          $$StockOutsTableAnnotationComposer,
          $$StockOutsTableCreateCompanionBuilder,
          $$StockOutsTableUpdateCompanionBuilder,
          (StockOut, $$StockOutsTableReferences),
          StockOut,
          PrefetchHooks Function({bool stockInId, bool stockOutSalesRefs})
        > {
  $$StockOutsTableTableManager(_$AppDatabase db, $StockOutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockOutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockOutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockOutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> stockInId = const Value.absent(),
                Value<int> quantitySold = const Value.absent(),
                Value<double> pricePerUnit = const Value.absent(),
                Value<String?> insuranceId = const Value.absent(),
                Value<double> itemTotal = const Value.absent(),
                Value<double> patientPays = const Value.absent(),
                Value<double> insurancePays = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockOutsCompanion(
                id: id,
                stockInId: stockInId,
                quantitySold: quantitySold,
                pricePerUnit: pricePerUnit,
                insuranceId: insuranceId,
                itemTotal: itemTotal,
                patientPays: patientPays,
                insurancePays: insurancePays,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String stockInId,
                required int quantitySold,
                required double pricePerUnit,
                Value<String?> insuranceId = const Value.absent(),
                required double itemTotal,
                required double patientPays,
                required double insurancePays,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockOutsCompanion.insert(
                id: id,
                stockInId: stockInId,
                quantitySold: quantitySold,
                pricePerUnit: pricePerUnit,
                insuranceId: insuranceId,
                itemTotal: itemTotal,
                patientPays: patientPays,
                insurancePays: insurancePays,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockOutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({stockInId = false, stockOutSalesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockOutSalesRefs) db.stockOutSales,
                  ],
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
                        if (stockInId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stockInId,
                                    referencedTable: $$StockOutsTableReferences
                                        ._stockInIdTable(db),
                                    referencedColumn: $$StockOutsTableReferences
                                        ._stockInIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockOutSalesRefs)
                        await $_getPrefetchedData<
                          StockOut,
                          $StockOutsTable,
                          StockOutSale
                        >(
                          currentTable: table,
                          referencedTable: $$StockOutsTableReferences
                              ._stockOutSalesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StockOutsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockOutSalesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stockOutId == item.id,
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

typedef $$StockOutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockOutsTable,
      StockOut,
      $$StockOutsTableFilterComposer,
      $$StockOutsTableOrderingComposer,
      $$StockOutsTableAnnotationComposer,
      $$StockOutsTableCreateCompanionBuilder,
      $$StockOutsTableUpdateCompanionBuilder,
      (StockOut, $$StockOutsTableReferences),
      StockOut,
      PrefetchHooks Function({bool stockInId, bool stockOutSalesRefs})
    >;
typedef $$StockOutSalesTableCreateCompanionBuilder =
    StockOutSalesCompanion Function({
      required String id,
      required String transactionId,
      required String stockOutId,
      required String patientName,
      Value<String?> destinationClinicService,
      Value<String?> insuranceCardNumber,
      Value<String?> issuingCompany,
      Value<String?> prescriberName,
      Value<String?> prescriberLicenseId,
      Value<String?> prescribingOrganization,
      required double totalPrice,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$StockOutSalesTableUpdateCompanionBuilder =
    StockOutSalesCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> stockOutId,
      Value<String> patientName,
      Value<String?> destinationClinicService,
      Value<String?> insuranceCardNumber,
      Value<String?> issuingCompany,
      Value<String?> prescriberName,
      Value<String?> prescriberLicenseId,
      Value<String?> prescribingOrganization,
      Value<double> totalPrice,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

final class $$StockOutSalesTableReferences
    extends BaseReferences<_$AppDatabase, $StockOutSalesTable, StockOutSale> {
  $$StockOutSalesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StockOutsTable _stockOutIdTable(_$AppDatabase db) =>
      db.stockOuts.createAlias(
        $_aliasNameGenerator(db.stockOutSales.stockOutId, db.stockOuts.id),
      );

  $$StockOutsTableProcessedTableManager get stockOutId {
    final $_column = $_itemColumn<String>('stock_out_id')!;

    final manager = $$StockOutsTableTableManager(
      $_db,
      $_db.stockOuts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stockOutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.stockOutSales.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager? get userId {
    final $_column = $_itemColumn<String>('user_id');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockOutSalesTableFilterComposer
    extends Composer<_$AppDatabase, $StockOutSalesTable> {
  $$StockOutSalesTableFilterComposer({
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

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationClinicService => $composableBuilder(
    column: $table.destinationClinicService,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insuranceCardNumber => $composableBuilder(
    column: $table.insuranceCardNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuingCompany => $composableBuilder(
    column: $table.issuingCompany,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriberName => $composableBuilder(
    column: $table.prescriberName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriberLicenseId => $composableBuilder(
    column: $table.prescriberLicenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescribingOrganization => $composableBuilder(
    column: $table.prescribingOrganization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StockOutsTableFilterComposer get stockOutId {
    final $$StockOutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockOutId,
      referencedTable: $db.stockOuts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutsTableFilterComposer(
            $db: $db,
            $table: $db.stockOuts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockOutSalesTableOrderingComposer
    extends Composer<_$AppDatabase, $StockOutSalesTable> {
  $$StockOutSalesTableOrderingComposer({
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

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationClinicService => $composableBuilder(
    column: $table.destinationClinicService,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insuranceCardNumber => $composableBuilder(
    column: $table.insuranceCardNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuingCompany => $composableBuilder(
    column: $table.issuingCompany,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriberName => $composableBuilder(
    column: $table.prescriberName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriberLicenseId => $composableBuilder(
    column: $table.prescriberLicenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescribingOrganization => $composableBuilder(
    column: $table.prescribingOrganization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StockOutsTableOrderingComposer get stockOutId {
    final $$StockOutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockOutId,
      referencedTable: $db.stockOuts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutsTableOrderingComposer(
            $db: $db,
            $table: $db.stockOuts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockOutSalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockOutSalesTable> {
  $$StockOutSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationClinicService => $composableBuilder(
    column: $table.destinationClinicService,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insuranceCardNumber => $composableBuilder(
    column: $table.insuranceCardNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issuingCompany => $composableBuilder(
    column: $table.issuingCompany,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescriberName => $composableBuilder(
    column: $table.prescriberName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescriberLicenseId => $composableBuilder(
    column: $table.prescriberLicenseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescribingOrganization => $composableBuilder(
    column: $table.prescribingOrganization,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $$StockOutsTableAnnotationComposer get stockOutId {
    final $$StockOutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockOutId,
      referencedTable: $db.stockOuts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockOutsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockOuts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockOutSalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockOutSalesTable,
          StockOutSale,
          $$StockOutSalesTableFilterComposer,
          $$StockOutSalesTableOrderingComposer,
          $$StockOutSalesTableAnnotationComposer,
          $$StockOutSalesTableCreateCompanionBuilder,
          $$StockOutSalesTableUpdateCompanionBuilder,
          (StockOutSale, $$StockOutSalesTableReferences),
          StockOutSale,
          PrefetchHooks Function({bool stockOutId, bool userId})
        > {
  $$StockOutSalesTableTableManager(_$AppDatabase db, $StockOutSalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockOutSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockOutSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockOutSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> stockOutId = const Value.absent(),
                Value<String> patientName = const Value.absent(),
                Value<String?> destinationClinicService = const Value.absent(),
                Value<String?> insuranceCardNumber = const Value.absent(),
                Value<String?> issuingCompany = const Value.absent(),
                Value<String?> prescriberName = const Value.absent(),
                Value<String?> prescriberLicenseId = const Value.absent(),
                Value<String?> prescribingOrganization = const Value.absent(),
                Value<double> totalPrice = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockOutSalesCompanion(
                id: id,
                transactionId: transactionId,
                stockOutId: stockOutId,
                patientName: patientName,
                destinationClinicService: destinationClinicService,
                insuranceCardNumber: insuranceCardNumber,
                issuingCompany: issuingCompany,
                prescriberName: prescriberName,
                prescriberLicenseId: prescriberLicenseId,
                prescribingOrganization: prescribingOrganization,
                totalPrice: totalPrice,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String stockOutId,
                required String patientName,
                Value<String?> destinationClinicService = const Value.absent(),
                Value<String?> insuranceCardNumber = const Value.absent(),
                Value<String?> issuingCompany = const Value.absent(),
                Value<String?> prescriberName = const Value.absent(),
                Value<String?> prescriberLicenseId = const Value.absent(),
                Value<String?> prescribingOrganization = const Value.absent(),
                required double totalPrice,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockOutSalesCompanion.insert(
                id: id,
                transactionId: transactionId,
                stockOutId: stockOutId,
                patientName: patientName,
                destinationClinicService: destinationClinicService,
                insuranceCardNumber: insuranceCardNumber,
                issuingCompany: issuingCompany,
                prescriberName: prescriberName,
                prescriberLicenseId: prescriberLicenseId,
                prescribingOrganization: prescribingOrganization,
                totalPrice: totalPrice,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockOutSalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stockOutId = false, userId = false}) {
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
                    if (stockOutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stockOutId,
                                referencedTable: $$StockOutSalesTableReferences
                                    ._stockOutIdTable(db),
                                referencedColumn: $$StockOutSalesTableReferences
                                    ._stockOutIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$StockOutSalesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$StockOutSalesTableReferences
                                    ._userIdTable(db)
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

typedef $$StockOutSalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockOutSalesTable,
      StockOutSale,
      $$StockOutSalesTableFilterComposer,
      $$StockOutSalesTableOrderingComposer,
      $$StockOutSalesTableAnnotationComposer,
      $$StockOutSalesTableCreateCompanionBuilder,
      $$StockOutSalesTableUpdateCompanionBuilder,
      (StockOutSale, $$StockOutSalesTableReferences),
      StockOutSale,
      PrefetchHooks Function({bool stockOutId, bool userId})
    >;
typedef $$StockRequestsTableCreateCompanionBuilder =
    StockRequestsCompanion Function({
      required String id,
      required String userId,
      required String requestNumber,
      required DateTime requestDate,
      Value<DateTime?> neededByDate,
      required StockRequestStatus status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> submittedAt,
      Value<DateTime?> receivedAt,
      Value<int> rowid,
    });
typedef $$StockRequestsTableUpdateCompanionBuilder =
    StockRequestsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> requestNumber,
      Value<DateTime> requestDate,
      Value<DateTime?> neededByDate,
      Value<StockRequestStatus> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> submittedAt,
      Value<DateTime?> receivedAt,
      Value<int> rowid,
    });

final class $$StockRequestsTableReferences
    extends BaseReferences<_$AppDatabase, $StockRequestsTable, StockRequest> {
  $$StockRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.stockRequests.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockRequestItemsTable, List<StockRequestItem>>
  _stockRequestItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockRequestItems,
        aliasName: $_aliasNameGenerator(
          db.stockRequests.id,
          db.stockRequestItems.requestId,
        ),
      );

  $$StockRequestItemsTableProcessedTableManager get stockRequestItemsRefs {
    final manager = $$StockRequestItemsTableTableManager(
      $_db,
      $_db.stockRequestItems,
    ).filter((f) => f.requestId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockRequestItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StockRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $StockRequestsTable> {
  $$StockRequestsTableFilterComposer({
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

  ColumnFilters<String> get requestNumber => $composableBuilder(
    column: $table.requestNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestDate => $composableBuilder(
    column: $table.requestDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get neededByDate => $composableBuilder(
    column: $table.neededByDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StockRequestStatus, StockRequestStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockRequestItemsRefs(
    Expression<bool> Function($$StockRequestItemsTableFilterComposer f) f,
  ) {
    final $$StockRequestItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockRequestItems,
      getReferencedColumn: (t) => t.requestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockRequestItemsTableFilterComposer(
            $db: $db,
            $table: $db.stockRequestItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockRequestsTable> {
  $$StockRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get requestNumber => $composableBuilder(
    column: $table.requestNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestDate => $composableBuilder(
    column: $table.requestDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get neededByDate => $composableBuilder(
    column: $table.neededByDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockRequestsTable> {
  $$StockRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestNumber => $composableBuilder(
    column: $table.requestNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get requestDate => $composableBuilder(
    column: $table.requestDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get neededByDate => $composableBuilder(
    column: $table.neededByDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<StockRequestStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockRequestItemsRefs<T extends Object>(
    Expression<T> Function($$StockRequestItemsTableAnnotationComposer a) f,
  ) {
    final $$StockRequestItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.stockRequestItems,
          getReferencedColumn: (t) => t.requestId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StockRequestItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.stockRequestItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StockRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockRequestsTable,
          StockRequest,
          $$StockRequestsTableFilterComposer,
          $$StockRequestsTableOrderingComposer,
          $$StockRequestsTableAnnotationComposer,
          $$StockRequestsTableCreateCompanionBuilder,
          $$StockRequestsTableUpdateCompanionBuilder,
          (StockRequest, $$StockRequestsTableReferences),
          StockRequest,
          PrefetchHooks Function({bool userId, bool stockRequestItemsRefs})
        > {
  $$StockRequestsTableTableManager(_$AppDatabase db, $StockRequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> requestNumber = const Value.absent(),
                Value<DateTime> requestDate = const Value.absent(),
                Value<DateTime?> neededByDate = const Value.absent(),
                Value<StockRequestStatus> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockRequestsCompanion(
                id: id,
                userId: userId,
                requestNumber: requestNumber,
                requestDate: requestDate,
                neededByDate: neededByDate,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                submittedAt: submittedAt,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String requestNumber,
                required DateTime requestDate,
                Value<DateTime?> neededByDate = const Value.absent(),
                required StockRequestStatus status,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockRequestsCompanion.insert(
                id: id,
                userId: userId,
                requestNumber: requestNumber,
                requestDate: requestDate,
                neededByDate: neededByDate,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                submittedAt: submittedAt,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userId = false, stockRequestItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockRequestItemsRefs) db.stockRequestItems,
                  ],
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
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$StockRequestsTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$StockRequestsTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockRequestItemsRefs)
                        await $_getPrefetchedData<
                          StockRequest,
                          $StockRequestsTable,
                          StockRequestItem
                        >(
                          currentTable: table,
                          referencedTable: $$StockRequestsTableReferences
                              ._stockRequestItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StockRequestsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockRequestItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.requestId == item.id,
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

typedef $$StockRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockRequestsTable,
      StockRequest,
      $$StockRequestsTableFilterComposer,
      $$StockRequestsTableOrderingComposer,
      $$StockRequestsTableAnnotationComposer,
      $$StockRequestsTableCreateCompanionBuilder,
      $$StockRequestsTableUpdateCompanionBuilder,
      (StockRequest, $$StockRequestsTableReferences),
      StockRequest,
      PrefetchHooks Function({bool userId, bool stockRequestItemsRefs})
    >;
typedef $$StockRequestItemsTableCreateCompanionBuilder =
    StockRequestItemsCompanion Function({
      required String id,
      required String requestId,
      required String productId,
      required int quantityRequested,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$StockRequestItemsTableUpdateCompanionBuilder =
    StockRequestItemsCompanion Function({
      Value<String> id,
      Value<String> requestId,
      Value<String> productId,
      Value<int> quantityRequested,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$StockRequestItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StockRequestItemsTable,
          StockRequestItem
        > {
  $$StockRequestItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StockRequestsTable _requestIdTable(_$AppDatabase db) =>
      db.stockRequests.createAlias(
        $_aliasNameGenerator(
          db.stockRequestItems.requestId,
          db.stockRequests.id,
        ),
      );

  $$StockRequestsTableProcessedTableManager get requestId {
    final $_column = $_itemColumn<String>('request_id')!;

    final manager = $$StockRequestsTableTableManager(
      $_db,
      $_db.stockRequests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_requestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.stockRequestItems.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockRequestItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StockRequestItemsTable> {
  $$StockRequestItemsTableFilterComposer({
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

  ColumnFilters<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$StockRequestsTableFilterComposer get requestId {
    final $$StockRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestId,
      referencedTable: $db.stockRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockRequestsTableFilterComposer(
            $db: $db,
            $table: $db.stockRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockRequestItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockRequestItemsTable> {
  $$StockRequestItemsTableOrderingComposer({
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

  ColumnOrderings<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$StockRequestsTableOrderingComposer get requestId {
    final $$StockRequestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestId,
      referencedTable: $db.stockRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockRequestsTableOrderingComposer(
            $db: $db,
            $table: $db.stockRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockRequestItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockRequestItemsTable> {
  $$StockRequestItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantityRequested => $composableBuilder(
    column: $table.quantityRequested,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$StockRequestsTableAnnotationComposer get requestId {
    final $$StockRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.requestId,
      referencedTable: $db.stockRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockRequestItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockRequestItemsTable,
          StockRequestItem,
          $$StockRequestItemsTableFilterComposer,
          $$StockRequestItemsTableOrderingComposer,
          $$StockRequestItemsTableAnnotationComposer,
          $$StockRequestItemsTableCreateCompanionBuilder,
          $$StockRequestItemsTableUpdateCompanionBuilder,
          (StockRequestItem, $$StockRequestItemsTableReferences),
          StockRequestItem,
          PrefetchHooks Function({bool requestId, bool productId})
        > {
  $$StockRequestItemsTableTableManager(
    _$AppDatabase db,
    $StockRequestItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockRequestItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockRequestItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockRequestItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantityRequested = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockRequestItemsCompanion(
                id: id,
                requestId: requestId,
                productId: productId,
                quantityRequested: quantityRequested,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String requestId,
                required String productId,
                required int quantityRequested,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockRequestItemsCompanion.insert(
                id: id,
                requestId: requestId,
                productId: productId,
                quantityRequested: quantityRequested,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockRequestItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({requestId = false, productId = false}) {
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
                    if (requestId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.requestId,
                                referencedTable:
                                    $$StockRequestItemsTableReferences
                                        ._requestIdTable(db),
                                referencedColumn:
                                    $$StockRequestItemsTableReferences
                                        ._requestIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$StockRequestItemsTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$StockRequestItemsTableReferences
                                        ._productIdTable(db)
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

typedef $$StockRequestItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockRequestItemsTable,
      StockRequestItem,
      $$StockRequestItemsTableFilterComposer,
      $$StockRequestItemsTableOrderingComposer,
      $$StockRequestItemsTableAnnotationComposer,
      $$StockRequestItemsTableCreateCompanionBuilder,
      $$StockRequestItemsTableUpdateCompanionBuilder,
      (StockRequestItem, $$StockRequestItemsTableReferences),
      StockRequestItem,
      PrefetchHooks Function({bool requestId, bool productId})
    >;
typedef $$ModulesTableCreateCompanionBuilder =
    ModulesCompanion Function({
      Value<int> id,
      Value<String?> moduleCode,
      Value<String?> publicKey,
      Value<String?> name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> country,
      Value<String?> province,
      Value<String?> district,
      Value<String?> sector,
      Value<String?> logoUrl,
      required ActivationStatus activationStatus,
      Value<DateTime?> activationTime,
      Value<SubscriptionTier?> subscriptionTier,
      Value<DateTime?> expirationDate,
      Value<DateTime?> timestamp,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<ServiceType?> serviceType,
      Value<ModuleSubtype?> subType,
      Value<String?> privateKey,
    });
typedef $$ModulesTableUpdateCompanionBuilder =
    ModulesCompanion Function({
      Value<int> id,
      Value<String?> moduleCode,
      Value<String?> publicKey,
      Value<String?> name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> country,
      Value<String?> province,
      Value<String?> district,
      Value<String?> sector,
      Value<String?> logoUrl,
      Value<ActivationStatus> activationStatus,
      Value<DateTime?> activationTime,
      Value<SubscriptionTier?> subscriptionTier,
      Value<DateTime?> expirationDate,
      Value<DateTime?> timestamp,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<ServiceType?> serviceType,
      Value<ModuleSubtype?> subType,
      Value<String?> privateKey,
    });

class $$ModulesTableFilterComposer
    extends Composer<_$AppDatabase, $ModulesTable> {
  $$ModulesTableFilterComposer({
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

  ColumnFilters<String> get moduleCode => $composableBuilder(
    column: $table.moduleCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivationStatus, ActivationStatus, String>
  get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get activationTime => $composableBuilder(
    column: $table.activationTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SubscriptionTier?, SubscriptionTier, String>
  get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ServiceType?, ServiceType, String>
  get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ModuleSubtype?, ModuleSubtype, String>
  get subType => $composableBuilder(
    column: $table.subType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ModulesTable> {
  $$ModulesTableOrderingComposer({
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

  ColumnOrderings<String> get moduleCode => $composableBuilder(
    column: $table.moduleCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get activationTime => $composableBuilder(
    column: $table.activationTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subType => $composableBuilder(
    column: $table.subType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModulesTable> {
  $$ModulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get moduleCode => $composableBuilder(
    column: $table.moduleCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivationStatus, String>
  get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get activationTime => $composableBuilder(
    column: $table.activationTime,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SubscriptionTier?, String>
  get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ServiceType?, String> get serviceType =>
      $composableBuilder(
        column: $table.serviceType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ModuleSubtype?, String> get subType =>
      $composableBuilder(column: $table.subType, builder: (column) => column);

  GeneratedColumn<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => column,
  );
}

class $$ModulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModulesTable,
          Module,
          $$ModulesTableFilterComposer,
          $$ModulesTableOrderingComposer,
          $$ModulesTableAnnotationComposer,
          $$ModulesTableCreateCompanionBuilder,
          $$ModulesTableUpdateCompanionBuilder,
          (Module, BaseReferences<_$AppDatabase, $ModulesTable, Module>),
          Module,
          PrefetchHooks Function()
        > {
  $$ModulesTableTableManager(_$AppDatabase db, $ModulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> moduleCode = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> province = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<ActivationStatus> activationStatus = const Value.absent(),
                Value<DateTime?> activationTime = const Value.absent(),
                Value<SubscriptionTier?> subscriptionTier =
                    const Value.absent(),
                Value<DateTime?> expirationDate = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<ServiceType?> serviceType = const Value.absent(),
                Value<ModuleSubtype?> subType = const Value.absent(),
                Value<String?> privateKey = const Value.absent(),
              }) => ModulesCompanion(
                id: id,
                moduleCode: moduleCode,
                publicKey: publicKey,
                name: name,
                phone: phone,
                email: email,
                country: country,
                province: province,
                district: district,
                sector: sector,
                logoUrl: logoUrl,
                activationStatus: activationStatus,
                activationTime: activationTime,
                subscriptionTier: subscriptionTier,
                expirationDate: expirationDate,
                timestamp: timestamp,
                latitude: latitude,
                longitude: longitude,
                serviceType: serviceType,
                subType: subType,
                privateKey: privateKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> moduleCode = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> province = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                required ActivationStatus activationStatus,
                Value<DateTime?> activationTime = const Value.absent(),
                Value<SubscriptionTier?> subscriptionTier =
                    const Value.absent(),
                Value<DateTime?> expirationDate = const Value.absent(),
                Value<DateTime?> timestamp = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<ServiceType?> serviceType = const Value.absent(),
                Value<ModuleSubtype?> subType = const Value.absent(),
                Value<String?> privateKey = const Value.absent(),
              }) => ModulesCompanion.insert(
                id: id,
                moduleCode: moduleCode,
                publicKey: publicKey,
                name: name,
                phone: phone,
                email: email,
                country: country,
                province: province,
                district: district,
                sector: sector,
                logoUrl: logoUrl,
                activationStatus: activationStatus,
                activationTime: activationTime,
                subscriptionTier: subscriptionTier,
                expirationDate: expirationDate,
                timestamp: timestamp,
                latitude: latitude,
                longitude: longitude,
                serviceType: serviceType,
                subType: subType,
                privateKey: privateKey,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModulesTable,
      Module,
      $$ModulesTableFilterComposer,
      $$ModulesTableOrderingComposer,
      $$ModulesTableAnnotationComposer,
      $$ModulesTableCreateCompanionBuilder,
      $$ModulesTableUpdateCompanionBuilder,
      (Module, BaseReferences<_$AppDatabase, $ModulesTable, Module>),
      Module,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      Value<int> id,
      Value<String?> moduleId,
      required String deviceId,
      Value<String?> deviceName,
      Value<String?> appVersion,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> lastAction,
      Value<String?> deviceType,
      required ActivationStatus activationStatus,
      Value<bool> supportMultiUsers,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> createdAt,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<int> id,
      Value<String?> moduleId,
      Value<String> deviceId,
      Value<String?> deviceName,
      Value<String?> appVersion,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> lastAction,
      Value<String?> deviceType,
      Value<ActivationStatus> activationStatus,
      Value<bool> supportMultiUsers,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> createdAt,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
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

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAction => $composableBuilder(
    column: $table.lastAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivationStatus, ActivationStatus, String>
  get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get supportMultiUsers => $composableBuilder(
    column: $table.supportMultiUsers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
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

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAction => $composableBuilder(
    column: $table.lastAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get supportMultiUsers => $composableBuilder(
    column: $table.supportMultiUsers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get lastAction => $composableBuilder(
    column: $table.lastAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ActivationStatus, String>
  get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get supportMultiUsers => $composableBuilder(
    column: $table.supportMultiUsers,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> moduleId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deviceName = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> lastAction = const Value.absent(),
                Value<String?> deviceType = const Value.absent(),
                Value<ActivationStatus> activationStatus = const Value.absent(),
                Value<bool> supportMultiUsers = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                moduleId: moduleId,
                deviceId: deviceId,
                deviceName: deviceName,
                appVersion: appVersion,
                latitude: latitude,
                longitude: longitude,
                lastAction: lastAction,
                deviceType: deviceType,
                activationStatus: activationStatus,
                supportMultiUsers: supportMultiUsers,
                lastSeenAt: lastSeenAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> moduleId = const Value.absent(),
                required String deviceId,
                Value<String?> deviceName = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> lastAction = const Value.absent(),
                Value<String?> deviceType = const Value.absent(),
                required ActivationStatus activationStatus,
                Value<bool> supportMultiUsers = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                moduleId: moduleId,
                deviceId: deviceId,
                deviceName: deviceName,
                appVersion: appVersion,
                latitude: latitude,
                longitude: longitude,
                lastAction: lastAction,
                deviceType: deviceType,
                activationStatus: activationStatus,
                supportMultiUsers: supportMultiUsers,
                lastSeenAt: lastSeenAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InsurancesTableTableManager get insurances =>
      $$InsurancesTableTableManager(_db, _db.insurances);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductInsurancesTableTableManager get productInsurances =>
      $$ProductInsurancesTableTableManager(_db, _db.productInsurances);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$StockInsTableTableManager get stockIns =>
      $$StockInsTableTableManager(_db, _db.stockIns);
  $$StockOutsTableTableManager get stockOuts =>
      $$StockOutsTableTableManager(_db, _db.stockOuts);
  $$StockOutSalesTableTableManager get stockOutSales =>
      $$StockOutSalesTableTableManager(_db, _db.stockOutSales);
  $$StockRequestsTableTableManager get stockRequests =>
      $$StockRequestsTableTableManager(_db, _db.stockRequests);
  $$StockRequestItemsTableTableManager get stockRequestItems =>
      $$StockRequestItemsTableTableManager(_db, _db.stockRequestItems);
  $$ModulesTableTableManager get modules =>
      $$ModulesTableTableManager(_db, _db.modules);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
}
