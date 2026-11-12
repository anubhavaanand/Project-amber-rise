// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAlarmCollection on Isar {
  IsarCollection<Alarm> get alarms => this.collection();
}

const AlarmSchema = CollectionSchema(
  name: r'Alarm',
  id: -6172094888861729789,
  properties: {
    r'captchaRequired': PropertySchema(
      id: 0,
      name: r'captchaRequired',
      type: IsarType.bool,
    ),
    r'challengeMissions': PropertySchema(
      id: 1,
      name: r'challengeMissions',
      type: IsarType.stringList,
    ),
    r'challengeModeEnabled': PropertySchema(
      id: 2,
      name: r'challengeModeEnabled',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentSnoozeCount': PropertySchema(
      id: 4,
      name: r'currentSnoozeCount',
      type: IsarType.long,
    ),
    r'fadeInMusic': PropertySchema(
      id: 5,
      name: r'fadeInMusic',
      type: IsarType.bool,
    ),
    r'gentleWakeDurationSeconds': PropertySchema(
      id: 6,
      name: r'gentleWakeDurationSeconds',
      type: IsarType.long,
    ),
    r'gentleWakeEnabled': PropertySchema(
      id: 7,
      name: r'gentleWakeEnabled',
      type: IsarType.bool,
    ),
    r'isEnabled': PropertySchema(
      id: 8,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'isNapAlarm': PropertySchema(
      id: 9,
      name: r'isNapAlarm',
      type: IsarType.bool,
    ),
    r'label': PropertySchema(
      id: 10,
      name: r'label',
      type: IsarType.string,
    ),
    r'lastTriggered': PropertySchema(
      id: 11,
      name: r'lastTriggered',
      type: IsarType.dateTime,
    ),
    r'mathBeforeSnooze': PropertySchema(
      id: 12,
      name: r'mathBeforeSnooze',
      type: IsarType.bool,
    ),
    r'maxSnoozeCount': PropertySchema(
      id: 13,
      name: r'maxSnoozeCount',
      type: IsarType.long,
    ),
    r'missionData': PropertySchema(
      id: 14,
      name: r'missionData',
      type: IsarType.string,
    ),
    r'missionDifficulty': PropertySchema(
      id: 15,
      name: r'missionDifficulty',
      type: IsarType.long,
    ),
    r'missionType': PropertySchema(
      id: 16,
      name: r'missionType',
      type: IsarType.string,
      enumMap: _AlarmmissionTypeEnumValueMap,
    ),
    r'napDurationMinutes': PropertySchema(
      id: 17,
      name: r'napDurationMinutes',
      type: IsarType.long,
    ),
    r'noPhoneFlip': PropertySchema(
      id: 18,
      name: r'noPhoneFlip',
      type: IsarType.bool,
    ),
    r'preAlarmEnabled': PropertySchema(
      id: 19,
      name: r'preAlarmEnabled',
      type: IsarType.bool,
    ),
    r'preAlarmMinutes': PropertySchema(
      id: 20,
      name: r'preAlarmMinutes',
      type: IsarType.long,
    ),
    r'repeatDays': PropertySchema(
      id: 21,
      name: r'repeatDays',
      type: IsarType.longList,
    ),
    r'repeatDaysString': PropertySchema(
      id: 22,
      name: r'repeatDaysString',
      type: IsarType.string,
    ),
    r'showMotivationalQuote': PropertySchema(
      id: 23,
      name: r'showMotivationalQuote',
      type: IsarType.bool,
    ),
    r'skipCount': PropertySchema(
      id: 24,
      name: r'skipCount',
      type: IsarType.long,
    ),
    r'smartAlarmEnabled': PropertySchema(
      id: 25,
      name: r'smartAlarmEnabled',
      type: IsarType.bool,
    ),
    r'smartAlarmWindowMinutes': PropertySchema(
      id: 26,
      name: r'smartAlarmWindowMinutes',
      type: IsarType.long,
    ),
    r'snoozeDurationMinutes': PropertySchema(
      id: 27,
      name: r'snoozeDurationMinutes',
      type: IsarType.long,
    ),
    r'soundPath': PropertySchema(
      id: 28,
      name: r'soundPath',
      type: IsarType.string,
    ),
    r'spotifyPlaylistUri': PropertySchema(
      id: 29,
      name: r'spotifyPlaylistUri',
      type: IsarType.string,
    ),
    r'time': PropertySchema(
      id: 30,
      name: r'time',
      type: IsarType.dateTime,
    ),
    r'timeString': PropertySchema(
      id: 31,
      name: r'timeString',
      type: IsarType.string,
    ),
    r'vibrate': PropertySchema(
      id: 32,
      name: r'vibrate',
      type: IsarType.bool,
    ),
    r'volume': PropertySchema(
      id: 33,
      name: r'volume',
      type: IsarType.double,
    ),
    r'wakeUpCheckEnabled': PropertySchema(
      id: 34,
      name: r'wakeUpCheckEnabled',
      type: IsarType.bool,
    ),
    r'weatherAnnouncementEnabled': PropertySchema(
      id: 35,
      name: r'weatherAnnouncementEnabled',
      type: IsarType.bool,
    )
  },
  estimateSize: _alarmEstimateSize,
  serialize: _alarmSerialize,
  deserialize: _alarmDeserialize,
  deserializeProp: _alarmDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _alarmGetId,
  getLinks: _alarmGetLinks,
  attach: _alarmAttach,
  version: '3.1.0+1',
);

int _alarmEstimateSize(
  Alarm object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.challengeMissions.length * 3;
  {
    for (var i = 0; i < object.challengeMissions.length; i++) {
      final value = object.challengeMissions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.label.length * 3;
  {
    final value = object.missionData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.missionType.name.length * 3;
  bytesCount += 3 + object.repeatDays.length * 8;
  bytesCount += 3 + object.repeatDaysString.length * 3;
  bytesCount += 3 + object.soundPath.length * 3;
  {
    final value = object.spotifyPlaylistUri;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.timeString.length * 3;
  return bytesCount;
}

void _alarmSerialize(
  Alarm object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.captchaRequired);
  writer.writeStringList(offsets[1], object.challengeMissions);
  writer.writeBool(offsets[2], object.challengeModeEnabled);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeLong(offsets[4], object.currentSnoozeCount);
  writer.writeBool(offsets[5], object.fadeInMusic);
  writer.writeLong(offsets[6], object.gentleWakeDurationSeconds);
  writer.writeBool(offsets[7], object.gentleWakeEnabled);
  writer.writeBool(offsets[8], object.isEnabled);
  writer.writeBool(offsets[9], object.isNapAlarm);
  writer.writeString(offsets[10], object.label);
  writer.writeDateTime(offsets[11], object.lastTriggered);
  writer.writeBool(offsets[12], object.mathBeforeSnooze);
  writer.writeLong(offsets[13], object.maxSnoozeCount);
  writer.writeString(offsets[14], object.missionData);
  writer.writeLong(offsets[15], object.missionDifficulty);
  writer.writeString(offsets[16], object.missionType.name);
  writer.writeLong(offsets[17], object.napDurationMinutes);
  writer.writeBool(offsets[18], object.noPhoneFlip);
  writer.writeBool(offsets[19], object.preAlarmEnabled);
  writer.writeLong(offsets[20], object.preAlarmMinutes);
  writer.writeLongList(offsets[21], object.repeatDays);
  writer.writeString(offsets[22], object.repeatDaysString);
  writer.writeBool(offsets[23], object.showMotivationalQuote);
  writer.writeLong(offsets[24], object.skipCount);
  writer.writeBool(offsets[25], object.smartAlarmEnabled);
  writer.writeLong(offsets[26], object.smartAlarmWindowMinutes);
  writer.writeLong(offsets[27], object.snoozeDurationMinutes);
  writer.writeString(offsets[28], object.soundPath);
  writer.writeString(offsets[29], object.spotifyPlaylistUri);
  writer.writeDateTime(offsets[30], object.time);
  writer.writeString(offsets[31], object.timeString);
  writer.writeBool(offsets[32], object.vibrate);
  writer.writeDouble(offsets[33], object.volume);
  writer.writeBool(offsets[34], object.wakeUpCheckEnabled);
  writer.writeBool(offsets[35], object.weatherAnnouncementEnabled);
}

Alarm _alarmDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Alarm();
  object.captchaRequired = reader.readBool(offsets[0]);
  object.challengeMissions = reader.readStringList(offsets[1]) ?? [];
  object.challengeModeEnabled = reader.readBool(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.currentSnoozeCount = reader.readLong(offsets[4]);
  object.fadeInMusic = reader.readBool(offsets[5]);
  object.gentleWakeDurationSeconds = reader.readLong(offsets[6]);
  object.gentleWakeEnabled = reader.readBool(offsets[7]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[8]);
  object.isNapAlarm = reader.readBool(offsets[9]);
  object.label = reader.readString(offsets[10]);
  object.lastTriggered = reader.readDateTimeOrNull(offsets[11]);
  object.mathBeforeSnooze = reader.readBool(offsets[12]);
  object.maxSnoozeCount = reader.readLong(offsets[13]);
  object.missionData = reader.readStringOrNull(offsets[14]);
  object.missionDifficulty = reader.readLong(offsets[15]);
  object.missionType =
      _AlarmmissionTypeValueEnumMap[reader.readStringOrNull(offsets[16])] ??
          MissionType.math;
  object.napDurationMinutes = reader.readLong(offsets[17]);
  object.noPhoneFlip = reader.readBool(offsets[18]);
  object.preAlarmEnabled = reader.readBool(offsets[19]);
  object.preAlarmMinutes = reader.readLong(offsets[20]);
  object.repeatDays = reader.readLongList(offsets[21]) ?? [];
  object.showMotivationalQuote = reader.readBool(offsets[23]);
  object.skipCount = reader.readLong(offsets[24]);
  object.smartAlarmEnabled = reader.readBool(offsets[25]);
  object.smartAlarmWindowMinutes = reader.readLong(offsets[26]);
  object.snoozeDurationMinutes = reader.readLong(offsets[27]);
  object.soundPath = reader.readString(offsets[28]);
  object.spotifyPlaylistUri = reader.readStringOrNull(offsets[29]);
  object.time = reader.readDateTime(offsets[30]);
  object.vibrate = reader.readBool(offsets[32]);
  object.volume = reader.readDouble(offsets[33]);
  object.wakeUpCheckEnabled = reader.readBool(offsets[34]);
  object.weatherAnnouncementEnabled = reader.readBool(offsets[35]);
  return object;
}

P _alarmDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (_AlarmmissionTypeValueEnumMap[reader.readStringOrNull(offset)] ??
          MissionType.math) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readLongList(offset) ?? []) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readBool(offset)) as P;
    case 24:
      return (reader.readLong(offset)) as P;
    case 25:
      return (reader.readBool(offset)) as P;
    case 26:
      return (reader.readLong(offset)) as P;
    case 27:
      return (reader.readLong(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readDateTime(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readBool(offset)) as P;
    case 33:
      return (reader.readDouble(offset)) as P;
    case 34:
      return (reader.readBool(offset)) as P;
    case 35:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AlarmmissionTypeEnumValueMap = {
  r'math': r'math',
  r'shake': r'shake',
  r'squat': r'squat',
  r'barcode': r'barcode',
  r'photo': r'photo',
  r'typing': r'typing',
  r'walking': r'walking',
  r'memory': r'memory',
};
const _AlarmmissionTypeValueEnumMap = {
  r'math': MissionType.math,
  r'shake': MissionType.shake,
  r'squat': MissionType.squat,
  r'barcode': MissionType.barcode,
  r'photo': MissionType.photo,
  r'typing': MissionType.typing,
  r'walking': MissionType.walking,
  r'memory': MissionType.memory,
};

Id _alarmGetId(Alarm object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _alarmGetLinks(Alarm object) {
  return [];
}

void _alarmAttach(IsarCollection<dynamic> col, Id id, Alarm object) {
  object.id = id;
}

extension AlarmQueryWhereSort on QueryBuilder<Alarm, Alarm, QWhere> {
  QueryBuilder<Alarm, Alarm, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AlarmQueryWhere on QueryBuilder<Alarm, Alarm, QWhereClause> {
  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterWhereClause> idBetween(
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

extension AlarmQueryFilter on QueryBuilder<Alarm, Alarm, QFilterCondition> {
  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> captchaRequiredEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'captchaRequired',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeMissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'challengeMissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'challengeMissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'challengeMissions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'challengeMissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'challengeMissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'challengeMissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'challengeMissions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeMissions',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'challengeMissions',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'challengeMissions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> challengeMissionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'challengeMissions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'challengeMissions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'challengeMissions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'challengeMissions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      challengeMissionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'challengeMissions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> challengeModeEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeModeEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> currentSnoozeCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentSnoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      currentSnoozeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentSnoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> currentSnoozeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentSnoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> currentSnoozeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentSnoozeCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> fadeInMusicEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fadeInMusic',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      gentleWakeDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gentleWakeDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      gentleWakeDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gentleWakeDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      gentleWakeDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gentleWakeDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      gentleWakeDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gentleWakeDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> gentleWakeEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gentleWakeEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> isEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> isNapAlarmEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNapAlarm',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> lastTriggeredIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastTriggered',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> lastTriggeredIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastTriggered',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> lastTriggeredEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastTriggered',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> lastTriggeredGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastTriggered',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> lastTriggeredLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastTriggered',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> lastTriggeredBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastTriggered',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> mathBeforeSnoozeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mathBeforeSnooze',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> maxSnoozeCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxSnoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> maxSnoozeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxSnoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> maxSnoozeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxSnoozeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> maxSnoozeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxSnoozeCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'missionData',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'missionData',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missionData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missionData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missionData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'missionData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'missionData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'missionData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'missionData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionData',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'missionData',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDifficultyEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionDifficulty',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      missionDifficultyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'missionDifficulty',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDifficultyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'missionDifficulty',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionDifficultyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'missionDifficulty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeEqualTo(
    MissionType value, {
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeGreaterThan(
    MissionType value, {
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeLessThan(
    MissionType value, {
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeBetween(
    MissionType lower,
    MissionType upper, {
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeStartsWith(
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeEndsWith(
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

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'missionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'missionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missionType',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> missionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'missionType',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> napDurationMinutesEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'napDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      napDurationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'napDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> napDurationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'napDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> napDurationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'napDurationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> noPhoneFlipEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noPhoneFlip',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> preAlarmEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preAlarmEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> preAlarmMinutesEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preAlarmMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> preAlarmMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preAlarmMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> preAlarmMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preAlarmMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> preAlarmMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preAlarmMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysElementEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      repeatDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repeatDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatDaysString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatDaysString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatDaysString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatDaysString',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'repeatDaysString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'repeatDaysString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'repeatDaysString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'repeatDaysString',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> repeatDaysStringIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatDaysString',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      repeatDaysStringIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'repeatDaysString',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      showMotivationalQuoteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showMotivationalQuote',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> skipCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skipCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> skipCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'skipCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> skipCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'skipCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> skipCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'skipCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> smartAlarmEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smartAlarmEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      smartAlarmWindowMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smartAlarmWindowMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      smartAlarmWindowMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'smartAlarmWindowMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      smartAlarmWindowMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'smartAlarmWindowMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      smartAlarmWindowMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'smartAlarmWindowMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      snoozeDurationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snoozeDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      snoozeDurationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snoozeDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      snoozeDurationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snoozeDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      snoozeDurationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snoozeDurationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soundPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'soundPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'soundPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'soundPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'soundPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'soundPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'soundPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'soundPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soundPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> soundPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'soundPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> spotifyPlaylistUriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'spotifyPlaylistUri',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      spotifyPlaylistUriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'spotifyPlaylistUri',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> spotifyPlaylistUriEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spotifyPlaylistUri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      spotifyPlaylistUriGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spotifyPlaylistUri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> spotifyPlaylistUriLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spotifyPlaylistUri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> spotifyPlaylistUriBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spotifyPlaylistUri',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      spotifyPlaylistUriStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'spotifyPlaylistUri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> spotifyPlaylistUriEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'spotifyPlaylistUri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> spotifyPlaylistUriContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'spotifyPlaylistUri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> spotifyPlaylistUriMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'spotifyPlaylistUri',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      spotifyPlaylistUriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spotifyPlaylistUri',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      spotifyPlaylistUriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'spotifyPlaylistUri',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeString',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'timeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'timeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'timeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'timeString',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeString',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> timeStringIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'timeString',
        value: '',
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> vibrateEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vibrate',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> volumeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> volumeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> volumeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> volumeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volume',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition> wakeUpCheckEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wakeUpCheckEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterFilterCondition>
      weatherAnnouncementEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherAnnouncementEnabled',
        value: value,
      ));
    });
  }
}

extension AlarmQueryObject on QueryBuilder<Alarm, Alarm, QFilterCondition> {}

extension AlarmQueryLinks on QueryBuilder<Alarm, Alarm, QFilterCondition> {}

extension AlarmQuerySortBy on QueryBuilder<Alarm, Alarm, QSortBy> {
  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByCaptchaRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'captchaRequired', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByCaptchaRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'captchaRequired', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByChallengeModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByChallengeModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByCurrentSnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSnoozeCount', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByCurrentSnoozeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSnoozeCount', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByFadeInMusic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadeInMusic', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByFadeInMusicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadeInMusic', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByGentleWakeDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gentleWakeDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy>
      sortByGentleWakeDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gentleWakeDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByGentleWakeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gentleWakeEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByGentleWakeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gentleWakeEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByIsNapAlarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNapAlarm', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByIsNapAlarmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNapAlarm', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByLastTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggered', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByLastTriggeredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggered', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMathBeforeSnooze() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mathBeforeSnooze', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMathBeforeSnoozeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mathBeforeSnooze', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMaxSnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSnoozeCount', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMaxSnoozeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSnoozeCount', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMissionData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionData', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMissionDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionData', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMissionDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionDifficulty', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMissionDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionDifficulty', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMissionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByMissionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByNapDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'napDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByNapDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'napDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByNoPhoneFlip() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noPhoneFlip', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByNoPhoneFlipDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noPhoneFlip', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByPreAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preAlarmEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByPreAlarmEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preAlarmEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByPreAlarmMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preAlarmMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByPreAlarmMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preAlarmMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByRepeatDaysString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatDaysString', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByRepeatDaysStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatDaysString', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByShowMotivationalQuote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showMotivationalQuote', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByShowMotivationalQuoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showMotivationalQuote', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySkipCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipCount', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySkipCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipCount', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySmartAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySmartAlarmEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySmartAlarmWindowMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmWindowMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySmartAlarmWindowMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmWindowMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySnoozeDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySnoozeDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySoundPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundPath', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySoundPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundPath', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySpotifyPlaylistUri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyPlaylistUri', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortBySpotifyPlaylistUriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyPlaylistUri', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByTimeString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeString', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByTimeStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeString', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByVibrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrate', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByVibrateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrate', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByWakeUpCheckEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpCheckEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByWakeUpCheckEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpCheckEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> sortByWeatherAnnouncementEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherAnnouncementEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy>
      sortByWeatherAnnouncementEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherAnnouncementEnabled', Sort.desc);
    });
  }
}

extension AlarmQuerySortThenBy on QueryBuilder<Alarm, Alarm, QSortThenBy> {
  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByCaptchaRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'captchaRequired', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByCaptchaRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'captchaRequired', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByChallengeModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByChallengeModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByCurrentSnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSnoozeCount', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByCurrentSnoozeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSnoozeCount', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByFadeInMusic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadeInMusic', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByFadeInMusicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fadeInMusic', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByGentleWakeDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gentleWakeDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy>
      thenByGentleWakeDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gentleWakeDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByGentleWakeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gentleWakeEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByGentleWakeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gentleWakeEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByIsNapAlarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNapAlarm', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByIsNapAlarmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNapAlarm', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByLastTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggered', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByLastTriggeredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggered', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMathBeforeSnooze() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mathBeforeSnooze', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMathBeforeSnoozeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mathBeforeSnooze', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMaxSnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSnoozeCount', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMaxSnoozeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxSnoozeCount', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMissionData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionData', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMissionDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionData', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMissionDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionDifficulty', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMissionDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionDifficulty', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMissionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByMissionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missionType', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByNapDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'napDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByNapDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'napDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByNoPhoneFlip() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noPhoneFlip', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByNoPhoneFlipDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noPhoneFlip', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByPreAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preAlarmEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByPreAlarmEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preAlarmEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByPreAlarmMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preAlarmMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByPreAlarmMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preAlarmMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByRepeatDaysString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatDaysString', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByRepeatDaysStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatDaysString', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByShowMotivationalQuote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showMotivationalQuote', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByShowMotivationalQuoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showMotivationalQuote', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySkipCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipCount', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySkipCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipCount', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySmartAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySmartAlarmEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySmartAlarmWindowMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmWindowMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySmartAlarmWindowMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smartAlarmWindowMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySnoozeDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySnoozeDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySoundPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundPath', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySoundPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundPath', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySpotifyPlaylistUri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyPlaylistUri', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenBySpotifyPlaylistUriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyPlaylistUri', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByTimeString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeString', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByTimeStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeString', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByVibrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrate', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByVibrateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrate', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByWakeUpCheckEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpCheckEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByWakeUpCheckEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wakeUpCheckEnabled', Sort.desc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy> thenByWeatherAnnouncementEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherAnnouncementEnabled', Sort.asc);
    });
  }

  QueryBuilder<Alarm, Alarm, QAfterSortBy>
      thenByWeatherAnnouncementEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherAnnouncementEnabled', Sort.desc);
    });
  }
}

extension AlarmQueryWhereDistinct on QueryBuilder<Alarm, Alarm, QDistinct> {
  QueryBuilder<Alarm, Alarm, QDistinct> distinctByCaptchaRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'captchaRequired');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByChallengeMissions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'challengeMissions');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByChallengeModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'challengeModeEnabled');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByCurrentSnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentSnoozeCount');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByFadeInMusic() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fadeInMusic');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByGentleWakeDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gentleWakeDurationSeconds');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByGentleWakeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gentleWakeEnabled');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByIsNapAlarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNapAlarm');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByLastTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastTriggered');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByMathBeforeSnooze() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mathBeforeSnooze');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByMaxSnoozeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxSnoozeCount');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByMissionData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missionData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByMissionDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missionDifficulty');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByMissionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByNapDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'napDurationMinutes');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByNoPhoneFlip() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'noPhoneFlip');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByPreAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preAlarmEnabled');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByPreAlarmMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preAlarmMinutes');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByRepeatDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatDays');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByRepeatDaysString(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatDaysString',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByShowMotivationalQuote() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showMotivationalQuote');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctBySkipCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipCount');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctBySmartAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smartAlarmEnabled');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctBySmartAlarmWindowMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smartAlarmWindowMinutes');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctBySnoozeDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snoozeDurationMinutes');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctBySoundPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'soundPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctBySpotifyPlaylistUri(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spotifyPlaylistUri',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByTimeString(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeString', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByVibrate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vibrate');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volume');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByWakeUpCheckEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wakeUpCheckEnabled');
    });
  }

  QueryBuilder<Alarm, Alarm, QDistinct> distinctByWeatherAnnouncementEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weatherAnnouncementEnabled');
    });
  }
}

