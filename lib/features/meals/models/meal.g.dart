// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMealCollection on Isar {
  IsarCollection<Meal> get meals => this.collection();
}

const MealSchema = CollectionSchema(
  name: r'Meal',
  id: 2462895270179255875,
  properties: {
    r'aiConfidence': PropertySchema(
      id: 0,
      name: r'aiConfidence',
      type: IsarType.string,
    ),
    r'aiEmoji': PropertySchema(
      id: 1,
      name: r'aiEmoji',
      type: IsarType.string,
    ),
    r'aiRawJson': PropertySchema(
      id: 2,
      name: r'aiRawJson',
      type: IsarType.string,
    ),
    r'capturedAt': PropertySchema(
      id: 3,
      name: r'capturedAt',
      type: IsarType.dateTime,
    ),
    r'carbMax': PropertySchema(
      id: 4,
      name: r'carbMax',
      type: IsarType.long,
    ),
    r'carbMin': PropertySchema(
      id: 5,
      name: r'carbMin',
      type: IsarType.long,
    ),
    r'carbPoint': PropertySchema(
      id: 6,
      name: r'carbPoint',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 7,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fatMax': PropertySchema(
      id: 8,
      name: r'fatMax',
      type: IsarType.long,
    ),
    r'fatMin': PropertySchema(
      id: 9,
      name: r'fatMin',
      type: IsarType.long,
    ),
    r'fatPoint': PropertySchema(
      id: 10,
      name: r'fatPoint',
      type: IsarType.long,
    ),
    r'kcalMax': PropertySchema(
      id: 11,
      name: r'kcalMax',
      type: IsarType.long,
    ),
    r'kcalMin': PropertySchema(
      id: 12,
      name: r'kcalMin',
      type: IsarType.long,
    ),
    r'kcalPoint': PropertySchema(
      id: 13,
      name: r'kcalPoint',
      type: IsarType.long,
    ),
    r'photoDeletedAt': PropertySchema(
      id: 14,
      name: r'photoDeletedAt',
      type: IsarType.dateTime,
    ),
    r'photoPath': PropertySchema(
      id: 15,
      name: r'photoPath',
      type: IsarType.string,
    ),
    r'proteinMax': PropertySchema(
      id: 16,
      name: r'proteinMax',
      type: IsarType.long,
    ),
    r'proteinMin': PropertySchema(
      id: 17,
      name: r'proteinMin',
      type: IsarType.long,
    ),
    r'proteinPoint': PropertySchema(
      id: 18,
      name: r'proteinPoint',
      type: IsarType.long,
    ),
    r'retryCount': PropertySchema(
      id: 19,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'source': PropertySchema(
      id: 20,
      name: r'source',
      type: IsarType.string,
      enumMap: _MealsourceEnumValueMap,
    ),
    r'status': PropertySchema(
      id: 21,
      name: r'status',
      type: IsarType.string,
      enumMap: _MealstatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 22,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userEditedKcal': PropertySchema(
      id: 23,
      name: r'userEditedKcal',
      type: IsarType.bool,
    ),
    r'userNote': PropertySchema(
      id: 24,
      name: r'userNote',
      type: IsarType.string,
    )
  },
  estimateSize: _mealEstimateSize,
  serialize: _mealSerialize,
  deserialize: _mealDeserialize,
  deserializeProp: _mealDeserializeProp,
  idName: r'id',
  indexes: {
    r'capturedAt': IndexSchema(
      id: 7947551681198035194,
      name: r'capturedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'capturedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'components': LinkSchema(
      id: -1275824676251164871,
      name: r'components',
      target: r'MealComponent',
      single: false,
      linkName: r'meal',
    )
  },
  embeddedSchemas: {},
  getId: _mealGetId,
  getLinks: _mealGetLinks,
  attach: _mealAttach,
  version: '3.1.0+1',
);

int _mealEstimateSize(
  Meal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiConfidence;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aiEmoji;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aiRawJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.photoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.source.name.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.userNote.length * 3;
  return bytesCount;
}

void _mealSerialize(
  Meal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiConfidence);
  writer.writeString(offsets[1], object.aiEmoji);
  writer.writeString(offsets[2], object.aiRawJson);
  writer.writeDateTime(offsets[3], object.capturedAt);
  writer.writeLong(offsets[4], object.carbMax);
  writer.writeLong(offsets[5], object.carbMin);
  writer.writeLong(offsets[6], object.carbPoint);
  writer.writeDateTime(offsets[7], object.createdAt);
  writer.writeLong(offsets[8], object.fatMax);
  writer.writeLong(offsets[9], object.fatMin);
  writer.writeLong(offsets[10], object.fatPoint);
  writer.writeLong(offsets[11], object.kcalMax);
  writer.writeLong(offsets[12], object.kcalMin);
  writer.writeLong(offsets[13], object.kcalPoint);
  writer.writeDateTime(offsets[14], object.photoDeletedAt);
  writer.writeString(offsets[15], object.photoPath);
  writer.writeLong(offsets[16], object.proteinMax);
  writer.writeLong(offsets[17], object.proteinMin);
  writer.writeLong(offsets[18], object.proteinPoint);
  writer.writeLong(offsets[19], object.retryCount);
  writer.writeString(offsets[20], object.source.name);
  writer.writeString(offsets[21], object.status.name);
  writer.writeDateTime(offsets[22], object.updatedAt);
  writer.writeBool(offsets[23], object.userEditedKcal);
  writer.writeString(offsets[24], object.userNote);
}

Meal _mealDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Meal();
  object.aiConfidence = reader.readStringOrNull(offsets[0]);
  object.aiEmoji = reader.readStringOrNull(offsets[1]);
  object.aiRawJson = reader.readStringOrNull(offsets[2]);
  object.capturedAt = reader.readDateTime(offsets[3]);
  object.carbMax = reader.readLong(offsets[4]);
  object.carbMin = reader.readLong(offsets[5]);
  object.carbPoint = reader.readLong(offsets[6]);
  object.createdAt = reader.readDateTime(offsets[7]);
  object.fatMax = reader.readLong(offsets[8]);
  object.fatMin = reader.readLong(offsets[9]);
  object.fatPoint = reader.readLong(offsets[10]);
  object.id = id;
  object.kcalMax = reader.readLong(offsets[11]);
  object.kcalMin = reader.readLong(offsets[12]);
  object.kcalPoint = reader.readLong(offsets[13]);
  object.photoDeletedAt = reader.readDateTimeOrNull(offsets[14]);
  object.photoPath = reader.readStringOrNull(offsets[15]);
  object.proteinMax = reader.readLong(offsets[16]);
  object.proteinMin = reader.readLong(offsets[17]);
  object.proteinPoint = reader.readLong(offsets[18]);
  object.retryCount = reader.readLong(offsets[19]);
  object.source =
      _MealsourceValueEnumMap[reader.readStringOrNull(offsets[20])] ??
          MealSource.aiPhoto;
  object.status =
      _MealstatusValueEnumMap[reader.readStringOrNull(offsets[21])] ??
          MealStatus.provisional;
  object.updatedAt = reader.readDateTime(offsets[22]);
  object.userEditedKcal = reader.readBool(offsets[23]);
  object.userNote = reader.readString(offsets[24]);
  return object;
}

