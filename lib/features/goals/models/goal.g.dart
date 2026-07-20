// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGoalCollection on Isar {
  IsarCollection<Goal> get goals => this.collection();
}

const GoalSchema = CollectionSchema(
  name: r'Goal',
  id: 4693499363663894908,
  properties: {
    r'ageYears': PropertySchema(id: 0, name: r'ageYears', type: IsarType.long),
    r'bmr': PropertySchema(id: 1, name: r'bmr', type: IsarType.double),
    r'bodyFatPct': PropertySchema(
      id: 2,
      name: r'bodyFatPct',
      type: IsarType.double,
    ),
    r'carbTargetG': PropertySchema(
      id: 3,
      name: r'carbTargetG',
      type: IsarType.long,
    ),
    r'effectiveFrom': PropertySchema(
      id: 4,
      name: r'effectiveFrom',
      type: IsarType.dateTime,
    ),
    r'fatTargetG': PropertySchema(
      id: 5,
      name: r'fatTargetG',
      type: IsarType.long,
    ),
    r'goalType': PropertySchema(
      id: 6,
      name: r'goalType',
      type: IsarType.string,
      enumMap: _GoalgoalTypeEnumValueMap,
    ),
    r'heightCm': PropertySchema(
      id: 7,
      name: r'heightCm',
      type: IsarType.double,
    ),
    r'isMale': PropertySchema(id: 8, name: r'isMale', type: IsarType.bool),
    r'kcalTarget': PropertySchema(
      id: 9,
      name: r'kcalTarget',
      type: IsarType.long,
    ),
    r'priorActivityFactor': PropertySchema(
      id: 10,
      name: r'priorActivityFactor',
      type: IsarType.double,
    ),
    r'proteinTargetG': PropertySchema(
      id: 11,
      name: r'proteinTargetG',
      type: IsarType.long,
    ),
    r'targetDate': PropertySchema(
      id: 12,
      name: r'targetDate',
      type: IsarType.dateTime,
    ),
    r'targetWeight': PropertySchema(
      id: 13,
      name: r'targetWeight',
      type: IsarType.double,
    ),
    r'tdee': PropertySchema(id: 14, name: r'tdee', type: IsarType.double),
    r'weightKg': PropertySchema(
      id: 15,
      name: r'weightKg',
      type: IsarType.double,
    ),
  },
  estimateSize: _goalEstimateSize,
  serialize: _goalSerialize,
  deserialize: _goalDeserialize,
  deserializeProp: _goalDeserializeProp,
  idName: r'id',
  indexes: {
    r'effectiveFrom': IndexSchema(
      id: 678731101559454597,
      name: r'effectiveFrom',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'effectiveFrom',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _goalGetId,
  getLinks: _goalGetLinks,
  attach: _goalAttach,
  version: '3.1.0+1',
);

int _goalEstimateSize(
  Goal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.goalType.name.length * 3;
  return bytesCount;
}

void _goalSerialize(
  Goal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.ageYears);
  writer.writeDouble(offsets[1], object.bmr);
  writer.writeDouble(offsets[2], object.bodyFatPct);
  writer.writeLong(offsets[3], object.carbTargetG);
  writer.writeDateTime(offsets[4], object.effectiveFrom);
  writer.writeLong(offsets[5], object.fatTargetG);
  writer.writeString(offsets[6], object.goalType.name);
  writer.writeDouble(offsets[7], object.heightCm);
  writer.writeBool(offsets[8], object.isMale);
  writer.writeLong(offsets[9], object.kcalTarget);
  writer.writeDouble(offsets[10], object.priorActivityFactor);
  writer.writeLong(offsets[11], object.proteinTargetG);
  writer.writeDateTime(offsets[12], object.targetDate);
  writer.writeDouble(offsets[13], object.targetWeight);
  writer.writeDouble(offsets[14], object.tdee);
  writer.writeDouble(offsets[15], object.weightKg);
}

Goal _goalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Goal();
  object.ageYears = reader.readLong(offsets[0]);
  object.bmr = reader.readDouble(offsets[1]);
  object.bodyFatPct = reader.readDoubleOrNull(offsets[2]);
  object.carbTargetG = reader.readLong(offsets[3]);
  object.effectiveFrom = reader.readDateTime(offsets[4]);
  object.fatTargetG = reader.readLong(offsets[5]);
  object.goalType =
      _GoalgoalTypeValueEnumMap[reader.readStringOrNull(offsets[6])] ??
      GoalType.cut;
  object.heightCm = reader.readDouble(offsets[7]);
  object.id = id;
  object.isMale = reader.readBool(offsets[8]);
  object.kcalTarget = reader.readLong(offsets[9]);
  object.priorActivityFactor = reader.readDoubleOrNull(offsets[10]);
  object.proteinTargetG = reader.readLong(offsets[11]);
  object.targetDate = reader.readDateTimeOrNull(offsets[12]);
  object.targetWeight = reader.readDoubleOrNull(offsets[13]);
  object.tdee = reader.readDouble(offsets[14]);
  object.weightKg = reader.readDouble(offsets[15]);
  return object;
}

