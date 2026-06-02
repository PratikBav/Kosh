// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsCollectionCollection on Isar {
  IsarCollection<AppSettingsCollection> get appSettingsCollections =>
      this.collection();
}

const AppSettingsCollectionSchema = CollectionSchema(
  name: r'AppSettingsCollection',
  id: -1201272823460988305,
  properties: {
    r'appVersion': PropertySchema(
      id: 0,
      name: r'appVersion',
      type: IsarType.string,
    ),
    r'isAchievementSeeded': PropertySchema(
      id: 1,
      name: r'isAchievementSeeded',
      type: IsarType.bool,
    )
  },
  estimateSize: _appSettingsCollectionEstimateSize,
  serialize: _appSettingsCollectionSerialize,
  deserialize: _appSettingsCollectionDeserialize,
  deserializeProp: _appSettingsCollectionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsCollectionGetId,
  getLinks: _appSettingsCollectionGetLinks,
  attach: _appSettingsCollectionAttach,
  version: '3.1.0+1',
);

int _appSettingsCollectionEstimateSize(
  AppSettingsCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appVersion.length * 3;
  return bytesCount;
}

void _appSettingsCollectionSerialize(
  AppSettingsCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appVersion);
  writer.writeBool(offsets[1], object.isAchievementSeeded);
}

AppSettingsCollection _appSettingsCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsCollection();
  object.appVersion = reader.readString(offsets[0]);
  object.id = id;
  object.isAchievementSeeded = reader.readBool(offsets[1]);
  return object;
}

P _appSettingsCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsCollectionGetId(AppSettingsCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsCollectionGetLinks(
    AppSettingsCollection object) {
  return [];
}

void _appSettingsCollectionAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsCollection object) {
  object.id = id;
}

extension AppSettingsCollectionQueryWhereSort
    on QueryBuilder<AppSettingsCollection, AppSettingsCollection, QWhere> {
  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsCollectionQueryWhere on QueryBuilder<AppSettingsCollection,
    AppSettingsCollection, QWhereClause> {
  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterWhereClause>
      idBetween(
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

extension AppSettingsCollectionQueryFilter on QueryBuilder<
    AppSettingsCollection, AppSettingsCollection, QFilterCondition> {
  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> appVersionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> appVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> appVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> appVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> appVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> appVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
          QAfterFilterCondition>
      appVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
          QAfterFilterCondition>
      appVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> appVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> appVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
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

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
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

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
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

  QueryBuilder<AppSettingsCollection, AppSettingsCollection,
      QAfterFilterCondition> isAchievementSeededEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAchievementSeeded',
        value: value,
      ));
    });
  }
}

extension AppSettingsCollectionQueryObject on QueryBuilder<
    AppSettingsCollection, AppSettingsCollection, QFilterCondition> {}

extension AppSettingsCollectionQueryLinks on QueryBuilder<AppSettingsCollection,
    AppSettingsCollection, QFilterCondition> {}

extension AppSettingsCollectionQuerySortBy
    on QueryBuilder<AppSettingsCollection, AppSettingsCollection, QSortBy> {
  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      sortByAppVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      sortByAppVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      sortByIsAchievementSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAchievementSeeded', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      sortByIsAchievementSeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAchievementSeeded', Sort.desc);
    });
  }
}

extension AppSettingsCollectionQuerySortThenBy
    on QueryBuilder<AppSettingsCollection, AppSettingsCollection, QSortThenBy> {
  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      thenByAppVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      thenByAppVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      thenByIsAchievementSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAchievementSeeded', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QAfterSortBy>
      thenByIsAchievementSeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAchievementSeeded', Sort.desc);
    });
  }
}

extension AppSettingsCollectionQueryWhereDistinct
    on QueryBuilder<AppSettingsCollection, AppSettingsCollection, QDistinct> {
  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QDistinct>
      distinctByAppVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appVersion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsCollection, AppSettingsCollection, QDistinct>
      distinctByIsAchievementSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAchievementSeeded');
    });
  }
}

extension AppSettingsCollectionQueryProperty on QueryBuilder<
    AppSettingsCollection, AppSettingsCollection, QQueryProperty> {
  QueryBuilder<AppSettingsCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsCollection, String, QQueryOperations>
      appVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appVersion');
    });
  }

  QueryBuilder<AppSettingsCollection, bool, QQueryOperations>
      isAchievementSeededProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAchievementSeeded');
    });
  }
}