P _mealDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (_MealsourceValueEnumMap[reader.readStringOrNull(offset)] ??
          MealSource.aiPhoto) as P;
    case 21:
      return (_MealstatusValueEnumMap[reader.readStringOrNull(offset)] ??
          MealStatus.provisional) as P;
    case 22:
      return (reader.readDateTime(offset)) as P;
    case 23:
      return (reader.readBool(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MealsourceEnumValueMap = {
  r'aiPhoto': r'aiPhoto',
  r'barcode': r'barcode',
  r'quickAdd': r'quickAdd',
  r'manual': r'manual',
};
const _MealsourceValueEnumMap = {
  r'aiPhoto': MealSource.aiPhoto,
  r'barcode': MealSource.barcode,
  r'quickAdd': MealSource.quickAdd,
  r'manual': MealSource.manual,
};
const _MealstatusEnumValueMap = {
  r'provisional': r'provisional',
  r'queued': r'queued',
  r'processing': r'processing',
  r'done': r'done',
  r'error': r'error',
};
const _MealstatusValueEnumMap = {
  r'provisional': MealStatus.provisional,
  r'queued': MealStatus.queued,
  r'processing': MealStatus.processing,
  r'done': MealStatus.done,
  r'error': MealStatus.error,
};

Id _mealGetId(Meal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mealGetLinks(Meal object) {
  return [object.components];
}

void _mealAttach(IsarCollection<dynamic> col, Id id, Meal object) {
  object.id = id;
  object.components
      .attach(col, col.isar.collection<MealComponent>(), r'components', id);
}

extension MealQueryWhereSort on QueryBuilder<Meal, Meal, QWhere> {
  QueryBuilder<Meal, Meal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhere> anyCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'capturedAt'),
      );
    });
  }
}

