// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAlarmStatsCollection on Isar {
  IsarCollection<AlarmStats> get alarmStats => this.collection();
}

const AlarmStatsSchema = CollectionSchema(
  name: r'AlarmStats',
  id: -8376668144529557990,
  properties: {
    r'actualWakeTime': PropertySchema(
      id: 0,
      name: r'actualWakeTime',
      type: IsarType.dateTime,
    ),
    r'alarmId': PropertySchema(
      id: 1,
      name: r'alarmId',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dismissed': PropertySchema(
      id: 3,
      name: r'dismissed',
      type: IsarType.bool,
    ),
    r'missionAttempts': PropertySchema(
      id: 4,
      name: r'missionAttempts',
      type: IsarType.long,
    ),
    r'missionSuccessTime': PropertySchema(
      id: 5,
      name: r'missionSuccessTime',
      type: IsarType.long,
    ),
    r'missionType': PropertySchema(
      id: 6,
      name: r'missionType',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 7,
      name: r'notes',
      type: IsarType.string,
    ),
    r'scheduledTime': PropertySchema(
      id: 8,
      name: r'scheduledTime',
      type: IsarType.dateTime,
    ),
    r'snoozeCount': PropertySchema(
      id: 9,
      name: r'snoozeCount',
      type: IsarType.long,
    )
  },
  estimateSize: _alarmStatsEstimateSize,
  serialize: _alarmStatsSerialize,
  deserialize: _alarmStatsDeserialize,
  deserializeProp: _alarmStatsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _alarmStatsGetId,
  getLinks: _alarmStatsGetLinks,
  attach: _alarmStatsAttach,
  version: '3.1.0+1',
);

int _alarmStatsEstimateSize(
  AlarmStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.missionType.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _alarmStatsSerialize(
  AlarmStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.actualWakeTime);
  writer.writeLong(offsets[1], object.alarmId);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeBool(offsets[3], object.dismissed);
  writer.writeLong(offsets[4], object.missionAttempts);
  writer.writeLong(offsets[5], object.missionSuccessTime);
  writer.writeString(offsets[6], object.missionType);
  writer.writeString(offsets[7], object.notes);
  writer.writeDateTime(offsets[8], object.scheduledTime);
  writer.writeLong(offsets[9], object.snoozeCount);
}