extension AlarmQueryProperty on QueryBuilder<Alarm, Alarm, QQueryProperty> {
  QueryBuilder<Alarm, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> captchaRequiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'captchaRequired');
    });
  }

  QueryBuilder<Alarm, List<String>, QQueryOperations>
      challengeMissionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'challengeMissions');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> challengeModeEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'challengeModeEnabled');
    });
  }

  QueryBuilder<Alarm, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> currentSnoozeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentSnoozeCount');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> fadeInMusicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fadeInMusic');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations>
      gentleWakeDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gentleWakeDurationSeconds');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> gentleWakeEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gentleWakeEnabled');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> isNapAlarmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNapAlarm');
    });
  }

  QueryBuilder<Alarm, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<Alarm, DateTime?, QQueryOperations> lastTriggeredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastTriggered');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> mathBeforeSnoozeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mathBeforeSnooze');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> maxSnoozeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxSnoozeCount');
    });
  }

  QueryBuilder<Alarm, String?, QQueryOperations> missionDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missionData');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> missionDifficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missionDifficulty');
    });
  }

  QueryBuilder<Alarm, MissionType, QQueryOperations> missionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missionType');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> napDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'napDurationMinutes');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> noPhoneFlipProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'noPhoneFlip');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> preAlarmEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preAlarmEnabled');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> preAlarmMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preAlarmMinutes');
    });
  }

  QueryBuilder<Alarm, List<int>, QQueryOperations> repeatDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatDays');
    });
  }

  QueryBuilder<Alarm, String, QQueryOperations> repeatDaysStringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatDaysString');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> showMotivationalQuoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showMotivationalQuote');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> skipCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipCount');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> smartAlarmEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smartAlarmEnabled');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> smartAlarmWindowMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smartAlarmWindowMinutes');
    });
  }

  QueryBuilder<Alarm, int, QQueryOperations> snoozeDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snoozeDurationMinutes');
    });
  }

  QueryBuilder<Alarm, String, QQueryOperations> soundPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'soundPath');
    });
  }

  QueryBuilder<Alarm, String?, QQueryOperations> spotifyPlaylistUriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spotifyPlaylistUri');
    });
  }

  QueryBuilder<Alarm, DateTime, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<Alarm, String, QQueryOperations> timeStringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeString');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> vibrateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vibrate');
    });
  }

  QueryBuilder<Alarm, double, QQueryOperations> volumeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volume');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations> wakeUpCheckEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wakeUpCheckEnabled');
    });
  }

  QueryBuilder<Alarm, bool, QQueryOperations>
      weatherAnnouncementEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weatherAnnouncementEnabled');
    });
  }
}