extension MealQueryWhere on QueryBuilder<Meal, Meal, QWhereClause> {
  QueryBuilder<Meal, Meal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Meal, Meal, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> idBetween(
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

  QueryBuilder<Meal, Meal, QAfterWhereClause> capturedAtEqualTo(
      DateTime capturedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'capturedAt',
        value: [capturedAt],
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> capturedAtNotEqualTo(
      DateTime capturedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capturedAt',
              lower: [],
              upper: [capturedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capturedAt',
              lower: [capturedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capturedAt',
              lower: [capturedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capturedAt',
              lower: [],
              upper: [capturedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> capturedAtGreaterThan(
    DateTime capturedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capturedAt',
        lower: [capturedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> capturedAtLessThan(
    DateTime capturedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capturedAt',
        lower: [],
        upper: [capturedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterWhereClause> capturedAtBetween(
    DateTime lowerCapturedAt,
    DateTime upperCapturedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capturedAt',
        lower: [lowerCapturedAt],
        includeLower: includeLower,
        upper: [upperCapturedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MealQueryFilter on QueryBuilder<Meal, Meal, QFilterCondition> {
  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiConfidence',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiConfidence',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiConfidence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiConfidence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiConfidence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiConfidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiConfidence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiConfidence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiConfidence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiConfidence',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiConfidence',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiConfidenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiConfidence',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiEmoji',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiEmoji',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiEmoji',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiEmoji',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiEmoji',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiEmojiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiEmoji',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiRawJson',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiRawJson',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiRawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiRawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiRawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiRawJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiRawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiRawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiRawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiRawJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiRawJson',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> aiRawJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiRawJson',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> capturedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> capturedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> capturedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> capturedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capturedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbMaxEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbMaxGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbMaxLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbMaxBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbMax',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbPointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbPointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbPointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> carbPointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbPoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatMaxEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatMaxGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatMaxLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatMaxBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatMax',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatPointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatPointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatPointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> fatPointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatPoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Meal, Meal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Meal, Meal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalMaxEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kcalMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalMaxGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kcalMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalMaxLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kcalMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalMaxBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kcalMax',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kcalMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kcalMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kcalMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kcalMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalPointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kcalPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalPointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kcalPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalPointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kcalPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> kcalPointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kcalPoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoDeletedAt',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoDeletedAt',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoDeletedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoDeletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoDeletedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoDeletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoDeletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoDeletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoDeletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoDeletedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinMaxEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinMaxGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinMaxLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinMaxBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinMax',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinPointEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinPointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinPointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> proteinPointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinPoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> retryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> retryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> retryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceEqualTo(
    MealSource value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceGreaterThan(
    MealSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceLessThan(
    MealSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceBetween(
    MealSource lower,
    MealSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusEqualTo(
    MealStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusGreaterThan(
    MealStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusLessThan(
    MealStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusBetween(
    MealStatus lower,
    MealStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userEditedKcalEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userEditedKcal',
        value: value,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userNote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userNote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNote',
        value: '',
      ));
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> userNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userNote',
        value: '',
      ));
    });
  }
}

extension MealQueryObject on QueryBuilder<Meal, Meal, QFilterCondition> {}

extension MealQueryLinks on QueryBuilder<Meal, Meal, QFilterCondition> {
  QueryBuilder<Meal, Meal, QAfterFilterCondition> components(
      FilterQuery<MealComponent> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'components');
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> componentsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'components', length, true, length, true);
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> componentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'components', 0, true, 0, true);
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> componentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'components', 0, false, 999999, true);
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> componentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'components', 0, true, length, include);
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> componentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'components', length, include, 999999, true);
    });
  }

  QueryBuilder<Meal, Meal, QAfterFilterCondition> componentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'components', lower, includeLower, upper, includeUpper);
    });
  }
}

extension MealQuerySortBy on QueryBuilder<Meal, Meal, QSortBy> {
  QueryBuilder<Meal, Meal, QAfterSortBy> sortByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByAiConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByAiEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEmoji', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByAiEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEmoji', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByAiRawJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiRawJson', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByAiRawJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiRawJson', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCarbMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbMax', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCarbMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbMax', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCarbMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbMin', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCarbMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbMin', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCarbPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbPoint', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCarbPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbPoint', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByFatMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatMax', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByFatMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatMax', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByFatMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatMin', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByFatMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatMin', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByFatPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPoint', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByFatPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPoint', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByKcalMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalMax', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByKcalMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalMax', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByKcalMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalMin', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByKcalMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalMin', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByKcalPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPoint', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByKcalPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPoint', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByPhotoDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByPhotoDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByProteinMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinMax', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByProteinMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinMax', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByProteinMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinMin', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByProteinMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinMin', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByProteinPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPoint', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByProteinPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPoint', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByUserEditedKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userEditedKcal', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByUserEditedKcalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userEditedKcal', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByUserNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> sortByUserNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.desc);
    });
  }
}

