// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailySummaryCollection on Isar {
  IsarCollection<DailySummary> get dailySummarys => this.collection();
}

const DailySummarySchema = CollectionSchema(
  name: r'DailySummary',
  id: -8264136505301072183,
  properties: {
    r'day': PropertySchema(
      id: 0,
      name: r'day',
      type: IsarType.dateTime,
    ),
    r'deficit': PropertySchema(
      id: 1,
      name: r'deficit',
      type: IsarType.long,
    ),
    r'isCheat': PropertySchema(
      id: 2,
      name: r'isCheat',
      type: IsarType.bool,
    ),
    r'kcalTarget': PropertySchema(
      id: 3,
      name: r'kcalTarget',
      type: IsarType.long,
    ),
    r'mealsLogged': PropertySchema(
      id: 4,
      name: r'mealsLogged',
      type: IsarType.long,
    ),
    r'totalCarb': PropertySchema(
      id: 5,
      name: r'totalCarb',
      type: IsarType.long,
    ),
    r'totalFat': PropertySchema(
      id: 6,
      name: r'totalFat',
      type: IsarType.long,
    ),
    r'totalKcal': PropertySchema(
      id: 7,
      name: r'totalKcal',
      type: IsarType.long,
    ),
    r'totalProtein': PropertySchema(
      id: 8,
      name: r'totalProtein',
      type: IsarType.long,
    ),
    r'totalWaterMl': PropertySchema(
      id: 9,
      name: r'totalWaterMl',
      type: IsarType.long,
    ),
    r'xpEarned': PropertySchema(
      id: 10,
      name: r'xpEarned',
      type: IsarType.long,
    )
  },
  estimateSize: _dailySummaryEstimateSize,
  serialize: _dailySummarySerialize,
  deserialize: _dailySummaryDeserialize,
  deserializeProp: _dailySummaryDeserializeProp,
  idName: r'id',
  indexes: {
    r'day': IndexSchema(
      id: 3809350088207220763,
      name: r'day',
      unique: true,
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
  getId: _dailySummaryGetId,
  getLinks: _dailySummaryGetLinks,
  attach: _dailySummaryAttach,
  version: '3.1.0+1',
);

int _dailySummaryEstimateSize(
  DailySummary object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dailySummarySerialize(
  DailySummary object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.day);
  writer.writeLong(offsets[1], object.deficit);
  writer.writeBool(offsets[2], object.isCheat);
  writer.writeLong(offsets[3], object.kcalTarget);
  writer.writeLong(offsets[4], object.mealsLogged);
  writer.writeLong(offsets[5], object.totalCarb);
  writer.writeLong(offsets[6], object.totalFat);
  writer.writeLong(offsets[7], object.totalKcal);
  writer.writeLong(offsets[8], object.totalProtein);
  writer.writeLong(offsets[9], object.totalWaterMl);
  writer.writeLong(offsets[10], object.xpEarned);
}

DailySummary _dailySummaryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailySummary();
  object.day = reader.readDateTime(offsets[0]);
  object.deficit = reader.readLong(offsets[1]);
  object.id = id;
  object.isCheat = reader.readBool(offsets[2]);
  object.kcalTarget = reader.readLong(offsets[3]);
  object.mealsLogged = reader.readLong(offsets[4]);
  object.totalCarb = reader.readLong(offsets[5]);
  object.totalFat = reader.readLong(offsets[6]);
  object.totalKcal = reader.readLong(offsets[7]);
  object.totalProtein = reader.readLong(offsets[8]);
  object.totalWaterMl = reader.readLong(offsets[9]);
  object.xpEarned = reader.readLong(offsets[10]);
  return object;
}

P _dailySummaryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailySummaryGetId(DailySummary object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailySummaryGetLinks(DailySummary object) {
  return [];
}

void _dailySummaryAttach(
    IsarCollection<dynamic> col, Id id, DailySummary object) {
  object.id = id;
}

extension DailySummaryByIndex on IsarCollection<DailySummary> {
  Future<DailySummary?> getByDay(DateTime day) {
    return getByIndex(r'day', [day]);
  }

  DailySummary? getByDaySync(DateTime day) {
    return getByIndexSync(r'day', [day]);
  }

  Future<bool> deleteByDay(DateTime day) {
    return deleteByIndex(r'day', [day]);
  }

  bool deleteByDaySync(DateTime day) {
    return deleteByIndexSync(r'day', [day]);
  }

  Future<List<DailySummary?>> getAllByDay(List<DateTime> dayValues) {
    final values = dayValues.map((e) => [e]).toList();
    return getAllByIndex(r'day', values);
  }

  List<DailySummary?> getAllByDaySync(List<DateTime> dayValues) {
    final values = dayValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'day', values);
  }

  Future<int> deleteAllByDay(List<DateTime> dayValues) {
    final values = dayValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'day', values);
  }

  int deleteAllByDaySync(List<DateTime> dayValues) {
    final values = dayValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'day', values);
  }

  Future<Id> putByDay(DailySummary object) {
    return putByIndex(r'day', object);
  }

  Id putByDaySync(DailySummary object, {bool saveLinks = true}) {
    return putByIndexSync(r'day', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDay(List<DailySummary> objects) {
    return putAllByIndex(r'day', objects);
  }

  List<Id> putAllByDaySync(List<DailySummary> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'day', objects, saveLinks: saveLinks);
  }
}

