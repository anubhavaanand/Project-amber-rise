// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSleepRecordCollection on Isar {
  IsarCollection<SleepRecord> get sleepRecords => this.collection();
}

const SleepRecordSchema = CollectionSchema(
  name: r'SleepRecord',
  id: -4404257997226199616,
  properties: {
    r'awakeMinutes': PropertySchema(
      id: 0,
      name: r'awakeMinutes',
      type: IsarType.long,
    ),
    r'bedTime': PropertySchema(
      id: 1,
      name: r'bedTime',
      type: IsarType.dateTime,
    ),
    r'deepSleepMinutes': PropertySchema(
      id: 2,
      name: r'deepSleepMinutes',
      type: IsarType.long,
    ),
    r'lightSleepMinutes': PropertySchema(
      id: 3,
      name: r'lightSleepMinutes',
      type: IsarType.long,
    ),
    r'movementData': PropertySchema(
      id: 4,
      name: r'movementData',
      type: IsarType.doubleList,
    ),
    r'notes': PropertySchema(
      id: 5,
      name: r'notes',
      type: IsarType.string,
    ),
    r'remSleepMinutes': PropertySchema(
      id: 6,
      name: r'remSleepMinutes',
      type: IsarType.long,
    ),
    r'sleepQuality': PropertySchema(
      id: 7,
      name: r'sleepQuality',
      type: IsarType.long,
    ),
    r'smartAlarmUsed': PropertySchema(
      id: 8,
      name: r'smartAlarmUsed',
      type: IsarType.bool,
    ),
    r'wakeTime': PropertySchema(
      id: 9,
      name: r'wakeTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _sleepRecordEstimateSize,
  serialize: _sleepRecordSerialize,
  deserialize: _sleepRecordDeserialize,
  deserializeProp: _sleepRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sleepRecordGetId,
  getLinks: _sleepRecordGetLinks,
  attach: _sleepRecordAttach,
  version: '3.1.0+1',
);

int _sleepRecordEstimateSize(
  SleepRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.movementData.length * 8;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _sleepRecordSerialize(
  SleepRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.awakeMinutes);
  writer.writeDateTime(offsets[1], object.bedTime);
  writer.writeLong(offsets[2], object.deepSleepMinutes);
  writer.writeLong(offsets[3], object.lightSleepMinutes);
  writer.writeDoubleList(offsets[4], object.movementData);
  writer.writeString(offsets[5], object.notes);
  writer.writeLong(offsets[6], object.remSleepMinutes);
  writer.writeLong(offsets[7], object.sleepQuality);
  writer.writeBool(offsets[8], object.smartAlarmUsed);
  writer.writeDateTime(offsets[9], object.wakeTime);
}

SleepRecord _sleepRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SleepRecord();
  object.awakeMinutes = reader.readLong(offsets[0]);
  object.bedTime = reader.readDateTime(offsets[1]);
  object.deepSleepMinutes = reader.readLong(offsets[2]);
  object.id = id;
  object.lightSleepMinutes = reader.readLong(offsets[3]);
  object.movementData = reader.readDoubleList(offsets[4]) ?? [];
  object.notes = reader.readStringOrNull(offsets[5]);
  object.remSleepMinutes = reader.readLong(offsets[6]);
  object.sleepQuality = reader.readLong(offsets[7]);
  object.smartAlarmUsed = reader.readBool(offsets[8]);
  object.wakeTime = reader.readDateTime(offsets[9]);
  return object;
}

P _sleepRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sleepRecordGetId(SleepRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sleepRecordGetLinks(SleepRecord object) {
  return [];
}

void _sleepRecordAttach(
    IsarCollection<dynamic> col, Id id, SleepRecord object) {
  object.id = id;
}

extension SleepRecordQueryWhereSort
    on QueryBuilder<SleepRecord, SleepRecord, QWhere> {
  QueryBuilder<SleepRecord, SleepRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SleepRecordQueryWhere
    on QueryBuilder<SleepRecord, SleepRecord, QWhereClause> {
  QueryBuilder<SleepRecord, SleepRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SleepRecord, SleepRecord, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterWhereClause> idBetween(
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

extension SleepRecordQueryFilter
    on QueryBuilder<SleepRecord, SleepRecord, QFilterCondition> {
  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      awakeMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'awakeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      awakeMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'awakeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      awakeMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'awakeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      awakeMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'awakeMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> bedTimeEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      bedTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> bedTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> bedTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bedTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      deepSleepMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      deepSleepMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deepSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      deepSleepMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deepSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      deepSleepMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deepSleepMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      lightSleepMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lightSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      lightSleepMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lightSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      lightSleepMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lightSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      lightSleepMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lightSleepMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementData',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movementData',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movementData',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movementData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'movementData',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'movementData',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'movementData',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'movementData',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'movementData',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      movementDataLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'movementData',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      remSleepMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      remSleepMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      remSleepMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remSleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      remSleepMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remSleepMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      sleepQualityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      sleepQualityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      sleepQualityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      sleepQualityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepQuality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      smartAlarmUsedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smartAlarmUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> wakeTimeEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      wakeTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition>
      wakeTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterFilterCondition> wakeTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wakeTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SleepRecordQueryObject
    on QueryBuilder<SleepRecord, SleepRecord, QFilterCondition> {}

extension SleepRecordQueryLinks
    on QueryBuilder<SleepRecord, SleepRecord, QFilterCondition> {}

extension SleepRecordQuerySortBy
    on QueryBuilder<SleepRecord, SleepRecord, QSortBy> {
  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortByAwakeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awakeMinutes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      sortByAwakeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awakeMinutes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortByBedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bedTime', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortByBedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bedTime', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      sortByDeepSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      sortByDeepSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      sortByLightSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lightSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      sortByLightSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lightSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortByRemSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      sortByRemSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      sortBySleepQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortBySmartAlarmUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmUsed', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      sortBySmartAlarmUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmUsed', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortByWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> sortByWakeTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.desc);
    });
  }
}

extension SleepRecordQuerySortThenBy
    on QueryBuilder<SleepRecord, SleepRecord, QSortThenBy> {
  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByAwakeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awakeMinutes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      thenByAwakeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awakeMinutes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByBedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bedTime', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByBedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bedTime', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      thenByDeepSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      thenByDeepSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      thenByLightSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lightSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      thenByLightSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lightSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByRemSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remSleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      thenByRemSleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remSleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      thenBySleepQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenBySmartAlarmUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmUsed', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy>
      thenBySmartAlarmUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmUsed', Sort.desc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.asc);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QAfterSortBy> thenByWakeTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeTime', Sort.desc);
    });
  }
}