extension MealQuerySortThenBy on QueryBuilder<Meal, Meal, QSortThenBy> {
  QueryBuilder<Meal, Meal, QAfterSortBy> thenByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByAiConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByAiEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEmoji', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByAiEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiEmoji', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByAiRawJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiRawJson', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByAiRawJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiRawJson', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCarbMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbMax', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCarbMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbMax', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCarbMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbMin', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCarbMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbMin', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCarbPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbPoint', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCarbPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbPoint', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByFatMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatMax', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByFatMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatMax', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByFatMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatMin', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByFatMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatMin', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByFatPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPoint', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByFatPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPoint', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByKcalMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalMax', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByKcalMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalMax', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByKcalMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalMin', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByKcalMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalMin', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByKcalPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPoint', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByKcalPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPoint', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByPhotoDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByPhotoDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByProteinMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinMax', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByProteinMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinMax', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByProteinMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinMin', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByProteinMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinMin', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByProteinPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPoint', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByProteinPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPoint', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByUserEditedKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userEditedKcal', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByUserEditedKcalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userEditedKcal', Sort.desc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByUserNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.asc);
    });
  }

  QueryBuilder<Meal, Meal, QAfterSortBy> thenByUserNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.desc);
    });
  }
}

extension MealQueryWhereDistinct on QueryBuilder<Meal, Meal, QDistinct> {
  QueryBuilder<Meal, Meal, QDistinct> distinctByAiConfidence(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiConfidence', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByAiEmoji(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiEmoji', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByAiRawJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiRawJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capturedAt');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByCarbMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbMax');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByCarbMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbMin');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByCarbPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbPoint');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByFatMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatMax');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByFatMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatMin');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByFatPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatPoint');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByKcalMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalMax');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByKcalMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalMin');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByKcalPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalPoint');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByPhotoDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoDeletedAt');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByPhotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByProteinMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinMax');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByProteinMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinMin');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByProteinPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinPoint');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByUserEditedKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userEditedKcal');
    });
  }

  QueryBuilder<Meal, Meal, QDistinct> distinctByUserNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userNote', caseSensitive: caseSensitive);
    });
  }
}