extension DailySummaryQueryWhereSort
    on QueryBuilder<DailySummary, DailySummary, QWhere> {
  QueryBuilder<DailySummary, DailySummary, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterWhere> anyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'day'),
      );
    });
  }
}

extension DailySummaryQueryWhere
    on QueryBuilder<DailySummary, DailySummary, QWhereClause> {
  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> dayEqualTo(
      DateTime day) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'day',
        value: [day],
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> dayNotEqualTo(
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

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> dayGreaterThan(
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

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> dayLessThan(
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

  QueryBuilder<DailySummary, DailySummary, QAfterWhereClause> dayBetween(
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

extension DailySummaryQueryFilter
    on QueryBuilder<DailySummary, DailySummary, QFilterCondition> {
  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition> dayEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'day',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      dayGreaterThan(
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

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition> dayLessThan(
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

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition> dayBetween(
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

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      deficitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deficit',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      deficitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deficit',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      deficitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deficit',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      deficitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deficit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      isCheatEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCheat',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      kcalTargetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kcalTarget',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      kcalTargetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kcalTarget',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      kcalTargetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kcalTarget',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      kcalTargetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kcalTarget',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      mealsLoggedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealsLogged',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      mealsLoggedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealsLogged',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      mealsLoggedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealsLogged',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      mealsLoggedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealsLogged',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalCarbEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCarb',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalCarbGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCarb',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalCarbLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCarb',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalCarbBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCarb',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalFatEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFat',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalFatGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFat',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalFatLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFat',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalFatBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalKcalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalKcal',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalKcalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalKcal',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalKcalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalKcal',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalKcalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalKcal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalProteinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalProtein',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalProteinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalProtein',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalProteinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalProtein',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalProteinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalProtein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalWaterMlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalWaterMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalWaterMlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalWaterMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalWaterMlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalWaterMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      totalWaterMlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalWaterMl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      xpEarnedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xpEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      xpEarnedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xpEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      xpEarnedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xpEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterFilterCondition>
      xpEarnedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xpEarned',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailySummaryQueryObject
    on QueryBuilder<DailySummary, DailySummary, QFilterCondition> {}

extension DailySummaryQueryLinks
    on QueryBuilder<DailySummary, DailySummary, QFilterCondition> {}

extension DailySummaryQuerySortBy
    on QueryBuilder<DailySummary, DailySummary, QSortBy> {
  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByDeficit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deficit', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByDeficitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deficit', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByIsCheat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCheat', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByIsCheatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCheat', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTarget', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy>
      sortByKcalTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTarget', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByMealsLogged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsLogged', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy>
      sortByMealsLoggedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsLogged', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByTotalCarb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarb', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByTotalCarbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarb', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByTotalFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFat', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByTotalFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFat', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByTotalKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalKcal', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByTotalKcalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalKcal', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByTotalProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProtein', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy>
      sortByTotalProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProtein', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByTotalWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWaterMl', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy>
      sortByTotalWaterMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWaterMl', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByXpEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpEarned', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> sortByXpEarnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpEarned', Sort.desc);
    });
  }
}

extension DailySummaryQuerySortThenBy
    on QueryBuilder<DailySummary, DailySummary, QSortThenBy> {
  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByDeficit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deficit', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByDeficitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deficit', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByIsCheat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCheat', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByIsCheatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCheat', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTarget', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy>
      thenByKcalTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTarget', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByMealsLogged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsLogged', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy>
      thenByMealsLoggedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsLogged', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByTotalCarb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarb', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByTotalCarbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarb', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByTotalFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFat', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByTotalFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFat', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByTotalKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalKcal', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByTotalKcalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalKcal', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByTotalProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProtein', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy>
      thenByTotalProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProtein', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByTotalWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWaterMl', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy>
      thenByTotalWaterMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWaterMl', Sort.desc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByXpEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpEarned', Sort.asc);
    });
  }

  QueryBuilder<DailySummary, DailySummary, QAfterSortBy> thenByXpEarnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpEarned', Sort.desc);
    });
  }
}

extension DailySummaryQueryWhereDistinct
    on QueryBuilder<DailySummary, DailySummary, QDistinct> {
  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'day');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByDeficit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deficit');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByIsCheat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCheat');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalTarget');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByMealsLogged() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealsLogged');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByTotalCarb() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCarb');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByTotalFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFat');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByTotalKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalKcal');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByTotalProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalProtein');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByTotalWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalWaterMl');
    });
  }

  QueryBuilder<DailySummary, DailySummary, QDistinct> distinctByXpEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xpEarned');
    });
  }
}

extension DailySummaryQueryProperty
    on QueryBuilder<DailySummary, DailySummary, QQueryProperty> {
  QueryBuilder<DailySummary, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailySummary, DateTime, QQueryOperations> dayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'day');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> deficitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deficit');
    });
  }

  QueryBuilder<DailySummary, bool, QQueryOperations> isCheatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCheat');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> kcalTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalTarget');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> mealsLoggedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealsLogged');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> totalCarbProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCarb');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> totalFatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFat');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> totalKcalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalKcal');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> totalProteinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalProtein');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> totalWaterMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalWaterMl');
    });
  }

  QueryBuilder<DailySummary, int, QQueryOperations> xpEarnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpEarned');
    });
  }
}