AlarmStats _alarmStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AlarmStats();
  object.actualWakeTime = reader.readDateTimeOrNull(offsets[0]);
  object.alarmId = reader.readLong(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.dismissed = reader.readBool(offsets[3]);
  object.id = id;
  object.missionAttempts = reader.readLong(offsets[4]);
  object.missionSuccessTime = reader.readLong(offsets[5]);
  object.missionType = reader.readString(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.scheduledTime = reader.readDateTime(offsets[8]);
  object.snoozeCount = reader.readLong(offsets[9]);
  return object;
}

P _alarmStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _alarmStatsGetId(AlarmStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _alarmStatsGetLinks(AlarmStats object) {
  return [];
}

void _alarmStatsAttach(IsarCollection<dynamic> col, Id id, AlarmStats object) {
  object.id = id;
}

extension AlarmStatsQueryWhereSort
    on QueryBuilder<AlarmStats, AlarmStats, QWhere> {
  QueryBuilder<AlarmStats, AlarmStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AlarmStatsQueryWhere
    on QueryBuilder<AlarmStats, AlarmStats, QWhereClause> {
  QueryBuilder<AlarmStats, AlarmStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterWhereClause> idBetween(
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

extension AlarmStatsQueryFilter
    on QueryBuilder<AlarmStats, AlarmStats, QFilterCondition> {
  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      actualWakeTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualWakeTime',
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      actualWakeTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualWakeTime',
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      actualWakeTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualWakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      actualWakeTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualWakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      actualWakeTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualWakeTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      actualWakeTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualWakeTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> alarmIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alarmId',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      alarmIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alarmId',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> alarmIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alarmId',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> alarmIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alarmId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> dismissedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dismissed',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionAttemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missionAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionAttemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missionAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionAttemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missionAttempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionSuccessTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionSuccessTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionSuccessTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missionSuccessTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionSuccessTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missionSuccessTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionSuccessTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missionSuccessTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'missionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'missionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'missionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'missionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionType',
        value: '',
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      missionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'missionType',
        value: '',
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesContains(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesMatches(
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

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      scheduledTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      scheduledTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      scheduledTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      scheduledTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      snoozeCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      snoozeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      snoozeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterFilterCondition>
      snoozeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snoozeCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AlarmStatsQueryObject
    on QueryBuilder<AlarmStats, AlarmStats, QFilterCondition> {}

extension AlarmStatsQueryLinks
    on QueryBuilder<AlarmStats, AlarmStats, QFilterCondition> {}

extension AlarmStatsQuerySortBy
    on QueryBuilder<AlarmStats, AlarmStats, QSortBy> {
  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByActualWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualWakeTime', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy>
      sortByActualWakeTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualWakeTime', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByAlarmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissed', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissed', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByMissionAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionAttempts', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy>
      sortByMissionAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionAttempts', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy>
      sortByMissionSuccessTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionSuccessTime', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy>
      sortByMissionSuccessTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionSuccessTime', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByMissionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByMissionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortBySnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeCount', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> sortBySnoozeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeCount', Sort.desc);
    });
  }
}

extension AlarmStatsQuerySortThenBy
    on QueryBuilder<AlarmStats, AlarmStats, QSortThenBy> {
  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByActualWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualWakeTime', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy>
      thenByActualWakeTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualWakeTime', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByAlarmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissed', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissed', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByMissionAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionAttempts', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy>
      thenByMissionAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionAttempts', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy>
      thenByMissionSuccessTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionSuccessTime', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy>
      thenByMissionSuccessTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionSuccessTime', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByMissionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByMissionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenBySnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeCount', Sort.asc);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QAfterSortBy> thenBySnoozeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeCount', Sort.desc);
    });
  }
}

extension AlarmStatsQueryWhereDistinct
    on QueryBuilder<AlarmStats, AlarmStats, QDistinct> {
  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctByActualWakeTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualWakeTime');
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alarmId');
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctByDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dismissed');
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctByMissionAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missionAttempts');
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct>
      distinctByMissionSuccessTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missionSuccessTime');
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctByMissionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledTime');
    });
  }

  QueryBuilder<AlarmStats, AlarmStats, QDistinct> distinctBySnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snoozeCount');
    });
  }
}

extension AlarmStatsQueryProperty
    on QueryBuilder<AlarmStats, AlarmStats, QQueryProperty> {
  QueryBuilder<AlarmStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AlarmStats, DateTime?, QQueryOperations>
      actualWakeTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualWakeTime');
    });
  }

  QueryBuilder<AlarmStats, int, QQueryOperations> alarmIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alarmId');
    });
  }

  QueryBuilder<AlarmStats, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<AlarmStats, bool, QQueryOperations> dismissedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dismissed');
    });
  }

  QueryBuilder<AlarmStats, int, QQueryOperations> missionAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missionAttempts');
    });
  }

  QueryBuilder<AlarmStats, int, QQueryOperations> missionSuccessTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missionSuccessTime');
    });
  }

  QueryBuilder<AlarmStats, String, QQueryOperations> missionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missionType');
    });
  }

  QueryBuilder<AlarmStats, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<AlarmStats, DateTime, QQueryOperations> scheduledTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledTime');
    });
  }

  QueryBuilder<AlarmStats, int, QQueryOperations> snoozeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snoozeCount');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAggregatedStatsCollection on Isar {
  IsarCollection<AggregatedStats> get aggregatedStats => this.collection();
}

