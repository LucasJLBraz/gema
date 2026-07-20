// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeightEntryCollection on Isar {
  IsarCollection<WeightEntry> get weightEntrys => this.collection();
}

const WeightEntrySchema = CollectionSchema(
  name: r'WeightEntry',
  id: -5509044357954421771,
  properties: {
    r'bodyFatPct': PropertySchema(
      id: 0,
      name: r'bodyFatPct',
      type: IsarType.double,
    ),
    r'measuredOn': PropertySchema(
      id: 1,
      name: r'measuredOn',
      type: IsarType.dateTime,
    ),
    r'note': PropertySchema(id: 2, name: r'note', type: IsarType.string),
    r'weightKg': PropertySchema(
      id: 3,
      name: r'weightKg',
      type: IsarType.double,
    ),
  },
  estimateSize: _weightEntryEstimateSize,
  serialize: _weightEntrySerialize,
  deserialize: _weightEntryDeserialize,
  deserializeProp: _weightEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'measuredOn': IndexSchema(
      id: 5347136873488548279,
      name: r'measuredOn',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'measuredOn',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _weightEntryGetId,
  getLinks: _weightEntryGetLinks,
  attach: _weightEntryAttach,
  version: '3.1.0+1',
);

int _weightEntryEstimateSize(
  WeightEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _weightEntrySerialize(
  WeightEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bodyFatPct);
  writer.writeDateTime(offsets[1], object.measuredOn);
  writer.writeString(offsets[2], object.note);
  writer.writeDouble(offsets[3], object.weightKg);
}

WeightEntry _weightEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeightEntry();
  object.bodyFatPct = reader.readDoubleOrNull(offsets[0]);
  object.id = id;
  object.measuredOn = reader.readDateTime(offsets[1]);
  object.note = reader.readStringOrNull(offsets[2]);
  object.weightKg = reader.readDouble(offsets[3]);
  return object;
}

P _weightEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weightEntryGetId(WeightEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _weightEntryGetLinks(WeightEntry object) {
  return [];
}

void _weightEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  WeightEntry object,
) {
  object.id = id;
}

extension WeightEntryByIndex on IsarCollection<WeightEntry> {
  Future<WeightEntry?> getByMeasuredOn(DateTime measuredOn) {
    return getByIndex(r'measuredOn', [measuredOn]);
  }

  WeightEntry? getByMeasuredOnSync(DateTime measuredOn) {
    return getByIndexSync(r'measuredOn', [measuredOn]);
  }

  Future<bool> deleteByMeasuredOn(DateTime measuredOn) {
    return deleteByIndex(r'measuredOn', [measuredOn]);
  }

  bool deleteByMeasuredOnSync(DateTime measuredOn) {
    return deleteByIndexSync(r'measuredOn', [measuredOn]);
  }

  Future<List<WeightEntry?>> getAllByMeasuredOn(
    List<DateTime> measuredOnValues,
  ) {
    final values = measuredOnValues.map((e) => [e]).toList();
    return getAllByIndex(r'measuredOn', values);
  }

  List<WeightEntry?> getAllByMeasuredOnSync(List<DateTime> measuredOnValues) {
    final values = measuredOnValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'measuredOn', values);
  }

  Future<int> deleteAllByMeasuredOn(List<DateTime> measuredOnValues) {
    final values = measuredOnValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'measuredOn', values);
  }

  int deleteAllByMeasuredOnSync(List<DateTime> measuredOnValues) {
    final values = measuredOnValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'measuredOn', values);
  }

  Future<Id> putByMeasuredOn(WeightEntry object) {
    return putByIndex(r'measuredOn', object);
  }

  Id putByMeasuredOnSync(WeightEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'measuredOn', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMeasuredOn(List<WeightEntry> objects) {
    return putAllByIndex(r'measuredOn', objects);
  }

  List<Id> putAllByMeasuredOnSync(
    List<WeightEntry> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'measuredOn', objects, saveLinks: saveLinks);
  }
}

extension WeightEntryQueryWhereSort
    on QueryBuilder<WeightEntry, WeightEntry, QWhere> {
  QueryBuilder<WeightEntry, WeightEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhere> anyMeasuredOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'measuredOn'),
      );
    });
  }
}

extension WeightEntryQueryWhere
    on QueryBuilder<WeightEntry, WeightEntry, QWhereClause> {
  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause> measuredOnEqualTo(
    DateTime measuredOn,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'measuredOn', value: [measuredOn]),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause>
  measuredOnNotEqualTo(DateTime measuredOn) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'measuredOn',
                lower: [],
                upper: [measuredOn],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'measuredOn',
                lower: [measuredOn],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'measuredOn',
                lower: [measuredOn],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'measuredOn',
                lower: [],
                upper: [measuredOn],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause>
  measuredOnGreaterThan(DateTime measuredOn, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'measuredOn',
          lower: [measuredOn],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause> measuredOnLessThan(
    DateTime measuredOn, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'measuredOn',
          lower: [],
          upper: [measuredOn],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterWhereClause> measuredOnBetween(
    DateTime lowerMeasuredOn,
    DateTime upperMeasuredOn, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'measuredOn',
          lower: [lowerMeasuredOn],
          includeLower: includeLower,
          upper: [upperMeasuredOn],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WeightEntryQueryFilter
    on QueryBuilder<WeightEntry, WeightEntry, QFilterCondition> {
  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  bodyFatPctIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'bodyFatPct'),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  bodyFatPctIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'bodyFatPct'),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  bodyFatPctEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bodyFatPct',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  bodyFatPctGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bodyFatPct',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  bodyFatPctLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bodyFatPct',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  bodyFatPctBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bodyFatPct',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  measuredOnEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'measuredOn', value: value),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  measuredOnGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'measuredOn',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  measuredOnLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'measuredOn',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  measuredOnBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'measuredOn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> weightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightKg',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  weightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightKg',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition>
  weightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightKg',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterFilterCondition> weightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightKg',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension WeightEntryQueryObject
    on QueryBuilder<WeightEntry, WeightEntry, QFilterCondition> {}

extension WeightEntryQueryLinks
    on QueryBuilder<WeightEntry, WeightEntry, QFilterCondition> {}

extension WeightEntryQuerySortBy
    on QueryBuilder<WeightEntry, WeightEntry, QSortBy> {
  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> sortByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> sortByBodyFatPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.desc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> sortByMeasuredOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'measuredOn', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> sortByMeasuredOnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'measuredOn', Sort.desc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension WeightEntryQuerySortThenBy
    on QueryBuilder<WeightEntry, WeightEntry, QSortThenBy> {
  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByBodyFatPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.desc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByMeasuredOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'measuredOn', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByMeasuredOnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'measuredOn', Sort.desc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QAfterSortBy> thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension WeightEntryQueryWhereDistinct
    on QueryBuilder<WeightEntry, WeightEntry, QDistinct> {
  QueryBuilder<WeightEntry, WeightEntry, QDistinct> distinctByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyFatPct');
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QDistinct> distinctByMeasuredOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'measuredOn');
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeightEntry, WeightEntry, QDistinct> distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension WeightEntryQueryProperty
    on QueryBuilder<WeightEntry, WeightEntry, QQueryProperty> {
  QueryBuilder<WeightEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeightEntry, double?, QQueryOperations> bodyFatPctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyFatPct');
    });
  }

  QueryBuilder<WeightEntry, DateTime, QQueryOperations> measuredOnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'measuredOn');
    });
  }

  QueryBuilder<WeightEntry, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<WeightEntry, double, QQueryOperations> weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}