extension MealQueryProperty on QueryBuilder<Meal, Meal, QQueryProperty> {
  QueryBuilder<Meal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Meal, String?, QQueryOperations> aiConfidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiConfidence');
    });
  }

  QueryBuilder<Meal, String?, QQueryOperations> aiEmojiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiEmoji');
    });
  }

  QueryBuilder<Meal, String?, QQueryOperations> aiRawJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiRawJson');
    });
  }

  QueryBuilder<Meal, DateTime, QQueryOperations> capturedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capturedAt');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> carbMaxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbMax');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> carbMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbMin');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> carbPointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbPoint');
    });
  }

  QueryBuilder<Meal, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> fatMaxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatMax');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> fatMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatMin');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> fatPointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatPoint');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> kcalMaxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalMax');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> kcalMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalMin');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> kcalPointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalPoint');
    });
  }

  QueryBuilder<Meal, DateTime?, QQueryOperations> photoDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoDeletedAt');
    });
  }

  QueryBuilder<Meal, String?, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> proteinMaxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinMax');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> proteinMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinMin');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> proteinPointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinPoint');
    });
  }

  QueryBuilder<Meal, int, QQueryOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<Meal, MealSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<Meal, MealStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Meal, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<Meal, bool, QQueryOperations> userEditedKcalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userEditedKcal');
    });
  }

  QueryBuilder<Meal, String, QQueryOperations> userNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userNote');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMealComponentCollection on Isar {
  IsarCollection<MealComponent> get mealComponents => this.collection();
}

const MealComponentSchema = CollectionSchema(
  name: r'MealComponent',
  id: -7095548932312453350,
  properties: {
    r'estimatedMassG': PropertySchema(
      id: 0,
      name: r'estimatedMassG',
      type: IsarType.long,
    ),
    r'grupoAlimentar': PropertySchema(
      id: 1,
      name: r'grupoAlimentar',
      type: IsarType.string,
    ),
    r'kcalPoint': PropertySchema(
      id: 2,
      name: r'kcalPoint',
      type: IsarType.long,
    ),
    r'metodoPreparo': PropertySchema(
      id: 3,
      name: r'metodoPreparo',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'normalizedTag': PropertySchema(
      id: 5,
      name: r'normalizedTag',
      type: IsarType.string,
    )
  },
  estimateSize: _mealComponentEstimateSize,
  serialize: _mealComponentSerialize,
  deserialize: _mealComponentDeserialize,
  deserializeProp: _mealComponentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'meal': LinkSchema(
      id: -5167127834658329218,
      name: r'meal',
      target: r'Meal',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _mealComponentGetId,
  getLinks: _mealComponentGetLinks,
  attach: _mealComponentAttach,
  version: '3.1.0+1',
);

int _mealComponentEstimateSize(
  MealComponent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.grupoAlimentar.length * 3;
  bytesCount += 3 + object.metodoPreparo.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.normalizedTag.length * 3;
  return bytesCount;
}

void _mealComponentSerialize(
  MealComponent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.estimatedMassG);
  writer.writeString(offsets[1], object.grupoAlimentar);
  writer.writeLong(offsets[2], object.kcalPoint);
  writer.writeString(offsets[3], object.metodoPreparo);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.normalizedTag);
}

MealComponent _mealComponentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MealComponent();
  object.estimatedMassG = reader.readLongOrNull(offsets[0]);
  object.grupoAlimentar = reader.readString(offsets[1]);
  object.id = id;
  object.kcalPoint = reader.readLong(offsets[2]);
  object.metodoPreparo = reader.readString(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.normalizedTag = reader.readString(offsets[5]);
  return object;
}