P _goalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (_GoalgoalTypeValueEnumMap[reader.readStringOrNull(offset)] ??
              GoalType.cut)
          as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _GoalgoalTypeEnumValueMap = {
  r'cut': r'cut',
  r'maintain': r'maintain',
  r'bulk': r'bulk',
};
const _GoalgoalTypeValueEnumMap = {
  r'cut': GoalType.cut,
  r'maintain': GoalType.maintain,
  r'bulk': GoalType.bulk,
};

Id _goalGetId(Goal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _goalGetLinks(Goal object) {
  return [];
}

void _goalAttach(IsarCollection<dynamic> col, Id id, Goal object) {
  object.id = id;
}

extension GoalQueryWhereSort on QueryBuilder<Goal, Goal, QWhere> {
  QueryBuilder<Goal, Goal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Goal, Goal, QAfterWhere> anyEffectiveFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'effectiveFrom'),
      );
    });
  }
}

extension GoalQueryWhere on QueryBuilder<Goal, Goal, QWhereClause> {
  QueryBuilder<Goal, Goal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Goal, Goal, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Goal, Goal, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterWhereClause> idBetween(
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

  QueryBuilder<Goal, Goal, QAfterWhereClause> effectiveFromEqualTo(
    DateTime effectiveFrom,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'effectiveFrom',
          value: [effectiveFrom],
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterWhereClause> effectiveFromNotEqualTo(
    DateTime effectiveFrom,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'effectiveFrom',
                lower: [],
                upper: [effectiveFrom],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'effectiveFrom',
                lower: [effectiveFrom],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'effectiveFrom',
                lower: [effectiveFrom],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'effectiveFrom',
                lower: [],
                upper: [effectiveFrom],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Goal, Goal, QAfterWhereClause> effectiveFromGreaterThan(
    DateTime effectiveFrom, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'effectiveFrom',
          lower: [effectiveFrom],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterWhereClause> effectiveFromLessThan(
    DateTime effectiveFrom, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'effectiveFrom',
          lower: [],
          upper: [effectiveFrom],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterWhereClause> effectiveFromBetween(
    DateTime lowerEffectiveFrom,
    DateTime upperEffectiveFrom, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'effectiveFrom',
          lower: [lowerEffectiveFrom],
          includeLower: includeLower,
          upper: [upperEffectiveFrom],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension GoalQueryFilter on QueryBuilder<Goal, Goal, QFilterCondition> {
  QueryBuilder<Goal, Goal, QAfterFilterCondition> ageYearsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ageYears', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> ageYearsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ageYears',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> ageYearsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ageYears',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> ageYearsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ageYears',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bmrEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bmr',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bmrGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bmr',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bmrLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bmr',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bmrBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bmr',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bodyFatPctIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'bodyFatPct'),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bodyFatPctIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'bodyFatPct'),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bodyFatPctEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bodyFatPctGreaterThan(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bodyFatPctLessThan(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> bodyFatPctBetween(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> carbTargetGEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'carbTargetG', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> carbTargetGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'carbTargetG',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> carbTargetGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'carbTargetG',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> carbTargetGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'carbTargetG',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> effectiveFromEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'effectiveFrom', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> effectiveFromGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'effectiveFrom',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> effectiveFromLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'effectiveFrom',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> effectiveFromBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'effectiveFrom',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> fatTargetGEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fatTargetG', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> fatTargetGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fatTargetG',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> fatTargetGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fatTargetG',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> fatTargetGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fatTargetG',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeEqualTo(
    GoalType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'goalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeGreaterThan(
    GoalType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'goalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeLessThan(
    GoalType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'goalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeBetween(
    GoalType lower,
    GoalType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'goalType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'goalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'goalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'goalType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'goalType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'goalType', value: ''),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> goalTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'goalType', value: ''),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> heightCmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'heightCm',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> heightCmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'heightCm',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> heightCmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'heightCm',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> heightCmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'heightCm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> isMaleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isMale', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> kcalTargetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kcalTarget', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> kcalTargetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kcalTarget',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> kcalTargetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kcalTarget',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> kcalTargetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kcalTarget',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> priorActivityFactorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'priorActivityFactor'),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition>
  priorActivityFactorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'priorActivityFactor'),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> priorActivityFactorEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'priorActivityFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition>
  priorActivityFactorGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'priorActivityFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> priorActivityFactorLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'priorActivityFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> priorActivityFactorBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'priorActivityFactor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> proteinTargetGEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'proteinTargetG', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> proteinTargetGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'proteinTargetG',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> proteinTargetGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'proteinTargetG',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> proteinTargetGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'proteinTargetG',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'targetDate'),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'targetDate'),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'targetDate', value: value),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetWeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'targetWeight'),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetWeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'targetWeight'),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetWeightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'targetWeight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetWeightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetWeight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetWeightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetWeight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> targetWeightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetWeight',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> tdeeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tdee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> tdeeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tdee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> tdeeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tdee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> tdeeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tdee',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Goal, Goal, QAfterFilterCondition> weightKgEqualTo(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> weightKgGreaterThan(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> weightKgLessThan(
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

  QueryBuilder<Goal, Goal, QAfterFilterCondition> weightKgBetween(
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

extension GoalQueryObject on QueryBuilder<Goal, Goal, QFilterCondition> {}

extension GoalQueryLinks on QueryBuilder<Goal, Goal, QFilterCondition> {}

extension GoalQuerySortBy on QueryBuilder<Goal, Goal, QSortBy> {
  QueryBuilder<Goal, Goal, QAfterSortBy> sortByAgeYears() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageYears', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByAgeYearsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageYears', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByBmr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmr', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByBmrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmr', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByBodyFatPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByCarbTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbTargetG', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByCarbTargetGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbTargetG', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByEffectiveFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveFrom', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByEffectiveFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveFrom', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByFatTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatTargetG', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByFatTargetGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatTargetG', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByGoalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalType', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByGoalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalType', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByIsMale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMale', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByIsMaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMale', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTarget', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByKcalTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTarget', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByPriorActivityFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priorActivityFactor', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByPriorActivityFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priorActivityFactor', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByProteinTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinTargetG', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByProteinTargetGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinTargetG', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByTargetWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdee', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByTdeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdee', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension GoalQuerySortThenBy on QueryBuilder<Goal, Goal, QSortThenBy> {
  QueryBuilder<Goal, Goal, QAfterSortBy> thenByAgeYears() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageYears', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByAgeYearsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageYears', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByBmr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmr', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByBmrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bmr', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByBodyFatPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByCarbTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbTargetG', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByCarbTargetGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbTargetG', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByEffectiveFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveFrom', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByEffectiveFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveFrom', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByFatTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatTargetG', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByFatTargetGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatTargetG', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByGoalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalType', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByGoalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalType', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByIsMale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMale', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByIsMaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMale', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTarget', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByKcalTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTarget', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByPriorActivityFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priorActivityFactor', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByPriorActivityFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priorActivityFactor', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByProteinTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinTargetG', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByProteinTargetGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinTargetG', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByTargetWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdee', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByTdeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdee', Sort.desc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<Goal, Goal, QAfterSortBy> thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension GoalQueryWhereDistinct on QueryBuilder<Goal, Goal, QDistinct> {
  QueryBuilder<Goal, Goal, QDistinct> distinctByAgeYears() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ageYears');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByBmr() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bmr');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyFatPct');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByCarbTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbTargetG');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByEffectiveFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveFrom');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByFatTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatTargetG');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByGoalType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heightCm');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByIsMale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMale');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByKcalTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalTarget');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByPriorActivityFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priorActivityFactor');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByProteinTargetG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinTargetG');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDate');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetWeight');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tdee');
    });
  }

  QueryBuilder<Goal, Goal, QDistinct> distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension GoalQueryProperty on QueryBuilder<Goal, Goal, QQueryProperty> {
  QueryBuilder<Goal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Goal, int, QQueryOperations> ageYearsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ageYears');
    });
  }

  QueryBuilder<Goal, double, QQueryOperations> bmrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bmr');
    });
  }

