// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWaterLogCollection on Isar {
  IsarCollection<WaterLog> get waterLogs => this.collection();
}

const WaterLogSchema = CollectionSchema(
  name: r'WaterLog',
  id: -2141755497822994266,
  properties: {
    r'day': PropertySchema(
      id: 0,
      name: r'day',
      type: IsarType.dateTime,
    ),
    r'loggedAt': PropertySchema(
      id: 1,
      name: r'loggedAt',
      type: IsarType.dateTime,
    ),
    r'ml': PropertySchema(
      id: 2,
      name: r'ml',
      type: IsarType.long,
    )
  },
  estimateSize: _waterLogEstimateSize,
  serialize: _waterLogSerialize,
  deserialize: _waterLogDeserialize,
  deserializeProp: _waterLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'day': IndexSchema(
      id: 3809350088207220763,
      name: r'day',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'day',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _waterLogGetId,
  getLinks: _waterLogGetLinks,
  attach: _waterLogAttach,
  version: '3.1.0+1',
);

int _waterLogEstimateSize(
  WaterLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _waterLogSerialize(
  WaterLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.day);
  writer.writeDateTime(offsets[1], object.loggedAt);
  writer.writeLong(offsets[2], object.ml);
}

WaterLog _waterLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WaterLog();
  object.day = reader.readDateTime(offsets[0]);
  object.id = id;
  object.loggedAt = reader.readDateTime(offsets[1]);
  object.ml = reader.readLong(offsets[2]);
  return object;
}

P _waterLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _waterLogGetId(WaterLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _waterLogGetLinks(WaterLog object) {
  return [];
}

void _waterLogAttach(IsarCollection<dynamic> col, Id id, WaterLog object) {
  object.id = id;
}

extension WaterLogQueryWhereSort on QueryBuilder<WaterLog, WaterLog, QWhere> {
  QueryBuilder<WaterLog, WaterLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterWhere> anyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'day'),
      );
    });
  }
}

extension WaterLogQueryWhere on QueryBuilder<WaterLog, WaterLog, QWhereClause> {
  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> dayEqualTo(DateTime day) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'day',
        value: [day],
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> dayNotEqualTo(
      DateTime day) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'day',
              lower: [],
              upper: [day],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'day',
              lower: [day],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'day',
              lower: [day],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'day',
              lower: [],
              upper: [day],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> dayGreaterThan(
    DateTime day, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'day',
        lower: [day],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> dayLessThan(
    DateTime day, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'day',
        lower: [],
        upper: [day],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterWhereClause> dayBetween(
    DateTime lowerDay,
    DateTime upperDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'day',
        lower: [lowerDay],
        includeLower: includeLower,
        upper: [upperDay],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WaterLogQueryFilter
    on QueryBuilder<WaterLog, WaterLog, QFilterCondition> {
  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> dayEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'day',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> dayGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'day',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> dayLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'day',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> dayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'day',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> loggedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loggedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> loggedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loggedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> loggedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loggedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> loggedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loggedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> mlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ml',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> mlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ml',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> mlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ml',
        value: value,
      ));
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterFilterCondition> mlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ml',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WaterLogQueryObject
    on QueryBuilder<WaterLog, WaterLog, QFilterCondition> {}

extension WaterLogQueryLinks
    on QueryBuilder<WaterLog, WaterLog, QFilterCondition> {}

extension WaterLogQuerySortBy on QueryBuilder<WaterLog, WaterLog, QSortBy> {
  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> sortByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.asc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> sortByDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.desc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> sortByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> sortByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> sortByMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ml', Sort.asc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> sortByMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ml', Sort.desc);
    });
  }
}

extension WaterLogQuerySortThenBy
    on QueryBuilder<WaterLog, WaterLog, QSortThenBy> {
  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> thenByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.asc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> thenByDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.desc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> thenByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.asc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> thenByLoggedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loggedAt', Sort.desc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> thenByMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ml', Sort.asc);
    });
  }

  QueryBuilder<WaterLog, WaterLog, QAfterSortBy> thenByMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ml', Sort.desc);
    });
  }
}

extension WaterLogQueryWhereDistinct
    on QueryBuilder<WaterLog, WaterLog, QDistinct> {
  QueryBuilder<WaterLog, WaterLog, QDistinct> distinctByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'day');
    });
  }

  QueryBuilder<WaterLog, WaterLog, QDistinct> distinctByLoggedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loggedAt');
    });
  }

  QueryBuilder<WaterLog, WaterLog, QDistinct> distinctByMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ml');
    });
  }
}

extension WaterLogQueryProperty
    on QueryBuilder<WaterLog, WaterLog, QQueryProperty> {
  QueryBuilder<WaterLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WaterLog, DateTime, QQueryOperations> dayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'day');
    });
  }

  QueryBuilder<WaterLog, DateTime, QQueryOperations> loggedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loggedAt');
    });
  }

  QueryBuilder<WaterLog, int, QQueryOperations> mlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ml');
    });
  }
}