P _mealComponentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mealComponentGetId(MealComponent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mealComponentGetLinks(MealComponent object) {
  return [object.meal];
}

void _mealComponentAttach(
    IsarCollection<dynamic> col, Id id, MealComponent object) {
  object.id = id;
  object.meal.attach(col, col.isar.collection<Meal>(), r'meal', id);
}

extension MealComponentQueryWhereSort
    on QueryBuilder<MealComponent, MealComponent, QWhere> {
  QueryBuilder<MealComponent, MealComponent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MealComponentQueryWhere
    on QueryBuilder<MealComponent, MealComponent, QWhereClause> {
  QueryBuilder<MealComponent, MealComponent, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MealComponent, MealComponent, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterWhereClause> idBetween(
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

extension MealComponentQueryFilter
    on QueryBuilder<MealComponent, MealComponent, QFilterCondition> {
  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      estimatedMassGIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'estimatedMassG',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      estimatedMassGIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'estimatedMassG',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      estimatedMassGEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedMassG',
        value: value,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      estimatedMassGGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedMassG',
        value: value,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      estimatedMassGLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedMassG',
        value: value,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      estimatedMassGBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedMassG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grupoAlimentar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grupoAlimentar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grupoAlimentar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grupoAlimentar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'grupoAlimentar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'grupoAlimentar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'grupoAlimentar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'grupoAlimentar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grupoAlimentar',
        value: '',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      grupoAlimentarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'grupoAlimentar',
        value: '',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      kcalPointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kcalPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      kcalPointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kcalPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      kcalPointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kcalPoint',
        value: value,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      kcalPointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kcalPoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodoPreparo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metodoPreparo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metodoPreparo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metodoPreparo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metodoPreparo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metodoPreparo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metodoPreparo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metodoPreparo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodoPreparo',
        value: '',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      metodoPreparoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metodoPreparo',
        value: '',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'normalizedTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'normalizedTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'normalizedTag',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'normalizedTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'normalizedTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'normalizedTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'normalizedTag',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedTag',
        value: '',
      ));
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      normalizedTagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'normalizedTag',
        value: '',
      ));
    });
  }
}

extension MealComponentQueryObject
    on QueryBuilder<MealComponent, MealComponent, QFilterCondition> {}

extension MealComponentQueryLinks
    on QueryBuilder<MealComponent, MealComponent, QFilterCondition> {
  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition> meal(
      FilterQuery<Meal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'meal');
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterFilterCondition>
      mealIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'meal', 0, true, 0, true);
    });
  }
}

extension MealComponentQuerySortBy
    on QueryBuilder<MealComponent, MealComponent, QSortBy> {
  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByEstimatedMassG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedMassG', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByEstimatedMassGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedMassG', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByGrupoAlimentar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoAlimentar', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByGrupoAlimentarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoAlimentar', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy> sortByKcalPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPoint', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByKcalPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPoint', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByMetodoPreparo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPreparo', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByMetodoPreparoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPreparo', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByNormalizedTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedTag', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      sortByNormalizedTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedTag', Sort.desc);
    });
  }
}

extension MealComponentQuerySortThenBy
    on QueryBuilder<MealComponent, MealComponent, QSortThenBy> {
  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByEstimatedMassG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedMassG', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByEstimatedMassGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedMassG', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByGrupoAlimentar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoAlimentar', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByGrupoAlimentarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grupoAlimentar', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy> thenByKcalPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPoint', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByKcalPointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPoint', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByMetodoPreparo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPreparo', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByMetodoPreparoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPreparo', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByNormalizedTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedTag', Sort.asc);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QAfterSortBy>
      thenByNormalizedTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedTag', Sort.desc);
    });
  }
}

extension MealComponentQueryWhereDistinct
    on QueryBuilder<MealComponent, MealComponent, QDistinct> {
  QueryBuilder<MealComponent, MealComponent, QDistinct>
      distinctByEstimatedMassG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedMassG');
    });
  }

  QueryBuilder<MealComponent, MealComponent, QDistinct>
      distinctByGrupoAlimentar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grupoAlimentar',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QDistinct> distinctByKcalPoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalPoint');
    });
  }

  QueryBuilder<MealComponent, MealComponent, QDistinct> distinctByMetodoPreparo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metodoPreparo',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealComponent, MealComponent, QDistinct> distinctByNormalizedTag(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'normalizedTag',
          caseSensitive: caseSensitive);
    });
  }
}

extension MealComponentQueryProperty
    on QueryBuilder<MealComponent, MealComponent, QQueryProperty> {
  QueryBuilder<MealComponent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MealComponent, int?, QQueryOperations> estimatedMassGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedMassG');
    });
  }

  QueryBuilder<MealComponent, String, QQueryOperations>
      grupoAlimentarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grupoAlimentar');
    });
  }

  QueryBuilder<MealComponent, int, QQueryOperations> kcalPointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalPoint');
    });
  }

  QueryBuilder<MealComponent, String, QQueryOperations>
      metodoPreparoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodoPreparo');
    });
  }

  QueryBuilder<MealComponent, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MealComponent, String, QQueryOperations>
      normalizedTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedTag');
    });
  }
}