const AggregatedStatsSchema = CollectionSchema(
  name: r'AggregatedStats',
  id: -6683531986040337517,
  properties: {
    r'avgMissionTime': PropertySchema(
      id: 0,
      name: r'avgMissionTime',
      type: IsarType.double,
    ),
    r'avgWakeDelay': PropertySchema(
      id: 1,
      name: r'avgWakeDelay',
      type: IsarType.double,
    ),
    r'bestStreak': PropertySchema(
      id: 2,
      name: r'bestStreak',
      type: IsarType.long,
    ),
    r'currentStreak': PropertySchema(
      id: 3,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'missedAlarms': PropertySchema(
      id: 4,
      name: r'missedAlarms',
      type: IsarType.long,
    ),
    r'missionTypeUsageJson': PropertySchema(
      id: 5,
      name: r'missionTypeUsageJson',
      type: IsarType.string,
    ),
    r'snoozedAlarms': PropertySchema(
      id: 6,
      name: r'snoozedAlarms',
      type: IsarType.long,
    ),
    r'totalAlarms': PropertySchema(
      id: 7,
      name: r'totalAlarms',
      type: IsarType.long,
    ),
    r'weekStartDate': PropertySchema(
      id: 8,
      name: r'weekStartDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _aggregatedStatsEstimateSize,
  serialize: _aggregatedStatsSerialize,
  deserialize: _aggregatedStatsDeserialize,
  deserializeProp: _aggregatedStatsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _aggregatedStatsGetId,
  getLinks: _aggregatedStatsGetLinks,
  attach: _aggregatedStatsAttach,
  version: '3.1.0+1',
);

int _aggregatedStatsEstimateSize(
  AggregatedStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.missionTypeUsageJson.length * 3;
  return bytesCount;
}

void _aggregatedStatsSerialize(
  AggregatedStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.avgMissionTime);
  writer.writeDouble(offsets[1], object.avgWakeDelay);
  writer.writeLong(offsets[2], object.bestStreak);
  writer.writeLong(offsets[3], object.currentStreak);
  writer.writeLong(offsets[4], object.missedAlarms);
  writer.writeString(offsets[5], object.missionTypeUsageJson);
  writer.writeLong(offsets[6], object.snoozedAlarms);
  writer.writeLong(offsets[7], object.totalAlarms);
  writer.writeDateTime(offsets[8], object.weekStartDate);
}

AggregatedStats _aggregatedStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AggregatedStats();
  object.avgMissionTime = reader.readDouble(offsets[0]);
  object.avgWakeDelay = reader.readDouble(offsets[1]);
  object.bestStreak = reader.readLong(offsets[2]);
  object.currentStreak = reader.readLong(offsets[3]);
  object.id = id;
  object.missedAlarms = reader.readLong(offsets[4]);
  object.missionTypeUsageJson = reader.readString(offsets[5]);
  object.snoozedAlarms = reader.readLong(offsets[6]);
  object.totalAlarms = reader.readLong(offsets[7]);
  object.weekStartDate = reader.readDateTime(offsets[8]);
  return object;
}

P _aggregatedStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _aggregatedStatsGetId(AggregatedStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _aggregatedStatsGetLinks(AggregatedStats object) {
  return [];
}

void _aggregatedStatsAttach(
    IsarCollection<dynamic> col, Id id, AggregatedStats object) {
  object.id = id;
}

extension AggregatedStatsQueryWhereSort
    on QueryBuilder<AggregatedStats, AggregatedStats, QWhere> {
  QueryBuilder<AggregatedStats, AggregatedStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AggregatedStatsQueryWhere
    on QueryBuilder<AggregatedStats, AggregatedStats, QWhereClause> {
  QueryBuilder<AggregatedStats, AggregatedStats, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterWhereClause>
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

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterWhereClause> idBetween(
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

extension AggregatedStatsQueryFilter
    on QueryBuilder<AggregatedStats, AggregatedStats, QFilterCondition> {
  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      avgMissionTimeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgMissionTime',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      avgMissionTimeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgMissionTime',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      avgMissionTimeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgMissionTime',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      avgMissionTimeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgMissionTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      avgWakeDelayEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgWakeDelay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      avgWakeDelayGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgWakeDelay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      avgWakeDelayLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgWakeDelay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      avgWakeDelayBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgWakeDelay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      bestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      bestStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      bestStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      bestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bestStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
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

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missedAlarmsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missedAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missedAlarmsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missedAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missedAlarmsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missedAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missedAlarmsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missedAlarms',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionTypeUsageJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missionTypeUsageJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missionTypeUsageJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missionTypeUsageJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'missionTypeUsageJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'missionTypeUsageJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'missionTypeUsageJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'missionTypeUsageJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionTypeUsageJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      missionTypeUsageJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'missionTypeUsageJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      snoozedAlarmsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snoozedAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      snoozedAlarmsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snoozedAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      snoozedAlarmsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snoozedAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      snoozedAlarmsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snoozedAlarms',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      totalAlarmsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      totalAlarmsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      totalAlarmsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAlarms',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      totalAlarmsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAlarms',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      weekStartDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      weekStartDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      weekStartDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterFilterCondition>
      weekStartDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AggregatedStatsQueryObject
    on QueryBuilder<AggregatedStats, AggregatedStats, QFilterCondition> {}

extension AggregatedStatsQueryLinks
    on QueryBuilder<AggregatedStats, AggregatedStats, QFilterCondition> {}

extension AggregatedStatsQuerySortBy
    on QueryBuilder<AggregatedStats, AggregatedStats, QSortBy> {
  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByAvgMissionTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgMissionTime', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByAvgMissionTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgMissionTime', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByAvgWakeDelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgWakeDelay', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByAvgWakeDelayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgWakeDelay', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByMissedAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedAlarms', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByMissedAlarmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedAlarms', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByMissionTypeUsageJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionTypeUsageJson', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByMissionTypeUsageJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionTypeUsageJson', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortBySnoozedAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozedAlarms', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortBySnoozedAlarmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozedAlarms', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByTotalAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAlarms', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByTotalAlarmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAlarms', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      sortByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }
}

extension AggregatedStatsQuerySortThenBy
    on QueryBuilder<AggregatedStats, AggregatedStats, QSortThenBy> {
  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByAvgMissionTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgMissionTime', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByAvgMissionTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgMissionTime', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByAvgWakeDelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgWakeDelay', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByAvgWakeDelayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgWakeDelay', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByMissedAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedAlarms', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByMissedAlarmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedAlarms', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByMissionTypeUsageJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionTypeUsageJson', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByMissionTypeUsageJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionTypeUsageJson', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenBySnoozedAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozedAlarms', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenBySnoozedAlarmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozedAlarms', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByTotalAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAlarms', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByTotalAlarmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAlarms', Sort.desc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QAfterSortBy>
      thenByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }
}

extension AggregatedStatsQueryWhereDistinct
    on QueryBuilder<AggregatedStats, AggregatedStats, QDistinct> {
  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctByAvgMissionTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgMissionTime');
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctByAvgWakeDelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgWakeDelay');
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bestStreak');
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctByMissedAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missedAlarms');
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctByMissionTypeUsageJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missionTypeUsageJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctBySnoozedAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snoozedAlarms');
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctByTotalAlarms() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAlarms');
    });
  }

  QueryBuilder<AggregatedStats, AggregatedStats, QDistinct>
      distinctByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekStartDate');
    });
  }
}

extension AggregatedStatsQueryProperty
    on QueryBuilder<AggregatedStats, AggregatedStats, QQueryProperty> {
  QueryBuilder<AggregatedStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AggregatedStats, double, QQueryOperations>
      avgMissionTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgMissionTime');
    });
  }

  QueryBuilder<AggregatedStats, double, QQueryOperations>
      avgWakeDelayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgWakeDelay');
    });
  }

  QueryBuilder<AggregatedStats, int, QQueryOperations> bestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bestStreak');
    });
  }

  QueryBuilder<AggregatedStats, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<AggregatedStats, int, QQueryOperations> missedAlarmsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missedAlarms');
    });
  }

  QueryBuilder<AggregatedStats, String, QQueryOperations>
      missionTypeUsageJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missionTypeUsageJson');
    });
  }

  QueryBuilder<AggregatedStats, int, QQueryOperations> snoozedAlarmsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snoozedAlarms');
    });
  }

  QueryBuilder<AggregatedStats, int, QQueryOperations> totalAlarmsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAlarms');
    });
  }

  QueryBuilder<AggregatedStats, DateTime, QQueryOperations>
      weekStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekStartDate');
    });
  }
}
