// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_settings_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSecuritySettingsCollectionCollection on Isar {
  IsarCollection<SecuritySettingsCollection> get securitySettingsCollections =>
      this.collection();
}

const SecuritySettingsCollectionSchema = CollectionSchema(
  name: r'SecuritySettingsCollection',
  id: -6681964424462168260,
  properties: {
    r'autoLockDuration': PropertySchema(
      id: 0,
      name: r'autoLockDuration',
      type: IsarType.long,
    ),
    r'isAppLockEnabled': PropertySchema(
      id: 1,
      name: r'isAppLockEnabled',
      type: IsarType.bool,
    ),
    r'lastUnlockedAt': PropertySchema(
      id: 2,
      name: r'lastUnlockedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _securitySettingsCollectionEstimateSize,
  serialize: _securitySettingsCollectionSerialize,
  deserialize: _securitySettingsCollectionDeserialize,
  deserializeProp: _securitySettingsCollectionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _securitySettingsCollectionGetId,
  getLinks: _securitySettingsCollectionGetLinks,
  attach: _securitySettingsCollectionAttach,
  version: '3.1.0+1',
);

int _securitySettingsCollectionEstimateSize(
  SecuritySettingsCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _securitySettingsCollectionSerialize(
  SecuritySettingsCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.autoLockDuration);
  writer.writeBool(offsets[1], object.isAppLockEnabled);
  writer.writeDateTime(offsets[2], object.lastUnlockedAt);
}

SecuritySettingsCollection _securitySettingsCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SecuritySettingsCollection();
  object.autoLockDuration = reader.readLong(offsets[0]);
  object.id = id;
  object.isAppLockEnabled = reader.readBool(offsets[1]);
  object.lastUnlockedAt = reader.readDateTimeOrNull(offsets[2]);
  return object;
}

P _securitySettingsCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _securitySettingsCollectionGetId(SecuritySettingsCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _securitySettingsCollectionGetLinks(
    SecuritySettingsCollection object) {
  return [];
}

void _securitySettingsCollectionAttach(
    IsarCollection<dynamic> col, Id id, SecuritySettingsCollection object) {
  object.id = id;
}

extension SecuritySettingsCollectionQueryWhereSort on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QWhere> {
  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SecuritySettingsCollectionQueryWhere on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QWhereClause> {
  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SecuritySettingsCollectionQueryFilter on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QFilterCondition> {
  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> autoLockDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoLockDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> autoLockDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoLockDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> autoLockDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoLockDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> autoLockDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoLockDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> isAppLockEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAppLockEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> lastUnlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUnlockedAt',
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> lastUnlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUnlockedAt',
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> lastUnlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUnlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> lastUnlockedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUnlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> lastUnlockedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUnlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterFilterCondition> lastUnlockedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUnlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SecuritySettingsCollectionQueryObject on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QFilterCondition> {}

extension SecuritySettingsCollectionQueryLinks on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QFilterCondition> {}

extension SecuritySettingsCollectionQuerySortBy on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QSortBy> {
  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> sortByAutoLockDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockDuration', Sort.asc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> sortByAutoLockDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockDuration', Sort.desc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> sortByIsAppLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAppLockEnabled', Sort.asc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> sortByIsAppLockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAppLockEnabled', Sort.desc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> sortByLastUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUnlockedAt', Sort.asc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> sortByLastUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUnlockedAt', Sort.desc);
    });
  }
}

extension SecuritySettingsCollectionQuerySortThenBy on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QSortThenBy> {
  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> thenByAutoLockDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockDuration', Sort.asc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> thenByAutoLockDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoLockDuration', Sort.desc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> thenByIsAppLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAppLockEnabled', Sort.asc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> thenByIsAppLockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAppLockEnabled', Sort.desc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> thenByLastUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUnlockedAt', Sort.asc);
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QAfterSortBy> thenByLastUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUnlockedAt', Sort.desc);
    });
  }
}

extension SecuritySettingsCollectionQueryWhereDistinct on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QDistinct> {
  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QDistinct> distinctByAutoLockDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoLockDuration');
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QDistinct> distinctByIsAppLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAppLockEnabled');
    });
  }

  QueryBuilder<SecuritySettingsCollection, SecuritySettingsCollection,
      QDistinct> distinctByLastUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUnlockedAt');
    });
  }
}

extension SecuritySettingsCollectionQueryProperty on QueryBuilder<
    SecuritySettingsCollection, SecuritySettingsCollection, QQueryProperty> {
  QueryBuilder<SecuritySettingsCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SecuritySettingsCollection, int, QQueryOperations>
      autoLockDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoLockDuration');
    });
  }

  QueryBuilder<SecuritySettingsCollection, bool, QQueryOperations>
      isAppLockEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAppLockEnabled');
    });
  }

  QueryBuilder<SecuritySettingsCollection, DateTime?, QQueryOperations>
      lastUnlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUnlockedAt');
    });
  }
}