  QueryBuilder<Goal, double?, QQueryOperations> bodyFatPctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyFatPct');
    });
  }

  QueryBuilder<Goal, int, QQueryOperations> carbTargetGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbTargetG');
    });
  }

  QueryBuilder<Goal, DateTime, QQueryOperations> effectiveFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveFrom');
    });
  }

  QueryBuilder<Goal, int, QQueryOperations> fatTargetGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatTargetG');
    });
  }

  QueryBuilder<Goal, GoalType, QQueryOperations> goalTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalType');
    });
  }

  QueryBuilder<Goal, double, QQueryOperations> heightCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heightCm');
    });
  }

  QueryBuilder<Goal, bool, QQueryOperations> isMaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMale');
    });
  }

  QueryBuilder<Goal, int, QQueryOperations> kcalTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalTarget');
    });
  }

  QueryBuilder<Goal, double?, QQueryOperations> priorActivityFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priorActivityFactor');
    });
  }

  QueryBuilder<Goal, int, QQueryOperations> proteinTargetGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinTargetG');
    });
  }

  QueryBuilder<Goal, DateTime?, QQueryOperations> targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDate');
    });
  }

  QueryBuilder<Goal, double?, QQueryOperations> targetWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetWeight');
    });
  }

  QueryBuilder<Goal, double, QQueryOperations> tdeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tdee');
    });
  }

  QueryBuilder<Goal, double, QQueryOperations> weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}