extension SleepRecordQueryWhereDistinct
    on QueryBuilder<SleepRecord, SleepRecord, QDistinct> {
  QueryBuilder<SleepRecord, SleepRecord, QDistinct> distinctByAwakeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'awakeMinutes');
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct> distinctByBedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bedTime');
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct>
      distinctByDeepSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deepSleepMinutes');
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct>
      distinctByLightSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lightSleepMinutes');
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct> distinctByMovementData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movementData');
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct>
      distinctByRemSleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remSleepMinutes');
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct> distinctBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepQuality');
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct> distinctBySmartAlarmUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smartAlarmUsed');
    });
  }

  QueryBuilder<SleepRecord, SleepRecord, QDistinct> distinctByWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wakeTime');
    });
  }
}

extension SleepRecordQueryProperty
    on QueryBuilder<SleepRecord, SleepRecord, QQueryProperty> {
  QueryBuilder<SleepRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SleepRecord, int, QQueryOperations> awakeMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'awakeMinutes');
    });
  }

  QueryBuilder<SleepRecord, DateTime, QQueryOperations> bedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bedTime');
    });
  }

  QueryBuilder<SleepRecord, int, QQueryOperations> deepSleepMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deepSleepMinutes');
    });
  }

  QueryBuilder<SleepRecord, int, QQueryOperations> lightSleepMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lightSleepMinutes');
    });
  }

  QueryBuilder<SleepRecord, List<double>, QQueryOperations>
      movementDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movementData');
    });
  }

  QueryBuilder<SleepRecord, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<SleepRecord, int, QQueryOperations> remSleepMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remSleepMinutes');
    });
  }

  QueryBuilder<SleepRecord, int, QQueryOperations> sleepQualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepQuality');
    });
  }

  QueryBuilder<SleepRecord, bool, QQueryOperations> smartAlarmUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smartAlarmUsed');
    });
  }

  QueryBuilder<SleepRecord, DateTime, QQueryOperations> wakeTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wakeTime');
    });
  }
}
